/*
* <freelist_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module freelist_test;
  parameter STEP  = 10;
  parameter DEPTH = 16;
  parameter MODE  = `LOW;
  parameter DATA  = MODE? DEPTH : $clog2(DEPTH);
  parameter READ  = 4;
  parameter WRITE = 4;
  localparam RNUM = $clog2(READ)+1;
  localparam WNUM = $clog2(WRITE)+1;

  reg                        clk;
  reg                        reset;
  reg                        flush;
  reg [WRITE-1:0]            we;
  reg [WRITE-1:0][DATA-1:0]  wd;
  reg [READ-1:0]             re;
  wire [READ-1:0][DATA-1:0]  rd;
  wire [READ-1:0]            v;
  wire                       empty;

  always #(STEP/2) begin
    clk <= ~clk;
  end


  freelist#(
    .DEPTH   ( DEPTH ),
    .DATA    ( DATA ),
    .READ    ( READ ),
    .WRITE   ( WRITE ),
    .MODE    ( MODE )
  ) freelist (
    .clk     ( clk ),
    .reset   ( reset ),
    .flush   ( flush ),
    .we      ( we ),
    .wd      ( wd ),
    .re      ( re ),
    .rd      ( rd ),
    .v       ( v ),
    .empty   ( empty )
  );

  task mRnW;
    input [DATA-1:0]  data;
    input [WNUM-1:0]  wnum;
    input [RNUM-1:0]  rnum;
    integer i;
    begin
      re = {READ{`DISABLE}};
      we = {WRITE{`DISABLE}};
      for ( i = 0; i < rnum; i = i + 1 ) begin
        re[i] = `ENABLE;
      end
      if ( MODE ) begin
        for ( i = 0; i < wnum; i = i + 1 ) begin
          we[i] = `ENABLE;
          wd[i] = 1 << (data + i);
        end
      end else begin
        for ( i = 0; i < wnum; i = i + 1 ) begin
          we[i] = `ENABLE;
          wd[i] = data + i;
        end
      end
      #(STEP);
      re = {READ{`DISABLE}};
      we = {WRITE{`DISABLE}};
    end
  endtask

  initial begin
    clk <= `LOW;
    reset <= `ENABLE;
    flush <= `DISABLE;
    we <= {WRITE{`DISABLE}};
    wd <= {WRITE*DATA{1'b0}};
    re <= {READ{`DISABLE}};
    #(STEP*5);
    reset <= `DISABLE;
    #(STEP*5);
    mRnW(32'h00000000, 0, 2);
    $display("two read");
    dump_data;
    mRnW(32'h00000000, 0, 3);
    $display("three read");
    dump_data;
    mRnW(32'h00000000, 2, 3);
    $display("three read, two freed");
    dump_data;
    mRnW(32'h00000002, 0, 4);
    $display("four read");
    dump_data;
    mRnW(32'h00000002, 0, 4);
    $display("four read");
    dump_data;
    mRnW(32'h00000002, 2, 0);
    $display("two freed");
    dump_data;
    #(STEP*5);
    flush <= `ENABLE;
    #(STEP);
    flush <= `DISABLE;
    #(STEP*10);
    dump_data;
    $finish;
  end

  task dump_data;
    integer i;
    begin
      $display("  %b", freelist.r_usage);
    end
  endtask

`ifdef SimVision
  initial begin
    $shm_open();
    $shm_probe("ACF");
  end
`endif

endmodule
