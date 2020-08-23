; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.70 exercise 4.
;
; Write an assembly program to dissect a double stored in memory.
; This is a 64 bit floating point value. Store the sign bit in one
; memory location. Store the exponent after subtracting the bias
; value into a second memory location. Store the fraction field with
; the implicit 1 bit at the front of the bit string into a third memory
; location.

section .data
	double: dq 1.77

section .bss
	signbit: resb 1
	exponent: resw 1
	fraction: resq 1

section .text
	global _start

_start: mov rax, [double]
        
        rol rax, 1
        mov rbx, 1
        and rbx, rax
        mov [signbit], bl
	
        rol rax, 11
        mov rbx, 0x7ff
        and rbx, rax
        sub rbx, 1023
        mov [exponent], ax

        rol rax, 52
        mov rbx, 0xfffffffffffff
        and rbx, rax
        mov rcx, 0x10000000000000
        or  rbx, rcx
        mov [fraction], rbx

        mov rax, 60
        mov rdi, 0
        syscall