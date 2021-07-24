`include "stddef.vh"

`ifdef GATE_SIM
 `timescale 1ns/10ps
`endif

module regfile_test;
	parameter STEP = 100;
	parameter DATA = 32;
	parameter DEPTH = 32;
	parameter ADDR = $clog2(DEPTH);
	parameter READ = 4;
	parameter WRITE = 4;
	parameter ZERO_REG = `Enable;
	localparam RNUM = $clog2(READ) + 1;
	localparam WNUM = $clog2(WRITE) + 1;

	reg						clk;
	reg						reset_;
	reg [ADDR*READ-1:0]		raddr;
	wire [DATA*READ-1:0]	rdata;
	reg [WRITE-1:0]			we_;
	reg [DATA*WRITE-1:0]	in;
	reg [ADDR*WRITE-1:0]	waddr;

	always #(STEP/2) begin
		clk <= ~clk;
	end

	regfile #(
		.DATA		( DATA ),
		.ADDR		( ADDR ),
		.READ		( READ ),
		.WRITE		( WRITE ),
		.ZERO_REG	( ZERO_REG )
	) rf (
		.clk		( clk ),
		.reset_		( reset_ ),
		.raddr		( raddr ),
		.waddr		( waddr ),
		.we_		( we_ ),
		.wdata		( in ),
		.rdata		( rdata )
	);

	task reg_clear;
		begin
			raddr	= {ADDR*READ{1'b0}};
			we_	= {WRITE{1'b1}};
			in		= {DATA*WRITE{1'b0}};
			waddr	= {ADDR*WRITE{1'b0}};
		end
	endtask

	// fetch data set
	task f_set;
		input [RNUM-1:0]	pos;
		input [ADDR-1:0]	addr;
		begin
			raddr[pos*ADDR +: ADDR] = addr;
		end
	endtask

	// backend data set
	task b_set;
		input [WNUM-1:0]	pos;
		input [ADDR-1:0]	addr;
		input [DATA-1:0]	data;
		begin
			waddr[pos*ADDR +: ADDR] = addr;
			in[pos*DATA +: DATA] = data;
		end
	endtask

	task b_write;
		input [WRITE-1:0]	we_pattern_;
		begin
			we_ = we_pattern_;
			#(STEP)
			we_ = {WRITE{`Disable_}};
		end
	endtask

	task dump_register;
		integer i;
		begin
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				$display("reg[%d] : %x", i, rf.regs[i]);
			end
		end
	endtask

	initial begin
		clk	<= `Low;
		reset_ <= `Enable_;
		reg_clear;
		#(STEP)
		reset_ <= `Disable_;
		#(STEP)
		// Read/Write check
		b_set(0, 31, 31); 
		b_set(1, 1, 1);
		b_set(2, 2, 2);
		b_set(3, 3, 3);
		b_write(4'b0000);
		#(STEP)
		// check zero is not changed
		b_set(0,0, 32'hdeadbeef);
		b_write(4'b1110);
		#(STEP)
		// read zero register
		f_set(0, 0);
		#(STEP)
		// register read
		f_set(0, 2);
		f_set(1, 3);
		f_set(2, 1);
		f_set(3, 31);
		// Read/Write check
		b_set(0, 31, 31); 
		b_set(1, 4, 32'h10);
		b_set(2, 5, 32'h20);
		b_set(3, 6, 32'h30);
		b_write(4'b0000);
		#(STEP)
		dump_register;
		$finish;
	end
	
`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("ACM");
	end
`endif
endmodule
