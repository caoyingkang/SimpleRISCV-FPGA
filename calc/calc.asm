.text
main:
    andi x5, x0, 0      # reset accumulator x5 and command reg x6
	andi x6, x0, 0
    lui x2, 8           # x2 = 0x8000
    lw x3, -0xF0(x2)    # read portB
	sw x3, -0xE0(x2)	# write portC
nochange:
    lw x7, -0xF0(x2)    # read portB
	bne x7, x3, bchange
    lw x8, -0x100(x2)   # read portA
	bne x8, x0, anonzero
	j nochange
bchange:
	ori x3, x7, 0
	sw x7, -0xE0(x2)	# write portC
	j nochange
anonzero:
    lw x4, -0x100(x2)   # read portA again, wait for buttons to be released
	bne x4, x0, anonzero
	beq x6, x0, op1st
	andi x4, x6, 1		# x4 = btnU
	bne x4, x0, cmd_eq
	srli x6, x6, 1
	andi x4, x6, 1		# x4 = btnR
	bne x4, x0, cmd_mult
	srli x6, x6, 1
	andi x4, x6, 1		# x4 = btnC
	bne x4, x0, cmd_sub
	srli x6, x6, 1
	andi x4, x6, 1		# x4 = btnL
	bne x4, x0, cmd_add
cmd_eq:
cmd_done:
	sw x5, -0xE0(x2)	# write portC
	ori x6, x8, 0
	j nochange
cmd_add:				# x5 += x7
	add x5, x5, x7
	j cmd_done
cmd_sub:				# x5 -= x7
	sub x5, x5, x7
	j cmd_done
cmd_mult:				# x5 *= x7
	xori x4, x5, 0		# multiplicand: x4, multiplier: x7, product: x5
    addi x5, x0, 0
    addi x9, x0, 32 	# remaining loops
multloop:
    andi x10, x7, 1		# x10 = multiplier[0]
    beq x10, x0, multtag
    add x5, x5, x4
multtag:
    slli x4, x4, 1
    srli x7, x7, 1
    addi x9, x9, -1
    bne x9, x0, multloop
	j cmd_done
op1st:
	ori x6, x8, 0		# register command into x6
	ori x5, x7, 0		# register first operand
	j nochange
