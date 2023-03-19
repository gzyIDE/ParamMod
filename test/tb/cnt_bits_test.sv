/*
* <cnt_bits_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

`ifdef NETLIST
 `timescale 1ns/10ps
`endif

module cnt_bits_test;
  parameter STEP = 10;
  parameter IN   = 5;
  parameter OUT  = $clog2(IN) + 1;
  parameter ACT  = `HIGH;

  reg [IN-1:0]   in;
  wire [OUT-1:0] out;

`ifdef NETLIST
  cnt_bits cnt_bits (
`else
  cnt_bits #(
    .IN   ( IN ),
    .ACT  ( ACT )
  ) cnt_bits (
`endif
    .in   ( in ),
    .out  ( out )
  );

  function [OUT-1:0] gen_answer;
    input [IN-1:0]    in;
    integer        i;
    begin
      gen_answer = 0;
      for ( i = 0; i < IN; i = i + 1 ) begin
        if ( in[i] == ACT ) begin
          gen_answer = gen_answer + 1;
        end
      end
    end
  endfunction

  integer i;
  initial begin
    in = {IN{1'b0}};
    #(STEP);

    for ( i = 0; i < 1<<IN; i = i + 1 ) begin
      if ( out != gen_answer(in) ) begin
        `SetCharBold
        `SetCharRed
        $display("Check Failed: expected %x, acquired %x", 
          gen_answer(in), out);
        `ResetCharSetting
      end else begin
        `SetCharBold
        `SetCharCyan
        $display("Check Success: expected %x, acquired %x", 
          gen_answer(in), out);
        `ResetCharSetting
      end
      in = in + 1;
      #(STEP);
    end

    #(STEP);
    $finish();
  end

`ifdef SimVision
  initial begin
    $shm_open();
    $shm_probe("AC");
  end
`endif

endmodule
