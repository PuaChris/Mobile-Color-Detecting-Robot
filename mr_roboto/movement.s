# M0 - left back
# M1 - right back
# M2 - right front
# M3 - left front

# S0 - centre
# S1 - left angle
# S2 - left horizontal
# S3 - right angle
# S4 - right horizontal

# to move forward - left forward, right reverse

.equ LEGO_MOTORS_OFF_OR,	0x3FF
.equ LEGO_MOTORS_OFF_AND,	0xFFFFFFFF

#.equ LEGO_MOTORS_FORWARD,	0xFFFFFFF8
#.equ LEGO_MOTORS_BACKWARD,	0xFFFFFFF2
#.equ LEGO_MOTORS_LEFT,		0xFFFFFFF0
#.equ LEGO_MOTORS_RIGHT,	0xFFFFFFFA

.equ LEGO_MOTORS_FORWARD,	0xFFFFFF82
.equ LEGO_MOTORS_BACKWARD,	0xFFFFFF28
.equ LEGO_MOTORS_LEFT,		0xFFFFFF00
.equ LEGO_MOTORS_RIGHT,		0xFFFFFFAA



.section .text

.global StopMoving
.global MoveForward
.global MoveBackward
.global MoveRight
.global MoveLeft



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
