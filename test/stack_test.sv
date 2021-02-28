/*
* <stack_test.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module stack_test;
	parameter STEP = 10;
	parameter DATA = 32;
	parameter DEPTH = 16;
	parameter BUF_EXT = `Enable;
	parameter PUSH = 1;
	parameter POP = 1;
	parameter WNUM = $clog2(PUSH)+1;
	parameter RNUM = $clog2(POP)+1;

	reg					clk;
	reg					reset_;
	reg					flush_;
	reg [PUSH-1:0]		push_;
	reg [PUSH*DATA-1:0]	wd;
	reg [POP-1:0]		pop_;
	wire [POP*DATA-1:0]	rd;
	wire [POP-1:0]		v;
	wire				busy;

	stack #(
		.DATA		( DATA ),
		.DEPTH		( DEPTH ),
		.BUF_EXT	( BUF_EXT ),
		.PUSH		( PUSH ),
		.POP		( POP )
	) stack (
		.clk		( clk ),
		.reset_		( reset_ ),
		.flush_		( flush_ ),
		.push_		( push_ ),
		.wd			( wd ),
		.pop_		( pop_ ),
		.rd			( rd ),
		.v			( v ),
		.busy		( busy )
	);

	task push_n;
		input [DATA-1:0]		data;
		input [(WNUM+1)-1:0]	num;
		integer i;
		begin
			push_ = {PUSH{`Disable_}};
			for ( i = 0; i < num; i = i + 1 ) begin
				wd[`Range(i,DATA)] = data + i;
				push_[i] = `Enable_;
			end
			#(STEP);
			push_ = {PUSH{`Disable_}};
		end
	endtask

	task pop_n;
		input [(RNUM+1):0]	num;
		integer i;
		begin
			pop_ = {POP{`Disable_}};
			for ( i = 0; i < num; i = i + 1 ) begin
				pop_[i] = `Enable_;
			end
			#(STEP);
			pop_ = {POP{`Disable_}};
		end
	endtask

	task mRnW;
		input [DATA-1:0]		data;
		input [(WNUM+1)-1:0]	wnum;
		input [(RNUM+1)-1:0]	rnum;
		integer i;
		begin
			pop_ = {POP{`Disable_}};
			push_ = {PUSH{`Disable_}};
			for ( i = 0; i < rnum; i = i + 1 ) begin
				pop_[i] = `Enable_;
			end
			for ( i = 0; i < wnum; i = i + 1 ) begin
				push_[i] = `Enable_;
				wd[`Range(i,DATA)] = data + i;
			end
			#(STEP);
			pop_ = {POP{`Disable_}};
			push_ = {PUSH{`Disable_}};
		end
	endtask

	always #(STEP/2) begin
		clk <= ~clk;
	end

	initial begin
		clk <= `Low;
		reset_ <= `Enable_;
		flush_ <= `Disable_;
		push_ <= {PUSH{`Disable_}};
		wd <= {PUSH*DATA{1'b0}};
		pop_ <= {POP{`Disable_}};
		#(STEP*5);
		reset_ <= `Disable_;
		#(STEP*5);
		mRnW(32'hdeadbeef, 1, 0);
		#(STEP*5);
		mRnW(32'hdeadbeef, 0, 1);
		#(STEP*10);
		$finish;
	end

`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("ACM");
	end
`endif

endmodule
