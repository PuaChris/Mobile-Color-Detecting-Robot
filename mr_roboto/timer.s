.equ TIMER, 0xFF202000
.equ PWM, 262150 #50% 

.section .text
.global SetupTimer
.global Delay

SetupTimer:
	subi sp, sp, 8
	stw r16, 0(sp)
	stw r17, 0(sp)

	movia r16, TIMER
	stwio r0, (r16)
	stwio r0, 4(r16)

	movia r17, %lo(PWM)
	stwio r17, 8(r16)

	movia r17, %hi(PWM)
	stwio r17, 12(r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	addi sp, sp 8
	ret

Delay: 
	#could do this in an interrupt...
	subi sp, sp, 8
	stw r16, (sp)
	stw r17, 4(sp)

	movia r16, TIMER
	movi r17, 0b1 << 2
	stwio r17, 4(sp)

Poll: 
    ldwio r17, (r16)
    andi r17, r17, 1
    beq r17, zero, Poll

    ldw r16, (sp)
    ldw r17, 4(sp)
	addi sp, sp, 8
	ret
