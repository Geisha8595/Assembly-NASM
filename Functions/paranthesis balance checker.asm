; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.98 exercise 7.
;
; Write an assembly program to read a string of left and right paren­
; theses and determine whether the string contains a balanced set of
; parentheses. You can read the string with scanf using "%79s" into
; a character array of length 80. A set of parentheses is balanced if
; it is the empty string or if it consists of a left parenthesis followed
; by a sequence of balanced sets and a right parenthesis. Here's an
; example of a balanced set of parentheses: " ((()())())".

section .data
	fmt: db "%79s",0
	msg0: db "not balanced",0x0a,0
	msg1: db "balanced",0x0a,0

section .text
      global main
      extern scanf
      extern printf

main: push  rbp
      mov   rbp, rsp
      sub   rsp, 96
      
      lea   rax, [rel msg0]
      mov   [rbp-96], rax
      lea   rax, [rel msg1]
      mov   [rbp-88], rax
      
      lea   rdi, [rel fmt]
      lea   rsi, [rbp-80]
      xor   rax, rax
      call  [rel scanf WRT ..got]
      
      xor   rax, rax
      xor   rdi, rdi

.L1:  mov   cl, [rbp-80+rax]
      cmp   cl, 0
      jz    .ret
      cmp   cl, 40
      setz  dl
      movzx rdx, dl
      add   rdi, rdx
      cmp   cl, 41
      setz  dl
      movzx rdx, dl
      sub   rdi, rdx
      inc   rax
      jmp   .L1

.ret: cmp   rdi, 0
      setz  cl
      movzx rcx, cl
      mov   rdi, [rbp-96+rcx*8]
      xor   rax, rax
      call  [rel printf WRT ..got]

      add   rsp, 96
      xor   rax, rax
      leave
      ret