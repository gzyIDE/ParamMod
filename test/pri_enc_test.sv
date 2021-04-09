/*
* <pri_enc_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "sim.vh"

`ifdef NETLIST
 `timescale 10ps/1ps
`endif

module pri_enc_test;
	parameter STEP = 10;
	parameter IN = 8;
	parameter OUT = $clog2(IN);
	parameter ACT = `Low;

	reg [IN-1:0]		in;
	reg					valid_ans;
	reg [OUT-1:0]		out_ans;
	wire				valid;
	wire [OUT-1:0]		out;

`ifdef NETLIST
	pri_enc pri_enc (
`else
	pri_enc #(
		.IN		( IN ),
		.OUT	( OUT ),
		.ACT	( ACT )
	) pri_enc (
`endif
		.in		( in ),
		.valid	( valid ),
		.out	( out )
	);

	function [(OUT+1)-1:0] gen_answer;
		input [IN-1:0]		in;
		reg [OUT-1:0]		out;
		reg					valid;
		longint			i;
		begin
			out = {OUT{1'b0}};
			valid = !ACT;
			for ( i = 0; i < IN; i = i + 1 ) begin
				if ( in[i] == ACT ) begin
					valid = ACT;
					out = i;
				end
			end
			gen_answer = {valid, out};
		end
	endfunction

	longint i;
	initial begin
		if ( ACT ) begin
			// Acitve High
			in = {IN{1'b0}};
			#(STEP*5);
			for ( i = 0; i < IN; i = i + 1 ) begin
				in = ( 1 << i );
				{valid_ans, out_ans} = gen_answer(in);
				#(STEP);
				assert ( (out_ans == out) && (valid_ans == valid) ) begin
					`SetCharBold
					`SetCharCyan
					$display("Check Success: acquired %x", out);
					`ResetCharSetting
				end else begin
					`SetCharBold
					`SetCharRed
					$display("Check Failed: expected %x, acquired %x", 
						out_ans, out);
					`ResetCharSetting
				end
			end
		end else begin
			// Acitve Low
			in = {IN{1'b1}};
			#(STEP*5);
			for ( i = 0; i < IN; i = i + 1 ) begin
				in = {IN{1'b1}} ^ ( 1 << i );
				{valid_ans, out_ans} = gen_answer(in);
				#(STEP);
				assert ( (out_ans == out) && (valid_ans == valid) ) begin
					`SetCharBold
					`SetCharCyan
					$display("Check Success: acquired %x", out);
					`ResetCharSetting
				end else begin
					`SetCharBold
					`SetCharRed
					$display("Check Failed: expected %x, acquired %x", 
						out_ans, out);
					`ResetCharSetting
				end
			end
		end

		// check all
		#(STEP*10);
		in = 0;
		for ( i = 0; i < (1<<IN); i = i + 1 ) begin
		//	$display("Checking %d", i);
			in = in + 1'b1;
			{valid_ans, out_ans} = gen_answer(in);
			#(STEP);
			if ( (out_ans != out) || (valid_ans != valid) ) begin
				`SetCharBold
				`SetCharRed
				$display("Check Failed: expected %x, acquired %x", 
					out_ans, out);
				`ResetCharSetting
			end
		end

		#(STEP*5);
		$finish;
	end

	`include "waves.vh"

endmodule
