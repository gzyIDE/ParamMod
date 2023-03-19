/*
* <sel_minmax_test.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

module sel_minmax_test;
  parameter STEP    = 10;
  parameter MINMAX_ = `HIGH;
  parameter IN      = 8;
  parameter DATA    = 8;
  parameter ACT     = `HIGH;
  parameter OUT     = $clog2(IN);
  parameter ENABLE  = ACT ? `ENABLE  : `ENABLE_;
  parameter DISABLE = ACT ? `DISABLE : `DISABLE_;

  reg [IN-1:0][DATA-1:0] in;
  wire [OUT-1:0]         out_idx;
  wire [IN-1:0]          out_vec;
  wire [DATA-1:0]        out;

  sel_minmax #(
    .MINMAX_ ( MINMAX_ ),
    .IN      ( IN ),
    .DATA    ( DATA ),
    .ACT     ( ACT )
  ) sel_max (
    .*
  );

  task check_result; 
    int ti;
    reg [OUT-1:0]  ans_idx;
    reg [IN-1:0]   ans_vec;
    reg [DATA-1:0] ans;

    ans_idx = 0;
    ans_vec = {{IN-1{DISABLE}}, ENABLE};
    ans = in[0];
    for ( ti = 1; ti < IN; ti = ti + 1 ) begin
      if ( MINMAX_ == `HIGH ) begin
        // min
        if ( ans > in[ti] ) begin
          ans_vec[ans_idx] = DISABLE;
          ans_vec[ti] = ENABLE;
          ans_idx = ti;
          ans = in[ti];
        end
      end else begin
        // max
        if ( ans < in[ti] ) begin
          ans_vec[ans_idx] = DISABLE;
          ans_vec[ti] = ENABLE;
          ans_idx = ti;
          ans = in[ti];
        end
      end
    end

    assert(ans_idx == out_idx) begin
      $display("Index Check Success");
    end else begin
      `SetCharRedBold
      $display("Index Check Failed");
      `ResetCharSetting
      $display("    expected: 0x%x", ans_idx);
      $display("    result: 0x%x", out_idx);
    end
    assert(ans_vec == out_vec) begin
      $display("Vector Check Success");
    end else begin
      `SetCharRedBold
      $display("Vector Check Failed");
      `ResetCharSetting
      $display("    expected: 0x%x", ans_vec);
      $display("    result: 0x%x", out_vec);
    end
    assert(ans == out) begin
      $display("Result Check Success");
    end else begin
      `SetCharRedBold
      $display("Result Check Failed");
      `ResetCharSetting
      $display("    expected: 0x%x", ans);
      $display("    result: 0x%x", out);
    end
  endtask

  int i, j;
  initial begin
    in = {DATA*IN{1'b0}};

    #(STEP);
    for ( i = 0; i < 1000; i = i + 1 ) begin
      for ( j = 0; j < IN; j = j + 1 ) begin
        in[j] = $random();
      end
      #(STEP);
      check_result;
    end

    #(STEP);
  end

  `include "waves.vh"

endmodule
