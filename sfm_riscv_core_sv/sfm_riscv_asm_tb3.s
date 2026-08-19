# ==============================================================================
# RISC-V PIPELINE STRESS TEST
# Architecture: RV32I (Base Integer Instruction Set)
# No extensions (No 'M', No 'D'). Combined I/D Memory.
# ==============================================================================

_start:

    # Set a safe Data Pointer to avoid overwriting instructions.
    addi x2, x0, 0x800            # x2 (sp) = 0x800

    # TEST 1: The Zero Register (x0) Edge Case
    addi x0, x0, 100        # Try to overwrite x0
    add x3, x0, x0          # x3 should be 0, not 200

    addi x4, x0, 10               # x4 = 10
    
    # EX-to-EX Forwarding (Consecutive instructions)
    addi x5, x4, 5          # x5 = 15. Requires x4 from MEM stage 
    add  x6, x5, x4         # x6 = 25. Requires x5 from EX/MEM and x4 from MEM/WB
    
    # MEM-to-EX Forwarding (1 instruction gap)
    li x7, 2
    nop                     # Create a gap
    add x8, x6, x7          # x8 = 27. x7 requires forwarding from MEM/WB stage

    # A load followed immediately by a dependent instruction 
    sw x8, 0(x2)            # Store 27 at 0x800
    lw x9, 0(x2)            # Load 27 into x9
    addi x10, x9, 3         # x10 should be 30.
    
    # Check if a stall messed up the next instruction
    addi x11, x10, 2        # x11 should be 32.


    # Memory Sign/Zero Extension Edge Cases
    li x12, -2              # x12 = 0xFFFFFFFE (-2)
    sw x12, 4(x2)           # Store 0xFFFFFFFE at 0x804
    
    lb x13, 4(x2)           # Load Byte (Sign Extended). x13 should be 0xFFFFFFFE (-2)
    lbu x14, 4(x2)          # Load Byte Unsigned (Zero Ext). x14 should be 0x000000FE (254)
    
    lh x15, 4(x2)           # Load Half (Sign Extended). x15 should be 0xFFFFFFFE (-2)
    lhu x16, 4(x2)          # Load Half Unsigned. x16 should be 0x0000FFFE (65534)

    # Control Hazards - Branches
    li x17, 5
    li x18, 5
    
    # Branch Taken (Requires pipeline flush of fetched instructions)
    beq x17, x18, branch_taken
    addi x19, x0, 99        # SHOULD NOT EXECUTE! If x19 == 99, flush failed.
    addi x19, x0, 99        # SHOULD NOT EXECUTE!
    
branch_taken:
    # Branch Not Taken (Should flow straight through, no flush)
    bne x17, x18, fail_loop
    addi x20, x0, 1         # SHOULD EXECUTE. x20 = 1

    # Backwards Branching
    li x21, 3               # Loop counter
loop_start:
    addi x21, x21, -1       # Decrement counter
    bne x21, x0, loop_start # Loop until x21 == 0


    # Control Hazards - Jumps & Subroutines
    # Jumps also require pipeline flushes.
    jal x1, subroutine      # Jump and Link. PC+4 saved to x1.
    
return_point:
    # We should return here.
    addi x22, x0, 42        # x22 = 42

    # Jump to end to avoid falling through into subroutine
    jal x0, end_success

subroutine:
    addi x23, x0, 77        # x23 = 77
    # Return using jalr
    jalr x0, 0(x1)          # Return to PC saved in x1

fail_loop:
    # If the program ends up here, a branch prediction/jump failed.
    li x31, 0xDEAD
    jal x0, fail_loop

end_success:
    # Program completed successfully. 
    li x31, 0x1111          # x31 = 0x1111 signifies success.
infinite_loop:
    jal x0, infinite_loop   # End of program execution trap