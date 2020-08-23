; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.87 exercise 4.
;
; Write an assembly program to determine if a string stored in mem­-
; ory is a palindrome. A palindrome is a string which is the same after
; being reversed, like "refer" . Use at least one repeat instruction.
;
; Program sets the return value rdi to 1 if string is not a palindrome.
; Inspect the return value with echo $? 

section .data
	string: db "racecar"
	length: equ $-string

section .text
	global _start

_start:  mov    rbx, 1
         mov    rcx, length
         mov    rsi, string
         xor    rdi, rdi

for:     cmp    rcx, 0
         jz     end_for
         mov    dl, [string+rcx-1]
         lodsb
         dec    rcx
         cmp    al, dl
         jz     for

end_for: mov    rax, 60
         cmovnz rdi, rbx
         syscall 