_start:
	addi x1, x0, 2000	# x1 = 2000
	sw x1, 0(x1)		# mem(2000) = 2000
	addi x2, x1, -1500	# x2 = 500
	lh x3, 0(x1)		# x3 = 2000
	sub x4, x2, x3		# x4 = -1500
	addi x5, x0, -1500	# x5 = -1500
	beq x5, x4, _success
_notSuccess:
	lui x6, 0x55555		# x6 = 0x55555000
	addi x6, x6, 0x555	# x6 = 0x55555555
	sb x6, 0(x6)		# mem(opd) = 0x55
	lhu x7, 0(x6)		# x7 = mem(ipd(0xffffaaaa))
	jal x0, _done 		# jumps to done test

_success:
	lui x6, 0xaaaaa		# x6 = 0xaaaaa000
	addi x6, x6, 0xaa	# x6 = 0xaaaaa0aa
	sh x6, 0(x6)		# mem(opd) = 0xa0aa
	lbu x7, 0(x6)		# x7 = mem(ipd(0xffffffaa))
	jal x0, _done 		# jumps to done test

_done:
	addi x8, x0, 67		# x8 = 67
	addi x8, x1, -1900	# x8 = 100
	addi x9, x1, -1950	# x9 = 50
	xor x10, x9, x8		# x10 = 32
	lw x11, 0(x1)		# x11 = 2000
	sw x11, 4(x1)		# mem(2001) = 2000
	lw x12, 4(x1)		# x12 = 2000
	
_trap:
	jal, x0 _trap		# loop trap
	