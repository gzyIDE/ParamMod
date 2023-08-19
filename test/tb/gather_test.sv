/*
* <gather_test.sv>
* 
* Copyright (c) 2021-2023 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

module gather_test;
  parameter STEP = 10;
  parameter DATA = 32;          // Data Size
  parameter IN = 8;             // Input Data
  parameter ACT = `HIGH;        // Active High/Low (sel; valid)
  parameter OUT = 4;            // Gathered Output
  parameter OFFSET = `ENABLE;   // Use offset of output elements
  parameter OFS = $clog2(OUT);  // Select offset
  localparam ENABLE  = ACT ? `ENABLE  : `ENABLE_;
  localparam DISABLE = ACT ? `DISABLE : `DISABLE_;

  reg [IN-1:0][DATA-1:0]    in;
  reg [OFS-1:0]             offset;
  reg [IN-1:0]              sel;
  wire [OUT-1:0]            valid;
  wire [OUT-1:0][DATA-1:0]  out;

  bit              error;

  gather #(
    .DATA     ( DATA ),
    .IN       ( IN ),
    .OFFSET   ( OFFSET ),
    .ACT      ( ACT ),
    .OUT      ( OUT )
  ) gather (
    .*
  );



  task calculate_ans (
    input [IN-1:0][DATA-1:0]    in,
    input [IN-1:0]              sel,
    input [OUT-1:0]             valid,
    input [OUT-1:0][DATA-1:0]   out
  );
    int              fi;
    int             cnt;
    reg [OUT-1:0][DATA-1:0]    ans;
    reg [OUT-1:0]               ans_valid;

    ans = 0;
    cnt = 0;
    ans_valid = {OUT{DISABLE}};
    for ( fi = 0; fi < IN; fi = fi + 1 ) begin
      if ( sel[fi] == ENABLE ) begin
        ans[cnt] = in[fi];
        ans_valid[cnt] = ENABLE;
        cnt = cnt + 1;
      end
    end

    if ( OFFSET ) begin
      for ( fi = IN-1; fi >= 0; fi = fi - 1 ) begin
        if ( fi >= offset ) begin
          ans[fi] = ans[fi-offset];
          ans_valid[fi] = ans_valid[fi-offset];
        end else begin
          ans[fi] = 0;
          ans_valid[fi] = `DISABLE;
        end
      end
    end

    assert ( ( ans == out ) && ( valid== ans_valid ) ) begin
      error = `DISABLE;
    end else begin
      error = `ENABLE;
      $error("Check Failed");
      $display("    output   : 0x%x", out);
      $display("    expected : 0x%x", ans);
      $display("    output valid   : 0x%x", valid);
      $display("    expected valid : 0x%x", ans_valid);
    end

  endtask



  //***** test body
  int i, j, ofs;
  initial begin
    for ( i = 0; i < IN; i = i + 1 ) begin
      in[i] = i + 1;
    end
    sel = {IN{DISABLE}};
    offset = 2;
    #(STEP);

    // output = {D, D, D, D, D, 6, 2, 1}
    sel[0] = ENABLE;
    sel[1] = ENABLE;
    sel[5] = ENABLE;

    #(STEP);
    calculate_ans(in, sel, valid,out);
    #(STEP);

    for ( ofs = 0; ofs < OUT; ofs = ofs + 1 ) begin
      offset = ofs;
      for ( i = 0; i < 1000; i = i + 1 ) begin
        sel = $random();
        for ( j = 0; j < IN; j = j + 1 ) begin
          in[j] = $random();
        end
        #(STEP);
        calculate_ans(in, sel, valid, out);
        #(STEP);
      end
      #(STEP*50);
    end

    #(STEP);
    $finish;
  end

  `include "waves.vh"

endmodule
