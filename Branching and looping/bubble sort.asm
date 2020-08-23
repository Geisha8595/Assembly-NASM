; "64 Bit Intel Assembly Language Programming for Linux"

; p.87 exercise 3.

; Write an assembly program to sort an array of double words using
; bubble sort . Bubble sort is defined as

;      do {
;          swapped = false ;
;          for ( i = 0 ; i < n- 1 ; i++ ) {
;              if ( a [i] > a [i+1] } {
;                  swap a [i] and a [i+1]
;                  swapped = true 
;              }
;          }
;      } while ( swapped );

; The program works with signed numbers ranging from -2147483648 to 2147483647
; Typing the following commands in gdb: break p87e3.asm:56 if $rax == 60, run, 
; p (int[number of elements])array gives the sorted array.

section .data
	array: dd -3,7,2,20,15,-14
	array_end: db 0
	fmt: db "%d",0x0a,0

section .text
	global _start

          ; determines the length of the array.
_start:   mov rax, array_end
          sub rax, array
          mov rbx, 4
          div rbx
          dec rax

while:    xor rbx, rbx
          xor rsi, rsi

for:      cmp rbx, rax
          jz  end_for
          mov ecx, [array+rbx*4]
          mov edx, [array+rbx*4+4]
          cmp ecx, edx
          jle in_order
          cmp edx, ecx
          jg  in_order
          mov [array+rbx*4], edx
          mov [array+rbx*4+4], ecx
          mov rsi, 1
            
in_order: inc rbx
          jmp for

end_for:  cmp rsi, 1
          jz  while    

          mov rax, 60
          mov rdi, 0
          syscall
