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
    subi    sp, sp, 16
    stw     ra,  0(sp)
    stw     r16, 4(sp)
    stw     r17, 8(sp)
	stw 	r18, 12(sp)

    movia   r16, JP1

#check if bit is 1. If it is true, then move foward. Else move onto the next bit 
#Once you found the bit that triggered the interrupt, check
#but multiple sensors can trigger the interrupt...

Sensor0:
    #Checking if sensor0 triggered the interrupt 
    ldwio   r17, 12(r16)
	movia 	r18, 0b1 << 27
    and    	r17, r17, r18
    bne     r17, zero, Interrupt0
/*
Sensor1:
    #Checking if sensor1 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 28
    bne     r17, zero, Interrupt1

Sensor2:
    #Checking if sensor2 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 29
    bne     r17, zero, Interrupt2

Sensor3:
    #Checking if sensor3 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 30
    bne     r17, zero, Interrupt3

Sensor4:
    #Checking if sensor4 triggered the interrupt 
    ldwio   r17, 12(r16)
    andi    r17, r17, 0b1 << 31
    bne     r17, zero, Interrupt4
*/
    #At this point, at least ONE of the sensors triggered the interrupt...
    br      FinishCheck

Interrupt0:
    call Move0
    br FinishCheck
/*
Interrupt1:
    call Move1
    br FinishCheck

Interrupt2:
    call Move2
    br FinishCheck

Interrupt3:
    call Move4
    br FinishCheck

Interrupt4:
    call Move4
    br FinishCheck
*/
FinishCheck:
    #Resetting edge clear register
    movia   r17, 0xFFFFFFFF
    stwio   r17, 12(r16)

    ldw     ra,  0(sp)
    ldw     r16, 4(sp)
    ldw     r17, 8(sp)
	ldw 	r18, 12(sp)	
	
	addi 	sp, sp, 16
    ret

