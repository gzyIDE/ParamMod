/*
* <regfile.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "reset_config.vh"

module regfile #(
	parameter DATA = 32,				// bit width of register
	parameter ADDR = 4,					// address width of reg array
	parameter READ = 4,					// number of read
	parameter WRITE = 1,				// number of write
	parameter bit ZERO_REG = `Disable	// for GPR ( regs[0] is Zero reigister )
)(
	input wire							clk,
	input wire							reset,
	input wire [READ-1:0][ADDR-1:0]		raddr,
	input wire [WRITE-1:0][ADDR-1:0]	waddr,
	input wire [WRITE-1:0]				we_,
	input wire [WRITE-1:0][DATA-1:0]	wdata,
	output logic [READ-1:0][DATA-1:0]	rdata
);

	//***** internal parameters
	localparam DEPTH = 1 << ADDR;	// number of register (32)

	//***** registers
	reg [DATA-1:0]		regs [DEPTH-1:0];

	//***** combinational cells
	logic [WRITE-1:0]	internal_we_;



	//***** assign output
	always_comb begin
		int i;
		for ( i = 0; i < READ; i = i + 1 ) begin
			rdata[i] = regs[raddr[i]];
		end
	end



	//***** assign internal
	generate
		if ( ZERO_REG ) begin : if_z
			always_comb begin
				int i;
				for ( i = 0; i < WRITE; i = i + 1 ) begin
					internal_we_[i] = we_[i] || (waddr[i] == {ADDR{1'b0}});
				end
			end
		end else begin : if_nz
			assign internal_we_ = we_;
		end
	endgenerate



	//***** sequantial logics
	always_ff @( `ResetTrigger(clk, reset) ) begin
		int i;
		if ( reset == `ResetEnable ) begin
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				regs[i] <= {DATA{1'b0}};
			end
		end else begin
			for ( i = 0; i < WRITE; i = i + 1 ) begin
				regs[waddr[i]] <= 
					( internal_we_[i] ) ? regs[waddr[i]] : wdata[i];
			end
		end
	end

endmodule
