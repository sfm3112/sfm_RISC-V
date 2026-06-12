#################################################
#     Created by: Stephen Meyer (6/12/2026)     #
#	        RISC-V cocotb Test Bench            #
#	    Copyright (C) 2026 Stephen Meyer        #
#################################################

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, Timer

@cocotb.test()
async def testA(dut):
    clock = Clock(dut.clk, 10, units="ns")  #creates the clock cycle
    cocotb.start_soon(clock.start())        #tells program to begin pulsing clock cycle, .start_soon tells it to run in the background

    dut.rst.value = 1
    await ClockCycles(dut.clk, 2)  # reset for 2 clock cycles
    dut.rst.value = 0
    await RisingEdge(dut.clk)      # ensure its back in sync with clock cycle (since rst is an async signal)
    
    
    
    
    pass