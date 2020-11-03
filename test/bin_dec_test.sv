/*
* <bin_dec_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "sim.vh"

`ifdef GATE_SIM
 `timescale 1ns/10ps
`endif

module bin_dec_test;
	parameter STEP = 10;
	parameter IN = 3;
	parameter OUT = 1 << IN;
	parameter ACT = `High;

	logic [IN-1:0]		in;
	logic [OUT-1:0]		out;

`ifdef NETLIST
	bin_dec bin_dec (
`else
	bin_dec #(
		.IN		( IN ),
		.ACT	( ACT )
	) bin_dec (
`endif
		.in		( in ),
		.out	( out )
	);

	//***** Simulation Body
	int i;
	initial begin
		in = 0;
		#(STEP);
		for ( i = 0; i < 1 << IN; i = i + 1 ) begin
			if ( out[i] != ACT ) begin
				`SetCharBold
				`SetCharRed
				$display("Check Failed: acquired %x", out);
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharCyan
				$display("Check Success: acquired %x", out);
				`ResetCharSetting
			end
			in = in + 1;
			#(STEP);
		end
	end


	initial begin
`ifdef SimVision
		$shm_open();
		$shm_probe("AC");
`endif
	end

endmodule
