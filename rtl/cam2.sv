/*
* <cam2.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

// <asciidoc>
// = cam2.sv
// Content addressable memory module with parameterized port number.
// Synonym detection is also supported.
// </asciidoc>
`include "parammod_stddef.vh"

module cam2 #(
  // <asciidoc>
  // == Parameters
  // DATA :: 
  //    Bit Width of read/write data
  // DEPTH :: 
  //    Depth of RAM. $clog2(DEPTH) generates address width of ram
  // WRITE ::
  //    Number of write ports
  // READ ::
  //    Number of read ports
  // MSB ::
  //    Data select policy when multiple entries hit. +
  //    * 0: Select from entry with lower index numbers.
  //    * 1: Select from entry with higher index numbers.
  // </asciidoc>
  parameter DATA  = 16,
  parameter DEPTH = 64,
  parameter WRITE = 4,
  parameter READ  = 4,
  parameter MSB   = `FALSE, // TRUE/FALSE: select from MSB/LSB entry
  // constant
  parameter ADDR = $clog2(DEPTH)
)(
  // <asciidoc>
  // == Input/Output signals
  // clk (in) ::
  //    Clock signal
  // reset (in) ::
  //    Reset signal (configurable)
  // we (in) ::
  //    Write enable
  // wm (in) ::
  //    Write mask of individual data bit
  // wd (in) ::
  //    Write data
  // waddr (in) ::
  //    Write ram address
  // re (in) ::
  //    Read enable
  // rm (in) ::
  //    Read mask of individual data bit for ternary operations
  // rd (in) ::
  //    Read data for CAM lookup
  // match ::
  //    Match in CAM entry
  // multi (in) ::
  //    Multiple hit (synonym detection)
  // raddr (out) ::
  //    Write ram address
  // </asciidoc>
  input  wire                       clk,
  input  wire                       reset,

  // write ports
  input  wire [WRITE-1:0]           we,   // write enable
  input  wire [WRITE-1:0][DATA-1:0] wm,    //       mask
  input  wire [WRITE-1:0][DATA-1:0] wd,    //       data
  input  wire [WRITE-1:0][ADDR-1:0] waddr, //       addr

  //* read ports
  input  wire [READ-1:0]            re,   // read enable
  input  wire [READ-1:0][DATA-1:0]  rm,    //      mask
  input  wire [READ-1:0][DATA-1:0]  rd,    //      data
  output wire [READ-1:0]            match, // matched
  output wire [READ-1:0]            multi, // matched with multiple entry ( currently not supported )
  output wire [READ-1:0][ADDR-1:0]  raddr  // matched address
);

//***** internal registers
reg [DATA-1:0]             cam_cell [DEPTH-1:0];

//***** internal wires
wire [DEPTH-1:0][ADDR-1:0] addr_const_conc;
wire [DATA-1:0]            next_cam_cell [DEPTH-1:0];


//***** entry update
generate
  genvar gi, gj, gk;
  for ( gi = 0; gi < DEPTH; gi = gi + 1 ) begin : LP_ent
    wire [WRITE-1:0]           wmatch;        // address match
    wire [DATA-1:0]            cell_each;     // current cell
    wire [WRITE-1:0][DATA-1:0] next_cell_vec; // next cell data ( wired-or )

    //*** this entry
    assign cell_each = cam_cell[gi];

    //*** update
    for ( gj = 0; gj < WRITE; gj = gj + 1 ) begin : LP_cell
      wire [DATA-1:0] wr_each;

      //* Address Check
      assign wmatch[gj] = we[gj] && (waddr[gj] == gi);

      //* for auto layout
      assign wr_each           = {DATA{wmatch[gj]}} & ~wm[gj];
      assign next_cell_vec[gj] = (cell_each & ~wr_each)
                               | (cell_each & ~wd[gj])
                               | (~cell_each & wr_each & wd[gj]);
    end

    reduct #(
      .OPE  ( "or" ),
      .NOT  ( `DISABLE ),
      .IN   ( WRITE ),
      .DATA ( DATA )
    ) reduct_or (
      .in  ( next_cell_vec ),
      .out ( next_cam_cell[gi] )
    );

  end
endgenerate



//***** constant address creation
generate
  genvar gc, gd;
  for ( gc = 0; gc < DEPTH; gc = gc + 1 ) begin : LP_adr
    wire [ADDR-1:0] idx_each;
    assign idx_each            = gc;
    assign addr_const_conc[gc] = idx_each;
  end
endgenerate


//***** read logic
generate
  genvar gr, gs, gt;
  for ( gr = 0; gr < READ; gr = gr + 1 ) begin : LP_rd
    wire [DATA-1:0]     rd_each;    // data for matching
    wire [DATA-1:0]     rm_each;    // read mask
    wire [DEPTH-1:0]    rmatch;      // data is match
    wire [DEPTH-1:0]    rmatch_;    // data is match ( inverted )
    wire                match_each;    // match
    wire [ADDR-1:0]     raddr_each;    // read address

    //*** this address
    assign rd_each = rd[gr];
    assign rm_each = rm[gr];

    //*** read data check
    for ( gs = 0; gs < DEPTH; gs = gs + 1 ) begin : LP_ent
      wire [DATA-1:0]    cell_each;
      wire [DATA-1:0]    cmp;
      wire               rdct_cmp;
      assign cell_each = cam_cell[gs];

      assign cmp        = rm_each | ~(cam_cell[gs] ^ rd_each);
      assign rdct_cmp   = &cmp;
      assign rmatch[gs] = re[gr] && rdct_cmp;
    end

    //*** read data select
    cam_sel #(
      .DATA   ( ADDR ),
      .DEPTH  ( DEPTH ),
      .MSB    ( MSB )
    ) cam_sel (
      .data   ( addr_const_conc ),
      .sel    ( rmatch ),
      .match  ( match_each ),
      .multi  ( multi[gr] ),
      .result ( raddr_each )
    );

    //*** concat
    assign match[gr] = match_each;
    assign raddr[gr] = raddr_each;
  end
endgenerate


//***** sequential logics
integer i;
always @( posedge clk ) begin
  if ( reset == `ENABLE ) begin
    for ( i = 0; i < DEPTH; i = i + 1 ) begin
      cam_cell[i] <= {DATA{1'b0}};
    end
  end else begin
    for ( i = 0; i < DEPTH; i = i + 1 ) begin
      cam_cell[i] <= next_cam_cell[i]; 
    end
  end
end

endmodule


// cell data select (N:1 selector with synonym check)
module cam_sel #(
  parameter DATA  = 16,
  parameter DEPTH = 64,
  parameter MSB   = `ENABLE
)(
  input wire [DATA*DEPTH-1:0] data,
  input wire [DEPTH-1:0]      sel,
  output wire                 match,
  output logic                multi,  // hit multiple times
  output wire [DATA-1:0]      result
);

//***** check multiple hit
// TODO : make this logic with a binary tree
logic   hit;
always_comb begin
  hit = sel[0];
  multi = `DISABLE;

  for ( int i = 0; i < DEPTH; i = i + 1 ) begin
    if ( sel[i] && hit ) begin  // hit more than twice
      multi = `ENABLE;
    end
  end
end

//***** data select
wire [DEPTH-1:0]  dummy_pos;
selector #(
  .BIT_MAP  ( `ENABLE ),
  .DATA    ( DATA ),
  .IN      ( DEPTH ),
  .ACT    ( `HIGH ),
  .MSB    ( MSB )
) selector (
  .in      ( data ),
  .sel    ( sel ),
  .valid    ( match ),
  .pos    ( dummy_pos ),
  .out    ( result )
);

endmodule
