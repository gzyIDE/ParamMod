/*
* <fifo_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "sim.vh"

//`define DUMP_RW_INFO
`ifdef NETLIST
 `timescale 1ns/10ps
`else
 //`define DUMP_FIFO_ON_WRITE
 //`define DUMP_FIFO_ON_READ
 `define DUMP_FIFO_ON_RW
 `define DUMP_FIFO_ON_EXIT
 //`define ASSERTION_OUTPUT
`endif

module fifo_test;
	parameter STEP = 10;
	parameter CHECK = 1;	// delay for check
	parameter DATA = 32;
	parameter DEPTH = 16;
	parameter BUF_EXT = `Enable;
	parameter READ = 4;
	parameter WRITE = 4;
	localparam RNUM = $clog2(READ);
	localparam WNUM = $clog2(WRITE);

	reg							clk;
	reg							reset_;
	reg							flush_;
	reg [WRITE-1:0]				we_;
	reg [WRITE-1:0][DATA-1:0]	wd;	
	reg [READ-1:0]				re_;
	wire [READ-1:0][DATA-1:0]	rd;
	wire [READ-1:0]				valid;
	wire						busy;

	fifo #(
		.DATA		( DATA ),
		.DEPTH		( DEPTH ),
		.BUF_EXT	( BUF_EXT ),
		.READ		( READ ),
		.WRITE		( WRITE ),
		.ACT		( `Low )
	) fifo (
		.clk		( clk ),
		.reset_		( reset_ ),
		.flush_		( flush_ ),
		.we			( we_ ),
		.wd			( wd ),
		.re			( re_ ),
		.rd			( rd ),
		.v			( valid ),
		.busy		( busy )
	);


	/***** Simulation Functions *****/
	task write_single;
		input [DATA-1:0]		data;
		begin
			we_ = {WRITE{`Disable_}};
			we_[0] =  `Enable_;
			wd[DATA-1:0] = data;
			$display("write :%x", wd[DATA-1:0]);
			#(STEP);
			we_[0] = `Disable_;
`ifdef DUMP_FIFO_ON_WRITE
		dump_fifo;
`endif
		end
	endtask

	task write_n;
		input [DATA-1:0]		data;
		input [(WNUM+1)-1:0]	num;
		integer i;
		begin
			we_ = {WRITE{`Disable_}};
			for ( i = 0; i < num; i = i + 1 ) begin
				wd[i] = data + i;
`ifdef DUMP_RW_INFO
				$display("write :%x", wd[i]);
`endif
				we_[i] = `Enable_;
			end
			#(STEP);
			we_ = {WRITE{`Disable_}};
`ifdef DUMP_FIFO_ON_WRITE
		dump_fifo;
`endif
		end
	endtask
	
	task read_single;
		begin
			re_ = {READ{`Disable_}};
			re_[0] = `Enable_;
`ifdef DUMP_RW_INFO
			$display("read : %x",rd[DATA-1:0]);
`endif
			#(STEP);
			re_[0] = `Disable_;
`ifdef DUMP_FIFO_ON_READ
		dump_fifo;
`endif
		end
	endtask

	task read_n;
		input [(RNUM+1):0]	num;
		integer i;
		begin
			re_ = {READ{`Disable_}};
			for ( i = 0; i < num; i = i + 1 ) begin
`ifdef DUMP_RW_INFO
				$display("read : %x", rd[i]);
`endif
				re_[i] = `Enable_;
			end
			#(STEP);
			re_ = {READ{`Disable_}};
`ifdef DUMP_FIFO_ON_READ
		dump_fifo;
`endif
		end
	endtask

	task mRnW;
		input [DATA-1:0]		data;
		input [(WNUM+1)-1:0]	wnum;
		input [(RNUM+1)-1:0]	rnum;
		integer i;
		begin
			re_ = {READ{`Disable_}};
			we_ = {WRITE{`Disable_}};
			for ( i = 0; i < rnum; i = i + 1 ) begin
`ifdef DUMP_RW_INFO
				$display("read : %x", rd[i]);
`endif
				re_[i] = `Enable_;
			end
			for ( i = 0; i < wnum; i = i + 1 ) begin
				we_[i] = `Enable_;
				wd[i] = data + i;
`ifdef DUMP_RW_INFO
				$display("write :%x", wd[i]);
`endif
			end
			#(STEP);
			re_ = {READ{`Disable_}};
			we_ = {WRITE{`Disable_}};
`ifdef DUMP_FIFO_ON_RW
		dump_fifo;
`endif
		end
	endtask

	task dump_fifo;
		integer i;
		begin
			$display("###### contents of fifo ######");
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				$display("[%4d]: %x", i, fifo.data[i]);
			end
			$display("##############################");
			#(STEP);
		end
	endtask


	always #(STEP/2) begin
		clk <= ~clk;
	end

	initial begin
		clk <= `Low;
		reset_ <= `Enable_;
		flush_ <= `Disable_;
		we_ <= {WRITE{`Disable_}};
		re_ <= {READ{`Disable_}};
		wd <= {WRITE*DATA{1'b0}};
		#(STEP*10);
		reset_ <= `Disable_;
		#(STEP*10);

		/*** single read/write ***/
		write_single(32'hdeadbeef);
		#(STEP*5);
		read_single;

		#(STEP*5);
		/* multiple read/write */
		write_n(32'h1, 2);
		read_n(2);
		write_n(32'ha, 3);
		read_n(2);
		write_n(32'hbb, 4);
		read_n(2);
		write_n(32'hdead, 4);
		read_n(2);
		write_n(32'hdeadbead, 4);
		read_n(4);
		read_n(4);
		read_single;

		///* simultaneous read/write */
		write_n(32'hdead, 4);
		mRnW(32'habcd, 2, 1);
		mRnW(32'habcdef01, 3, 3);
		mRnW(32'h23456789, 4, 4);
		mRnW(32'heeeeeeee, 4, 2);

		// busy bit check
		write_n(32'habcdabcd, 4);
		write_n(32'habcdabcd, 4);
		write_n(32'habcdabcd, 2);

		#(STEP*10);
`ifdef DUMP_FIFO_ON_EXIT
		dump_fifo;
`endif

		#(STEP);
		flush_ <= `Enable_;
		#(STEP);
		flush_ <= `Disable_;

		dump_fifo;
		$finish;
	end

	`include "waves.vh"


endmodule
