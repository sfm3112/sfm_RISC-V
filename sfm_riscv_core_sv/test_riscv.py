import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, Timer

@cocotb.test()
async def testA(dut):
    # control code goes here
    pass