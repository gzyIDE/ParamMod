`include "parammod_stddef.vh"

//`define BITMAP

`ifdef GATE_SIM
 `timescale 1ns/10ps
`endif

module selector_test;
	parameter STEP = 10;
	parameter DATA = 32;
	parameter IN = 4;
	parameter ACT = `HIGH;
	parameter MSB = `ENABLE;
`ifdef BITMAP
	parameter SEL_WIDTH = IN;
	parameter BIT_MAP = `ENABLE;
`else
	parameter SEL_WIDTH = $clog2(IN);
	parameter BIT_MAP = `DISABLE;
`endif

	reg [DATA*IN-1:0]		in;
	reg [SEL_WIDTH-1:0]		sel;
	wire					valid;
	wire [IN-1:0]			pos;
	wire [DATA-1:0]			out;

`ifdef GATE_SIM
	selector selector (
`else
	selector #(
		.DATA		( DATA ),
		.IN			( IN ),
		.SEL_WIDTH	( SEL_WIDTH ),
		.BIT_MAP	( BIT_MAP ),
		.ACT		( ACT ),
		.MSB		( MSB )
	) selector (
`endif
		.in			( in ),
		.sel		( sel ),
		.valid		( valid ),
		.pos		( pos ),
		.out		( out )
	);

	integer i;
	initial begin
		in <= {DATA*IN{1'b0}};
		sel <= {SEL_WIDTH{1'b0}};
		#(STEP)
		for ( i = 0; i < IN; i = i + 1 ) begin
			in[DATA*i +: DATA] = i+1;
		end
`ifdef BITMAP
		// one bit
		sel <= 4'b0001;
		#(STEP)
		sel <= 4'b0010;
		#(STEP)
		sel <= 4'b0100;
		#(STEP)
		sel <= 4'b1000;
		#(STEP)
		// two bit
		sel <= 4'b0011;
		#(STEP)
		sel <= 4'b0101;
		#(STEP)
		sel <= 4'b1001;
		#(STEP)
		sel <= 4'b0110;
		#(STEP)
		sel <= 4'b1010;
		#(STEP)
		sel <= 4'b1100;
		// three bit
		#(STEP)
		sel <= 4'b0111;
		#(STEP)
		sel <= 4'b1011;
		#(STEP)
		sel <= 4'b1101;
		#(STEP)
		sel <= 4'b1110;
		#(STEP)
		// four bit
		sel <= 4'b1111;
		#(STEP)
		// 8 bit
		sel <= 32'b0000_0110_1000_1000_0010_1000_0001_1000;
		// 10 bit ( excessive )
		// select of bit 30 and 29 must be ignored
		sel <= 32'b0110_0110_1000_1000_0010_1000_0001_1000;
`else
		sel <= 2'd0;
		#(STEP)
		sel <= 2'd1;
		#(STEP)
		sel <= 2'd2;
		#(STEP)
		sel <= 2'd3;
`endif
		#(STEP)
		$finish;
	end

	`include "waves.vh"

endmodule
