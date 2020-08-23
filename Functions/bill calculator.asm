; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.97 exercise 1.
;
; Write an assembly program to produce a billing report for an electric
; company. It should read a series of customer records using scanf
; and print one output line per customer giving the customer details
; and the amount of the bill. The customer data will consist of a name
; ( up to 64 characters not including the terminal 0 ) and a number
; of kilowatt hours per customer. The number of kilowatt hours is
; an integer. The cost for a customer will be $20.00 if the number of
; kilowatt hours is less than or equal to 1000 or $20.00 plus 1 cent
; per kilowatt hour over 1000 if the usage is greater than 1000. Use
; quotient and remainder after dividing by 100 to print the amounts
; as normal dollars and cents. Write and use a function to compute
; the bill amount ( in pennies )

; The push rbp pushes the current frame base address on the stack and mov rbp, rsp
; 



; and move rbp, rsp operations could be replaced by either 
; sub rsp, 8 or push 8 byte register. Leave instruction undoes the push
; rbp and move rbp, rsp and could be replaced by add rsp, 8 or pop 8 byte
; register. When call instuction is being excecuted, the 8 byte return address 
; is pushed on the stack and as a result the stack is aligned to 16 byte (8 byte + 8 byte). 
; If register contents are saved on the stack by pushing or the number of registers
; reserved for passing parameters to functions is not enough and the rest of the
; parameters is pushed on the stack, measures has to be taken to make sure the 
; stack is aligned to 16 byte. 
; Apparently the SSE and AVX instructions which are used for parallel calculations 
; require this but some sources state that stack misalignment just slows down the 
; execution of these instructions because extra steps has to be performed to get the 
; wanted data to the right place. 
; How misalignment is handled in general depends on the hardware. Some recognises it 
; and performs the additional steps which takes longer, some recognised it but can't 
; handle it, instead they throw an exception and some just crash. I don't know why stack 
; alignment is required for scanf. Printf seems to do fine without it. The push rbp, move 
; rbp, rsp and leave operations make debugging stack frames possible. I'm going to take a 
; deeper look at that in the exercise 6 (same chapter) where recursive functions are used.
; There might be differences between instructions

; x86 ABI (Application Binary Interface) is worth reading. Something what I seem to be doing
; is avoiding using registers in calle functions that are used in caller functions. This is
; not a good approach especially when the programs get larger. The registers contents should
; be pushed (saved) on the stack.

; The return value from scanf is stored in rax and it tells how many of the inputs specified
; in the scanf format were successfully picked from stdin stream. If only 2 inputs are acceptable
; 3 inputs has to be specified in the scanf format because if only 2 inputs were specified in
; scanf format and 3 inputs were given scanf would return 2. Ascii numbers could be used
; to verify the character array input.

%define nr_of_samples 3

section .data
    printf_format: db "%s: %hd dollars %hd cents",0x0a,0
    scanf_format: db "%64s %hd",0
    name_array: times 64 db 0    

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