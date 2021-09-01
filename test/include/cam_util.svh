/*
* <cam_util.svh>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

/***** write *****/
task set_write;
	input integer		idx;
	input [DATA-1:0]	mask;
	input [DATA-1:0]	data;
	input [ADDR-1:0]	addr;
	begin
		we_[idx] = `Enable_;
		wm[idx] = mask;
		wd[idx] = data;
		waddr[idx] = addr;
	end
endtask

task reset_write;
	begin
		we_ = {WRITE{`Disable_}};
		wm = {DATA*WRITE{1'b0}};
		wd = {DATA*WRITE{1'b0}};
		waddr = {ADDR*WRITE{1'b0}};
	end
endtask



/***** read *****/
task set_read;
	input integer		idx;
	input [DATA-1:0]	mask;
	input [DATA-1:0]	data;
	begin
		re_[idx] = `Enable_;
		rm[idx] = mask;
		rd[idx] = data;
	end
endtask

task reset_read;
	begin
		re_ = {READ{`Disable_}};
		rm = {DATA*READ{1'b0}};
		rd = {DATA*READ{1'b0}};
	end
endtask

/***** monitor status *****/
integer mi;
always @( posedge clk ) begin
	/* write check */
	for ( mi = 0; mi < WRITE; mi = mi + 1 ) begin
		if ( !we_[mi] ) begin
			$display("write[%d] : addr = %d, data = %x",
				mi, waddr[mi], wd[mi]);
		end
	end
	/* read check */
	for ( mi = 0; mi < READ; mi = mi + 1 ) begin
		if ( !re_[mi] ) begin
			if ( match[mi] ) begin
				$display("read[%d] : addr = %d, data = %x",
					mi, raddr[mi], rd[mi]);
			end else begin
				$display("read data[%x] not found", rd[mi]);
			end
		end
	end
end
