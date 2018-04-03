.equ JP1, 0XFF200060
.equ SP, 0X80000000

.equ SOUND_500Hz, 0b1	# for global r15
.equ PUSHBUTTONS, 0xFF200050

/*
Global register allocation:
r15 - sound to play (see constants)
*/

.global JP1
.section .text
.global _start
_start:
	movia sp, SP
	
	call SetupTimer
	movi r4, 9	# start with threshold 9
	call SetupLego
	call SetupGlobalInterrupts
	call SetupAudio
	
	# TESTING - always play 500Hz
	#movi r15, 1

loop:

	movia r16, PUSHBUTTONS
	ldwio r17, 0(r16)
	andi r18, r17, 0b1	# get KEY0


	
	call DetectColor
	br loop

end:
	br end

	

SetupGlobalInterrupts:
	subi sp, sp, 4
	stw r16, 0(sp)

	#Enable global interrupt
	movi r16, 0b1
	wrctl status, r16

	#Enable lego controller interrupt
	rdctl r16, ienable
	ori r16, r16, 0b1 << 11
	wrctl ienable, r16 

/*
	#Enable timer interrupt
	ori r16, r16, 0b1
	wrctl ienable, r16 
*/
	ldw r16, 0(sp)
	addi sp, sp, 4

	ret

