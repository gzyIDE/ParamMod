/*
* <stack.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "reset_config.vh"

module stack #(
	parameter DATA = 64,
	parameter DEPTH = 8,
	parameter BUF_EXT = `Disable,
	parameter PUSH = 1,
	parameter POP = 1
)(
	input wire						clk,
	input wire						reset,
	input wire						flush_,	// clear buffer
	input wire [PUSH-1:0]			push_,	// write enable
	input wire [PUSH-1:0][DATA-1:0]	wd,		// write data
	input wire [POP-1:0]			pop_,	// read enable
	output wire [POP-1:0][DATA-1:0]	rd,		// read data
	output wire [POP-1:0]			v,		// read data valid
	output wire						busy	// busy
);

	//***** internal parameters
	localparam INT_DEPTH = BUF_EXT ? ( DEPTH + PUSH ) : DEPTH;
	localparam INT_POP = POP + 1;
	localparam INT_PUSH = PUSH + 1;
	localparam ADDR = $clog2(INT_DEPTH);
	localparam AL_D = 1 << ADDR;				// alinged to avoid error
	localparam WNUM = $clog2(PUSH) + 1;
	localparam RNUM = $clog2(POP) + 1;

	//***** internal registers
	reg [DATA-1:0]			data [AL_D-1:0];	//  [AL_D-1:INT_DEPTH] is not used
	reg [AL_D-1:0]			valid;
	reg [ADDR-1:0]			ptr;

	//***** internal wires
	wire [DATA-1:0]			next_data [INT_DEPTH-1:0];
	wire [INT_DEPTH-1:0]	next_valid;
	wire [ADDR-1:0]			next_ptr;
	wire [WNUM-1:0]			wnum;
	wire [RNUM-1:0]			rnum;



	//***** assign output
	assign busy = valid[INT_DEPTH-PUSH];
	generate
		genvar gi, gj;
		for ( gj = 0; gj < POP; gj = gj + 1 ) begin : Loop_reshape_rd
			wire [ADDR-1:0] rptr_each;
			assign rptr_each =  ptr - gj - 1;
			assign rd[gj]  = data[rptr_each];
			assign v[gj] = valid[rptr_each];
		end
	endgenerate


	//***** number of write and read
	cnt_bits #(
		.IN		( PUSH ),
		.ACT	( `Enable_ )
	) cnt_write (
		.in		( push_ ),
		.out	( wnum )
	);

	cnt_bits #(
		.IN		( POP ),
		.ACT	( `Enable_ )
	) cnt_read (
		.in		( pop_ ),
		.out	( rnum )
	);


	//***** data, pointer and valid
	assign next_ptr =
		( ptr + wnum > rnum ) ? ptr + wnum - rnum : {ADDR{1'b0}};
	generate
		genvar gk, gl;
		for ( gk = 0; gk < INT_DEPTH; gk = gk + 1 ) begin : Loop_data
			assign {next_valid[gk], next_data[gk]} 
				= func_data(gk, ptr, wd, data[gk], valid[gk], rnum, wnum);
		end
	endgenerate

	//*** function for update
	localparam FUNC_DATA = 1 + DATA;
	function [FUNC_DATA-1:0] func_data;
		input [ADDR-1:0]			idx;
		input [ADDR-1:0]			ptr;
		input [PUSH-1:0][DATA-1:0]	wd;
		input [DATA-1:0]			data;
		input						valid;
		input [RNUM-1:0]			rnum;
		input [WNUM-1:0]			wnum;
		integer i;
		reg [ADDR-1:0]			ptr_tmp;
		reg [DATA-1:0]			next_data;
		reg						next_valid;
		begin
			ptr_tmp = ( ptr > rnum ) ? ptr - rnum : {ADDR{1'b0}};
			next_data = data;
			next_valid = (idx < ptr_tmp);
			for ( i = 0; i < PUSH; i = i + 1 ) begin
				if ( ( idx == ( ptr_tmp + i ) ) && ( i < wnum ) ) begin
					next_data = wd[i];
					next_valid = `Enable;
				end
			end
			func_data = {next_valid, next_data};
		end
	endfunction



	//***** Sequencial logics
	int i;
	always @( `ClkRstTrigger(clk, reset) ) begin
		if ( reset == `ResetEnable ) begin
			valid <= {AL_D{`Disable}};
			ptr <= {ADDR{1'b0}};
			for ( i = 0; i < AL_D; i = i + 1 ) begin
				data[i] <= {DATA{1'b0}};
			end
		end else begin
			valid <= next_valid;
			ptr <= next_ptr;
			for ( i = 0; i < INT_DEPTH; i = i + 1 ) begin
				data[i] <= next_data[i];
			end
		end
	end

endmodule
