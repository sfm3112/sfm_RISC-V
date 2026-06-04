# Custom RV32I RISC-V Processor

A custom multi-cycle RV32I-compatible processor written in SystemVerilog for FPGA implementation.

## Current Status

**In Development**

Completed:

* Datapath architecture and schematic
* Register file design
* ALU design
* Immediate generation unit
* Memory interface
* Writeback logic
* ASM chart
* Control State Table (CST)

In Progress:

* Control unit implementation
* Datapath wiring and integration
* Debugging and optimization

Planned:

* Functional verification
* FPGA synthesis and testing
* Performance benchmarking

## Architecture

The processor implements a simplified multi-cycle RV32I architecture.

Key features:

* 32-bit instruction word format
* 32 general-purpose registers (x0-x31)
* Multi-cycle execution model
* Hybrid Harvard/Von Neumann memory organization
* Separate instruction fetch and data access ports
* SystemVerilog RTL implementation
* Downloadable QAR file will be generated once RISC-V is operational

## Repository Structure

Quartus Project

* [RISC-V SystemVerilog](/sfm_riscv_core_sv)

Design Docs

* [Design documentation](/Design_Docs)

Logs and Notes

* [Daily Logs](/Daily_Logs)
* [Weekly Summaries](/Weekly_Summaries)

## Supported Instructions

Target ISA: RV32I

Instruction support is currently under implementation.

## Project Goals

The objective of this project is to design, implement, verify, and deploy a functioning RV32I processor on FPGA hardware while gaining experience with CPU microarchitecture, RTL design, verification, and digital system integration.


