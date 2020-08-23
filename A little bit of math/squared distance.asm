; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.60 exercise 1.
;
; Write an assembly language program to compute the distance squared
; between 2 points in the plane identified as 2 integer coordinates
; each, stored in memory.
;
; Remember the Pythagorean Theorem!
;
; Here we need to pick the rigth sized registers carefully so that we don't end up
; in a situation where the registers meant for storing the results are too small.
; After multiplication the bit length of the product will max(a,b) at least or
; a+b at most where a and b are the bit lengths of the factors in binary. In this
; case a and b are equal. Imul instruction is used for signed multiplication whereas
; mul is used for unsigned multiplication. Imul is also more flexible than mul since
; it allows you the choose which registers to use for the multiplication.
;
; There might be exercises where I've mistakenly used imul instead of mul.

section .data
    ; this program handles values ranging from -32768 to 32767
    point1_x: dw -32768
	point1_y: dw -32768
	point2_x: dw  32767
	point2_y: dw  32767

section .bss
	distance: resq 1

section .text
	global _start

_start: movzx ax, [point1_x]
        mov   bx, ax
	    movzx cx, [point2_x]
	    
	    sub   ax, cx
        sub   cx, bx
        mov   bx, cx
	    cmovs cx, ax 
	    cmovs cx, bx ; the result is intepreted as an unsigned value (check slope.asm file)

	    imul  ecx, ecx

        movzx ax, [point1_y]
	    mov   cx, ax
        movzx dx, [point2_y]

	    sub   ax, dx
	    sub   dx, cx
    	mov   cx, dx 
    	cmovs dx, ax
    	cmovo dx, cx
	
        imul  edx, edx

	    add   rcx, rdx

    	mov   rax, 60
	    mov   rdi, 0
	    syscall
