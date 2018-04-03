.equ AUDIO, 0xFF203040

# For control register
.equ CLEAR_AUDIO, 0b1 << 3

# Number of samples to skip between high/low values
.equ AUDIO_500HZ_SAMPLE_COUNT, 48

# Number of samples to fill 75% of FIFO queue
.equ AUDIO_75_PCT_SAMPLE_COUNT, 96

# Highest and lowest audio values
#.equ AUDIO_HIGH,    0x7FFFFFFF
#.equ AUDIO_LOW,     0x80000000
.equ AUDIO_HIGH,	+10000000
.equ AUDIO_LOW,     -10000000




.section .text

.global SetupAudio
.global PlayAudioEmpty
.global PlayAudio500Hz


# ------------------------------------------------------------------------------
/*
Sets up audio output (with interrupts)
*/
SetupAudio:
	subi	sp, sp, 8
	stw 	r16, 0(sp)
	stw 	r17, 4(sp)
	
	# Enable write interrupt on audio device
	movia	r16, AUDIO
	movi 	r17, 0b10
	stwio 	r17, 0(r16)

	# Enable audio interrupt on Nios
    rdctl 	r16, ienable
	ori 	r16, r16, 0b1 << 6
	wrctl 	ienable, r16

	ldw 	r16, 0(sp)
	ldw 	r17, 4(sp)
	addi 	sp, sp, 8

	ret





# ------------------------------------------------------------------------------
/*
Plays an empty sound (fills the FIFO with zeros)
*/
PlayAudioEmpty:
    subi    sp, sp, 8
    stw     r16, 0(sp)
	stw		r17, 4(sp)
	
	movia	r16, AUDIO

    # Keep looping and writing zero
    movi    r17, AUDIO_500HZ_SAMPLE_COUNT
    addi    r17, r17, AUDIO_500HZ_SAMPLE_COUNT
    subi    r17, r17, 1
PlayAudioEmptyLoop:
    stwio   zero, 8(r16)  # left
    stwio   zero, 12(r16) # right
    subi    r17, r17, 1
    bgt     r17, zero, PlayAudioEmptyLoop	# loop back


PlayAudioEmptyEnd:
    ldw     r16, 0(sp)
	ldw		r17, 4(sp)
    addi    sp, sp, 8

    ret








# ------------------------------------------------------------------------------
/*
Plays a 500Hz sound
*/
PlayAudio500Hz:
    subi    sp, sp, 12
    stw     r16, 0(sp)
    stw     r17, 4(sp)
	stw		r18, 8(sp)
	
	movia	r16, AUDIO

	# Keep looping and writing high (50% cycle)
	movia 	r18, AUDIO_HIGH
    movi    r17, AUDIO_500HZ_SAMPLE_COUNT
    subi    r17, r17, 1
PlayAudio500HzLoopHigh:
    stwio   r18, 8(r16)  # left
    stwio   r18, 12(r16) # right
    subi    r17, r17, 1
    bgt     r17, zero, PlayAudio500HzLoopHigh

	# Keep looping and writing low (50% cycle)
	movia	r18, AUDIO_LOW
    movi    r17, AUDIO_500HZ_SAMPLE_COUNT
    subi    r17, r17, 1
PlayAudio500HzLoopLow:
    stwio   r18, 8(r16)
    stwio   r18, 12(r16)
    subi    r17, r17, 1
    bgt     r17, zero, PlayAudio500HzLoopLow

PlayAudio500HzEnd:
    ldw     r16, 0(sp)
    ldw     r17, 4(sp)
	ldw		r18, 8(sp)
    addi    sp, sp, 12

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
