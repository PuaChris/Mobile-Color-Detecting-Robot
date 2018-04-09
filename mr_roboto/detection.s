.section .text
.global DetectColor


DetectColor:
	subi 	sp, sp, 16
	stw 	ra,  0(sp)
	stw 	r16, 4(sp)
	stw 	r17, 8(sp)
	stw		r18, 12(sp)

	#If any sensor = 0, it is detecting a color
	#If all sensors are 1, then no sensors are detecting anything -> stop moving
	movia 	r16, JP1
	
	# Read sensor state bits
	ldwio 	r17, (r16)
	srli 	r17, r17, 27
	andi 	r17, r17, 0b11111
	
	#sensor 0
	srli	r18, r17, 0
	andi 	r18, r18, 0x1
	beq 	r18, r0, FinishDetect

	#sensor 1
	srli 	r18, r17, 1
	andi 	r18, r18, 0x1
	beq 	r18, r0, FinishDetect

	#sensor 2
	srli 	r18, r17, 2
	andi 	r18, r18, 0x1
	beq 	r18, r0, FinishDetect

	#sensor 3
	srli 	r18, r17, 3
	andi 	r18, r18, 0x1
	beq 	r18, r0, FinishDetect

	#sensor 4
	srli 	r18, r17, 4
	andi 	r18, r18, 0x1
	beq 	r18, r0, FinishDetect

MovementStop:
	# If none of the sensors are 0, stop moving
	movi	r14, MOVEMENT_STOP
	movi	r15, AUDIO_EMPTY

FinishDetect:
	ldw 	ra,  0(sp)
	ldw 	r16, 4(sp)
	ldw 	r17, 8(sp)
	ldw		r18, 12(sp)
	addi 	sp, sp, 16

	ret
