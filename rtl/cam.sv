/*
* <cam.sv>
* 
* Copyright (c) 2020-2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module cam #(
  parameter DATA = 16,
  parameter DEPTH = 64,
  parameter WRITE = 4,
  parameter READ = 4,
  // constant
  parameter ADDR = $clog2(DEPTH)
)(
  input  wire                       clk,
  input  wire                       reset,

  // write ports
  input  wire [WRITE-1:0]           we,     // write enable
  input  wire [WRITE-1:0][DATA-1:0] wm,     //       mask
  input  wire [WRITE-1:0][DATA-1:0] wd,     //       data
  input  wire [WRITE-1:0][ADDR-1:0] waddr,  //       addr

  // read ports
  input  wire [READ-1:0]            re,    // read enable
  input  wire [READ-1:0][DATA-1:0]  rm,     //      mask
  input  wire [READ-1:0][DATA-1:0]  rd,     //      data
  output wire [READ-1:0]            match,  // matched
  output wire [READ-1:0][ADDR-1:0]  raddr   // matched address
);

//***** internal registers
reg [DATA-1:0]          cam_cell [DEPTH-1:0];

//***** internal wires
wire [DATA-1:0]         next_cam_cell [DEPTH-1:0];



//***** entry update
generate
  genvar gi, gj, gk;
  for ( gi = 0; gi < DEPTH; gi = gi + 1 ) begin : LP_ent
    wire [WRITE-1:0]            wmatch;         // address match
    wire [DATA-1:0]             cell_each;      // current cell
    wire [WRITE-1:0][DATA-1:0]  next_cell_vec;  // next cell data ( wired-or )

    //*** this entry
    assign cell_each = cam_cell[gi];


    //*** update
    for ( gj = 0; gj < WRITE; gj = gj + 1 ) begin : LP_cell
      //* separate
      wire [DATA-1:0] wr_each;

      //* Address check
      assign wmatch[gj] = we[gj] && (waddr[gj] == gi);

      //* data select
      //assign wr_each = {DATA{wmatch[gj]}} & ~wm[gj];
      //assign next_cell_each
      //  = ( cell_each & ~wr_each )
      //    | ( cell_each & ~wd[gj] )
      //    | ( ~cell_each & wr_each & wd[gj] );
      //assign next_cell_vec[gj] =
      //  ( wmatch[gj] && !wm[gj] ) ? wd[gj] : cell_each;
      assign wr_each           = {DATA{wmatch[gj]}} & ~wm[gj];
      assign next_cell_vec[gj] = (cell_each & ~wr_each)
                               | (cell_each & ~wd[gj])
                               | (~cell_each & wr_each & wd[gj]);
    end


    //*** concat
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



//***** read logic
generate
  genvar gr, gs;
  for ( gr = 0; gr < READ; gr = gr + 1 ) begin : LP_rd
    wire [DEPTH-1:0]              rmatch;
    wire [DEPTH-1:0][ADDR-1:0]    raddr_vec;    // read address

    //*** read address check
    for ( gs = 0; gs < DEPTH; gs = gs + 1 ) begin : LP_ent
      wire [DATA-1:0]   cmp;
      wire              rdct_cmp;

      assign cmp = rm[gr] | ~(cam_cell[gs] ^ rd[gr]);
      assign rdct_cmp = &cmp;
      assign rmatch[gs] = re[gr] && rdct_cmp;
    end


    //*** read data select
    for ( gs = 0; gs < DEPTH; gs = gs + 1 ) begin : LP_sel
      wire [ADDR-1:0]   idx;
      assign idx = gs;
      assign raddr_vec[gs]= {ADDR{rmatch[gs]}} & idx;
    end


    //*** concat
    assign match[gr] = |rmatch;
    reduct #(
      .OPE  ( "or" ),
      .NOT  ( `DISABLE ),
      .IN   ( DEPTH ),
      .DATA ( ADDR )
    ) reduct_or (
      .in  ( raddr_vec ),
      .out ( raddr[gr] )
    );
  end
endgenerate



//***** sequential logics
int i;
always @( posedge clk ) begin
  if ( reset == `ENABLE) begin
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
