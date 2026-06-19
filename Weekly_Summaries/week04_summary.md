# Weekly Summary: June 14-19, 2026
**Author:** Stephen Meyer  
**Project:** Custom 32-Bit RISC-V Core (RV32I Variant)

## Overview
Week 4 pivoted from working on the hardware design of the risc-v to setting up and configuring the testbench. Unlike traditional testbenches, which are HDL descriptions run in ModelSim, the approach taken here is a python testbench which plugs into modelsim, which has the potential to be much more versatile than a typical HDL testbench. There was a notable learning curve in writing all of the necessary files, and configuring the toolchain to properly communicate with the project and the modelsim executable. The week ended with cocotb being able to successfully read the python testbench, configured by the readme file, and seemingly successfully interacting with the project files.

## Architectural Decisions and Milestones
1. Automated Testbench Framework
* Developed a python based testbench script utilizing Cocotb coroutines to automatically evaluate the processor's device under test (the risc-v) against good expected values
* Implemented an automated parsing mechanism to scan through the assembly (.s) file, identifying formatted comments describing the result of the operation and the register storing the result, and dynamically formats them to serve as verification metrics
2. Design Flow Debugging
* Integrated a command line XML parsing script to extract the specific failure messages from results.xml
* Refined the python testbench syntax to successfully read project files

## Environment, & Methodology Pivots
1. Pivoted to MSYS2 MINGW32 which supports 32-bit architecture of ModelSim, unlike MSYS2 UCRT64 which is explicitly 64 bit
2. Installed make utility using MSYS2 Linux compatible packages and appended the path to the windows system environment so the terminal can correctly path
3. Established a virtual environment inside MINGW32 containing cocotb and the make setup keeping everything isolated and organized

## Current Project Status and Next Steps
The testbench verification setup is now largely functional and outputting valid error outputs. Next week will consist of utilizing and expanding the script to give more comprehensive feedback about where signals are getting lost.

Last week, it was noted that the risc-v project is well ahead of schedule. The implementation of a completely new testbench verification setup has slowed this accelerated progress significantly. Nonetheless, The original goals of the project are still expected to be met well ahead of the original three month schedule. Therefore, the current blueprint for scope expansion is as follows:
1. Implement multiplication hardware for the RISC-V multiplication instruction set expansion
2. Implement external communication via integrated UART encoding and decoding

A note on this, these are tentative goals which are not guaranteed to be met. The goals of top priority are those associated with the baseline ISA excluding FENCE, ECALL, and EBREAK.
