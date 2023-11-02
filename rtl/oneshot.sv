/*
* <oneshot.sv>
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module oneshot #(
  parameter bit ACT = `HIGH
)(
  input wire    clk,
  input wire    reset,
  input wire    level_in,
  output wire   pls_out
);

reg r_level;

wire   c_active = (level_in == ACT) && (r_level == !ACT);
assign pls_out  = c_active ? ACT : !ACT;

always_ff @(posedge clk) begin
  if ( reset ) begin
    r_level <= !ACT;
  end else begin
    r_level <= level_in;
  end
end

endmodule
