/*
* <ram_test.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

module ram_test;
  parameter STEP  = 10;
  parameter DATA  = 32;
  parameter DEPTH = 4;
  parameter PORT  = 2;
  parameter bit OUTREG = `DISABLE;
  parameter ADDR = $clog2(DEPTH);

  reg                       clk;
  reg                       reset;
  reg [PORT-1:0]            en;
  reg [PORT-1:0]            rw_;
  reg [PORT-1:0][ADDR-1:0]  addr;
  reg [PORT-1:0][DATA-1:0]  wdata;
  wire [PORT-1:0][DATA-1:0] rdata;



  //***** dut
  ram #(
    .DATA   ( DATA ),
    .DEPTH  ( DEPTH ),
    .PORT   ( PORT ),
    .OUTREG ( OUTREG )
  ) ram (
    .*
  );




`ifdef VERILATOR
`else
  //***** clock generation
  always #(STEP/2) begin
    clk = ~clk;
  end


  //***** status monitor
  always @( posedge clk ) begin
    int i;
    foreach ( en[i] ) begin
      if ( en[i] == `ENABLE ) begin
        if ( rw_[i] == `READ ) begin
          `SetCharCyanBold
          $display("Port[%1d]: Read ram[%d]", i, addr[i]);
          `ResetCharSetting
          if ( OUTREG ) begin
            @( posedge clk );
          end
          $display("  data: 0x%x", rdata[i]);
        end else begin
          `SetCharGreenBold
          $display("Port[%1d]: Write ram[%d]", i, addr[i]);
          `ResetCharSetting
          $display("  data: 0x%x", wdata[i]);
        end
      end
    end
  end


  //***** test body
  initial begin
    clk = `LOW;
    reset = `ENABLE;
    en    = {PORT{`DISABLE}};
    rw_   = {PORT{`READ}};
    addr  = 0;
    wdata = 0;

    #(STEP);
    reset = `DISABLE;

    #(STEP);
    // write "deadbeef" to ram[0] from port0
    en[0]    = `ENABLE;
    rw_[0]   = `WRITE;
    addr[0]  = 0;
    wdata[0] = 'hdaedbeef;

    #(STEP);
    en[0]    = `DISABLE;

    #(STEP);
    // read ram[0] from port1
    en[1]   = `ENABLE;
    rw_[1]  = `READ;
    addr[0] = 0;

    #(STEP);
    en[1]   = `DISABLE;

    #(STEP*5);

    $finish;
  end

  `include "waves.vh"

`endif

endmodule
