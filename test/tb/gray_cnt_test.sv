/*
* <gray_cnt_test.sv>
* 
* Copyright (c) 2023 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

`ifdef GATE_SIM
  `timescale 1ns/10ps
`endif

module gray_cnt_test;
  parameter STEP = 10;
  parameter DATA = 4;

  logic           clk;
  logic           reset;
  logic           inc;
  wire [DATA-1:0] out_gray;
  wire [DATA-1:0] out_bin;
  wire [DATA-1:0] out_bin_test;

`ifdef NETLIST
  gray_cnt gray_cnt(
`else
  gray_cnt #(
    .DATA     ( DATA )
  ) gray_cnt (
`endif
    .clk      ( clk ),
    .reset    ( reset ),
    .inc      ( inc ),
    .out_bin  ( out_bin ),
    .out_gray ( out_gray )
  );

  gray_bin #(
    .DATA     ( DATA )
  ) gray_bin (
    .in       ( out_gray ),
    .out      ( out_bin_test )
  );

  always #(STEP/2) begin
    clk <= ~clk;
  end

  //***** Simulation Body
  initial begin
    clk   = `LOW;
    reset = `ENABLE;
    inc   = `DISABLE;
    repeat(5) @(posedge clk);
    reset = `DISABLE;

    repeat(5) @(posedge clk);
    inc = `ENABLE;
    repeat(10) @(posedge clk);
    inc = `DISABLE;

    repeat(5) @(posedge clk);
    $finish;
  end

  initial begin
`ifdef SimVision
    $shm_open();
    $shm_probe("AC");
`endif
  end

  always @(posedge clk) begin
    if ( out_bin != out_bin_test ) begin
      $display("gray-binary conversion error!");
    end
  end
endmodule
