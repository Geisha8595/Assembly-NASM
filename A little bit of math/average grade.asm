; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.60 exercise 3.
;
; Write an assembly language program to compute the average of 4
; grades. Use memory locations for the 4 grades. Make the grades all
; different numbers from 0 to 100. Store the average of the 4 grades in
; memory and also store the remainder from the division in memory

section .data
	grade1: db 2
	grade2: db 2
	grade3: db 2
	grade4: db 5

section .bss
	average: resb 1
	remainder: resb 1

section .text
	global _start

_start: movzx rax, byte [grade1]
	    movzx rbx, byte [grade2]
	    movzx rcx, byte [grade3]
	    movzx rdx, byte [grade4]
	    add   ax, bx
	    add   ax, cx
	    add   ax, dx

        mov   bl, 4
	    div   bl

	    mov   [average], al
	    mov   [remainder], ah

	    mov   rax, 60
	    mov   rdi, 0
	    syscall