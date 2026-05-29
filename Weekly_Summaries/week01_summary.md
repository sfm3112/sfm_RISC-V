# Weekly Summary: May 25-29, 2026
**Author:** Stephen Meyer  
**Project:** Custom 32-Bit RISC-V Core (RV32I Variant)

## Overview
Week 1 began with defining the RV32I instruction set, mapping out the operations, and understanding their functions. This led to designing the datapath, taking heavy inspiration from the Digital Systems II simplified RISC processing unit. After wrapping up the first iteration of the datapath, the ASM and CST were mapped out. After design checks which caught numerous logic flaws, the Quartus systemVerilog project was established.

## Architectural Decisions and Milestones
1. Scope and Memory Configuration
* **Uniform 32-Bit ISA:** Opted to stick to the standard 32-bit instruction length, foregoing RV32C compatibility to prioritize functionality and save design overhead
* **Hybrid Dual-Port Memory:** Settled on a dual-ported memory scheme that stores code and data in a single address space but allows simultaneous single cycle instruction fetches and data lookups without memory conflicts
	- Memory system is a Harvard Von-Neumann hybrid which enables potential future optimizations and pipelining
2. Microarchitecture Optimization and Timing Corrections
* **Hardware Efficiency Shortcuts:** Used specific bits embedded within the native RISC-V instruction word to directly control datapath multilplexers cutting down on unnecessary control unit decoding logic
* **The Mixed-Cycle Breakthrough:** Discovered a critical sequential hazard involving synchronous block RAM and register file reads. Refactored the entire ASM chart from a uniform 3-cycle model to a mixed 3/4-cycle flow, granting memory load instructions an extra machine cycle to let data propagate and settle safely.
* **Control State Table (CST) Completion:** Finalized the comprehensive state decoder table for all machine cycles (MC0 through MC3), catching and resolving an error regarding accidental memory-write permissions during the instruction fetch stage.

## Tooling, Environment, & Methodology Pivots
* **Clean Repository Architecture:** Created the Primary Quartus Prime SystemVerilog workspace and established a .gitignore to protect the repository from overwhelming support files
* **Bottom Up Pivot:** Recognized that attempting to map out top level control unit and datapath interconnects before writing the internal logic was error prone, intentionally shifted to a bottom up coding strategy:
	1. Instantiate empty component shells (ALU, Registers, Multiplexers) to define clear physical inputs and outputs
	2. Wire them backward into the higher-level datapath file
	3. Fill out the operational internal logic
	4. Implement overarching control unit last
	
## Current Project Status and Next Steps
The project design is largely completed, and component instantiation shells are partially mapped to the top level datapath module.

For next week, the immediate focus will be wrapping up the structural component footprints in the datapath file, routing local inputs and outputs, and beginning the implementation of explicit internal hardware logic block by block.

## Note on Intended Timetables:
This project is intended to take approximately three months. Debugging, testing, and benchmarking is intended to take up somewhere between 1/3 to 2/3 of the total time. Therefore, the goal is to have the RISC-V systemVerilog largely completed by the end of June. If a viable RISC-V is completed ahead of schedule, a decision will be made to either add FENCE, ECALL, and EBREAK compatibility, or a UART interface module.