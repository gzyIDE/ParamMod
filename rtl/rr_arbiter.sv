/*
* <rr_arbiter.sv>
* N:1 Round robin arbiter
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

`default_nettype none

module rr_arbiter #(
  parameter PORT = 4,
  // Constant
  parameter IDX  = $clog2(PORT)
)(
  input wire              clk,
  input wire              reset,
  input wire              stall,

  input wire [PORT-1:0]   req,
  output wire [PORT-1:0]  granto
);

localparam PORT_I = 2 ** $clog2(PORT); // Port count is aligned to 2^n

reg [IDX-1:0]   r_prev;

//***** Input width adjust
wire [PORT_I-1:0] req_i = {{PORT_I-PORT{1'b0}}, req};

//***** Cominational logic
//*** Request select
wire [PORT_I-1:0]   c_req_sft;
shifter #(
  .BIT_VEC  ( `DISABLE ),
  .ROTATE   ( `ENABLE ),
  .TO_RIGHT ( `ENABLE ),  // to right
  .DATA     ( PORT_I ),
  .SHAMT    ( IDX )
) shifter0 (
  .in       ( req_i ),
  .shamt    ( r_prev ),
  .out      ( c_req_sft )
);

logic [PORT_I-1:0] c_grant_sft;
logic            c_req_exist;
logic [IDX-1:0]  c_prev_idx;
always_comb begin
  c_grant_sft = `ZERO(PORT_I);
  c_req_exist = `DISABLE;
  c_prev_idx  = `ZERO(IDX);
  for (int i = PORT_I-1; i >= 0; i--) begin
    if ( c_req_sft[i] ) begin
      c_grant_sft = `ONE(PORT_I) << i;
      c_req_exist = `ENABLE;
      c_prev_idx  = i[IDX-1:0] + `ONE(IDX) + r_prev;
    end
  end
end

wire [PORT_I-1:0] c_grant;
shifter #(
  .BIT_VEC    ( `DISABLE ),
  .ROTATE     ( `ENABLE ),
  .TO_RIGHT   ( `DISABLE ), // to left
  .DATA       ( PORT_I ),
  .SHAMT      ( IDX )
) shifter1 (
  .in         ( c_grant_sft ),
  .shamt      ( r_prev ),
  .out        ( c_grant )
);


//***** sequential logics
always_ff @(posedge clk) begin
  if ( reset ) begin
    r_prev <= `ZERO(IDX);
  end else begin
    r_prev <= !stall && c_req_exist ? c_prev_idx 
            :                         r_prev;
  end
end


//***** output
assign granto = c_grant[PORT-1:0];

endmodule

`default_nettype wire
