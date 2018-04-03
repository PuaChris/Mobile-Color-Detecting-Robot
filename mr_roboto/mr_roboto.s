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
	call SetupLego
	call SetupGlobalInterrupts
	#call SetupAudio
	
	# TESTING - always play 500Hz
	#movi r15, 1

loop:
/*
	# TESTING - play 500Hz when KEY0 is pressed
	movia r16, PUSHBUTTONS
	ldwio r17, 0(r16)
	andi r15, r17, 0b1
*/
	
	call DetectColor
	br loop

end:
	br end

	
SetupLego:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	#note: values stored in base address are not exactly
	movia r16, JP1

	#loading threshold in value mode and threshold = 9
	#enabling sensors 0 and 1
	movia r17, 0x04AFC1FF
	stwio r17, (r16)

	#disabling load to threshold
	#disable sensors 
	movia r18, 0x00401400
	or r17, r17, r18
	stwio r17, (r16)

	#setting to state mode
	movia r18, 0xFFDFFFFF
	and r17, r17, r18 
	stwio r17, (r16)

	#SetupLego direction register
	movia r17, 0x07F557FF
	stwio r17, 4(r16)

	#SetupLego interrupt; only sensor 0 interrupts
	movia r17, 0x08000000
	stwio r17, 8(r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12
	ret

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

	#Enable timer interrupt
	ori r16, r16, 0b1
	wrctl ienable, r16 

	ldw r16, 0(sp)
	addi sp, sp, 4

	ret

