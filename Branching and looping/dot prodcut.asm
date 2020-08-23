; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.87 exercise 1.
;
; Write an assembly program to compute the dot product of 2 arrays,
; i.e.
;                         n-1
;                      p = E ai * bi
;                         i=O
;
; Your arrays should be double word arrays in memory and the dot
; product should be stored in memory.
;
; The following program can handle signed numbers ranging from
; -2147483648to 2147483647 and it will set the return value to 1
; and quit if overflow occurs during the calculation of dotproduct

section .data
	array1: dd 4294967295,4294967295
	array1_end: db 0
	array2: dd 4294967295,4294967295
	array2_end: db 0

section .bss
	dotproduct: resd 1

section .text
	global _start

         ; checks that the arrays are equally sized before proceeding
_start:  mov   rax, array1_end
         sub   rax, array1
         mov   rbx, 4
         div   ebx
         mov   rcx, rax
         mov   rax, array2_end
         sub   rax, array2
         div   ebx
         cmp   rax, rcx
         jnz   else

         mov   r8, 1
         xor   rbx, rbx
         xor   rdx, rdx
         xor   rdi, rdi

for:     cmp   rbx, rcx
         jz    end_for
         movsx rax, dword [array1+rbx*4]
         movsx rsi, dword [array2+rbx*4]
         inc   rbx
         imul  rax, rsi
         add   rdx, rax
         cmovo rdi, r8
         jno   for

end_for: mov   [dotproduct], rdx

else:    mov   rax, 60
         syscall
