# Weekly Summary: June 8-12, 2026
**Author:** Stephen Meyer  
**Project:** Custom 32-Bit RISC-V Core (RV32I Variant)

## Overview
Week 3 was characterized by a transition from independent module architecture to full-core integration, resulting in the successful behavioral synthesis of the Control Unit (CU). Significant structural alterations were executed to achieve true byte-addressable memory compatibility with the official RV32I ISA. Finally, the project established a modern verification pipeline, bypassing legacy modelSim methodologies in favor of a Python-based co-simulation environment.

## Architectural Decisions and Milestones
1. Full-Core Synthesis & ALU Optimization
	* The FSM and machine-cycle routing tables were completed. Unlike the structural datapath, the CU was compiled using behavioral SystemVerilog, allowing Quartus to generate highly optimized, non-intuitive gate logic that minimized resource usage
	* Discovered a critical flaw in the ALU where the instruction word bit IW[30] uniformly forced a subtraction. This broke immediate operations (which must always add) and branch conditions (which must always subtract). By mapping a Karnaugh map from OpCode[6:5] and Func7[5], a unified combinational hardware expression was derived: add_sub = OpCode[6] + (Func7[5]•OpCode[5]). This correctly routes add/sub flags and isolates a 33-bit internal bus (FaddSubRes) to safely calculate carry and negative flags (CNZres) 
2. Transition to Byte-Addressable Memory Architecture
	* Reconfigured the Program Counter to increment by 4 instead of 1 to achieve true native alignment. The upper bits PCout[13:2] are routed to the synchronous block RAM to correctly drop the 2 least significant bits (LSBs)
	* Replaced the legacy LDmux with a nested case-statement block driven by funct3 and the 2 LSBs of MARout. This serves as the dynamic routing matrix for byte (sb/lb), half-word (sh/lh), and word (sw/lw) boundaries, explicitly forcing a 0000 write-mask on unaligned half-word transactions to guarantee fault tolerance
	
## Tooling, Environment, & Methodology Pivots
* Successfully established a modern verification environment within an MSYS2 virtual environment (v_env). Integrated Cocotb (Coroutine-based Cosimulation Testbench) and pytest via a custom Makefile to bridge Python test scripts directly to ModelSim (vsim) over a Simulator Execution Interface
* Installed the bronzebeard assembler package into the development environment. Built a command-line pipeline to compile native assembly (.s) directly into raw binary (.bin)

## Current Project Status and Next Steps
The complete microarchitecture is structurally complete and fully synthesized without critical errors or compilation warnings. A comprehensive RV32I verification routine containing all core R-type operations, select I-type instructions, and a conditional loop profile has been authored and assembled.

For next week, the immediate priority is writing the Python-based driver logic to run the compiled test suite through the Cocotb simulator. Subsequent milestones are entirely contingent on the velocity of this verification phase. If bugs are minimal, the architecture will expand inward to support the M-extension (Hardware Multiplier) rather than moving immediately to external UART peripherals, keeping the near-term focus centered on the core CPU microarchitecture.

