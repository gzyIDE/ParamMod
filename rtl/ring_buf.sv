/*
* <ring_buf.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

// Ring buffer
module ring_buf #(
	parameter DATA = 64,
	parameter DEPTH = 16,
	parameter READ = 4,
	parameter WRITE= 4,
	parameter ACT = `Low
)(
	input wire							clk,
	input wire							reset_,
	input wire							flush_,		// clear buffer
	input wire [WRITE-1:0]				we,			// write enable
	input wire [WRITE-1:0][DATA-1:0]	wd,			// write data
	input wire [READ-1:0]				re,			// read enable
	output wire [READ-1:0][DATA-1:0]	rd,			// read data
	output wire [READ-1:0]				v,			// read data valid
	output wire							busy		// entry is full
);

	//***** internal parameters
	localparam ENABLE = ACT ? `Enable : `Enable_;
	localparam DISABLE = ACT ? `Disable : `Disable_;
	localparam ADDR = $clog2(DEPTH);
	localparam RNUM = $clog2(READ) + 1;
	localparam WNUM = $clog2(WRITE) + 1;

	//***** registers
	reg [DEPTH-1:0][DATA-1:0]	data;
	reg [ADDR-1:0]				head;
	reg [ADDR-1:0]				tail;
	reg [DEPTH-1:0]				valid;

	//***** wires
	wire [WRITE-1:0][ADDR-1:0]	wr_addr;
	wire [READ-1:0][ADDR-1:0]	rd_addr;
	wire [ADDR-1:0]				check_ptr;
	wire [RNUM-1:0]				rnum;
	wire [WNUM-1:0]				wnum;
	wire [ADDR-1:0]				next_head;
	wire [ADDR-1:0]				next_tail;


	//***** output
	assign check_ptr = head + ( WRITE - 1 );
	assign busy = valid[check_ptr];


	//***** generate address and data
	generate
		genvar gi, gj;
		for ( gi = 0; gi < WRITE; gi = gi + 1 ) begin : Loop_write
			assign wr_addr[gi] = head + gi;
		end

		for ( gj = 0; gj < READ; gj = gj + 1 ) begin : Loop_read
			wire [ADDR-1:0]		rd_addr_each;
			assign rd_addr_each = tail + gj;
			assign rd_addr[gj] = rd_addr_each;

			/* concatenate */
			assign rd[gj] = data[rd_addr_each];
			assign v[gj] = valid[rd_addr_each];
		end
	endgenerate


	//***** update head, tail and num
	assign next_head = head + wnum;
	assign next_tail = tail + rnum;

	cnt_bits #(
		.IN			( READ ),
		.ACT		( ACT )
	) cnt_read (
		.in			( re ),
		.out		( rnum )
	);

	cnt_bits #(
		.IN			( WRITE ),
		.ACT		( ACT )
	) cnt_write (
		.in			( we ),
		.out		( wnum )
	);


	//***** sequential logics
	integer i;
	always @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			head <= {ADDR{1'b0}};
			tail <= {ADDR{1'b0}};
			valid <= {DEPTH{DISABLE}};
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				data[i] <= {DATA{1'b0}};
			end
		end else begin
			if ( flush_ == `Enable_ ) begin
				head <= {ADDR{1'b0}};
				tail <= {ADDR{1'b0}};
				valid <= {DEPTH{DISABLE}};
				for ( i = 0; i < DEPTH; i = i + 1 ) begin
					data[i] <= {DATA{1'b0}};
				end
			end else begin
				head <= next_head;
				tail <= next_tail;
				for ( i = 0; i < WRITE; i = i + 1 ) begin
					if ( we[i] == ENABLE ) begin
						data[wr_addr[i]] <= wd[i];
						valid[wr_addr[i]] <= ENABLE;
					end
				end
				for ( i = 0; i < READ; i = i + 1 ) begin
					if ( re[i] == ENABLE ) begin
						data[rd_addr[i]] <= {DATA{1'b0}};
						valid[rd_addr[i]] <= DISABLE;
					end
				end
			end
		end
	end

endmodule
