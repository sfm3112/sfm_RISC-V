#################################################
#     Created by: Stephen Meyer (6/12/2026)     #
#           RISC-V cocotb Test Bench            #
#       Copyright (C) 2026 Stephen Meyer        #
#################################################

import cocotb
import re
from cocotb.clock import Clock
from cocotb.triggers import Edge, FallingEdge, RisingEdge, ClockCycles, Timer
from cocotb.utils import get_sim_time

#===============================================#
#    Any input from the dut passes through to   #
#      verify it is a valid binary number.      #
#        Also handles undefined inputs.         #
#===============================================#
def safe_format(signal, as_hex=False):
	raw_str = str(signal.value).lower()
	if any(char in raw_str for char in ['x', 'z', 'u']):
		return "0xXXXX" if as_hex else "XXXX"
	val = int(signal.value)
	return f"0x{val:X}" if as_hex else val

#===============================================#
#           Signal Watcher Functions            #
#===============================================#
async def waitForSignalLDrd(dut):
	while int(dut.DataPath.LDrd.value) == 0:
		await RisingEdge(dut.clk)
	await FallingEdge(dut.clk)

async def waitForSignalMC1(dut):
	while int(dut.ControlUnit.MC.value) == 01:
		await RisingEdge(dut.clk)
	await FallingEdge(dut.clk)

async def waitForSignalLdPC(dut):
	while int(dut.DataPath.LdPC.value) == 0:
		await RisingEdge(dut.clk)
	await FallingEdge(dut.clk)

async def waitForSignalLdMax(dut):
	while int(dut.ControlUnit.LdMax.value) == 0:
		await RisingEdge(dut.clk)
	await FallingEdge(dut.clk)

#===============================================#
#                   DUT Tests                   #
#===============================================#

@cocotb.test()
async def testA(dut):
	
	#===============================================#
	#                  Clock Start                  #
	#===============================================#
	
	clock = Clock(dut.clk, 10, unit="ns")
	cocotb.start_soon(clock.start())
	
	#===============================================#
	#           2 Clock Cycle Reset state           #
	#===============================================#
	
	dut.rst.value = 1
	await ClockCycles(dut.clk, 2)
	dut.rst.value = 0
	await RisingEdge(dut.clk)
	
	#===============================================#
	#  Read the ASM file and make expected outputs  #
	#===============================================#
	
	goodOutput = []
	
	with open("testSuite.s", "r") as asm:
		for line in asm:
			match = re.search(r"#\s*x(\d+)\s*=\s*(0x[0-9a-fA-F]+|-?\d+)", line)
			if match:
				regNum = int(match.group(1))
				
				rawVal = match.group(2)
				
				val = int(rawVal, 16) if "0x" in rawVal.lower() else int(rawVal)
				
				if val < 0:
					
					val = (1 << 32) + val
					
				goodOutput.append((regNum, val, line.strip()))
				
	#===============================================#
	#                Test Test Bench                #
	#===============================================#
	errors_found = 0
	
	dut._log.info(f"Found {len(goodOutput)} assembly operations to run")
	
	with open("riscv_debug_tb.txt", "w") as riscvTb:
		riscvTb.write("### RISC-V Test Bench Debug Log ###\n\n")
		
		#===============================================#
		#    Independent Sequential Instruction Test    #
		#===============================================#
		
		for regNum, expectedVal, originalLine in goodOutput:
			
			await waitForSignalMC1(dut)
			InstWordTb = safe_format(dut.DataPath.IWRreg.Q, as_hex=True)
			aluTb = safe_format(dut.DataPath.ArithmeticLogicUnit.ALUres, as_hex=True)
			wbMuxTb = safe_format(dut.DataPath.WBmux.out, as_hex=True)
			wbMuxSelTb = safe_format(dut.DataPath.WBmux.Sel)
			await waitForSignalLDrd(dut)
			wbDecoderSel = safe_format(dut.DataPath.WriteBackDecoder.DECsel)
			actualValRaw = safe_format(dut.DataPath.register_stage[regNum].NbitRegister.Q)
			
			
			riscvTb.write(f"Current assembly instruction is: {originalLine}\n")
			riscvTb.write(f"Instruction Word: {InstWordTb}\n")
			riscvTb.write(f"ALU result: {aluTb}\n")
			riscvTb.write(f"Write Back Mux Select: {wbMuxSelTb}\n")
			riscvTb.write(f"Write Back Mux output: {wbMuxTb}\n")
			riscvTb.write(f"Register Load Decoder select: {wbDecoderSel}\n")
			riscvTb.write(f"EXPECTED RESULT: x{regNum} = {expectedVal} ({expectedVal})\n")
			
			if actualValRaw == "XXXX":
				riscvTb.write(f"ACTUAL RESULT: x{regNum} = 0xXXXX (XXXX)\n\n")
				dut._log.error(f"Fail on instruction: {originalLine} -> Got uninitialized value (XXXX)")
				errors_found += 1
			else:
				actualVal = int(actualValRaw)
				riscvTb.write(f"ACTUAL RESULT: x{regNum} = {hex(actualVal)} ({actualVal})\n\n")
				
				
				if actualVal != expectedVal:
					dut._log.error(f"Fail on instruction: {originalLine} -> Expected {hex(expectedVal)}, Got {hex(actualVal)}")
					errors_found += 1
				else:
					dut._log.info(f"Instruction passed: {originalLine}")
		
		#===============================================#
		#         Branch Loop Instruction Test          #
		#===============================================#
		
		dut._log.info("Testing branch loop.")
		riscvTb.write("\n\n### RISC-V Test Bench Branch Loop Debug Log ###\n\n")
		
		
pass
