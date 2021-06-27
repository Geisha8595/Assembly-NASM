; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.97 exercise 2.
;
; Write an assembly program to generate an array of random integers
; (by calling the C library function random), to sort the array using
; a bubble sort function and to print the array. The array should be
; stored in the bss segment and does not need to be dynamically
; allocated. The number of elements to fill, sort and print should be 
; stored in a memory location. Write a function to loop through the 
; array elements filling the array with random integers. Write a
; function to print the array contents. If the array size is less than 
; or equal to 20, call your print function before and after printing.
;
; I wrote a c program which printed RAND_MAX and it turned out to be
; 2147483647 which fits in a 4 byte register. System time could be use
; as a "seed" to generate a different sequence of numbers on each run.
; The output in this version is unfortunately the same each time.

%define array_size 10

section .data
	fmt: db "%d",0x0a,0
	newline: db 0x0a,0

section .text
	global main
    extern rand
    extern printf

main:    ; checking array size
         mov   rbx, array_size
         cmp   rbx, 0
         jz    .skip

         ; making room for the array on stack
         imul  rbx, 4
         sub   rsp, rbx
         
         ; aligning stack pointer to 16 byte
         mov   rax, rsp
         and   rax, 1111b
         sub   rsp, rax
         mov   r13, rsp
         add   rbx, rax

         ; filling array with random integers
         mov   rdi, r13
         mov   rsi, array_size
         call  rnd_fll

         ; printing the unsorted array
         mov   rdi, r13
         mov   rsi, array_size
         call  print

         ; sorting the array
         mov   rdi, r13
         mov   rsi, array_size
         call  bub_sor

         ; printing "empty" line
         lea   rdi, [newline]
         xor   rax, rax
         call  [rel printf WRT ..got]

         ; printing the sorted array
         mov   rdi, r13
         mov   rsi, array_size
         call  print

         ; cleaning stack and exiting
.skip    add   rsp, rbx
         xor   rax, rax
         ret

; print(long int array, long int size) prints the array
print:   push  rbx
         push  r12
         push  r13
         xor   rbx, rbx
         mov   r12, rdi
         mov   r13, rsi

.L1:     cmp   rbx, r13
         jz    .ret
         lea   rdi, [rel fmt]
         mov   esi, [r12+rbx*4]
         xor   rax, rax
         call  [rel printf WRT ..got]
         inc   rbx
         jmp   .L1

.ret:    pop   r13
         pop   r12
         pop   rbx
         ret

; rnd_fll(long int array, long int size) fills an array of integers with random numbers
rnd_fll: push  rbx
         push  r12
         push  r13
         xor   rbx, rbx
         mov   r12, rdi
         mov   r13, rsi

.L1:     cmp   rbx, r13
         jz    .ret
         xor   rax, rax
         call  [rel rand WRT ..got]
         mov   [r12+rbx*4], eax
         inc   rbx
         jmp   .L1

.ret     pop   r13
         pop   r12
         pop   rbx
         ret

; bub_sor(long int array, long int size) sorts the array in ascending order
bub_sor: push  rbx
         push  r12
         push  r13
         push  r14
         dec   rsi
         xor   rbx, rbx
         xor   r12, r12

.L1:     cmp   rbx, rsi
         jz    .ret
         mov   r13d, [rdi+rbx*4]
         mov   r14d, [rdi+rbx*4+4]
         cmp   r13d, r14d
         jle   .order
         mov   [rdi+rbx*4], r14d
         mov   [rdi+rbx*4+4], r13d
         mov   r12, 1

.order:  inc   rbx
         jmp   .L1

.ret:    xor   rbx, rbx
         cmp   r12, 1
         setnz r12b
         movzx r12, r12b
         jz    .L1
         pop   r14
         pop   r13
         pop   r12
         pop   rbx
         ret