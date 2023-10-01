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
  parameter STEP    = 10;
  parameter DATA    = 32;
  parameter BYTE    = 8;
  parameter DEPTH   = 4;
  parameter PORT    = 2;
  parameter bit OUTREG = `ENABLE;
  parameter bit WMODE  = 1;
  parameter ADDR    = $clog2(DEPTH);
  parameter BYTESEL = DATA/BYTE;

  reg                         clk;
  reg [PORT-1:0][BYTESEL-1:0] en;
  reg [PORT-1:0]              rw_;
  reg [PORT-1:0][ADDR-1:0]    addr;
  reg [PORT-1:0][DATA-1:0]    wdata;
  wire [PORT-1:0][DATA-1:0]   rdata;



  //***** dut
  ram #(
    .DATA   ( DATA ),
    .BYTE   ( BYTE ),
    .DEPTH  ( DEPTH ),
    .PORT   ( PORT ),
    .WMODE  ( WMODE ),
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
    en    = {PORT{`DISABLE}};
    rw_   = {PORT{`READ}};
    addr  = 0;
    wdata = 0;

    #(STEP);
    // write "deadbeef" to ram[0] from port0
    en[0]    = {BYTESEL{`ENABLE}};
    rw_[0]   = `WRITE;
    addr[0]  = 0;
    wdata[0] = 'hdaedbeef;

    #(STEP);
    en[0]    = `DISABLE;

    #(STEP);
    // read ram[0] from port1
    en[1]   = {BYTESEL{`ENABLE}};
    rw_[1]  = `READ;
    addr[1] = 0;
    #(STEP);
    en[1]   = {BYTESEL{`DISABLE}};

    // Byte Write
    // write "deadbeef" to ram[0] from port0
    en[0]    = {`DISABLE, `DISABLE, `DISABLE, `ENABLE};
    rw_[0]   = `WRITE;
    addr[0]  = 1;
    wdata[0] = 'h000000aa;
    #(STEP);
    en[0]    = {`DISABLE, `DISABLE, `ENABLE, `DISABLE};
    rw_[0]   = `WRITE;
    addr[0]  = 1;
    wdata[0] = 'h0000bb00;
    #(STEP);
    en[0]    = {`DISABLE, `ENABLE, `DISABLE, `DISABLE};
    rw_[0]   = `WRITE;
    addr[0]  = 1;
    wdata[0] = 'h00cc0000;
    #(STEP);
    en[0]    = {`ENABLE, `DISABLE, `DISABLE, `DISABLE};
    rw_[0]   = `WRITE;
    addr[0]  = 1;
    wdata[0] = 'hdd000000;
    #(STEP);
    en[0]    = {4{`DISABLE}};

    #(STEP);
    // read ram[0] from port1
    en[1]   = {BYTESEL{`ENABLE}};
    rw_[1]  = `READ;
    addr[1] = 1;
    #(STEP);
    en[1]   = {BYTESEL{`DISABLE}};

    #(STEP);
    en[1]   = `DISABLE;

    if ( WMODE ) begin
      en[0]    = {BYTESEL{`ENABLE}};
      rw_[0]   = `WRITE;
      addr[0]  = 3;
      wdata[0] = 32'hdeadbeef;
      en[1]    = {BYTESEL{`ENABLE}};
      rw_[1]   = `READ;
      addr[1]  = 3;
      #(STEP);
      if ( rdata[1] == 32'hdeadbeef ) begin
        `SetCharBold
        `SetCharGreen
        $display("Write first check success");
      end else begin
        `SetCharBold
        `SetCharRed
        $display("Write first check failed");
      end
      en       = `ZERO(PORT*BYTESEL);
      #(STEP * 5);
      en[0]    = 4'b1010;
      rw_[0]   = `WRITE;
      addr[0]  = 3;
      wdata[0] = 32'h33221100;
      en[1]    = {BYTESEL{`ENABLE}};
      rw_[1]   = `READ;
      addr[1]  = 3;
      #(STEP);
      if ( rdata[1] == 32'h33ad11ef ) begin
        `SetCharBold
        `SetCharGreen
        $display("Write first check success");
      end else begin
        `SetCharBold
        `SetCharRed
        $display("Write first check failed");
      end
      en       = `ZERO(PORT*BYTESEL);
    end

    #(STEP*5);

    $finish;
  end

  `include "waves.vh"

`endif

endmodule
