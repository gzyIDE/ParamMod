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

`include "stddef.vh"

module ram #(
	// <asciidoc>
	// == Parameters
	// DATA ::
	//		Bit width of read/write data
	// DEPTH ::
	//		Depth of RAM. $clog2(DEPTH) generates address width of ram
	// PORT ::
	//		Number of read/write ports in ram
	// OUTREG ::
	//		Output register option. +
	//		Output is pipelined by register if OUTREG == `Enable.
	// </asciidoc>
	parameter DATA = 16,
	parameter DEPTH = 4,
	parameter PORT = 1,
	parameter bit OUTREG = `Disable,
	// constant
	parameter ADDR = $clog2(DEPTH)
)(
	// <asciidoc>
	// == Input/Output signals
	// clk ::
	//		Clock signal
	// reset_ ::
	//		Reset signal (active low)
	// en_ ::
	//		Read/Write access enable (active low)
	// rw_ ::
	//		Read/Write select (Read: 1, Write: 1)
	// addr ::
	//		Address of ram 
	// wdata ::
	//		Write data
	// rdata ::
	//		Read data
	// </asciidoc>
	input wire							clk,
	input wire							reset_,
	input wire [PORT-1:0]				en_,
	input wire [PORT-1:0]				rw_,
	input wire [PORT-1:0][ADDR-1:0]		addr,
	input wire [PORT-1:0][DATA-1:0]		wdata,
	output logic [PORT-1:0][DATA-1:0]	rdata
);

	//***** internal wires
	wire [PORT-1:0]						ren_;
	wire [PORT-1:0]						wen_;		// write enable

	//***** internal registers
	reg [DATA-1:0]						ram_reg [DEPTH-1:0];



	//***** assign internal
	assign ren_ = ~rw_ | en_;
	assign wen_ = rw_ | en_;



	//***** parameter dependent
	generate
		if ( OUTREG ) begin
			always_ff @( posedge clk or negedge reset_ ) begin
				if ( reset_ == `Enable_ ) begin
					foreach ( rdata[i] ) begin
						rdata[i] <= {DATA{1'b0}};
					end
				end else begin
					foreach ( rdata[i] ) begin
						if ( ren_[i] == `Enable_ ) begin
							rdata[i] <= ram_reg[addr[i]];
						end else begin
							rdata[i] <= {DATA{1'b0}};
						end
					end
				end
			end
		end else begin
			always_comb begin
				foreach ( rdata[i] ) begin
					if ( ren_[i] == `Enable_ ) begin
						rdata[i] = ram_reg[addr[i]];
					end else begin
						rdata[i] = {DATA{1'b0}};
					end
				end
			end
		end
	endgenerate



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		int i;
		if ( reset_ == `Enable_ ) begin
			foreach ( ram_reg[i] ) begin
				ram_reg[i] <= {DATA{1'b0}};
			end
		end else begin
			foreach ( wdata[i] ) begin
				if ( wen_[i] == `Enable_ ) begin
					ram_reg[addr[i]] <= wdata[i];
				end
			end
		end
	end

endmodule
