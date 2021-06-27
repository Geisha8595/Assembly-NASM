; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.97 exercise 1.
;
; Write an assembly program to produce a billing report for an electric
; company. It should read a series of customer records using scanf
; and print one output line per customer giving the customer details
; and the amount of the bill. The customer data will consist of a name
; (up to 64 characters not including the terminal 0) and a number
; of kilowatt hours per customer. The number of kilowatt hours is
; an integer. The cost for a customer will be $20.00 if the number of
; kilowatt hours is less than or equal to 1000 or $20.00 plus 1 cent
; per kilowatt hour over 1000 if the usage is greater than 1000. Use
; quotient and remainder after dividing by 100 to print the amounts
; as normal dollars and cents. Write and use a function to compute
; the bill amount (in pennies)
;
; I made it more interesting by using the stack for local variables as opposed 
; to using .data and .bss sections. One has to make sure the stack pointer (rsp) 
; is aligned to 16 bytes before using SSE/AVX instructions or functions including
; library functions where the respective instructions are used. This makes it easier 
; for functions to place local variables, which are used with SSE/AVX instructions 
; at 16 byte alignments. Once main is called the stack is aligned to 8 (non-16) bytes. 
; By pushing 8 bytes or subtracting 8 (bytes) from the stack pointer (rsp) the stack 
; pointer gets aligned to 16 bytes. After that you might want to make some room for
; local variables on stack by either pushing or subtracting and storing. Eitherway
; it's recomendable to move the stack pointer (rsp) by a multiple of 16 bytes. This
; way the stack stays aligned to 16 bytes. When a library function is called the return 
; address (8 bytes) of the next intructions gets pushed on stack the stack pointer 
; gets misaligned but once the frame pointer (8 bytes) of the caller function gets 
; pushed on the stack the stack pointer is aligned back to 16 bytes, which is exactly
; what you want in the case where SSE/AVX instructions are used.
;
; Taken from the book "64 Bit Intel Assembly Language Programming for Linux":
; "You can push and pop smaller values than  8 bytes, at some peril. It works as long 
; as the stack remains bounded appropriately for the current operation. So if you push 
; a word and then push a quad-word, the quad-word word push may fail. It is simpler to push 
; and pop only 8 byte quantities". I haven't tested this.
;
; Scanf() doesn't accept strings with spaces!
;
; The return value from scanf() is stored in rax and it tells how many of the inputs 
; specified in the format were successfully picked from stdin stream. If 2 values are 
; specified in the format and 3 or more are given 2 will be the return value of scanf().
; No tests are done on the input
;
; If an attempt to store a value larger than 64 bits in long int is made using scanf() 
; the value will be limited to the max signed value, whereas with smaller variable 
; types, an overfitting value will roll over to the smallest negative value 

%define nr_of_samples 3

section .data
    scanf_fmt: db "%64s %hd",0
    printf_fmt: db "%s: %hd dollars %hd cents",0x0a,0   

section .text
    global main
    extern scanf
    extern printf
    
main:           ; checking the number of samples
                mov   rax, nr_of_samples
                cmp   rax, 0
                jz    .ret
            
                ; storing caller frame pointer and creating a new frame pointer
                ; for the local variables (array below) 
                push  rbp
                mov   rbp, rsp

                ; array of customer names
                mov   rax, 65
                imul  rax, nr_of_samples                   
                sub   rsp, rax
                mov   rbx, rsp
                add   r12, rax              
            
                ; array of kWh/customer
                mov   rax, 2
                imul  rax, nr_of_samples
                sub   rsp, rax
                mov   r13, rsp
                add   r12, rax              

                ; aligning stack pointer to 16 bytes
                mov   rax, rsp
                and   rax, 1111b
                sub   rsp, rax
                add   r12, rax

                ; reading a series of user input (name + kWh)
                xor   r14, r14
.L1:            lea   rdi, [rel scanf_fmt]
                mov   rsi, 65
                imul  rsi, r14
                add   rsi, rbx
                lea   rdx, [r13+r14*2]
                xor   rax, rax
                call  [rel scanf WRT ..got]
                inc   r14
                cmp   r14, nr_of_samples
                jnz   .L1

                ; calculating and printing the bill amount of each customer
                xor   r14, r14
.L2:            movzx rdi, word [r13+r14*2]
                call  clc_kWh_to_pen
                mov   edx, 0xffff0000
                and   edx, eax
                shr   edx, 16
                and   eax, 0xffff
                mov   cx, 100
                div   cx
                mov   cx, dx
                mov   dx, ax
                mov   rsi, 65
                imul  rsi, r14
                add   rsi, rbx
                lea   rdi, [rel printf_fmt]
                xor   rax, rax
                call  [rel printf WRT ..got]
                inc   r14
                cmp   r14, nr_of_samples
                jnz   .L2

                ; cleaning stack
                add   rsp, r12
                leave

.ret:           xor   rax, rax
                ret

; clc_kWh_to_pen(short int kWh) 
clc_kWh_to_pen: sub   rdi, 1000
                setg  al
                movzx rax, al
                imul  rax, rdi
                add   rax, 2000 
                ret
