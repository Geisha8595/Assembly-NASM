; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.88 exercise 6.
;
; A Pythagorean triple is a set of three integers a, b and c such that
; a2 + b2 = c2 . Write an assembly program to determine if an integer,
; c stored in memory has 2 smaller integers a and b making the 3
; integers a Pythagorean triple. If so, then place a and b in memory.

section .data
    c: dq 21269

section .bss
    a: resq 1
    b: resq 1

section .text
    global _start

_start:     mov  rax, [c]
            xor  rbx, rbx
            xor  rcx, rcx
        
while1:     add  rax, rbx
            mov  rbx, rcx
            inc  rbx
            mov  rcx, rbx
            imul rbx, rbx
            sub  rax, rbx
            jle  end_while1
            xor  rdx, rdx
        
while2:     mov  rsi, rdx
            inc  rsi
            mov  rdx, rsi
            imul rsi, rsi
            cmp  rax, rsi
            jg   while2
            jl   while1
            mov  [a], cl
            mov  [b], dl

end_while1: mov  rax, 60
            mov  rdi, 0
            syscall
