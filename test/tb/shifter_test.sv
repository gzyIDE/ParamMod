/*
* <bin_dec_test.sv>
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

module shifter_test;
parameter STEP      = 10;
parameter BIT_VEC   = `DISABLE;
parameter ROTATE    = `ENABLE;
parameter TO_RIGHT  = `DISABLE;
parameter DATA      = 8;
parameter SHAMT     = 3;
parameter ACT       = `HIGH;

reg [DATA-1:0]      in;
reg [SHAMT-1:0]     shamt;
wire [DATA-1:0]     out;
logic [DATA-1:0]    expected;

shifter #(
  .BIT_VEC  ( BIT_VEC ),
  .ROTATE   ( ROTATE ),
  .TO_RIGHT ( TO_RIGHT ),
  .DATA     ( DATA ),
  .SHAMT    ( SHAMT ),
  .ACT      ( ACT )
) shifter (
  .in       ( in ),
  .shamt    ( shamt ),
  .out      ( out )
);

integer i;
initial begin
  in    <= 8'b10011100;
  shamt <= {SHAMT{1'b0}};
  #(STEP*5);
  for ( i = 0; i < (1 << SHAMT); i = i + 1 ) begin
    shamt <= shamt + 1'b1;
    #(STEP);
  end
  #(STEP*5);
  $finish;
end

`include "waves.vh"

endmodule
