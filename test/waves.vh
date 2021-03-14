`ifdef WAVE_DUMP
	initial begin
 `ifdef CADENCE
		$shm_open();
		$shm_probe("ACFM");
 `elsif SYNOPSYS
		$fsdbDumpfile("waves.fsdb");
		$fsdbDumpvars(0);
 `elsif VCD
		$dumpfile("waves.vcd");
		$dumpvars(0);
 `endif
	end
`endif
