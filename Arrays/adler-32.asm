; "64 Bit Intel Assembly Language Programming for Linux"

; p.111 exercise 3.

; Write an assembly program to compute the Adler-32 checksum value for the sequence of bytes 
; read using fgets to read 1 line at a time until end of file. The prototype for fgets is

; char *fgets (char *s, int size ,FILE *fp);

; The parameter s is a character array which should be in the bss segment. The parameter size 
; is the number of bytes in the array s. The parameter fp is a pointer and you need stdin. Place 
; the following line in your code to tell the linker about stdin

; extern stdin

; fgets will return the parameter s when it succeeds and will return 0 when it fails. You are to 
; read until it fails. The Adler-32 checksum is computed by

; long adler32 (char *data , int len)
; {
;     long a = 1, b = 0;
;     int i;
;
;     for(i = 0 ; i < len ; i++) {
;        a = (a + data [i] ) % 65521;
;        b = (b + a) % 65521;
;     }
;     return (b << 16) | a;
; }

; Your code should compute 1 checksum for the entire file. If you use the function shown for 1 line, 
; it works for that line, but calling it again restarts . . .

; I'd problems with the "extern stdin" so I went with the syscall for reading 1 line at a time. The 
; syscall returns the nr of given charater including the newline character (10) if there's room for it.

section .text
	global main

main:   push rbp
        mov  rbp, rsp
        sub  rsp, 128

.L1:    mov  rax, 0
        mov  rdi, 0
        lea  rsi, [rbp-100]
        mov  rdx, 100
        syscall
        cmp  rax, 1
        jz   .ret

        dec   rax                
        mov   bl, [rbp-100+rax]
        cmp   bl, 10
        setnz cl
        movzx rcx, cl
        add   rax, rcx

        lea  rdi, [rbp-100]
        mov  rsi, rax
        call adlr32

.ret:   add  rsp, 128
        xor  rax, rax
        leave
        ret

adlr32: push  rbp
        push  rbx
        push  r12
        push  r13
        push  r14
        push  r15

        mov   rbp, 1
        xor   rbx, rbx
        xor   r12, r12
        mov   r13, 65521

.L1:    cmp   r12, rsi
        jz    .ret
        movzx r14, byte [rdi+r12]
        add   rbp, r14
        mov   rax, rbp
        xor   rdx, rdx
        div   r13
        mov   rbp, rdx
        add   rbx, rbp
        mov   rax, rbx
        xor   rdx, rdx
        div   r13
        mov   rbx, rdx     
        inc   r12
        jmp   .L1

.ret:   shl   rbx, 16
        or    rbx, rbp
        mov   rax, rbx    

        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  rbx
        pop  rbp
        ret
