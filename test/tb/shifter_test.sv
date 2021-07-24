`include "stddef.vh"

module shifter_test;
	parameter STEP = 10;
	parameter BIT_VEC = `Disable;
	parameter ROTATE = `Enable;
	parameter TO_RIGHT = `Disable;
	parameter DATA = 8;
	parameter SHAMT = 3;
	parameter ACT = `High;

	reg [DATA-1:0]		in;
	reg [SHAMT-1:0]		shamt;
	wire [DATA-1:0]		out;

	shifter #(
		.BIT_VEC	( BIT_VEC ),
		.ROTATE		( ROTATE ),
		.TO_RIGHT	( TO_RIGHT ),
		.DATA		( DATA ),
		.SHAMT		( SHAMT ),
		.ACT		( ACT )
	) shifter (
		.in			( in ),
		.shamt		( shamt ),
		.out		( out )
	);

	integer i;
	initial begin
		in <= 8'b10011100;
		shamt <= {SHAMT{1'b0}};
		#(STEP*5);
		for ( i = 0; i < (1 << SHAMT); i = i + 1 ) begin
			shamt <= shamt + 1'b1;
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
