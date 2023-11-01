/*
* <gray_cnt.sv>
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module gray_cnt #(
  parameter DATA = 4
)(
  input wire              clk,
  input wire              reset,
  input wire              inc,
  output wire [DATA-1:0]  out_bin,
  output wire [DATA-1:0]  out_gray
);

//***** internal registers
reg [DATA-1:0]  r_cnt;

always_ff @(posedge clk) begin
  if ( reset ) begin
    r_cnt <= `ZERO(DATA);
  end else begin
    r_cnt <= inc ? r_cnt + 'h1 
           :       r_cnt;
  end
end

//***** output
assign out_bin = r_cnt;
bin_gray #(
  .DATA ( DATA )
) bin2gray0 (
  .in   ( r_cnt ),
  .out  ( out_gray )
);

endmodule
