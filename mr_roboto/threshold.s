.section .text
.global SetupLego


SetupLego:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	#note: values stored in base address are not exactly
	movia r16, JP1
	
	# Go to value mode, sensor 0 on
	movia r17, 0x000FFFFF
	movia r18, 0b1 << 21
	or r17, r17, r18 	# value mode
	movi r18, 0b1 << 10 
	nor r18, r18, zero	# flip all bits
	and r17, r17, r18
	stwio r17, 0(r16)
Sensor0Loop:
	ldwio r17, 0(r16)
	srli r17, r17, 11
	andi r17, r17, 0b1
	bne r17, zero, Sensor0Loop

	#getting new threshold
	ldwio r18, 0(r16)
	srli r18, r18, 27
	andi r18, r18, 0b1111

	# old value with 9 threshold = 0x04AFC1FF
	#loading threshold in value mode and threshold
	#enabling sensor 0
	movia r17, 0x002FC1FF
	slli r18, r18, 23
	or r17, r17, r18
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
	movia r17, 0xF8000000
	stwio r17, 8(r16)

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12
	ret
