/*
* <freelist.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

// Tag distributer that manages free list.
module freelist #(
  parameter byte DEPTH  = 16,
  parameter byte READ   = 4,
  parameter byte WRITE  = 4,
  // impelementation option
  parameter bit BIT_VEC = `ENABLE,  // bit vector addressing
  parameter bit OUTREG  = `DISABLE,  // register output
  // constant
  parameter DATA = BIT_VEC ? DEPTH : $clog2(DEPTH)
)(
  input  wire                       clk,
  input  wire                       reset,
  input  wire                       flush, // clear buffer
  input  wire [WRITE-1:0]           we,    // collect
  input  wire [WRITE-1:0][DATA-1:0] wd,     // collect tags
  input  wire [READ-1:0]            re,    // request tag
  output wire [READ-1:0][DATA-1:0]  rd,     // served tag
  output wire [READ-1:0]            v,      // valid tags
  output wire                       empty   // some entry may be invalid
);


//***** internal parameter
localparam CNT   = $clog2(DEPTH);
localparam RDIDX = $clog2(READ);

//***** internal registers
reg [DEPTH-1:0] r_usage;
reg             r_empty;

//***** internal wires
wire [DEPTH-1:0][DATA-1:0] index;
wire [DEPTH-1:0]           next_usage;
wire [READ-1:0]            v_sel_out_;
wire [CNT:0]               empty_cnt;
wire                       next_empty;


//***** assign output
assign empty = r_empty;
assign v    = ~v_sel_out_;

generate
  genvar gj;
  if ( BIT_VEC ) begin : sel_vec
    //*** DATA = DEPTH
    for ( gj = 0; gj < READ; gj = gj + 1 ) begin : LP_rd
      assign {v_sel_out_[gj], rd[gj]} = rd_sel(gj, r_usage);
    end
  end else begin : sel_scl
    //*** DATA = $clog2(DEPTH)
    wire [READ-1:0][DEPTH-1:0]  pos;
    wire [READ-1:0][DEPTH-1:0]  usage_scl;
    assign usage_scl[0] = r_usage;
    selector #(
      .BIT_MAP ( `ENABLE ),
      .DATA    ( DATA ),
      .IN      ( DEPTH ),
      .ACT     ( `LOW ),
      .MSB     ( `DISABLE )
    ) sel_free (
      .in      ( index ),
      .sel     ( r_usage ),
      .valid   ( v_sel_out_[0] ),
      .pos     ( pos[0] ),
      .out     ( rd[0] )
    );

    for ( gj = 1; gj < READ; gj = gj + 1 ) begin : LP_rd
      assign usage_scl[gj] = usage_scl[gj-1] | ~pos[gj-1];

      selector #(
        .BIT_MAP ( `ENABLE ),
        .DATA    ( DATA ),
        .IN      ( DEPTH ),
        .ACT     ( `LOW ),
        .MSB     ( `DISABLE )
      ) sel_free (
        .in      ( index ),
        .sel     ( usage_scl[gj] ),
        .valid   ( v_sel_out_[gj] ),
        .pos     ( pos[gj] ),
        .out     ( rd[gj] )
      );
    end
  end
endgenerate

//*** selector for bit vector mode
localparam RD_SEL = 1 + DEPTH;
function [RD_SEL-1:0] rd_sel;
  input [RDIDX-1:0]          rdidx;
  input [DEPTH-1:0]          used;
  reg [DEPTH-1:0][DEPTH-1:0] index;
  reg [DEPTH-1:0][CNT-1:0]   cnt;
  reg                        v_;
  reg [DEPTH-1:0]            out;
  int i, j;
  begin
    // initialize
    v_ = `DISABLE_;
    out = {DEPTH{1'b0}};
    for ( i = 0; i < DEPTH; i = i + 1 ) begin
      cnt[i] = {CNT{1'b0}};
      for ( j = 0; j < i; j = j + 1 ) begin
        cnt[i] = cnt[i] + !used[j];
      end
    end

    for ( i = 0; i < DEPTH; i = i + 1 ) begin
      index[i] = (1'b1 << i);
    end

    for ( i = DEPTH-1; i >= 0; i = i - 1 ) begin
      if ( ( cnt[i] == rdidx ) && !used[i]  ) begin
        v_ = `ENABLE_;
        out = index[i];
      end
    end
    rd_sel = {v_, out};
  end
endfunction


//***** internal assign
assign next_empty = ( empty_cnt < READ );
generate
  genvar gi;
  for ( gi = 0; gi < DEPTH; gi = gi + 1 ) begin : LP_entry
    //*** tag generation
    assign index[gi] = gi;

    //*** entry update
    assign next_usage[gi] 
      = update_usage(gi, r_usage[gi], re, rd, we, wd);
  end
endgenerate

//*** update
function update_usage;
  input [DATA-1:0]      idx;
  input            current;
  input [READ-1:0]      re;
  input [READ-1:0][DATA-1:0]  rd;
  input [WRITE-1:0]      we;
  input [WRITE-1:0][DATA-1:0]  wd;
  reg [READ-1:0]        rmatch;
  reg [WRITE-1:0]        wmatch;
  reg              set;
  reg              reset;
  int i;
  begin
    //*** read/write check
    if ( BIT_VEC ) begin
      //* Bit Vector Addressing
      for ( i = 0; i < READ; i = i + 1 ) begin
        rmatch[i] = rd[i][idx] && re[i];
      end

      for ( i = 0; i < WRITE; i = i + 1 ) begin
        wmatch[i] = wd[i][idx] && we[i];
      end
    end else begin
      //* Scalar Index Addressing
      for ( i = 0; i < READ; i = i + 1 ) begin
        rmatch[i] = ( idx == rd[i] ) && re[i];
      end

      for ( i = 0; i < WRITE; i = i + 1 ) begin
        wmatch[i] = ( idx == wd[i] ) && we[i];
      end
    end

    //*** set valid bit
    set = |rmatch;
    //*** clear valid bit
    reset = |wmatch;

    update_usage = set || ( !reset && current );
  end
endfunction

cnt_bits #(
  .IN    ( DEPTH ),
  .ACT  ( `LOW )
) count_empty (
  .in    ( next_usage ),
  .out  ( empty_cnt )
);


//***** sequential logics
always_ff @( posedge clk ) begin
  r_usage <= reset || flush ? {DEPTH{`DISABLE}}
           :                  next_usage;
  r_empty <= reset || flush ? `DISABLE
           :                  next_empty;
end 

endmodule
