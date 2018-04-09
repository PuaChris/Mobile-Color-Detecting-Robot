.equ JP1, 0XFF200060

.section .exceptions, "ax"
.global ISR


ISR:
    subi    sp, sp, 28
    stw     ra, 0(sp)
    stw     r2, 4(sp)
    stw     r3, 8(sp)
    stw     r4, 12(sp)
    stw     r5, 16(sp)
    stw     r6, 20(sp)
    stw     r7, 24(sp)

    # Check for audio
    rdctl   et, ipending
    andi    et, et, 0b1 << 6
    bne     et, zero, ISRAudio

    #Check if sensors interrupt
    #Don't forget to clear the edge capture register after interrupting
	rdctl 	et, ipending
    andi    et, et, 0b1 << 11
    bne     et, zero, ISRSensor

    # Check button
    rdctl   et, ipending
    andi    et, et, 0b1 << 1
    bne     et, zero, ISRButton

    # Check timer
    rdctl 	et, ipending
    andi    et, et, 0b1
    bne     et, zero, ISRTimer

	br ISREnd

ISRAudio:
	call   HandleAudio
	br     ISREnd

ISRSensor:
    call    HandleSensor
    br      ISREnd

ISRTimer:
    call    HandleTimer
    br      ISREnd

ISRButton:
    call    HandleButton
    br      ISREnd

ISREnd:
    ldw     ra, 0(sp)
    ldw     r2, 4(sp)
    ldw     r3, 8(sp)
    ldw     r4, 12(sp)
    ldw     r5, 16(sp)
    ldw     r6, 20(sp)
    ldw     r7, 24(sp)
    addi    sp, sp, 28

    subi    ea, ea, 4
    eret




# ------------------------------------------------------------------------------
HandleAudio:
    subi    sp, sp, 8
    stw     ra, 0(sp)
    stw     r23, 4(sp)

    movi    r23, AUDIO_500Hz
    beq     r15, r23, HandleAudio500Hz
    br      HandleAudioEmpty

HandleAudio500Hz:
    call    PlayAudio500Hz
    br      HandleAudioEnd

HandleAudioEmpty:
    call    PlayAudioEmpty
    br      HandleAudioEnd

HandleAudioEnd:
    ldw     ra, 0(sp)
    ldw     r23, 4(sp)
    addi    sp, sp, 8

    ret




# ------------------------------------------------------------------------------
HandleSensor:
    subi    sp, sp, 16
    stw     ra,  0(sp)
    stw     r16, 4(sp)
    stw     r17, 8(sp)
    stw 	r18, 12(sp)

    #assuming we're only checking for one sensor interrupting
    #sensors can only interrupt if the state changes from 1 -> 0
    #if sensor is 0, that mean it detects light (below threshold means brighter)
    #still need to figure out how to stop it

    movia   r16, JP1

#check if bit is 1. If it is true, then move foward. Else move onto the next bit
#Once you found the bit that triggered the interrupt, check
#but multiple sensors can trigger the interrupt...

Sensor0:
    #Checking if sensor0 triggered the interrupt
    ldwio   r17, 12(r16)
	srli 	r17, r17, 27
    andi    r17, r17, 1
    bne     r17, zero, Interrupt0

Sensor1:
    #Checking if sensor1 triggered the interrupt
    ldwio   r17, 12(r16)
    srli 	r17, r17, 28
    andi    r17, r17, 1
    bne     r17, zero, Interrupt1

Sensor2:
    #Checking if sensor2 triggered the interrupt
    ldwio   r17, 12(r16)
    srli 	r17, r17, 29
    andi    r17, r17, 1
    bne     r17, zero, Interrupt2

Sensor3:
    #Checking if sensor3 triggered the interrupt
    ldwio   r17, 12(r16)
    srli 	r17, r17, 30
    andi    r17, r17, 1
    bne     r17, zero, Interrupt3

Sensor4:
    #Checking if sensor4 triggered the interrupt
    ldwio   r17, 12(r16)
    srli 	r17, r17, 31
    andi    r17, r17, 1
    bne     r17, zero, Interrupt4

    #At this point, at least ONE of the sensors SHOULD have triggered the interrupt...
    br      FinishCheck


Interrupt0:
    movi r14, MOVEMENT_FORWARD
	movi r15, AUDIO_500Hz
    br FinishCheck

Interrupt1:
    movi r14, MOVEMENT_LEFT
	movi r15, AUDIO_500Hz
    br FinishCheck

Interrupt2:
    movi r14, MOVEMENT_LEFT
	movi r15, AUDIO_500Hz
    br FinishCheck

Interrupt3:
    movi r14, MOVEMENT_RIGHT
	movi r15, AUDIO_500Hz
    br FinishCheck

Interrupt4:
    movi r14, MOVEMENT_RIGHT
	movi r15, AUDIO_500Hz
    br FinishCheck


FinishCheck:
    #Resetting edge clear register for state mode
    movia   r17, 0xFFFFFFFF
	
    stwio   r17, 12(r16)
	#stwio zero, 12(r16)
	
    ldw     ra,  0(sp)
    ldw     r16, 4(sp)
    ldw     r17, 8(sp)
	ldw 	r18, 12(sp)
	addi 	sp, sp, 16

    ret




# ------------------------------------------------------------------------------
HandleTimer:
    subi    sp, sp, 8
    stw     ra, 0(sp)
    stw     r23, 4(sp)

    # Invert r13 (PWM state)
    nor     r13, r13, zero

    # Check if PWM is off
    beq r13, zero, HandleTimerOff

    # Start the on timer
	call StartPWMOnTimer
	
	# If PWM is on, check how to move
    movi r23, MOVEMENT_FORWARD
    beq r14, r23, HandleTimerForward
    movi r23, MOVEMENT_BACKWARD
    beq r14, r23, HandleTimerBackward
    movi r23, MOVEMENT_LEFT
    beq r14, r23, HandleTimerLeft
    movi r23, MOVEMENT_RIGHT
    beq r14, r23, HandleTimerRight
    br HandleTimerStop

HandleTimerForward:
    call MoveForward
    br HandleTimerEnd
HandleTimerBackward:
    call MoveBackward
    br HandleTimerEnd
HandleTimerLeft:
    call MoveLeft
    br HandleTimerEnd
HandleTimerRight:
    call MoveRight
    br HandleTimerEnd
HandleTimerStop:
	call StopMoving
	br HandleTimerEnd

HandleTimerOff:
	# Start the off timer
	call StartPWMOffTimer
    call StopMoving
    br HandleTimerEnd

HandleTimerEnd:
    ldw     ra, 0(sp)
    ldw     r23, 4(sp)
    addi    sp, sp, 8

    ret



HandleButton:
    subi    sp, sp, 4
    stw     ra, 0(sp)

    call SetupLego

HandleButtonEnd:

    call ClearButtonRegister

    ldw     ra, 0(sp)
    addi    sp, sp, 4

	ret

