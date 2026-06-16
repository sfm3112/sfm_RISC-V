_start:
	addi x1, x0, 2	# x1 = 2
	addi x2, x0, 3	# x2 = 3
	addi x4, x0, -5	# x4 = -5
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
	xori x3, x2, 1	# x3 = 2
	ori x3, x2, 1	# x3 = 3
	andi x3, x2, 1	# x3 = 1
	slli x3, x1, 20	# x3 = 0x00020000 (2,097,152)
	srli x3, x1, 0	# x3 = 2
	srai x3, x4, 1	# x3 = 0xFFFFFFFD (-3)
	
	addi x1, x0, 0x345	# x1 = 837
	addi x2, x0, 345	# x2 = 345
_startBranchTests:
	beq x1, x2, _done	# if x1 = x2, jump to _done
	blt x1, x2, _isLT	# if x1 < x2, jump to 
	addi x1, x1, -100	# decrement x1 by 100
	jal x0, _startBranchTests 		# restart loop
	
_isLT:
	addi x2, x2, -1		# decrement x2 by 1
	jal x0, _startBranchTests 		# restart loop
	
_done:
	jal x0, _done 		# done catch