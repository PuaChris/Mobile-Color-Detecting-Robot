.equ AUDIO, 0xFF203040

# For control register
.equ CLEAR_AUDIO, 0b1 << 3

# Number of samples to skip between high/low values
.equ AUDIO_500HZ_SAMPLE_COUNT, 48

# Number of samples to fill 75% of FIFO queue
.equ AUDIO_75_PCT_SAMPLE_COUNT, 96

# Highest and lowest audio values
.equ AUDIO_HIGH,    0x7FFFFFFF
.equ AUDIO_LOW,     0x80000000




.section .text

.global SetupAudio
.global PlayAudioEmpty
.global PlayAudio500Hz


# ------------------------------------------------------------------------------
/*
Sets up audio output (with interrupts)
*/
SetupAudio:
	subi sp, sp, 8
	stw r16, 0(sp)
	stw r17, 4(sp)

	# Write interrupt enable
	movia r16, AUDIO
	movi r17, 0b10
	stwio r17, 0(r16)

	# Enable audio interrupt
    rdctl r16, ienable
	ori r16, 0b1 << 6
	wrctl ienable, r16

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	addi sp, sp, 8

	ret





# ------------------------------------------------------------------------------
/*
Plays an empty sound (fills the FIFO with zeros)
*/
PlayAudioEmpty:
    subi    sp, sp, 4
    stw     r16, 0(sp)

    # Keep looping and writing zero
    movi    r16, AUDIO_500HZ_SAMPLE_COUNT
    addi    r16, AUDIO_500HZ_SAMPLE_COUNT
    subi    r16, r16, 1
PlayAudioEmptyLoopHigh:
    stwio   zero, 8(r16)  # left
    stwio   zero, 12(r16) # right
    subi    r16, r16, 1
    bgt     r16, zero, Audio500HzLoopHigh    # loop back


PlayAudioEmptyEnd:
    ldw     r16, 0(sp)
    addi    sp, sp, 4

    ret








# ------------------------------------------------------------------------------
/*
Plays a 500Hz sound
*/
PlayAudio500Hz:
    subi    sp, sp, 8
    stw     r16, 0(sp)
    stw     r17, 4(sp)

    # Keep looping and writing zero
    movi    r16, AUDIO_500HZ_SAMPLE_COUNT
    subi    r16, r16, 2
PlayAudio500HzLoopHigh:
    stwio   zero, 8(r16)  # left
    stwio   zero, 12(r16) # right
    subi    r16, r16, 1
    bgt     r16, zero, PlayAudio500HzLoopHigh    # loop back

    # write high
    movia   r17, AUDIO_HIGH
    stwio   r17, 8(r16)   # left
    stwio   r17, 12(r16)  # right


    # Keep looping and writing zero
    movi    r16, AUDIO_500HZ_SAMPLE_COUNT
    subi    r16, r16, 2
PlayAudio500HzLoopLow:
    stwio   zero, 8(r16)
    stwio   zero, 12(r16)
    subi    r16, r16, 1
    bgt     r16, zero, PlayAudio500HzLoopLow    # loop back

    # write low
    movia   r17, AUDIO_LOW
    stwio   r17, 8(r16)
    stwio   r17, 12(r16)


PlayAudio500HzEnd:
    ldw     r16, 0(sp)
    ldw     r17, 4(sp)
    addi    sp, sp, 8

    ret




# ------------------------------------------------------------------------------
/*
Checks if both the left and write FIFOs have space for writing
Sets r2 = 1 if there is space, or r2 = 0 if it is full
*/
CanWriteAudio:
    subi    sp, sp, 16
    stw     r16, 0(sp)
    stw     r17, 4(sp)
    stw     r18, 8(sp)
    stw     r23, 12(sp)

    # Available by default
    movi    r2, 1

    # Get Fifospace register
    movia   r16, AUDIO
    ldwio   r17, 4(r16)

    # Get left write space
    movia   r23, 0xFF << 24
    and     r18, r17, r23
    beq     r18, zero, CanWriteAudioFull

    # Get right write space
    movia   r23, 0xFF << 16
    and     r18, r17, r23
    beq     r18, zero, CanWriteAudioFull

    br      CanWriteAudioEnd

CanWriteAudioFull:
    movi    r2, 0
    br      CanWriteAudioEnd

CanWriteAudioEnd:
    ldw     r16, 0(sp)
    ldw     r17, 4(sp)
    ldw     r18, 8(sp)
    ldw     r23, 12(sp)
    addi    sp, sp, 16

    ret
