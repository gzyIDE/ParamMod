/*
* <gray_bin.sv>
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module gray_bin #(
  parameter DATA = 4
)(
  input wire [DATA-1:0]   in,
  output wire [DATA-1:0]  out
);

logic [DATA-1:0] c_bin;
always_comb begin
  for ( int i = 0; i < DATA; i++ ) begin
    automatic logic c_bit = `LOW;
    for ( int j = i; j < DATA; j++ ) begin
      c_bit = c_bit ^ in[j];
    end
    c_bin[i] = c_bit;
  end
end

assign out = c_bin;

endmodule
