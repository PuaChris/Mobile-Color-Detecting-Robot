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
    andi    et, et, 0b1 << 11
    bne     et, zero, ISRSensor



	br ISREnd

ISRAudio:
	call HandleAudio
	br ISREnd

ISRSensor:
    call HandleSensor
    br ISREnd

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

    movi    r23, 1
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


# TODO - implement timer to clear FIFO when the sounds should stop
# TODO - determine when to play a sound in main loop

# ------------------------------------------------------------------------------

HandleSensor:
    #assuming we're only checking for one sensor interrupting 
    #sensors can only interrupt if the state changes from 1 -> 0
    #if sensor is 0, that mean it detects light (below threshold means brighter)
    #still need to figure out how to stop it

#DOUBLE CHECK IF RA IS NEEDED TO BE STORED ONTO THE STACK
    subi    sp, sp, 12
    stw     ra,  0(sp)
    stw     r16, 4(sp)
    stw     r17, 8(sp)

    movia   r16, JP1

    #Checking if sensor0 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 27
    bne     r17, zero, Move0
    br      FinishCheck

    #Checking if sensor1 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 28
    bne     r17, zero, Move1
    br      FinishCheck

    #Checking if sensor2 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 29
    bne     r17, zero, Move2
    br      FinishCheck

    #Checking if sensor3 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 30
    bne     r17, zero, Move3
    br      FinishCheck

    #Checking if sensor4 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 31
    bne     r17, zero, Move4
    br      FinishCheck

FinishCheck:
    #Resetting edge clear register
    movia   r17, 0xFFFFFFFF
    stwio   r17, 12(r16)

    ldw     ra,  0(sp)
    ldw     r16, 4(sp)
    ldw     r17, 8(sp)

    ret
