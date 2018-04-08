.equ BUTTON, 		0xFF200050
.equ BUTTON_RESET,	0xFFFFFFFF	

.section .text

.global SetupButton 
.global BUTTON
.global BUTTON_RESET
.global ClearButtonRegister


SetupButton:
	subi 	sp, sp, 12
	stw 	ra,  0(sp)
	stw 	r16, 4(sp)
	stw 	r17, 8(sp)

	movia 	r16, BUTTON
	stwio 	zero, 0(r16)

	call ClearButtonRegister

	#allowing button0 to interrupt
	movui	r17, 0b1	
	stwio 	r17, 8(r16)

	#enabling interrupts for button in control
	rdctl r17, ienable
	ori r17, r17, 0b1 << 1
	wrctl ienable, r17

	ldw		ra,	 0(sp)
	ldw		r16, 4(sp)
	ldw 	r17, 8(sp)
	addi 	sp, sp, 12

	ret 

ClearButtonRegister:
	subi 	sp, sp, 8
	stw 	r16, 0(sp)
	stw 	r17, 4(sp)

	movia 	r16, BUTTON
	stwio 	zero, 0(r16)

	#reset edge capture register
	movia 	r17, BUTTON_RESET
	stwio 	r17, 12(r16)

	ldw 	r16, 0(sp)
	ldw		r17, 4(sp)
	addi 	sp, sp, 8

	ret

	