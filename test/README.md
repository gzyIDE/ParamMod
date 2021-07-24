# How to run a simulation
1. Check directory_setup.sh and configure directory appropriately.
2. Set top-level module name as DEFAULT_DESIGN in target.sh.  
Note that file names for top-level designs should be ${DEFAULT_DESIGN}.sv  
Top-level module can be also set with an argument for testvec.sh.  
3. Add new case statement corresponding to the top-level module and set dependent files in module.sh.  
At least, you need to set TEST_FILE and append top-level module file to RTL_FILE.
4. Select a simulation tool in sim_tool.sh.  
xmverilog, vcs, verilator, iverilog (sv2v required) and vivado simulator are supported.
5. run testvec.sh
6. (optional) Use wave viewer for your simulation environment for debug.  
For vivado simulator, a vivado project is created in ./xilinx directory
on every simulation, and following scripts open the project.
  - xwaves.sh :  
	This script only opens waveform database (wdb).
  - xdebug.sh :
    This script opens the vivado project and allow you to view waveform,
	edit source codes, run simulation and even synthesize your design.

# Some utilities for simulation
* include/sim.vh :  
  Some utilities for simulators
* include/waves.vh :  
  Wave dump options for RTL/Netlist Simulations  
  Include this file somewhere in test bench modules.  
