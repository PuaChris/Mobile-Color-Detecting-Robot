.section .text
.global DetectColor


DetectColor:
	subi 	sp, sp, 12
	stw 	ra,  0(sp)
	stw 	r16, 4(sp)
	stw 	r17, 8(sp)

	#If any sensor = 0, it is detecting a color
	#If all sensors are 1, then no sensors are detecting anything -> stop moving
	movia 	r16, JP1

	#sensor 0
	ldwio 	r17, (r16)
	srli 	r17, r17, 27
	andi 	r17, r17, 0x1
	beq 	r17, r0, FinishDetect

	#sensor 1
	ldwio 	r17, (r16)
	srli 	r17, r17, 28
	andi 	r17, r17, 0x1
	beq 	r17, r0, FinishDetect

	#sensor 2
	ldwio 	r17, (r16)
	srli 	r17, r17, 29
	andi 	r17, r17, 0x1
	beq 	r17, r0, FinishDetect

	#sensor 3
	ldwio 	r17, (r16)
	srli 	r17, r17, 30
	andi 	r17, r17, 0x1
	beq 	r17, r0, FinishDetect

	#sensor 4
	ldwio 	r17, (r16)
	srli 	r17, r17, 31
	andi 	r17, r17, 0x1
	beq 	r17, r0, FinishDetect

StopMoving:
	# If none of the sensors are 0, stop moving
	call 	StopMoving
	movi	r15, AUDIO_EMPTY

FinishDetect:
	ldw 	ra,  0(sp)
	ldw 	r16, 4(sp)
	ldw 	r17, 8(sp)
	addi 	sp, sp, 12

	ret
