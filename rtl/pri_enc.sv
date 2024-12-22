/*
* <pri_enc.sv>
* 
* Copyright (c) 2024 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

// Priority Encoder
module pri_enc #(
  parameter IN  = 32,
  parameter ACT = `HIGH,
  parameter MSB = `ENABLE,
  // auto
  parameter OUT = $clog2(IN)
)(
  input wire [IN-1:0]    in,
  output wire            valid,
  output wire [OUT-1:0]  out
);

wire [IN-1:0]           in_act;
wire [IN-1:0]           sel;
wire [IN-1:0][OUT-1:0]  out_const;

assign in_act = ACT ? in : ~in;

generate
genvar gi;
if ( MSB ) begin : gen_msbf
  assign sel[IN-1] = in_act[IN-1];

  for (gi = IN-2; gi >= 0; gi = gi - 1 ) begin
    assign sel[gi] = !(|in_act[IN-1:gi+1]) && in_act[gi];
  end
end else begin : gen_lsbf
  assign sel[0] = in_act[0];

  for ( gi = 1; gi < IN; gi = gi + 1 ) begin
    assign sel[gi] = !(|in_act[gi-1:0]) && in_act[gi];
  end
end

for (gi = 0; gi < IN; gi = gi + 1 ) begin : gen_const
  assign out_const[gi] = gi;
end
endgenerate

assign valid = (|in_act) ? ACT : !ACT;
selector #(
  .MODE   ( 1'b1 ), // vector mode
  .DATA   ( OUT ),
  .IN     ( IN ),
  .ACT    ( `HIGH )
) select_out (
  .in     ( out_const ),
  .sel    ( sel ),
  .valid  (),
  .pos    (),
  .out    ( out )
);

endmodule
