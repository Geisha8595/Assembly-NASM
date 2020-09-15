; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.88 exercise 5.
;
; Write an assembly program to perform a "find and replace" 
; oper­ation on a string in memory. Your program should have an input
; array and an output array. Make your program replace every 
; oc­currence of "amazing" with "incredible"

section .data
  inputarray: db "amazing amazing damamzingf amazing" 
  inputarraylen: equ $-inputarray 
  
  replaceable: db "amazing"
  replaceablelen: equ $-replaceable
  
  replacing: db "incredible"
  replacinglen: equ $-replacing

section .bss
    ; size of the outputarry in bytes

    ; replaceable word >= replacing word
    ; outputarray length = inputarray length

    ; replaceable word < replacing word
    ; outputarray length = inputarray length + floor(inputarray length / 
    ; amazing length) * (incredible length - amazing length)

    ; 34 + floor(34/7) * (10-7) = 34 + 4 * 3 = 34 + 12 = 46

    outputarray: resb 46

%define inputarray_end inputarray+inputarraylen

section .text
  global _start

          ; determines the max nr of loops
_start:   mov  rax, inputarraylen
          sub  rax, replaceablelen
          xor  rbx, rbx
          xor  rdx, rdx
          xor  r8, r8

          ; loops through the input array searching for "amazing"
while:    cmp  rbx, rax
          jg  end
          lea  rsi, [inputarray+rbx]
          lea  rdi, [replaceable]
          mov  rcx, replaceablelen
          repe cmpsb
          cmp  rcx, 0
          jnz  miss

          ; checks that "amazing" if found is a standalone word
          ; (the 2 following sections can be uncommented if we want all occurences of "amazing" to be replaced)
          cmp  rsi, inputarray_end
          jz   front
          mov  dil, [rsi]
          cmp  dil, 32
          jnz  miss

front:    sub  rsi, inputarraylen
          dec  rsi
          cmp  rsi, inputarray
          jl   skip
          mov  dil, [rsi]
          cmp  dil, 32
          jnz  miss
         
          ; copies the content from the previous "amazing" to the recently found "amazing" and replaces
          ; the recently found amazing with "incredible"
skip:     lea  rsi, [inputarray+rdx]
          lea  rdi, [outputarray+r8]
          mov  rcx, rbx
          sub  rcx, rdx
          add  r8, rcx
          rep  movsb
          lea  rsi, [replacing]
          mov  rcx, replacinglen
          add  rbx, replaceablelen
          mov  rdx, rbx
          add  r8, replacinglen
          rep  movsb
          jmp  while

miss:     inc  rbx
          jmp  while

          ; copies the rest of the content from the input array to the output array
end:      lea  rsi, [inputarray+rdx] 
          lea  rdi, [outputarray+r8]
          mov  rcx, inputarraylen
          sub  rcx, rdx
          rep  movsb

          mov  rax, 60
          mov  rdi, 0
          syscall