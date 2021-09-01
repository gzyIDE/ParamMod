/*
* <cam_test.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "reset_config.vh"
`include "sim.vh"

`timescale 1ns/10ps

module cam_test;
	parameter STEP = 10;
	parameter DATA = 32;
	parameter DEPTH = 32;
	parameter WRITE = 4;
	parameter READ = 4;
	// constant
	parameter ADDR = $clog2(DEPTH);

	reg							clk;
	reg							reset;

	/* write */
	reg [WRITE-1:0]				we_;
	reg [WRITE-1:0][DATA-1:0]	wm;
	reg [WRITE-1:0][DATA-1:0]	wd;
	reg [WRITE-1:0][ADDR-1:0]	waddr;

	/* read */
	reg [READ-1:0]				re_;
	reg [READ-1:0][DATA-1:0]	rm;
	reg [READ-1:0][DATA-1:0]	rd;
	wire [READ-1:0]				match;
	wire [READ-1:0]				multi;
	wire [READ-1:0][ADDR-1:0]	raddr;



	/***** instanciate module *****/
	cam #(
		.DATA		( DATA ),
		.DEPTH		( DEPTH ),
		.WRITE		( WRITE ),
		.READ		( READ )
	) cam (
		.*
	);


	/***** simulation utils *****/
	`include "cam_util.svh"


	/***** clk generation *****/
	always #(STEP/2) begin
		clk <= ~clk;
	end


	/***** simulation body *****/
	integer i;
	initial begin
		clk <= `Low;
		reset <= `ResetEnable;
		we_ <= {WRITE{`Disable_}};
		wm <= {DATA*WRITE{`Disable}};
		wd <= {DATA*WRITE{1'b0}};
		waddr <= {ADDR*WRITE{1'b0}};
		re_ <= {READ{`Disable_}};
		rm <= {DATA*READ{`Disable}};
		rd <= {DATA*READ{1'b0}};
		#(STEP);
		reset <= `ResetDisable;


		/***** read/write check *****/
		`SetCharCyan
		`SetCharBold
		$display("read/write check");
		`ResetCharSetting
		#(STEP);
		for ( i = 0; i < WRITE; i = i + 1 ) begin
			set_write(i, 'h0, 'h100 << i, i << 1);
		end
		#(STEP);
		reset_write;
		#(STEP);
		for ( i = 0; i < READ; i = i + 1 ) begin
			set_read(i, 'h0, 'h100 << i);
		end
		#(STEP);
		reset_read;

		`SetCharCyan
		`SetCharBold
		$display("entry not found check");
		`ResetCharSetting
		for ( i = 0; i < READ; i = i + 1 ) begin
			set_read(i, 'h0, 'h100 << (i+2));
		end
		#(STEP);
		reset_read;


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
