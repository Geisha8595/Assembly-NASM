; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.70 exercise 5.
;
; Write an assembly program to perform a product of 2 float values
; using integer arithmetic and bit operations. Start with 2 float values
; in memory and store the product in memory
;
; This program doesn't handle arithmetic operations which result in NaN except operations
; where NaNs are involved or when the operations overflows/underflows. Operations which
; involve infinity will have unexpected results.
;
; This program is not tested

section .data
	float1: dd -18.0      
	float2: dd  9.5     

section .bss
	float_product: resd 1

section .text
	global _start

_start:   mov    eax, [float1]
          mov    ebx, [float2]

          ; extracts the signbits, determines the new signbit and places it 
          ; in it's designated bit position in the rsi register

          mov    rsi, 31
          bt     rax, rsi
          setc   sil
          bt     rbx, rsi   
          setc   dl
          xor    sil, dl
          shl    rsi, 31

          ; extracts the fractions and exponents, extend the fractions by adding the 
          ; significant one if the float is in normalized form which is denoted by a 
          ; non zero exponent field

          mov    rcx, 0x7fffff
          and    rcx, rax
          mov    rdx, 0xff00000000
          xor    rdi, rdi
          and    rdx, rax
          setnz  dil
          shl    dil, 23
          or     rcx, rdi

          mov    rdi, 0x7fffff
          and    rdi, rbx
          mov    r8, 0xff00000000
          xor    r9, r9
          and    r8, rbx
          setnz  r9b
          shl    r9, 23
          or     rbx, r9

          ; checks if the floats are of type NaN which is denoted by an exponent equal to 0xff. There are
          ; 2 types of NaNs, namely QNaN "Quiet Not a Number" and SNaN "Signaling Not a Number". QNaN denotes 
          ; results that aren't mathematically defined e.g. 0/0, inf - inf, sqrt(-1) whereas SNaN denotes 
          ; results that resulted from computations where an overflow or floating point underflow occured. 
          ; QNaN and SNaN are distinguished from each other by specific fraction fields. In a QNaN the most 
          ; significant bit in the fraction field is 0 and the rest of the fraction field consists of at least 
          ; one 1. In a SNaN the msb of the fraction field is a 0 and the rest of the fraction field consists 
          ; of any combination of 1s and 0s. Operations involving NaN lead to QNaN as result. As a side note;
          ; infinity is also represented by an exponent equal to 0xff but by a fraction equlal to zero. The sign
          ; bit tells whether the infinity is positive or negative

          xor    r9, r9
          cmp    rdx, 0xff
          setz   r9
          xor    r10, r10
          cmp    r8, 0xff
          setz   r10
          or     r9, r10
          jz     no_NaN
          or     rsi, 0x3fc00000
          or     rsi, 0x200000
          jmp    store_pr
  
          ; calculates the new unbiased exponent and checks for exponential overflow

no_NaN:   sub    rdx, 127
          sub    r8, 127
          add    rdx, r8
          jno    no_ovflw    
          or     rsi, 0x3fc00000
          or     rsi, 0x400000
          jmp    store_pr

          ; multiplies the mantissas

.n_ovflw: imul   rcx, rdi

          ; checks if we ended up with a subnormal value which has an unbiased exponent equal to -127 and 
          ; a mantissa product which can be fitted in the 23 bit fraction field without any loss of precision.
          ; If it dosen't fit we report underflow.

          cmp    rdx, -127
          jnz    no_sub          
          xor    rdi, rdi
          lzcnt  rdi, rcx
          cmp    rdi, 18
          jl     no_sub          ; product is normalized or it can be normalized
          xor    rdi, rdi
          tzcnt  rdi, rcx
          cmp    rdi, 23
          jl     undflow         ; report underflow if the last set digit exceedes the 23th decimal place
          shr    rcx, 23
          or     rsi, rcx          
          jmp    store_pr

undflw:   or     rsi, 0x3fc00000
          or     rsi, 0x400000
          jmp    store_pr
          
          ; normalizes the product if needed. The position of the decimal point is known because the bith lengths
          ; of both mantissas are 23 so the decimal point in the prodcut will be "between" the 46th and the 47th bit.
          ; The bit length of the product will be between max(a,b) and a+b, where a and b are the bit lengths of the
          ; factors. 

          mov    rdi, 46

normlz:   xor    r8, r8
          lznt   r8, rcx
          mov    r9, 64
          sub    r9, r8
          mov    r8, r9          ; r8 = index of the product's msb
          sub    r9, rdi         ; r9 = the value that's going to be added to the exponent       
          jz     done
          add    rdx, r9
          jno    n_ovrflw
          or     rsi, 0x3fc00000
          or     rsi, 0x400000
          jmp    store_pr

          ; checks if the product needs to be rounded to fit it into the 23 bit fraction field 
          ; according to the following schema: 
      
          ; If the what is left over is < 1/2 (24th bit right of msb is 0), round down by trunctating the rest of bits, 
          ; if what is left over is > 1/2 (24th bit right of msb is 1), round up by adding a 1 to the 23th bit right 
          ; of msb, if what is left over is = 1/2 (24th bit is 1 and rest of bits are zero), round up if the 23th bit is 
          ; 1 and round down if 23th bit is 0

.n_ovflw: sub    r8, 24          ; checks if the 24th bit right of the msb is set
          xor    r10, r10  
          bt     rcx, r8
          setc   r10b

          xor    r11, r11        ; checks if there's at least one set bit after the 24th bit
          not    r11
          mov    r12, 64
          sub    r12, r8
          sub    r12, 24
          shr    r11, r12
          xor    r12, r12
          and    r11, rcx
          setns  r12b

          inc    r8              ; checks if the 23th bit right of the msb is set
          xor    r11, r11
          bt     rcx, r8
          setc   r11b

          and    r10, r12        ; determines if rounding is required according the schema above
          or     r10, r11
          
          sub    r8, 23          ; rounds the products
          shl    r10, r8
          add    rcx, r10        

          add    r9, 23          ; shifts the product right "into the fraction field"
          shr    rcx, r9  
        
          mov    rdi, 24         ; changes the decimal point marker
          jmp    normlz

done:     mov    r9, 1           ; discards the significant one from the product
          shl    r9, 23
          not    r9
          and    rcx, r9   

          add    rdx, 127        ; adds the bias to the exponent and finishes the floating point representation
          shl    rdx, 23
          or     rsi, rdx
          or     rsi, rcx
          
          ; stores the product in memory

store_pr: mov    [float_product], rsi

          mov    rax, 60
          xor    rdi, rdi
          syscall
