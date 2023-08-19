/*
* <bin_dec.sv>
* 
* Copyright (c) 2020-2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

// Binary Decoder
module bin_dec #(
  parameter IN  = 4,
  parameter ACT = `HIGH,
  // constant
  parameter OUT = 1 << IN
)(
  input wire [IN-1:0]    in,
  output wire [OUT-1:0]  out
);

//***** internal parameter
localparam ENABLE  = ACT ? `ENABLE : `ENABLE_;
localparam DISABLE = ACT ? `DISABLE : `DISABLE_;


//***** Logic for Combinational logic
logic [OUT-1:0]    out_l;


//***** assign output
assign out = out_l;


//***** decode
int i;
always_comb begin
  for ( i = 0; i < OUT; i = i + 1 ) begin
    out_l[i] = ( i == in ) ? ENABLE : DISABLE;
  end
end

endmodule
