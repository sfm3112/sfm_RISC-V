.text
.global _start
_start:	# x1 = 2, x2 = 3, x3 = tbOut, x4 = -5
	addi x1 x1, 2	# x1 = 2
	addi x2, x2, 3	# x2 = 3
	addi x4, x4, -5	# x4 = -5
_startTests:
	add x3, x4, x2	# x3 = -2
	sub x3, x1, x2	# x3 = -1
	sll x3, x1, x2	# x3 = 16
	slt x3, x1, x4	# x3 = 0
	sltu x3, x1, x4	# x3 = 1
	xor x3, x4, x4	# x3 = 0
	srl x3, x4, x1	# x3 = 0x3FFFFFFE (1,073,741,822)
	sra x3, x4, x1	# x3 = 0xFFFFFFFE (-2)
	or x3, x1, x2	# x3 = 3
	and x3, x1, x2	# x3 = 2
	
	slti x3, x1, 5	# x3 = 1
	sltiu x3, x1, 5	# x3 = 1
	