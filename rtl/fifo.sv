/*
* <fifo.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

// First in First out queue
module fifo #(
	parameter DATA = 64,
	parameter DEPTH = 32,
	parameter BUF_EXT = `Disable,
	parameter READ = 4,
	parameter WRITE = 4,
	parameter ACT = `Low	// polarity of re, we
)(
	input wire							clk,
	input wire							reset_,
	input wire							flush_,		// clear buffer
	input wire [WRITE-1:0]				we,			// write enable
	input wire [WRITE-1:0][DATA-1:0]	wd,			// write data
	input wire [READ-1:0]				re,			// read enable
	output wire [READ-1:0][DATA-1:0]	rd,			// read data
	output wire [READ-1:0]				v,			// read data valid (Active high only)
	output wire							busy		// entry is full
);

	//***** internal parameters
	localparam INT_DEPTH = BUF_EXT ? ( DEPTH + WRITE ) : DEPTH;
	localparam INT_READ = READ + 1;
	localparam INT_WRITE = WRITE + 1;
	localparam ADDR = $clog2(INT_DEPTH);
	localparam WNUM = $clog2(WRITE) + 1;
	localparam RNUM = $clog2(READ) + 1;
	localparam WIDX = $clog2(INT_READ+WRITE);
	localparam AL_W = 1 << $clog2(INT_READ+WRITE);
	localparam AL_R = 1 << $clog2(INT_READ);
	localparam DIFF_W = AL_W - (INT_READ+WRITE);
	localparam DIFF_R = AL_R - INT_READ;

	//***** Internal registers
	reg [INT_DEPTH-1:0][DATA-1:0]	data;
	reg [INT_DEPTH-1:0]				valid;

	//***** internal wires
	wire [INT_DEPTH-1:0][DATA-1:0]	next_data;
	wire [WNUM-1:0]					wnum;
	wire [RNUM-1:0]					rnum;
	wire [INT_DEPTH-1:0]			next_valid;



	//***** input/output
	assign busy = valid[INT_DEPTH-WRITE];
	assign v = valid[READ-1:0];
	generate
		genvar gi;
		for ( gi = 0; gi < READ; gi = gi + 1 ) begin : LP_reshape_rd
			assign rd[gi] = data[gi];
		end
	endgenerate



	//***** number of write and read
	cnt_bits #(
		.IN		( WRITE ),
		.OUT	( WNUM ),
		.ACT	( ACT )
	) cnt_write (
		.in		( we ),
		.out	( wnum )
	);

	cnt_bits #(
		.IN		( READ ),
		.OUT	( RNUM ),
		.ACT	( ACT )
	) cnt_read (
		.in		( re ),
		.out	( rnum )
	);



	//***** data and valid generation
	generate
		genvar gk, gl, gm;
		for ( gk = 0; gk < INT_DEPTH; gk = gk + 1 ) begin : LP_data
			wire [INT_READ*DATA-1:0]	rcand;			// candidate for read
			wire [INT_READ-1:0]			rcand_valid;	// valid for read
			wire [INT_READ+WRITE-1:0]	wcand_valid;	// valid for write
			wire [DATA-1:0]				next_data_each;
			assign next_data[gk] = next_data_each;
			assign {next_valid[gk], next_data_each}
				= func_data(gk, flush_, wd, rcand, 
					rcand_valid, wcand_valid, wnum, rnum);

			//*** Shift Entry on read
			for ( gl = 0; gl < INT_READ; gl = gl + 1 ) begin : LP_rcand
				if ( gk + gl >= INT_DEPTH ) begin : IF_over_range
					assign rcand[`Range(gl,DATA)] = {DATA{1'b0}};
					assign rcand_valid[gl] = `Disable;
				end else begin : IF_in_range
					assign rcand[`Range(gl,DATA)] = data[gk+gl];
					assign rcand_valid[gl] = valid[gk+gl];
				end
			end

			//*** Append Entry on write
			for ( gm = -WRITE; gm < INT_READ; gm = gm + 1 ) begin : LP_wcand
				if ( gm + gk < 0 ) begin : IF_under_range
					assign wcand_valid[WRITE+gm] = `Enable;
				end else if ( gm + gk >= INT_DEPTH ) begin : IF_over_range
					assign wcand_valid[WRITE+gm] = `Disable;
				end else begin : IF_in_range
					assign wcand_valid[WRITE+gm] = valid[gm+gk];
				end
			end
		end
	endgenerate

	//*** data selection logic
	localparam FUNC_DATA = 1 + DATA;
	function [FUNC_DATA-1:0] func_data;
		input [ADDR-1:0]				idx;		// index
		input							flush_;		// buffer clear
		input [WRITE-1:0][DATA-1:0]		wd;			// write
		//input [INT_READ*DATA-1:0]		data;		// currently in data
		input [INT_READ-1:0][DATA-1:0]	data;
		input [INT_READ-1:0]			valid_r;	// readable entries
		input [(WRITE+INT_READ)-1:0]	valid_w;	// writable entries
		input [WNUM-1:0]				wnum;
		input [RNUM-1:0]				rnum;
		reg [AL_R-1:0]					valid_r_cp;	// complemented to 2^n
		reg [AL_W-1:0]					valid_w_cp;	// complemented to 2^n
		reg [WRITE-1:0]					valid_edge;
		reg								next_valid;
		reg [DATA-1:0]					next_data;
		reg [WIDX-1:0]					widx;
		reg [WIDX-1:0]					widx_cur [WRITE-1:0];
		reg [WIDX-1:0]					widx_prev [WRITE-1:0];
		int i;
		begin
			// initialize default value
			valid_r_cp = {{DIFF_R{1'b0}}, valid_r};
			valid_w_cp = {{DIFF_W{1'b0}}, valid_w};
			widx = WRITE + rnum;
			next_data = {DATA{1'b0}};
			next_valid = `Disable;
			for ( i = 0; i < WRITE; i = i + 1 ) begin
				widx_prev[i] = widx - i - 1;
				widx_cur[i] = widx - i;
			end

			if ( valid_r_cp[rnum] ) begin
				next_valid = `Enable;
				for ( i = 0; i < INT_READ; i = i + 1 ) begin
					if ( i == rnum ) begin
						next_data = data[i];
					end
				end
			end else begin
				for ( i = 0; i < WRITE; i = i + 1 ) begin
					valid_edge[i]
						= valid_w_cp[widx_prev[i]] ^ valid_w_cp[widx_cur[i]];
					if ( valid_edge[i] && ( i < wnum ) ) begin
						next_data = wd[i];
						next_valid = `Enable;
					end
				end
			end
			func_data = flush_ ? {next_valid, next_data} : {FUNC_DATA{1'b0}};
		end
	endfunction


	
	//***** sequantial logics
	int i;
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			valid <= {INT_DEPTH{1'b0}};
			data <= {INT_DEPTH*DATA{1'b0}};
		end else begin
			valid <= next_valid;
			data <= next_data;
		end
	end

endmodule
