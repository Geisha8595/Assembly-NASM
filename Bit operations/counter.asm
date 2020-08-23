; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.70 exercise 1.
;
; Write an assembly program to count all the 1 bits in a byte stored
; in memory. Use repeated code rather than a loop.

section .data
	array: db 11101010b

section .text
	global _start

_start:
    mov  al, [array]
    xor  dil, dil
    mov  bl, 0

    bt   ax, bx
    setc cl
    add  dil, cl
    inc  bx

    bt   ax, bx
    setc cl
    add  dil, cl
    inc  bx

    bt   ax, bx
    setc cl
    add  dil, cl
    inc  bx

    bt   ax, bx
    setc cl
    add  dil, cl
    inc  bx

    bt   ax, bx
    setc cl
    add  dil, cl
    inc  bx

    bt   ax, bx
    setc cl
    add  dil, cl
    inc  bx

    bt   ax, bx
    setc cl
    add  dil, cl
    inc  bx

    bt   ax, bx
    setc cl
    add  dil, cl
    inc  bx
    
    mov  rax, 60
    syscall
