/*
* <bin_gray.sv>
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module bin_gray #(
  parameter DATA = 4
)(
  input wire [DATA-1:0]   in,
  output wire [DATA-1:0]  out
);

logic [DATA-1:0]  c_gray;
always_comb begin
  c_gray[DATA-1] = in[DATA-1];
  for ( int i = 0; i < DATA-1; i++ ) begin
    c_gray[i] = in[i] ^ in[i+1];
  end
end

assign out = c_gray;

endmodule
