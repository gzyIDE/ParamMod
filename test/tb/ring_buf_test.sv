/*
* <ring_buf_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module ring_buf_test;
	parameter STEP = 10;
	parameter DATA = 32;
	parameter DEPTH = 20;
	parameter READ = 4;
	parameter WRITE= 4;
	parameter ACT = `HIGH;
	localparam RNUM = $clog2(READ) + 1;
	localparam WNUM = $clog2(WRITE) + 1;
	localparam ENABLE = ACT ? `ENABLE : `ENABLE_;
	localparam DISABLE = ACT ? `DISABLE : `DISABLE_;

	reg							          clk;
	reg							          reset;
	reg							          flush;
	reg [WRITE-1:0]				    we;
	reg [WRITE-1:0][DATA-1:0]	wd;
	reg [READ-1:0]				    re;
	wire [READ-1:0][DATA-1:0]	rd;
	wire [READ-1:0]				    rv;
	wire						          busy;

	ring_buf #(
		.DATA		( DATA ),
		.DEPTH	( DEPTH ),
		.READ		( READ ),
		.WRITE	( WRITE ),
		.ACT		( ACT )
	) ring (
		.clk		( clk ),
		.reset	( reset ),
		.flush 	( flush ),
		.we			( we ),
		.wd			( wd ),
		.re			( re ),
		.rd			( rd ),
		.rv			( rv ),
		.busy		( busy )
	);

	task write_n;
		input [DATA-1:0]		data;
		input [(WNUM+1)-1:0]	num;
		integer i;
		begin
			we = {WRITE{DISABLE}};
			for ( i = 0; i < num; i = i + 1 ) begin
				wd[i] = data + i;
				we[i] = ENABLE;
			end
			#(STEP);
			we = {WRITE{DISABLE}};
		end
	endtask

	task read_n;
		input [(RNUM+1):0]	num;
		integer i;
		begin
			re = {READ{DISABLE}};
			for ( i = 0; i < num; i = i + 1 ) begin
				re[i] = ENABLE;
			end
			#(STEP);
			re = {READ{DISABLE}};
		end
	endtask
	
	task dump_buf;
		integer i;
		begin
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				$display("buf[%d] = %x", i, ring.data[i]);
			end
		end
	endtask

	always #( STEP/2 ) begin
		clk <= ~clk;
	end

	initial begin
		clk <= `LOW;
		reset <= `ENABLE;
		flush <= `DISABLE;
		we <= {WRITE{DISABLE}};
		wd <= {WRITE*DATA{1'b0}};
		re <= {READ{DISABLE}};
		#(STEP);
		reset <= `DISABLE;
		#(STEP);
		write_n(32'h1, 2);
		#(STEP*2);
		read_n(1);
		#(STEP*2);
		read_n(1);
		#(STEP);
		write_n(32'h1, 2);
		#(STEP);
		write_n(32'ha, 4);
		#(STEP);
		write_n(32'haa, 4);
		#(STEP);
		write_n(32'haaaa, 4);
		#(STEP);
		write_n(32'haaaaaaaa, 4);
		#(STEP);
		write_n(32'hcccccccc, 4);
		#(STEP*10);
		dump_buf;
		$finish;
	end

`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("AC");
	end
`endif

endmodule
