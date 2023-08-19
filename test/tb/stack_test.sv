/*
* <stack_test.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

module stack_test;
  parameter STEP = 10;
  parameter DATA = 32;
  parameter DEPTH = 16;
  parameter BUF_EXT = `ENABLE;
  parameter PUSH = 1;
  parameter POP = 1;
  parameter WNUM = $clog2(PUSH)+1;
  parameter RNUM = $clog2(POP)+1;

  reg                       clk;
  reg                       reset;
  reg [PUSH-1:0]            push;
  reg [PUSH-1:0][DATA-1:0]  wd;
  reg [POP-1:0]             pop;
  wire [POP-1:0][DATA-1:0]  rd;
  wire [POP-1:0]            v;
  wire                      busy;

  stack #(
    .DATA     ( DATA ),
    .DEPTH    ( DEPTH ),
    .BUF_EXT  ( BUF_EXT ),
    .PUSH     ( PUSH ),
    .POP      ( POP )
  ) stack (
    .clk      ( clk ),
    .reset    ( reset ),
    .push     ( push ),
    .wd       ( wd ),
    .pop      ( pop ),
    .rd       ( rd ),
    .v        ( v ),
    .busy     ( busy )
  );

  task push_n;
    input [DATA-1:0]    data;
    input [(WNUM+1)-1:0]  num;
    integer i;
    begin
      push = {PUSH{`DISABLE}};
      for ( i = 0; i < num; i = i + 1 ) begin
        wd[i] = data + i;
        push[i] = `ENABLE;
      end
      #(STEP);
      push = {PUSH{`DISABLE}};
    end
  endtask

  task pop_n;
    input [(RNUM+1):0]  num;
    integer i;
    begin
      pop = {POP{`DISABLE}};
      for ( i = 0; i < num; i = i + 1 ) begin
        pop[i] = `ENABLE;
      end
      #(STEP);
      pop = {POP{`DISABLE}};
    end
  endtask

  task mRnW;
    input [DATA-1:0]    data;
    input [(WNUM+1)-1:0]  wnum;
    input [(RNUM+1)-1:0]  rnum;
    integer i;
    begin
      pop = {POP{`DISABLE}};
      push = {PUSH{`DISABLE}};
      for ( i = 0; i < rnum; i = i + 1 ) begin
        pop[i] = `ENABLE;
      end
      for ( i = 0; i < wnum; i = i + 1 ) begin
        push[i] = `ENABLE;
        wd[i] = data + i;
      end
      #(STEP);
      pop  = {POP{`DISABLE}};
      push = {PUSH{`DISABLE}};
    end
  endtask

  always #(STEP/2) begin
    clk <= ~clk;
  end

  initial begin
    clk   <= `LOW;
    reset <= `ENABLE;
    push  <= {PUSH{`DISABLE}};
    wd    <= {PUSH*DATA{1'b0}};
    pop   <= {POP{`DISABLE}};
    #(STEP*5);
    reset <= `DISABLE;
    #(STEP*5);
    mRnW(32'hdeadbeef, 1, 0);
    #(STEP*5);
    mRnW(32'hdeadbeef, 0, 1);
    #(STEP*10);
    $finish;
  end

`ifdef SimVision
  initial begin
    $shm_open();
    $shm_probe("ACM");
  end
`endif

endmodule
