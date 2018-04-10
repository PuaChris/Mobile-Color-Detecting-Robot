.equ JP1, 0XFF200060
.equ PUSHBUTTONS, 0xFF200050
.equ SP, 0X80000000


# Global Registers:

# r13 - PWM state
.equ PWM_OFF, 0
.equ PWM_ON, 1

# r14 - movement state
.equ MOVEMENT_STOP, 0
.equ MOVEMENT_FORWARD, 1
.equ MOVEMENT_BACKWARD, 2
.equ MOVEMENT_LEFT, 3
.equ MOVEMENT_RIGHT, 4

# r15 - audio to play
.equ AUDIO_EMPTY, 0
.equ AUDIO_500Hz, 1


.global JP1

.global MOVEMENT_STOP
.global MOVEMENT_FORWARD
.global MOVEMENT_BACKWARD
.global MOVEMENT_LEFT
.global MOVEMENT_RIGHT

.global AUDIO_EMPTY
.global AUDIO_500Hz



.section .text
.global _start

_start:
	# Setup stack
	movia sp, SP

	# Setup devices and interrupts
	call SetupTimer
	call SetupLego
	call SetupAudio
	call SetupButton

	# Defaults
	movi r13, PWM_OFF
	movi r14, MOVEMENT_STOP
	movi r15, AUDIO_EMPTY

	#Enable global interrupt
	movi r16, 0b1
	wrctl status, r16

	# Start PWM off
	call StartPWMOffTimer

# Main loop
loop:
	call DetectColor
	br loop

end:
	br end
