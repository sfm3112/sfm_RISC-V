# Custom 5-Stage Pipelined RV32I RISC-V Processor Core

A synthesized, 5-stage pipelined 32-bit RISC-V (RV32I) processor core written in SystemVerilog, featured with hardware forwarding, load-use hazard detection, branch flushing, and target FPGA synthesis metrics.

**Author:** Stephen Meyer  
**Contact:** [sfm3112@rit.edu](mailto:sfm3112@rit.edu) | [LinkedIn](https://linkedin.com/in/stephenmeyer-ee)  
**GitHub:** [github.com/sfm3112](https://github.com/sfm3112)

---

## Technical Overview

This project implements a fully functional 5-stage pipelined RV32I RISC-V CPU core designed for FPGA targets. The architecture features hardware-level hazard mitigation, self-checking verification testbenches, and physical synthesis validation on an Intel Cyclone IV E FPGA.

### Key Architectural Features
* **Pipeline Architecture:** 5-stage execution pipeline (**IF**, **ID**, **EX**, **MEM**, **WB**).
* **Data Forwarding Unit:** Full `EX/MEM` and `MEM/WB` hazard forwarding to eliminate pipeline stalls on register-dependent instructions.
* **Hazard Detection & Control:** Automatic load-use hazard stalling (IF/ID stall + NOP insertion) and speculative branch/jump flushing at the `MEM` stage.
* **Instruction Set:** Supports standard RV32I base integer instructions (R-type, I-type, S-type, B-type, U-type, J-type).
* **Hardware Verification:** Automated self-checking assembly test suites paired with ModelSim waveform debugging.

---

## Hardware Performance & Synthesis Results

Synthesized and validated using **Intel Quartus Prime** targeting an **Altera Cyclone IV E FPGA** (`EP4CE115F29C7`).

| Metric | Measurement / Specification |
| :--- | :--- |
| **Max Clock Frequency ($F_{max}$)** | **67.7 MHz** (Slow 1200mV 85C Model) |
| **Logic Utilization** | ~4,900 Logic Cells (~4.3% of Cyclone IV E) |
| **Block Memory Bits** | Utilizing internal M9K RAM blocks for Data/Instruction memory |
| **Execution Performance** | **~3x Cycle-Count Reduction** vs. baseline sequential CPU architecture |

> **Timing Note:** Timing closure is currently bounded by the MEM-to-EX load-use data path through the M9K memory blocks and ALU control MUXes (~14.1 ns propagation delay).

---

## Repository Structure

Quartus Project

* [RISC-V SystemVerilog](/sfm_riscv_core_sv)

Design Docs

* [Design documentation](/Design_Docs)

Weekly Summaries

* [Weekly Summaries](/Weekly_Summaries)

## Supported Instructions

Target ISA: RV32I

Instruction support is currently under implementation.

## Project Goals

The objective of this project is to design, implement, verify, and deploy a functioning RV32I processor on FPGA hardware while gaining experience with CPU microarchitecture, RTL design, verification, and digital system integration.


