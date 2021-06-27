; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.97 exercise 4
;
; Write an assembly program to keep track of 10 sets of size 1000000.
; Your program should read accept the following commands: add, union, 
; print and quit. The program should have a function to read the command 
; string and determine which it is and return 0, 1, 2 or 3 depending on 
; the string read. After reading add your program should read a set number 
; from 0 to 9 and an element number from 0 to 999999 and insert the element 
; into the proper set. You need to have a fu:p.ction to add an element to a 
; set. After reading union your program should read 2 set numbers and make 
; the first set be equal to the union of the 2 sets. You need a set union 
; function. After reading print your program should print all the elements of
; the set. You can assume that the set has only a few elements. After reading 
; quit your program should exit.

; Since our stack usage exceeds the default limit (8192 Kbytes), running ulimit -s 11000 (Kbytes)
; before running the actual program is required. The new stack limit is in effect for the current shell
; session.

section .data
    commands: db "add",0,"union",0,"print",0,"default",0
    commands_len: equ 4
    switch: dq add, union, print, quit, def
    printf_fmt: db "%ld",0x0a,0    

section .text
	global main
    extern strtol
    extern printf

main:      push rbp
           mov  rbp, rsp
           sub  rsp, 10000112
    
           ; rbp-101 = input buffer
           ; rbp-109 = pointer to the character following the command
           ; rbp-10000109 = sets (10 x 1 000 000 bytes) 
           ; rbp-10000112 = 16 byte stack alignment

           ; hard coded terminating null character
           mov  [rbp-1], byte 0x0

           ; zeroing the sets
           lea  rdi, [rbp-10000109]
           xor  rax, rax
           mov  rcx, 1000000
           rep  stosb

           ; getting user input
.L1:       lea  rdi, [rbp-101]
           lea  rsi, [rbp-109]
           mov  rdx, 100
           call get_input

           ; calling the matching function
           lea  rdi, [rbp-109]
           lea  rsi, [rbp-10000109]
           imul rax, 8
           lea  rbx, [rel switch]
           add  rbx, rax
           call [rbx]
           cmp  rax, 0
           jz   .L1

           add  rsp, 112
           xor  rax, rax
           leave
           ret

get_input: push rbx       
           push r12         
           push r13         
           push r14         
           mov  rbx, rdi
           mov  r12, rsi
           mov  r13, rdx

           ; rbx = input buffer
           ; r12 = pointer to the character following the command
           ; r13 = length of input buffer
           ; r14 = length of command

           ; getting user input
           mov  rax, 0
           mov  rdi, 0
           mov  rsi, rbx
           mov  rdx, r13
           syscall

           ; switching the newline character (0x0a) to a terminating null character (0x0)
           dec   rax
           mov   cl, [rbx+rax]   
           cmp   cl, 0x0a
           setnz dl
           movzx rcx, cl
           movzx rdx, dl                
           imul  rcx, rdx
           mov   [rbx+rax], cl
           add   rax, rdx         

           ; getting the length of the command
           mov   rdi, rbx
           mov   r14, rax
           mov   rcx, rax
           mov   al, 32
           repne scasb
           sub   r14, rcx
           mov   cl, [rdi-1]
           cmp   cl, 32
           setz  dl
           movzx rdx, dl
           sub   r14, rdx

           ; verifying the command and retrieving the corresponding index in switch array (.data)
           lea   rdi, [rel commands]
           mov   rcx, -1
           xor   r8, r8

;          The less flexible way
;
;          The following snippet of code works only with commands that are under 8 characters in 
;          length. We end up overwriting previously loaded characters if the limit exceeds. Cl is 
;          the only the register that can be used for rotation operations.
;       
;          section .data
;               commands: dq "add","print","union","quit","def"
;                                                                                               
;          mov   rsi, rbx
;          mov   rcx, r14
;          xor   rax, rax
;.more:    lodsb
;          ror   rax, 8
;          dec   rcx
;          cmp   rcx, 0
;          jg    .more
;          mov   rcx, r14
;          imul  rcx, 8
;          rol   rax, cl   
;
;          checking the command and fetching the corresponding index from command array (.data)
;          lea   rdi, [rel commands]    
;          mov   rcx, 5
;          repne scasq
;          mov   rax, 4
;          sub   rax, rcx

.L1:       xor   rax, rax
           repne scasb
           mov   rdx, -1
           sub   rdx, rcx
           mov   rcx, rdx
           dec   rcx
           cmp   rcx, r14
           jnz   .next
           sub   rdi, rcx
           dec   rdi
           mov   rsi, rbx
           repe  cmpsb
           cmp   rcx, 0
           jz    .quit
           add   rdi, rcx
           inc   rdi

.next:     inc   r8
           cmp   r8, commands_len
           jle   .L1

           ; storing the address of the character following the command
.quit:     add   rbx, r14
           mov   [r12], rbx

           pop   r14
           pop   r13
           pop   r12
           pop   rbx
           ret

