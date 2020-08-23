; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.87 exercise 2.
;
; Write an assembly program to compute Fibonacci numbers stor-­
; ing all the computed Fibonacci numbers in a quad-word array in
; memory. Fibonacci numbers are defined by
; 
;            fib{O) = 0
;            fib{l) = 1
;            fib(i) = fib(i - 1 ) + fib(i - 2) for i > 1
; 
; What is the largest i for which you can compute f ib(i)?
;
; At first I ran the program with the lines associated with fib_array commented out.
; The program loops and counts the iterations until carry flag is set. In gdb I wrote 
; the commands in the following order: break _start, run, record, break p87e2.asm:43 
; if $rax == 60, continue. I didn't know how to halt the program once carry flag was set. 
; At the second breakpoint I inspected the rdx register and got 93. Recording the 
; execution allowed me to reverse the execution and I found out that the last fibonacci 
; number was 12,200,160,415,121,876,738. After the first run I uncommented the lines
; mentioned above, allocated an array of 93 quadwords and ran the program again.

section .bss
	 fib_array: resq 93

section .text
	global _start

_start:    mov rax, 1
           xor rbx, rbx
           xor rdx, rdx

while:     mov [fib_array], rax
           inc rdx
           add rbx, rax
           mov rcx, rax
           mov rax, rbx
           mov rbx, rcx
           jnc while

           mov rax, 60
           mov rdi, 0
           syscall
