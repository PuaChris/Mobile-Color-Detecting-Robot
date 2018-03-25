.section .text
.equ JP1, 0XFF200060
.equ SP, 0X80000000
.equ AUDIO, 0xFF203040
.equ SOUND_500Hz, 0b1

/*
Register allocation

Global:
r15 - sound to play (see constants)
*/


.global _start
_start:
	movia sp, SP
	call initialize
	call setup_audio
	call setup_global_interrupts
loop:
	call detect_color
	br loop
end:
	br end




initialize:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

#note: values stored in base address are not exactly
	movia r16, JP1

	#loading threshold in value mode and threshold = 9
	movia r17, 0x04AFF1FF
	stwio r17, (r16)

	#disabling load to threshold
	movia r18, 0x00400400
	or r17, r17, r18
	stwio r17, (r16)

	movia r18, 0xFFDFFFFF
	and r17, r17, r18 #setting to state mode
	stwio r17, (r16)

	#initialize direction register
	movia r17, 0x07F557FF
	stwio r17, 4(r16)

	#initialize interrupt
	movia r17, 0xF8000000
	stwio r17, 8(r16)


	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12
	ret

detect_color:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw ra, 8(sp)

	movia r16, JP1
	ldwio r17, (r16)
	srli r17, r17, 27

	andi r17, r17, 0x1
	beq r17, r0, true

false:
	call stop_moving
	br finish_detect

true:
	call move_forward

finish_detect:
	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12

	ret

move_forward:
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

stop_moving:
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




setup_audio:
	subi sp, sp, 8
	stw r16, 0(sp)
	stw r17, 4(sp)


	# Setup audio device (write interrupt enable)
	movia r16, AUDIO
	movi r17, 0b10
	stwio r17, (r16)

	# Enable audio interrupt
	movi r16, 1 << 6
	wrctl ienable, r16


	ldw r16, 0(sp)
	ldw r17, 4(sp)
	addi sp, sp, 8

	ret




setup_global_interrupts:
	subi sp, sp, 4
	stw r16, 0(sp)

	# Enable global interrupts
	movi r16, 0b1
	wrctl status, r16

	ldw r16, 0(sp)
	addi sp, sp, 4

	ret
