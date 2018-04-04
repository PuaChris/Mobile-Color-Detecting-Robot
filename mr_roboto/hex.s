.equ HEX_3_TO_0, 0xFF200020

.section .text
.global DisplayHex0

# Takes the value of r4 (0-F) and puts the decoded segments in r2 (7 bits)
DecodeHex:
    beq r4, zero, n0

    movi r7, 0x1
    beq r4, r7, n1

    movi r7, 0x2
    beq r4, r7, n2

    movi r7, 0x3
    beq r4, r7, n3

    movi r7, 0x4
    beq r4, r7, n4

    movi r7, 0x5
    beq r4, r7, n5

    movi r7, 0x6
    beq r4, r7, n6

    movi r7, 0x7
    beq r4, r7, n7

    movi r7, 0x8
    beq r4, r7, n8

    movi r7, 0x9
    beq r4, r7, n9

    movi r7, 0xA
    beq r4, r7, nA

    movi r7, 0xB
    beq r4, r7, nB

    movi r7, 0xC
    beq r4, r7, nC

    movi r7, 0xD
    beq r4, r7, nD

    movi r7, 0xE
    beq r4, r7, nE

    movi r7, 0xF
    beq r4, r7, nF

    br n0

n0:
    movi r2, 0b0111111
    br DecodeHexEnd

n1:
    movi r2, 0b0000110
    br DecodeHexEnd

n2:
    movi r2, 0b1011011
    br DecodeHexEnd

n3:
    movi r2, 0b1001111
    br DecodeHexEnd

n4:
    movi r2, 0b1100110
    br DecodeHexEnd

n5:
    movi r2, 0b1101101
    br DecodeHexEnd

n6:
    movi r2, 0b1111101
    br DecodeHexEnd

n7:
    movi r2, 0b0000111
    br DecodeHexEnd

n8:
    movi r2, 0b1111111
    br DecodeHexEnd

n9:
    movi r2, 0b1101111
    br DecodeHexEnd

nA:
    movi r2, 0b1110111
    br DecodeHexEnd

nB:
    movi r2, 0b1111100
    br DecodeHexEnd

nC:
    movi r2, 0b0111001
    br DecodeHexEnd

nD:
    movi r2, 0b1011110
    br DecodeHexEnd

nE:
    movi r2, 0b1111001
    br DecodeHexEnd

nF:
    movi r2, 0b1110001
    br DecodeHexEnd

DecodeHexEnd:
    ret




# Takes the r4 value (0-F) and displays it on HEX0
DisplayHex0:
    subi sp, sp, 8
    stw ra, 0(sp)
    stw r16, 4(sp)

    call DecodeHex
    movia r16, HEX_3_TO_0
    stwio r2, (r16)

    ldw ra, 0(sp)
    ldw r16, 4(sp)
    addi sp, sp, 8

    ret
