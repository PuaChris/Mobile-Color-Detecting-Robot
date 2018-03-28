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


    # Check for audio interrupt
    rdctl   et, ipending
    andi    et, et, 0b1 << 6
    bne     et, zero, ISRAudio


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




ISRAudio:
    subi    sp, sp, 8
    stw     ra, 0(sp)
    stw     r23, 4(sp)

    movi    r23, 1
    beq     r15, r23, ISRAudio500Hz
    br      ISRAudioEmpty

ISRAudio500Hz:
    call    PlayAudio500Hz
    br      ISRAudioEnd

ISRAudioEmpty:
    call    PlayAudioEmpty
    br      ISRAudioEnd

ISRAudioEnd:
    ldw     ra, 0(sp)
    ldw     r23, 4(sp)
    addi    sp, sp, 8

    ret




# TODO - implement timer to clear FIFO when the sounds should stop
# TODO - determine when to play a sound in main loop
