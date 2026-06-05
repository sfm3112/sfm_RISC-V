# Weekly Summary: June 1-5, 2026
**Author:** Stephen Meyer  
**Project:** Custom 32-Bit RISC-V Core (RV32I Variant)

## Overview
Week 2 focused on executing the bottom-up implementation strategy established at the end of Week 1. Work rapidly progressed from standing up structural component footprints to writing internal execution logic, mapping internal wire networks, and successfully synthesizing the top-level datapath. With a verified datapath established in the RTL viewer, the project pivoted to implementing the Control Unit, resulting in microarchitectural timing optimizations that streamlined the execution.

## Architectural Decisions and Milestones
1. Datapath Logic Implementation and Synthesis
	* **Successful Datapath Synthesis:** Following six iterations of debugging syntax and structural discrepancies, the top-level datapath successfully synthesized in Quartus. RTL viewer analysis validated that the register file correctly generated arrays of D-flip-flops, the ALU mapped accurately, and the Program Counter accurately integrated its incrementing adder hardware
	* **Immediate Multiplexer Realignment:** Abandoned the plan to route the Immediate Processor outputs through a generic n-bit multiplexer module. Because a minimum of 4 bits is required to differentiate the five unique instruction formats, using the standard multi-input mux file was determined to be structurally inefficient. It was replaced with a case statement
	* **Hardcoded Register Zero Protection:** Finalized a 32-long writeback decoder case statement. To respect the RISC-V requirements that register x0 to remain hardcoded to 32'b0, the decoder was hard-wired to ensure a load enable signal can never be transmitted to the first register
2. Control Unit Architecture & Optimization
	* **The Inter-Edge Decoding Breakthrough (Eliminating MC1):** Achieved a major optimization by deviating from the academic baseline ASM chart. The original design utilized a dedicated machine cycle (MC1) exclusively for the Control Unit to decode the Instruction Word (IW). Because the program memory relies on local synchronous RAM with negligible propagation delay, moving the decoding logic to a combinational block outside the sequential state machine allows the IW to be parsed between rising clock edges. This safely trims an entire machine cycle off the instruction execution path
	
## Tooling, Environment, & Methodology Pivots
* **SystemVerilog Parameter and Array Governance:** Overcame strict syntax constraints regarding variable-width multi-input multiplexers and 2D routing matrices (logic [ROW][COLUMN]). Additionally, corrected a fundamental structural misunderstanding regarding compiler parameters. Explicitly defined default parameter fallbacks (WIDTH = 32) across all separate hardware files to satisfy independent module compilation requirements
* **RTL Viewer Resource Inspection:** Used the Quartus RTL Viewer to analyze post-synthesis hardware mapping. The tool revealed that Quartus interpreted the writeback decoder as a RAM block rather than pure combinational logic gates. While functionally viable, this is a clear target for future resource utilization optimization

## Current Project Status and Next Steps
The internal logic and wire routing for the datapath are fully realized and verified via synthesis. The structural skeleton of the Control Unit is established, OpCodes are mapped out using localized parameters, and machine cycles MC0 and MC1 are fully coded for Type L, JR, S, B, and I instructions.

For next week, the immediate focus will be finalizing the state machine paths for MC2 (specifically the conditional logic paths for branch evaluation), correctly mapping the placeholder writeback select variables to the multiplexer values, and launching full-core integration synthesis and verification.

## Note on Intended Timetables:
Last week it was stated that the current project scope should be satisfied in around three months. This assertion was made based on assumptions that the RISC-V would be substantially more complex and systemVerilog would be significantly more difficult to learn and use than it is turning out to be. Because of this, the project is significantly ahead of schedule by about two weeks. If debugging and testing goes better than expected, the project's current scope could be completed at least a month ahead of schedule. Therefore, a broadening of the scope should be more seriously considered. The idea from last week of adding a UART hardware module is now very likely to happen. It is unlikely the project's current goals will be achieved by the end of next week, but the UART idea should be reexplored in the week 3 summary.