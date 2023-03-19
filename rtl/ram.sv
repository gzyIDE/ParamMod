/*
* <ram.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
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
  parameter DATA       = 16,
  parameter DEPTH      = 4,
  parameter PORT       = 1,
  parameter bit OUTREG = `DISABLE,
  parameter string MEM_FILE = "none",
  // constant
  parameter ADDR = $clog2(DEPTH)
)(
  // <asciidoc>
  // == Input/Output signals
  // clk ::
  //    Clock signal
  // reset ::
  //    Reset signal (configurable)
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
  input wire                        clk,
  input wire                        reset,
  input wire [PORT-1:0]             en,
  input wire [PORT-1:0]             rw_,
  input wire [PORT-1:0][ADDR-1:0]   addr,
  input wire [PORT-1:0][DATA-1:0]   wdata,
  output logic [PORT-1:0][DATA-1:0] rdata
);

//***** internal wires
wire [PORT-1:0] ren;
wire [PORT-1:0] wen;    // write enable

//***** internal registers
reg [DATA-1:0]  ram_reg [DEPTH-1:0];


//***** assign internal
assign ren = rw_ & en;
assign wen = ~rw_ & en;


//***** parameter dependent
generate
  if ( OUTREG ) begin
    always_ff @( posedge clk ) begin
      foreach ( rdata[i] )
        rdata[i] <= reset   ? {DATA{1'b0}}
                  : ren[i]  ? ram_reg[addr[i]]
                  :           {DATA{1'b0}};
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
  if ( reset == `ENABLE ) begin
    foreach ( ram_reg[i] ) begin
      ram_reg[i] <= {DATA{1'b0}};
    end
  end else begin
    foreach ( wdata[i] ) begin
      if ( wen[i] == `ENABLE ) begin
        ram_reg[addr[i]] <= wdata[i];
      end
    end
  end
end


//***** memory initialize
initial begin
  // initialize memory at reset negated
`ifdef PosedgeReset
  @( negedge reset );
`else
  @( posedge reset );
`endif
  if ( MEM_FILE != "none" ) begin
    $readmemh(MEM_FILE, ram_reg);
  end
end

endmodule
