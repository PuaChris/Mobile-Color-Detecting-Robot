.equ TIMER, 0xFF202000
.equ PWM_ON, 262150 #50% 
.equ PWM_OFF, 262150 #50% 

.section .text
.global SetupTimer
.global DelayON
.global DelayOFF

SetupTimer:
	subi 	sp, sp, 8
	stw 	r16, 0(sp)
	stw 	r17, 4(sp)

	movia 	r16, TIMER
	stwio 	r0, (r16)
	stwio 	r0, 4(r16)

	ldw 	r16, 0(sp)
	ldw 	r17, 4(sp)
	addi 	sp, sp, 8
	ret

DelayON: 
	subi 	sp, sp, 8
	stw 	r16, 0(sp)
	stw 	r17, 4(sp)

	movia 	r17, %lo(PWM_ON)
	stwio 	r17, 8(r16)

	movia 	r17, %hi(PWM_ON)
	stwio 	r17, 12(r16)

	movia 	r16, TIMER
	movi 	r17, 0b1 << 2
	stwio 	r17, 4(sp)

PollON: 
    ldwio 	r17, (r16)
    andi 	r17, r17, 1
    beq 	r17, zero, PollON

	ldw 	r16, 0(sp)
	ldw 	r17, 4(sp)
	addi 	sp, sp, 8
	ret

DelayOFF:
	subi 	sp, sp, 8
	stw 	r16, 0(sp)
	stw 	r17, 4(sp)

	movia 	r17, %lo(PWM_OFF)
	stwio 	r17, 8(r16)

	movia 	r17, %hi(PWM_OFF)
	stwio 	r17, 12(r16)
	
	movia 	r16, TIMER
	movi 	r17, 0b1 << 2
	stwio 	r17, 4(sp)

PollOFF: 
    ldwio 	r17, (r16)
    andi 	r17, r17, 1
    beq 	r17, zero, PollOFF


	ldw 	r16, 0(sp)
	ldw 	r17, 4(sp)
	addi 	sp, sp, 8
	ret

