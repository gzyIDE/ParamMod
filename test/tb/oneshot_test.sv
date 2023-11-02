/*
* <oneshot_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

`ifdef GATE_SIM
 `timescale 1ns/10ps
`endif

module oneshot_test;
  parameter STEP = 10;
  parameter ACT = `HIGH;

  logic   clk;
  logic   reset;
  logic   level_in;
  logic   pls_out;

  oneshot #(
    .ACT      ( ACT )
  ) oneshot (
    .clk      ( clk ),
    .reset    ( reset ),
    .level_in ( level_in ),
    .pls_out  ( pls_out )
  );

  always #(STEP/2) begin
    clk <= ~clk;
  end

  initial begin
    clk       <= `LOW;
    reset     <= `ENABLE;
    level_in  <= !ACT;
    repeat(5) @(posedge clk);
    reset <= `DISABLE;
    repeat(5) @(posedge clk);

    level_in <= ACT;
    repeat(5) @(posedge clk);
    level_in <= !ACT;
    repeat(5) @(posedge clk);
  end

  initial begin
`ifdef SimVision
    $shm_open();
    $shm_probe("AC");
`endif
  end
endmodule
