# TODO - check if M1 is right

# move forward - M1 rev, M0 for
.equ LEGO_MOTORS_OFF_OR,	0x3FF
.equ LEGO_MOTORS_OFF_AND,	0xFFFFFFFF
.equ LEGO_MOTORS_FORWARD,	0xFFFFFFF8
.equ LEGO_MOTORS_BACKWARD,	0xFFFFFFF2
.equ LEGO_MOTORS_LEFT,		0xFFFFFFF0	# TODO - check this
.equ LEGO_MOTORS_RIGHT,		0xFFFFFFFA	# TODO - check this



.section .text
.global Move0
.global Move1
.global StopMoving

#Sensor 0 is in the centre
#Sensor 1 and 2 are placed on the left
#Sensor 3 and 4 are placed in the right
#Sensor 2 and 4 are placed horizontally




# Sets the motors to the given state
# r4 - Motor bits mask
SetMotors:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	# Get current Lego state
	movia r16, JP1
	ldwio r17, (r16)

	# Motors off
	movia r18, LEGO_MOTORS_OFF_OR
	or r17, r17, r18

	# New motor state
	and r17, r17, r4

	# Write new Lego state
	stwio r17, (r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12

	ret




StopMoving:
	subi 	sp, sp, 4
	stw 	ra, 0(sp)

	movia r4, LEGO_MOTORS_OFF_AND
	call SetMotors

	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret




MoveForward:
	subi 	sp, sp, 4
	stw 	ra, 0(sp)

	movia r4, LEGO_MOTORS_FORWARD
	call SetMotors

	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret




MoveBackward:
	subi 	sp, sp, 4
	stw 	ra, 0(sp)

	movia r4, LEGO_MOTORS_BACKWARD
	call SetMotors

	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret




MoveLeft:
	subi 	sp, sp, 4
	stw 	ra, 0(sp)

	movia r4, LEGO_MOTORS_LEFT
	call SetMotors

	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret




MoveRight:
	subi 	sp, sp, 4
	stw 	ra, 0(sp)

	movia r4, LEGO_MOTORS_RIGHT
	call SetMotors

	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret












/*
#right wheel moves forward to turn left
Move1:
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

Move2:
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

Move3:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	movia r16, JP1
	ldwio r17, (r16)
	movia r18, 0xFFFFFFF9
	and r17, r17, r18
	stwio r17, (r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12

	ret

Move4:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	movia r16, JP1
	ldwio r17, (r16)
	movia r18, 0xFFFFFFF9
	and r17, r17, r18
	stwio r17, (r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12

	ret
*/
