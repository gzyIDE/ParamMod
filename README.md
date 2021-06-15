# ParamMod
Parameterized and synthesizable modules written in SystemVerilog 
for FPGA/ASIC digital circuit designs.  
TODO: I will provide details of modules later, including supporting 
simulation/synthesis environments, synthesis scripts,
and performance in some example configurations.

# Directory Structure
- rtl: Synthesizable Verilog (SystemVerilog) Modules
- include: Verilog (SystemVerilog) Include Files
- test: Test Vectors
- syn: Synthesis Scripts

# Module Descriptions
## Binary Decoder (bin_dec.sv)
### Module Description
Set/Clear one bit designated by input.
Example) when "2'b10" is input, bin_dec.sv outputs "4'b0100".
### Parameter

## Bit counter (cnt_bits.sv)
### Module Description
Count Set/Cleared bits in input bit patterns.
Example) when "4'b0111" is input, cnt_bits.sv outputs "3'b011".
### Parameter

## Flip-Flop based Content Addressable Memory (cam.sv, cam2.sv)
### Module Description
### Parameter

## First-in First-out (FIFO) Buffer (fifo.sv)
### Module Description
### Parameter

## Free-List (freelist.sv)

## Priority Encoder (pri_enc.sv)
### Module Description
### Parameter

## Element-wise Reduction (reduct.sv)
### Module Description
### Parameter

## Register File (regfile.sv)
### Module Description
### Parameter

## Ring Buffer (ring_buf.sv)
### Module Description
### Parameter

## Minimum/Maximum Value Selector (sel_minmax.sv)
### Module Description
### Parameter

## N:1 Selector (selector.sv)
### Module Description
### Parameter

## Stack (stack.sv)
### Module Description
### Parameter
