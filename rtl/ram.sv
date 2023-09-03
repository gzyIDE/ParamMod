/*
* <ram.sv>
* 
* Copyright (c) 2020-2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

// <asciidoc>
// = ram.sv
// Flip-flop based random access memory with parameterized port number.
// Read/write ports are shared and controlled by rw_ signal.
// </asciidoc>

`include "parammod_stddef.vh"

module ram #(
  // <asciidoc>
  // == Parameters
  // DATA ::
  //    Bit width of read/write data
  // DEPTH ::
  //    Depth of RAM. $clog2(DEPTH) generates address width of ram
  // PORT ::
  //    Number of read/write ports in ram
  // OUTREG ::
  //    Output register option. +
  //    Output is pipelined by register if OUTREG == `Enable.
  // </asciidoc>
  parameter DATA       = 32,
  parameter BYTE       = DATA,
  parameter DEPTH      = 4,
  parameter PORT       = 1,
  parameter bit OUTREG = `DISABLE,
  parameter string MEM_FILE = "none",
  // constant
  parameter BYTESEL    = DATA/BYTE,
  parameter ADDR       = $clog2(DEPTH)
)(
  // <asciidoc>
  // == Input/Output signals
  // clk ::
  //    Clock signal
  // en_ ::
  //    Read/Write access enable (active low)
  // rw_ ::
  //    Read/Write select (Read: 1, Write: 1)
  // addr ::
  //    Address of ram 
  // wdata ::
  //    Write data
  // rdata ::
  //    Read data
  // </asciidoc>
  input wire                          clk,
  input wire [PORT-1:0][BYTESEL-1:0]  en,
  input wire [PORT-1:0]               rw_,
  input wire [PORT-1:0][ADDR-1:0]     addr,
  input wire [PORT-1:0][DATA-1:0]     wdata,
  output logic [PORT-1:0][DATA-1:0]   rdata
);

//***** internal registers
reg [DATA-1:0]  ram_reg [DEPTH-1:0];


//***** combinational logics
logic [PORT-1:0] ren;
logic [PORT-1:0] wen;    // write enable
always_comb begin
  for (int i = 0; i < PORT; i = i + 1 ) begin
    ren[i] =  rw_[i] & |en[i];
    wen[i] = !rw_[i] & |en[i];
  end
end


//***** parameter dependent
generate
  if ( OUTREG ) begin
    always_ff @( posedge clk ) begin
      foreach ( rdata[i] )
        rdata[i] <= ren[i]  ? ram_reg[addr[i]]
                  :           rdata[i];
      end
  end else begin
    always_comb begin
      foreach ( rdata[i] ) begin
        rdata[i] = ren[i] ? ram_reg[addr[i]]
                 :          {DATA{1'b0}};
      end
    end
  end
endgenerate


//***** sequential logics
always_ff @( posedge clk ) begin
  for(int i = 0; i < PORT; i = i + 1 ) begin
    if ( wen[i] ) begin
      for ( int j = 0; j < BYTESEL; j = j + 1 ) begin
        ram_reg[addr[i]][`RANGE(j, BYTE)] <= 
          wen[i] && en[i][j] ? wdata[i][`RANGE(j, BYTE)]
                             : ram_reg[addr[i]][`RANGE(j, BYTE)];
      end
    end
  end
end


//***** memory initialize
initial begin
  if ( MEM_FILE != "none" ) begin
    $readmemh(MEM_FILE, ram_reg);
  end else begin
    rdata = `ZERO(DATA);
    foreach ( ram_reg[i] ) begin
      ram_reg[i] = {DATA{1'b0}};
    end
  end
end

endmodule