add:       push  rbp 
           mov   rbp, rsp
           sub   rsp, 8
           push  rbx
           push  r12
           push  r13
           mov   rbx, rsi

           ; rbp-8 = pointer to character (strtol)
           ; rbx = pointer to sets
           ; r12 = set number
           ; r13 = element number

           ; checking for space character after command, e.g. add ...
           mov   rcx, [rdi]
           mov   dl, [rcx]
           cmp   dl, 32
           jnz   .ret

           ; parsing the set number, 0-9
           inc   rcx
           mov   rdi, rcx
           lea   rsi, [rbp-8]
           mov   rdx, 10
           call  [rel strtol WRT ..got]
           
           ; checking for space character after set number, e.g. add 0 ...
           mov   rcx, [rbp-8]
           mov   dl, [rcx]
           cmp   dl, 32
           jnz   .ret

           ; validating the set number range
           cmp   rax, 0
           jl    .ret
           cmp   rax, 9
           jg    .ret
           mov   r12, rax

           ; parsing the element number, 0-999999
           mov   rdi, [rbp-8]
           inc   rdi
           lea   rsi, [rbp-8]
           mov   rdx, 10
           call  [rel strtol WRT ..got]
           
           ; checking for terminating null character after element number, e.g. add 0 100,0
           mov   rcx, [rbp-8]
           mov   dl, [rcx]
           cmp   dl, 0
           jnz   .ret
           
           ; validating the element number range
           cmp   rax, 0
           jl    .ret
           cmp   rax, 999999
           jg    .ret
           mov   r13, rax

           ; storing the element number into the right set
           imul  r12, 1000000
           add   rbx, r12
           mov   [rbx+r13], byte -1
    
.ret:      pop   r13
           pop   r12
           pop   rbx
           add   rsp, 8
           xor   rax, rax
           leave
           ret      

print:     push  rbp
           mov   rbp, rsp
           sub   rsp, 16
           push  rbx
           push  r12

           mov   rbx, rsi

           ; rbp-8 = pointer to caracter (strol)
           ; rbp-16 = 16 byte stack alignment
           ; rbx = pointer to set
           ; r12 = element number

           ; checking for space character after command, e.g. print ...
           mov   rcx, [rdi]
           mov   dl, [rcx]
           cmp   dl, 32
           jnz   .ret       

           ; parsing the set number, 0-9
           inc   rcx
           mov   rdi, rcx
           lea   rsi, [rbp-8]
           mov   rdx, 10
           call  [rel strtol WRT ..got]

           ; checking for terminating null character after element number, e.g. print 0,0
           mov   rcx, [rbp-8]
           mov   dl, [rcx]
           cmp   dl, 0
           jnz   .ret

           ; validating the set number range
           cmp   rax, 0
           jl    .ret
           cmp   rax, 9
           jg    .ret
           
           ; printing the set
           imul  rax, 1000000
           add   rbx, rax
           xor   r12, r12

.L1:       mov   rax, rbx
           add   rax, r12
           mov   cl, [rax]
           cmp   cl, -1
           jnz   .skip

           lea   rdi, [rel printf_fmt]
           mov   rsi, r12
           xor   rax, rax
           call  [rel printf WRT ..got]

.skip:     inc   r12
           cmp   r12, 1000000
           jle   .L1

.ret:      pop   r12
           pop   rbx  
           add   rsp, 16
           xor   rax, rax
           leave
           ret          

union:     push  rbp
           mov   rbp, rsp     
           sub   rsp, 8
           push  rbx
           push  r12
           push  r13
           push  r14
           push  r15

           mov   rbx, rsi

           ; rbp-8 = pointer to character (strtol)
           ; rbx = pointer to sets/element holder (set 1)
           ; r12 = set 1
           ; r13 = set 2
           ; r14 = element number
           ; r15 = element holder (set 2)

           ; checking for space character after command, e.g. union ...
           mov   rcx, [rdi]
           mov   dl, [rcx]
           cmp   dl, 32
           jnz   .ret 

           ; parsing the set number 1, 0-9
           inc   rcx
           mov   rdi, rcx
           lea   rsi, [rbp-8]
           mov   rdx, 10
           call  [rel strtol WRT ..got]

           ; checking for space character after set number 1, e.g. union 0 ...
           mov   rcx, [rbp-8]
           mov   dl, [rcx]
           cmp   dl, 32
           jnz   .ret

           ; validating the set number 1 range
           cmp   rax, 0
           jl    .ret
           cmp   rax, 9
           jg    .ret
           mov   r12, rax

           ; checking for space character after set number 1, e.g. union 0 ...
           mov   rcx, [rbp-8]
           mov   dl, [rcx]
           cmp   dl, 32
           jnz   .ret

           ; parsing the set number 2, 0-9
           mov   rdi, [rbp-8]
           inc   rdi
           lea   rsi, [rbp-8]
           mov   rdx, 10
           call  [rel strtol WRT ..got]

           ; checking for terminating null character after element number 2, e.g. union 0,0
           mov   rcx, [rbp-8]
           mov   dl, [rcx]
           cmp   dl, 0
           jnz   .ret

           ; validating the set number 2 range
           cmp   rax, 0
           jl    .ret
           cmp   rax, 9
           jg    .ret
           mov   r13, rax

           ; performing union operation
           imul  r12, 1000000
           add   r12, rbx
           imul  r13, 1000000
           add   r13, rbx

           xor   r14, r14

.L1:       mov   bl, [r12+r14]
           mov   r15b, [r13+r14]
           or    bl, r15b
           mov   [r12+r14], bl
           inc   r14
           cmp   r14, 1000000
           jle   .L1

.ret:      pop   r15
           pop   r14
           pop   r13
           pop   r12
           pop   rbx
           xor   rax, rax
           leave
           ret
           
           ; checking for null character after command
quit:      mov   rcx, [rdi]
           mov   dl, [rcx]
           cmp   dl, 0
           setz  al
           movzx rax, al
           ret

           ; dummy function
def:       xor   rax, rax
           ret