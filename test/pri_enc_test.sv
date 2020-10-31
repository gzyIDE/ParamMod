/*
* <pri_enc_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module pri_enc_test;
	parameter STEP = 10;
	parameter IN = 16;
	parameter OUT = $clog2(IN);
	parameter ACT = `High;

	reg [IN-1:0]		in;
	wire				valid;
	wire [OUT-1:0]		out;

	pri_enc #(
		.IN		( IN ),
		.OUT	( OUT ),
		.ACT	( ACT )
	) pri_enc (
		.in		( in ),
		.valid	( valid ),
		.out	( out )
	);

	integer i;
	initial begin
		in <= {IN{1'b0}};
		#(STEP*5);
		for ( i = 0; i < IN; i = i + 1 ) begin
			in <= ( 1 << i );
			#(STEP);
		end

		#(STEP*10);

		in = 0;
		for ( i = 0; i < (1<<IN); i = i + 1 ) begin
			in <= in + 1'b1;
			#(STEP);
		end
		#(STEP*5);
		$finish;
	end

`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("AC");
	end
`endif

endmodule
