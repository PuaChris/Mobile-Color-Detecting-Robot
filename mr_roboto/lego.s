.equ LEGO_DIRECTION,			0x07F557FF
.equ LEGO_DEFAULT,				0xFFFFFFFF
.equ LEGO_LOAD_THRESHOLD_BASE, 	0xFFBFFFFF
.equ LEGO_THRESHOLD_TEMPLATE, 	0xF87FFFFF
.equ LEGO_STATE_MODE,			0xFFDFFFFF
.equ LEGO_INTERRUPTS,			0xF8000000


/******************************** QUESTION *************************************/
#is r2 the global variable?

#r2 is a return value from a subroutine

.section .text
.global SetupLego


# Sets up the Lego by reading the current sensor 0 value and setting it as the threshold
# Enables interrupts in state mode
SetupLego:
	subi sp, sp, 12
	stw ra, 0(sp)
	stw r16, 4(sp)
	stw r17, 8(sp)

	movia r16, JP1

	# Setup Lego direction register
	movia r17, LEGO_DIRECTION
	stwio r17, 4(r16)

	# Get and set sensor threshold
	call GetSensor0Value
	mov r4, r2
	call SetSensorThresholds

	# Enable state mode
	movia r17, LEGO_STATE_MODE
	stwio r17, 0(r16)

	# Enable interrupts on any sensor on Lego
	movia r17, LEGO_INTERRUPTS
	stwio r17, 8(r16)

	# Enable Lego controller (JP1) interrupt on Nios
	rdctl r16, ienable
	ori r16, r16, 0b1 << 11
	wrctl ienable, r16

	ldw ra, 0(sp)
	ldw r16, 4(sp)
	ldw r17, 8(sp)
	addi sp, sp, 12
	ret




# ------------------------------------------------------------------------------
# Returns sensor 0's value in r2 (4 bits)
GetSensor0Value:
	subi sp, sp, 12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)

	movia r16, JP1
	movia r17, LEGO_DEFAULT



	/******************************** QUESTION *************************************/
	# Confused about the operation here. Why did you 'or' it if r17 is 0xffffffff

	# It was meant to activate value mode, but wasn't really necessary

	# Value mode
	# Sensor 0 on
	movi r18, 0b1 << 10
	nor r18, r18, zero	# flips all bits
	and r17, r17, r18

	# Write to Lego
	stwio r17, 0(r16)

	# Loop until the sensor 0 value is valid
Sensor0Loop:
	ldwio r17, 0(r16)
	srli r17, r17, 11
	andi r17, r17, 0b1
	bne r17, zero, Sensor0Loop

/******************************** QUESTION *************************************/
	#Confused about the operation here. What value are you retrieving?

	# Read sensor 0 value ("sensor read value" bits)
	ldwio r2, 0(r16)
	srli r2, r2, 27
	andi r2, r2, 0b1111

	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12
	ret




# ------------------------------------------------------------------------------
# Sets all 5 sensors to the given threshold
# r4 - new threshold (4 bits)
SetSensorThresholds:
/**************** FOUND A BUG ********************************/
#ra was not stored onto the stack 

	subi sp, sp, 28
	stw ra, 0(sp)
	stw r16, 4(sp)
	stw r17, 8(sp)
	stw r18, 12(sp)
	stw r19, 16(sp)
	stw r20, 20(sp)
	stw r23, 24(sp)

	# Display the threshold on HEX0
	# Preserve r4, just in case
	mov r16, r4
	call DisplayHex0
	mov r4, r16


	movia r16, JP1


	# threshold mask
	slli r4, r4, 23

	# old value with threshold of 9 was 0x04AFC1FF
	# In value mode, loading threshold for each sensor (0-4)

	# Index of which bit to make 0 to select a sensor
	movi r19, 10
ThresholdLoop:
	# Put a 0 in the proper bit for the sensor
	movi r18, 0b1
	sll r18, r18, r19
	nor r18, r18, zero

	# Create sequence to load a threshold
	movia r17, LEGO_LOAD_THRESHOLD_BASE	# load, value
	and r17, r17, r18					# sensor on


/**************** FOUND A BUG ********************************/
#When you 'and' with r17 and r4, r17 is left with just the value of the threshold
#and the rest of the configuration is 0

	movia r20, LEGO_THRESHOLD_TEMPLATE 	# 0xF87FFFFF
	#used to be able to insert the threshold into the data register without losing 
	#the rest of the information 

	or r20, r20, r4						
	and r17, r17, r20					# threshold

	# Write threshold value
	stwio r17, 0(r16)

	# Disable sensor for loading
	movia r17, LEGO_DEFAULT
	stwio r17, 0(r16)

	# Check if all sensors have been loaded
	addi r19, r19, 2
	movi r23, 18	# Bit index of sensor 4
	ble r19, r23, ThresholdLoop
# End loop

	ldw ra,  0(sp)
	ldw r16, 4(sp)
	ldw r17, 8(sp)
	ldw r18, 12(sp)
	ldw r19, 16(sp)
	ldw r20, 20(sp)
	ldw r23, 24(sp)
	addi sp, sp, 28
	ret
