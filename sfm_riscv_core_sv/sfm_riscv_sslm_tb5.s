_start:
	# Safe Data Pointer
	addi x30, x0, 0x400
	slli x30, x30, 1
	
	# initialize the other registers
	sub x1, x1, x1
	sub x2, x2, x2
	sub x3, x3, x3
	sub x4, x4, x4
	
	# initialize the location which will store the product
	sw x3, 12(x30)
	
	# prepare and store iteration value
	addi x1, x0, 32
	sw x1, 0(x30)
	
	#--------------------------------------------------------------------
	# Read in and prepare m_val and M_val
	#--------------------------------------------------------------------
	
_begin:
	# read input port {PB, SW[3:0]} //-1 should map to IOPs 
	lw x3, -4(x0)
	# store m_val (4-bit pattern) 
	sw x3, 4(x30)
	# read input port {PB, SW[3:0]} //-1 should map to IOPs 
	lw x3, -4(x0)
	# store M_val (4-bit pattern) 
	sw x3, 8(x30)
	
	#--------------------------------------------------------------------
	# Multiply M_val and m_val using the shift-left algorithm
	#--------------------------------------------------------------------

	# R1 is holding the current partial product (PP)
	lw x1, 8(x30)
	# R2 is holding the remaining bits of the multiplier
	lw x2, 4(x30)
	# prepare mask for m-LSbit; this is the beginning of the iteration
_next:
	addi x3, x0, 1
	# mask m-LSbit in R3
	and x3, x3, x2
	# if it is 0 jump to label @mbitz
	beq x0, x3, _mbitz
	# else load the current product, add the current PP (R1) to it, and store it back
	lw x3, 12(x30)
	add x3, x3, x1
	sw x3, 12(x30)
	# prepare the next PP in R1 and the next mLSbit in R2
_mbitz:
	slli x1, x1, 1
	srai x2, x2, 1
	# load the iteration value and check if done or not
	lw x3, 0(x30)
	addi x3, x3, -1
	beq x0, x3, _done
	sw x3, 0(x30)
	jal x0, _next
	# if done load the final product into R3 and display it on the lEDs
_done:
	lw x3, 12(x30)
	sw x3, -4(x0)
	jal x0, _start
	