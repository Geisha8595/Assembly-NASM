; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.97 exercise 1.
;
; Write an assembly program to produce a billing report for an electric company. 
; It should read a series of customer records using scanf and print one output line 
; per customer giving the customer details and the amount of the bill. The customer
; data will consist of a name (up to 64 characters not including the terminal 0) and 
; a number of kilowatt hours per customer. The number of kilowatt hours is an integer. 
: The cost for a customer will be $20.00 if the number of kilowatt hours is less than or 
; equal to 1000 or $20.00 plus 1 cent per kilowatt hour over 1000 if the usage is greater 
; than 1000. Use quotient and remainder after dividing by 100 to print the amounts as normal 
; dollars and cents. Write and use a function to compute the bill amount (in pennies).

%define nr_of_samples 3

section .data
    printf_format: db "%s: %hd dollars %hd cents",0x0a,0
    scanf_format: db "%64s %hd",0
    name_array: times 65 db 0    

section .bss
    kWh_array: resw nr_of_samples
    dollars: resw 1
    pennies: resw 1

section .text
    global main
    extern scanf
    extern printf

main:           xor    rbx, rbx

for1:           cmp    rbx, nr_of_samples
                jz     end_for1
                push   rbp
                mov    rbp, rsp
                lea    rdi, [scanf_format]
                lea    rsi, [name_array+rbx*8]
                lea    rdx, [kWh_array+rbx*2]
                xor    rax, rax
                call   scanf
                leave
                inc    rbx
                jmp    for1

end_for1:       xor    rbx, rbx

for2:           cmp    rbx, nr_of_samples
                jz     end_for2
                push   rbp
                mov    rbp, rsp
                movzx  rdi, word [kWh_array+rbx*2]
                call   kWh_to_pennies
                leave
                mov    rcx, 100
                div    cx  
                mov    [dollars], ax
                mov    [pennies], dx
                push   rbp
                mov    rbp, rsp
                lea    rdi, [printf_format]
                lea    rsi, [name_array+rbx*8]
                movsx  rdx, word [dollars]
                movsx  rcx, word [pennies]
                xor    rax, rax
                call   printf
                leave
                inc    rbx
                jmp    for2

end_for2:       xor    rax, rax
                ret

kWh_to_pennies: mov    rax, rdi
                xor    rdi, rdi
                sub    rax, 1000
                cmovle rax, rdi
                add    rax, 2000
                mov    rdx, 0xffff0000
                and    rdx, rax
                ror    rdx, 16
                and    rax, 0xffff
                ret         
