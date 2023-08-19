/*
* <regfile.sv>
* 
* Copyright (c) 2021-2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module regfile #(
	parameter DATA  = 32,				      // bit width of register
	parameter ADDR  = 4,					    // address width of reg array
	parameter READ  = 4,					    // number of read
	parameter WRITE = 1,				      // number of write
	parameter bit ZERO_REG = `DISABLE // for GPR ( regs[0] is Zero reigister )
)(
	input wire							          clk,
	input wire							          reset,
	input wire [READ-1:0][ADDR-1:0]		raddr,
	input wire [WRITE-1:0][ADDR-1:0]	waddr,
	input wire [WRITE-1:0]				    we,
	input wire [WRITE-1:0][DATA-1:0]	wdata,
	output logic [READ-1:0][DATA-1:0]	rdata
);

	//***** internal parameters
	localparam DEPTH = 1 << ADDR;	// number of register (32)

	//***** registers
	reg [DATA-1:0]		regs [DEPTH-1:0];

	//***** combinational cells
	logic [WRITE-1:0]	internal_we;



	//***** assign output
	always_comb begin
		for ( int i = 0; i < READ; i = i + 1 ) begin
			rdata[i] = regs[raddr[i]];
		end
	end



	//***** assign internal
	generate
		if ( ZERO_REG ) begin : if_z
			always_comb begin
				for ( int i = 0; i < WRITE; i = i + 1 ) begin
					internal_we[i] = we[i] && (waddr[i] != {ADDR{1'b0}});
				end
			end
		end else begin : if_nz
			assign internal_we = we;
		end
	endgenerate



	//***** sequantial logics
	always_ff @( posedge clk ) begin
		int i;
		if ( reset == `ENABLE ) begin
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				regs[i] <= {DATA{1'b0}};
			end
		end else begin
			for ( i = 0; i < WRITE; i = i + 1 ) begin
				regs[waddr[i]] <= ( internal_we[i] ) ? wdata[i] : regs[waddr[i]];
			end
		end
	end

endmodule
