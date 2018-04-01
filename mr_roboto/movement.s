.section .text	
.global Move0
.global Move1
.global StopMoving

Move0:
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

StopMoving:
	subi 	sp, sp, 12
	stw 	r16, 0(sp)
	stw 	r17, 4(sp)
	stw 	r18, 8(sp)

	movia 	r16, JP1
	ldwio 	r17, (r16)
	movia 	r18, 0x3FF
	or 		r17, r17, r18
	stwio 	r17, (r16)

	ldw 	r16, 0(sp)
	ldw 	r17, 4(sp)
	ldw 	r18, 8(sp)
	addi 	sp, sp, 16

	ret


