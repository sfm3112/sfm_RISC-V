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

# Function to check for MC0 #

async def waitForNextIW(dut):
	if int(dut.ControlUnit.MC.value) == 0:
		while int(dut.ControlUnit.MC.value) == 0:
			await RisingEdge(dut.clk)
			
	while int(dut.ControlUnit.MC.value) != 0:
		await RisingEdge(dut.clk)
	await FallingEdge(dut.clk)

@cocotb.test()
async def testA(dut):
	
	# Initial setup lines #
	
	clock = Clock(dut.clk, 10, unit="ns")	#creates the clock cycle
	cocotb.start_soon(clock.start())		#tells program to begin pulsing clock cycle, .start_soon tells it to run in the background
	
	dut.rst.value = 1
	await ClockCycles(dut.clk, 2)	# reset for 2 clock cycles
	dut.rst.value = 0
	await RisingEdge(dut.clk)	# ensure its back in sync with clock cycle (since rst is an async signal)
	
	# Dynamic TestBench #
	
	# Read the .s assembly file #
	
	goodOutput = []	# Creates the variable to store the good expected outputs for the test bench
	
	with open("testSuite.s", "r") as asm:	# Reads the assembly file and creates a reference to it called "asm"
		for line in asm:	# For loop
			match = re.search(r"#\s*x(\d+)\s*=\s*(0x[0-9a-fA-F]+|-?\d+)", line)	# extracts the register result comment and assigns it to match (check log for specific syntax)
			if match:
				regNum = int(match.group(1))	# puts the register number in regNum secured from the re.search()
				rawVal = match.group(2)			# puts the raw value into rawVal, cannot be an int yet because it could also be a hex value
				
				val = int(rawVal, 16) if "0x" in rawVal.lower() else int(rawVal)	# if hex (0x), chenge the base to 16 instead of base 10, else just use base 10
				
				if val < 0:		# Python can't compare a negative decimal to a negative binary 2'sC
					val = (1 << 32) + val	# rotates the 1 to the maximum negative binary value, interpreted as very large decimal value, subtract the register value
					
				goodOutput.append((regNum, val, line.strip()))	# sticks on the end of goodOutput the register number, the expected value, and the assembly line stripped of newline characters
				
	# Run the loop #
	
	dut._log.info(f"Found {len(goodOutput)} assembly operations to run")	# printout of how long goodOutput is
	
	with open("riscv_debug_tb.txt", "w") as riscvTb:
		riscvTb.write("### RISC-V Test Bench Debug Log ###\n\n")
		
		cocotb.start_soon(cuTracker(dut, outputFile=riscvTb))
		
		for regNum, expectedVal, originalLine in goodOutput:	# unpacks goodOutput
			await waitForNextIW(dut)	# runs the function from above
			
			InstWordTb = int(dut.DataPath.IWRreg.Q.value)
			aluTb = int(dut.DataPath.ArithmeticLogicUnit.ALUres.value)
			wbMuxTb = int(dut.DataPath.WBmux.out.value)
			wbMuxSelTb = int(dut.DataPath.WBmux.Sel.value)
			wbDecoderSel = int(dut.DataPath.WriteBackDecoder.DECsel.value)
			actualVal = int(dut.DataPath.register_stage[regNum].NbitRegister.Q.value)	# sets "actualVal" to the value stored in the designated register
			
			# riscvTb writes:
			
			riscvTb.write(f"Current assembly instruction is: {originalLine}\n")
			riscvTb.write(f"Instruction Word: {hex(InstWordTb)}\n")
			riscvTb.write(f"ALU result: {aluTb}\n")
			riscvTb.write(f"Write Back Mux Select: {wbMuxSelTb}\n")
			riscvTb.write(f"Write Back Mux output: {wbMuxTb}\n")
			riscvTb.write(f"Register Load Decoder select: {wbDecoderSel}\n")
			riscvTb.write(f"EXPECTED RESULT: x{regNum} = {hex(expectedVal)} ({expectedVal})\n")
			riscvTb.write(f"ACTUAL RESULT: x{regNum} = {hex(actualVal)} ({actualVal})\n")
			
			# cocotb error statement:
			assert actualVal == expectedVal, (f"\nFail on instruction: {originalLine}\n" f"Expected x{regNum} = {hex(expectedVal)} ({expectedVal})\n" f"Got x{regNum} = {hex(actualVal)} ({actualVal})" )
			# If the actual value in the register doesn't match the expected value, print the failed TB statement
			
			dut._log.info("General test bench completed successfully.")	# Text printout
			
			dut._log.info("Testing branch loop.")	# Text printout
			
			await ClockCycles(dut.clk, 150)	# lets 150 clock cycles pass, program ends, to check the final result of the x1 and x2 registers
			
		final_x1 = int(dut.DataPath.register_file.stage[1].value)	# store final result of x1
		final_x2 = int(dut.DataPath.register_file.stage[2].value)	# store final result of x2
		
		assert final_x1 == 337, f"Branch Loop Filed: x1 expected 337, got {final_x1}"
		assert final_x2 == 337, f"Branch Loop Filed: x2 expected 337, got {final_x2}"
	
		dut._log.info("Branch test bench successful.")	# Final text printout
	

async def cuTracker(dut, outputFile=None):
	MCnames = {0: "MC0", 1: "MC1", 2: "MC2"}
	
	opcodes = {
		int(dut.ControlUnit.TYPE_R.value): "TYPE_R",
		int(dut.ControlUnit.TYPE_I.value): "TYPE_I",
		int(dut.ControlUnit.TYPE_L.value): "TYPE_L",
		int(dut.ControlUnit.TYPE_JR.value): "TYPE_JR",
		int(dut.ControlUnit.TYPE_S.value): "TYPE_S",
		int(dut.ControlUnit.TYPE_B.value): "TYPE_B",
		int(dut.ControlUnit.TYPE_UI.value): "TYPE_UI",
		int(dut.ControlUnit.TYPE_UPC.value): "TYPE_UPC",
		int(dut.ControlUnit.TYPE_J.value): "TYPE_J"
	}
	
	while True:
		try:
			await Edge(dut.ControlUnit.MC)
			currentMC = int(dut.ControlUnit.MC.value)
			mcStr = MCnames.get(currentMC, f"MC{currentMC} (Unknown Error)")
		
		timestamp = get_sim_time(unit="ns")
		
		mcStr = MCnames.get(currentMC, f"MC{currentMC} (Unknown Error)")
		
		logMsg = f"({timestamp:>6} ns) CU State Changed: {mcStr}\n"
		
		if currentMC in [1, 2]:
			try:
				rawIw = int(dut.ControlUnit.IW.value)
				opCode = rawIw & 0x7F
				opType = opcodes.get(opCode, f"Unknown Opcode (0x{opCode:02x})")
				logMsg += f" Processing {opType}"
			except ValueError:
				logMsg += " Processing Unknown type or Signals uninitialized"
		dut._log.info(logMsg)
		if outputFile:
			outputFile.write(logMsg + "\n\n")
pass
