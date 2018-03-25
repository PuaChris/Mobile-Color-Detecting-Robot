.equ CLEAR_AUDIO, 0b1 << 3
# number of samples to skip between high/low values
.equ AUDIO_500HZ_SAMPLE_COUNT, 48
.equ AUDIO_75_PCT_SAMPLE_COUNT, 96
.equ AUDIO_HIGH, 0x7FFFFFFF
.equ AUDIO_LOW,  0x80000000

.section .exceptions, "ax"
# .global ISR




ISR:
    # TODO - save r2
    subi sp, sp, 28
    stw ra, 0(sp)
    stw r2, 4(sp)
    stw r3, 8(sp)
    stw r4, 12(sp)
    stw r5, 16(sp)
    stw r6, 20(sp)
    stw r7, 24(sp)

    # Check for audio interrupt
    rdctl et, ipending
    andi et, et, 1 << 6
    bne et, zero, ISRAudio

    ldw ra, 0(sp)
    ldw r2, 4(sp)
    ldw r3, 8(sp)
    ldw r4, 12(sp)
    ldw r5, 16(sp)
    ldw r6, 20(sp)
    ldw r7, 24(sp)
    addi sp, sp, 28

    subi ea, ea, 4
    eret




ISRAudio:
    subi sp, sp, 12
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)

    call CanWriteAudio
    beq r2, zero, ISRAudioEnd

    movi r16, AUDIO
    movi r17, SOUND_500Hz
    beq r15, r17, ISRAudio500Hz
    # TODO - check other sounds
    br ISRAudioEnd

ISRAudioNone:
    # Keep looping and writing zero
    movi r16, AUDIO_75_PCT_SAMPLE_COUNT
    subi r16, r16, 1
ISRAudioNoneLoop:
    stwio zero, 8(r16)
    stwio zero, 12(r16)
    subi r16, r16, 1
    bgt r16, zero, ISRAudioNoneLoop    # loop back




ISRAudio500Hz:
    # Keep looping and writing zero
    movi r16, AUDIO_500HZ_SAMPLE_COUNT
    subi r16, r16, 2
ISRAudio500HzLoopHigh:
    stwio zero, 8(r16)
    stwio zero, 12(r16)
    subi r16, r16, 1
    bgt r16, zero, ISRAudio500HzLoopHigh    # loop back

    # write high
    movia r17, AUDIO_HIGH
    stwio r17, 8(r16)
    stwio r17, 12(r16)


    # Keep looping and writing zero
    movi r16, AUDIO_500HZ_SAMPLE_COUNT
    subi r16, r16, 2
ISRAudio500HzLoopLow:
    stwio zero, 8(r16)
    stwio zero, 12(r16)
    subi r16, r16, 1
    bgt r16, zero, ISRAudio500HzLoopLow    # loop back

    # write low
    movia r17, AUDIO_LOW
    stwio r17, 8(r16)
    stwio r17, 12(r16)


    br ISRAudioEnd

ISRAudioEnd:
    ldw ra, 0(sp)
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    addi sp, sp, 12

    ret





/*
Checks if both the left and write FIFOs have space for writing
r2 = 1 if there is space
*/
CanWriteAudio:
    subi sp, sp, 16
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw r23, 12(sp)

    movi r2, 1

    movia r16, AUDIO
    ldwio r17, 4(r16)   # get Fifospace register

    movi r23, 0xFF000000
    and r18, r17, r23   # left write space
    beq r18, zero, Full

    movi r23, 0x00FF0000
    andi r18, r17, r23   # right write space
    beq r18, zero, Full

    br CanWriteAudioEnd

Full:
    movi r2, 0
    br CanWriteAudioEnd

CanWriteAudioEnd:
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
    ldw r23, 12(sp)
    addi sp, sp, 16

    ret




# TODO - implement timer to clear FIFO when the sounds should stop
# TODO - determine when to play a sound in main loop
