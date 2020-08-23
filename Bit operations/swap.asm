; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.70 exercise 2.
;
; Write an assembly program to swap 2 quad-words in memory using
; xor. Use the following algorithm:
;
;              a = a ^ b
;              b = a ^ b
;              a = a ^ b

section .data
	quadword1: dq 0xFFFFFFFFFFFFFFFF
	quadword2: dq 0x1111111111111111

section .text
	global _start

_start: mov rax, [quadword1]
        mov rbx, [quadword2]
    
        xor rax, rbx
        xor rbx, rax
        xor rax, rbx
    
        mov rax, 60
        mov rdi, 0
        syscall