.equ JP1, 0XFF200060
.equ SP, 0X80000000
.equ TIMER, 0xFF202000
.equ DUTYCYCLE, 262150 #50% 
.equ SOUND_500Hz, 0b1	# for global r15
.equ PUSHBUTTONS, 0xFF200050

/*
Global register allocation:
r15 - sound to play (see constants)
*/




.section .text
.global _start
_start:
	movia sp, SP
	
	call SetupTimer
	call SetupLego
	call SetupAudio
	call SetupGlobalInterrupts
	
	# TESTING - always play 500Hz
	#movi r15, 1
loop:
	# TESTING - play 500Hz when KEY0 is pressed
	movia r16, PUSHBUTTONS
	ldwio r17, 0(r16)
	andi r15, r17, 0b1
	
	call DetectColor
	br loop
end:
	br end

SetupTimer:
	subi sp, sp, 8
	stw r16, 0(sp)
	stw r17, 0(sp)

	movia r16, TIMER
	stwio r0, (r16)
	stwio r0, 4(r16)

	movia r17, %lo(DUTYCYCLE)
	stwio r17, 8(r16)

	movia r17, %hi(DUTYCYCLE)
	stwio r17, 12(r16)



	
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

	#SetupLego interrupt
	movia r17, 0xF8000000
	stwio r17, 8(r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12
	ret

DetectColor:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw ra, 8(sp)

	#sensor 0 
	movia r16, JP1
	ldwio r17, (r16)
	srli r17, r17, 27

	andi r17, r17, 0x1
	beq r17, r0, True0

	call StopMoving

	#sensor 1 
	movia r16, JP1
	ldwio r17, (r16)
	srli r17, r17, 28

	andi r17, r17, 0x1
	beq r17, r0, True1

	#Here set up detection for all sensors and call True for different sensors

False:
	call StopMoving
	br FinishDetect

True0:
	call MoveForward0
	br FinishDetect

True1:
	call MoveForward1
	br FinishDetect

FinishDetect:
	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12

	ret

MoveForward0:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	movia r16, JP1
	ldwio r17, (r16)
	movia r18, 0xFFFFFFF8
	and r17, r17, r18
	stwio r17, (r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12

	ret

#right now it only one wheel is moving
#right wheel moves forward to turn left
MoveForward1:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	movia r16, JP1
	ldwio r17, (r16)
	movia r18, 0xFFFFFFF3
	and r17, r17, r18
	stwio r17, (r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12

	ret	

StopMoving:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	movia r16, JP1
	ldwio r17, (r16)
	movia r18, 0x3FF
	or r17, r17, r18
	stwio r17, (r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12

	ret




SetupGlobalInterrupts:
	subi sp, sp, 4
	stw r16, 0(sp)

	# Enable global interrupts
	movi r16, 0b1
	wrctl status, r16

	#Enable lego controller and timer
	rdctl r16, ienable
	ori r16, r16, 0b1 << 11
	ori r16, r16, 0b1
	wrctl ienable, r16 

	ldw r16, 0(sp)
	addi sp, sp, 4

	ret
