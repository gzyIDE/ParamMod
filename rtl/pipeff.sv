/*
* <pipeff.sv>
* 
* Copyright (c) 2025 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

// Pipeline Flip-flop
module pipeff #(
  parameter DATA = 32
)(
  input wire              clk,
  input wire              stall,
  input wire [DATA-1:0]   in,
  output reg [DATA-1:0]  out
);

always_ff @(posedge clk) begin
  out  <= !stall ? in 
        :          out;
end
endmodule
