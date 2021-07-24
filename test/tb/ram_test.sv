/*
* <ram_test.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "sim.vh"

module ram_test;
	parameter STEP = 10;
	parameter DATA = 32;
	parameter DEPTH = 4;
	parameter PORT = 2;
	parameter bit OUTREG = `Disable;
	parameter ADDR = $clog2(DEPTH);

	reg							clk;
	reg							reset_;
	reg [PORT-1:0]				en_;
	reg [PORT-1:0]				rw_;
	reg [PORT-1:0][ADDR-1:0]	addr;
	reg [PORT-1:0][DATA-1:0]	wdata;
	wire [PORT-1:0][DATA-1:0]	rdata;



	//***** dut
	ram #(
		.DATA	( DATA ),
		.DEPTH	( DEPTH ),
		.PORT	( PORT ),
		.OUTREG	( OUTREG )
	) ram (
		.*
	);




`ifdef VERILATOR
`else
	//***** clock generation
	always #(STEP/2) begin
		clk = ~clk;
	end



	//***** status monitor
	always @( posedge clk ) begin
		int i;
		foreach ( en_[i] ) begin
			if ( en_[i] == `Enable_ ) begin
				if ( rw_[i] == `Read ) begin
					`SetCharCyanBold
					$display("Port[%1d]: Read ram[%d]", i, addr[i]);
					`ResetCharSetting
					if ( OUTREG ) begin
						@( posedge clk );
					end
					$display("	data: 0x%x", rdata[i]);
				end else begin
					`SetCharGreenBold
					$display("Port[%1d]: Write ram[%d]", i, addr[i]);
					`ResetCharSetting
					$display("	data: 0x%x", wdata[i]);
				end
			end
		end
	end



	//***** test body
	initial begin
		clk = `Low;
		reset_ = `Enable_;
		en_ = {PORT{`Disable_}};
		rw_ = {PORT{`Read}};
		addr = 0;
		wdata = 0;

		#(STEP);
		reset_ = `Disable_;

		#(STEP);
		// write "deadbeef" to ram[0] from port0
		en_[0] = `Enable_;
		rw_[0] = `Write;
		addr[0] = 0;
		wdata[0] = 'hdaedbeef;

		#(STEP);
		en_[0] = `Disable_;

		#(STEP);
		// read ram[0] from port1
		en_[1] = `Enable_;
		rw_[1] = `Read;
		addr[0] = 0;

		#(STEP);
		en_[1] = `Disable_;

		#(STEP*5);

		$finish;
	end

	`include "waves.vh"

`endif

endmodule
