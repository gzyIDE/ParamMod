/*
* <freelist_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module freelist_test;
	parameter STEP = 10;
	parameter DEPTH = 16;
	parameter BIT_VEC = `Disable;
	parameter DATA = BIT_VEC ? DEPTH : $clog2(DEPTH);
	parameter READ = 4;
	parameter WRITE = 4;
	localparam RNUM = $clog2(READ)+1;
	localparam WNUM = $clog2(WRITE)+1;

	reg							clk;
	reg							reset_;
	reg							flush_;
	reg [WRITE-1:0]				we_;
	reg [WRITE-1:0][DATA-1:0]	wd;
	reg [READ-1:0]				re_;
	wire [READ-1:0][DATA-1:0]	rd;
	wire [READ-1:0]				v;
	wire						busy;

	always #(STEP/2) begin
		clk <= ~clk;
	end


	freelist#(
		.DEPTH		( DEPTH ),
		.DATA		( DATA ),
		.READ		( READ ),
		.WRITE		( WRITE ),
		.BIT_VEC	( BIT_VEC )
	) freelist (
		.clk	( clk ),
		.reset_	( reset_ ),
		.flush_	( flush_ ),
		.we_	( we_ ),
		.wd		( wd ),
		.re_	( re_ ),
		.rd		( rd ),
		.v		( v ),
		.busy	( busy )
	);

	task mRnW;
		input [DATA-1:0]	data;
		input [WNUM-1:0]	wnum;
		input [RNUM-1:0]	rnum;
		integer i;
		begin
			re_ = {READ{`Disable_}};
			we_ = {WRITE{`Disable_}};
			for ( i = 0; i < rnum; i = i + 1 ) begin
				re_[i] = `Enable_;
			end
			if ( BIT_VEC ) begin
				for ( i = 0; i < wnum; i = i + 1 ) begin
					we_[i] = `Enable_;
					wd[i] = 1 << (data + i);
				end
			end else begin
				for ( i = 0; i < wnum; i = i + 1 ) begin
					we_[i] = `Enable_;
					wd[i] = data + i;
				end
			end
			#(STEP);
			re_ = {READ{`Disable_}};
			we_ = {WRITE{`Disable_}};
		end
	endtask

	initial begin
		clk <= `Low;
		reset_ <= `Enable_;
		flush_ <= `Disable_;
		we_ <= {WRITE{`Disable_}};
		wd <= {WRITE*DATA{1'b0}};
		re_ <= {READ{`Disable_}};
		#(STEP*5);
		reset_ <= `Disable_;
		#(STEP*5);
		mRnW(32'h00000000, 0, 2);
		mRnW(32'h00000000, 0, 3);
		mRnW(32'h00000000, 2, 3);
		mRnW(32'h00000002, 0, 4);
		mRnW(32'h00000002, 0, 4);
		mRnW(32'h00000002, 2, 0);
		#(STEP*5);
		flush_ <= `Enable_;
		#(STEP);
		flush_ <= `Disable_;
		#(STEP*10);
		dump_data;
		$finish;
	end

	task dump_data;
		integer i;
		begin
			$display("%b", freelist.usage);
		end
	endtask

`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("ACF");
	end
`endif

endmodule
