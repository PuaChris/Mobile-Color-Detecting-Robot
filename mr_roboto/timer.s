.equ TIMER1, 0xFF202000

#50%
#.equ PWM_ON_CYCLES, 	262150
#.equ PWM_OFF_CYCLES, 	262150
# adds to 524300

.equ PWM_ON_CYCLES,		282150
.equ PWM_OFF_CYCLES,	242150

.section .text
.global SetupTimer
.global StartPWMOnTimer
.global StartPWMOffTimer




SetupTimer:
	subi 	sp, sp, 8
	stw 	r16, 0(sp)
	stw 	r17, 4(sp)

	# Enable interrupts on timer
	movia 	r16, TIMER1
	stwio 	r0, (r16)
	movi	r17, 0b0001
	stwio 	r17, 4(r16)

	# Enable interrupt on Nios
	rdctl 	r16, ienable
	ori 	r16, r16, 0b1
	wrctl 	ienable, r16

	ldw 	r16, 0(sp)
	ldw 	r17, 4(sp)
	addi 	sp, sp, 8

	ret




# Sets up and starts the timer for the given period
# r4 - lower 16 bits of period
# r5 - upper 16 bits of period
StartTimer:
	subi 	sp, sp, 8
	stw 	r16, 0(sp)
	stw 	r17, 4(sp)

	movia 	r16, TIMER1

	# Write status register (acknowledge timeout interrupt)
	stwio	zero, 0(r16)

	# Set period
	stwio 	r4, 8(r16)
	stwio 	r5, 12(r16)

	# Start timer (with interrupts)
	movi	r17, 0b0101	# start, interrupt
	stwio	r17, 4(r16)

	ldw 	r16, 0(sp)
	ldw 	r17, 4(sp)
	addi 	sp, sp, 8

	ret




StartPWMOnTimer:
	subi 	sp, sp, 4
	stw 	ra, 0(sp)

	movui 	r4, %lo(PWM_ON_CYCLES)
	movui 	r5, %hi(PWM_ON_CYCLES)
	call 	StartTimer

	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret




StartPWMOffTimer:
	subi 	sp, sp, 4
	stw 	ra, 0(sp)

	movui 	r4, %lo(PWM_OFF_CYCLES)
	movui 	r5, %hi(PWM_OFF_CYCLES)
	call 	StartTimer

	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret
