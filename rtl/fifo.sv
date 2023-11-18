/*
* <fifo.sv>
* N-in M-out First-in First-out Buffer
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`default_nettype none

// First in First out queue
module fifo #(
  parameter DATA    = 64,
  parameter DEPTH   = 32,
  parameter READ    = 4,
  parameter WRITE   = 4,
  parameter ACT     = `LOW  // polarity of re, we
)(
  input wire                       clk,
  input wire                       reset,
  input wire                       flush, // clear buffer
  input wire [WRITE-1:0]           we,     // write enable
  input wire [WRITE-1:0][DATA-1:0] wd,     // write data
  input wire [READ-1:0]            re,     // read enable
  output wire [READ-1:0][DATA-1:0] rd,     // read data
  output wire [READ-1:0]           v,      // read data valid (Active high only)
  output wire                      busy    // entry is full
);

//***** internal parameters
localparam READ_EXT  = READ + 1;
localparam WNUM      = $clog2(WRITE) + 1;
localparam RNUM      = $clog2(READ) + 1;

//***** Internal registers
reg [DEPTH-1:0][DATA-1:0] data;
reg [DEPTH-1:0]           valid;

//***** internal wires
wire [DEPTH-1:0][DATA-1:0] next_data;
wire [WNUM-1:0]            wnum;
wire [RNUM-1:0]            rnum;
wire [DEPTH-1:0]           next_valid;



//***** input/output
assign busy = valid[DEPTH-WRITE];
assign v    = valid[READ-1:0];
generate
  genvar gi;
  for ( gi = 0; gi < READ; gi = gi + 1 ) begin : LP_reshape_rd
    assign rd[gi] = data[gi];
  end
endgenerate



//***** number of write and read
cnt_bits #(
  .IN   ( WRITE ),
  .OUT  ( WNUM ),
  .ACT  ( ACT )
) cnt_write (
  .in   ( we ),
  .out  ( wnum )
);

cnt_bits #(
  .IN   ( READ ),
  .OUT  ( RNUM ),
  .ACT  ( ACT )
) cnt_read (
  .in   ( re ),
  .out  ( rnum )
);


//***** data and valid generation
generate
  for ( genvar gk = 0; gk < DEPTH; gk = gk + 1 ) begin : LP_data
    wire [READ_EXT-1:0][DATA-1:0] rcand;          // candidate for read
    wire [READ_EXT-1:0]           rcand_valid;    // valid for read
    wire [READ_EXT+WRITE-1:0]     wcand_valid;    // valid for write
    //wire [DATA-1:0]               next_data_each;
    //assign next_data[gk] = next_data_each;
    //assign {next_valid[gk], next_data_each}
    //  = func_data(gk, wd, rcand, rcand_valid, wcand_valid, wnum, rnum);
    fifo_sel #(
      .DATA         ( DATA ),
      .WRITE        ( WRITE ),
      .READ         ( READ )
    ) fifo_sel0 (
      .wd           ( wd ),
      .data         ( rcand ),
      .valid_r      ( rcand_valid ),
      .valid_w      ( wcand_valid ),
      .wnum         ( wnum ),
      .rnum         ( rnum ),
      .next_valido  ( next_valid[gk] ),
      .next_datao   ( next_data[gk] )
    );

    //*** Shift Entry on read
    for ( genvar gl = 0; gl < READ_EXT; gl = gl + 1 ) begin : LP_rcand
      if ( gk + gl >= DEPTH ) begin : IF_over_range
        assign rcand[gl]       = {DATA{1'b0}};
        assign rcand_valid[gl] = `DISABLE;
      end else begin : IF_in_range
        assign rcand[gl]       = data[gk+gl];
        assign rcand_valid[gl] = valid[gk+gl];
      end
    end

    //*** Append Entry on write
    for ( genvar gm = 0; gm < READ_EXT + WRITE; gm = gm + 1 ) begin : LP_wcand
      if ( gm + gk < WRITE ) begin : IF_under_range
        assign wcand_valid[gm] = `ENABLE;
      end else if ( gm + gk >= DEPTH + WRITE ) begin : IF_over_range
        assign wcand_valid[gm] = `DISABLE;
      end else begin : IF_in_range
        assign wcand_valid[gm] = valid[gm-WRITE+gk];
      end
    end
    //for ( gm = -WRITE; gm < READ_EXT; gm = gm + 1 ) begin : LP_wcand
    //  if ( gm + gk < 0 ) begin : IF_under_range
    //    assign wcand_valid[WRITE+gm] = `ENABLE;
    //  end else if ( gm + gk >= DEPTH ) begin : IF_over_range
    //    assign wcand_valid[WRITE+gm] = `DISABLE;
    //  end else begin : IF_in_range
    //    assign wcand_valid[WRITE+gm] = valid[gm+gk];
    //  end
    //end
  end
endgenerate


//***** sequantial logics
always_ff @( posedge clk ) begin
  valid <= reset || flush ? {DEPTH{1'b0}}
         :                  next_valid;
  data  <= reset || flush ? {DEPTH*DATA{1'b0}}
         :                  next_data;
end

endmodule

module fifo_sel #(
  parameter DATA = 64,
  parameter WRITE = 4,
  parameter READ = 4,
  // constant
  parameter READ_EXT = READ + 1,
  parameter RNUM = $clog2(READ) + 1,
  parameter WNUM = $clog2(WRITE) + 1,
  parameter AL_W = 1 << $clog2(READ_EXT+WRITE),
  parameter AL_R = 1 << $clog2(READ_EXT),
  parameter WIDX = $clog2(READ_EXT+WRITE)
)(
  input wire [WRITE-1:0][DATA-1:0]    wd,          // write
  input wire [READ_EXT-1:0][DATA-1:0] data,
  input wire [READ_EXT-1:0]           valid_r,     // readable entries
  input wire [(WRITE+READ_EXT)-1:0]   valid_w,     // writable entries
  input wire [WNUM-1:0]               wnum,
  input wire [RNUM-1:0]               rnum,
  output wire                         next_valido,
  output wire [DATA-1:0]              next_datao
);

localparam DIFF_W = AL_W - (READ_EXT+WRITE);
localparam DIFF_R = AL_R - READ_EXT;

logic [AL_R-1:0]  valid_r_cp;  // extended to 2^n
logic [AL_W-1:0]  valid_w_cp;  // extended to 2^n
logic             next_valid;
logic [DATA-1:0]  next_data;
logic [WIDX-1:0]  widx;

always_comb begin
  valid_r_cp = {{DIFF_R{1'b0}}, valid_r};
  valid_w_cp = {{DIFF_W{1'b0}}, valid_w};
  widx       = WRITE + rnum;
  next_data  = {DATA{1'b0}};
  next_valid = `DISABLE;

  if ( valid_r_cp[rnum] ) begin
    next_valid = `ENABLE;
    for (int i = 0; i < READ_EXT; i = i + 1 ) begin
      if ( i == rnum ) begin
        next_data = data[i];
      end
    end
  end else begin
    for (int i = 0; i < WRITE; i = i + 1 ) begin
      automatic logic [WIDX-1:0]  idx;
      automatic logic [WIDX-1:0]  widx_prev;
      automatic logic [WIDX-1:0]  widx_cur;
      automatic logic             valid_edge;
      idx         = i[WIDX-1:0];
      widx_prev   = widx - idx - 'h1;
      widx_cur    = widx - idx;
      valid_edge  = valid_w_cp[widx_prev] ^ valid_w_cp[widx_cur];
      if (valid_edge && (i < wnum)) begin
        next_data  = wd[i];
        next_valid = `ENABLE;
      end
    end
  end
end

assign next_valido = next_valid;
assign next_datao  = next_data;

endmodule

`default_nettype wire
