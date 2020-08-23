; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.70 exercise 3.
;
; Write an assembly program to move a quad-word stored in memory
; into a register and then compute the exclusive-or of the 8 bytes
; of the word. Use either ror or rol to manipulate the bits of the
; register so that the original value is retained.

section .data
	value: dq 0x73fc8ba333bd9ca5

section .text
	global _start

_start: mov rbx, [value]
        mov rcx, 0xff

        and rcx, rbx
        ror rbx, 8

        xor rcx, rbx
        ror rbx, 8

        xor rcx, rbx
        ror rbx, 8

        xor rcx, rbx
        ror rbx, 8

        xor rcx, rbx
        ror rbx, 8

        xor rcx, rbx
        ror rbx, 8

        xor rcx, rbx
        ror rbx, 8

        xor rcx, rbx
        ror rbx, 8

        mov rax, 60
        mov rdi, 0
        syscall
