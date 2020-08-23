; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.60 exercise 4.
;
; Write an assembly language program to compute the cost of elec­
; tricity for a home. The cost per kilowatt hour will be an integer
; number of pennies stored in a memory location. The kilowatt hours
; used will also be an integer stored in memory. The bill amount will
; be $5 .00 plus the cost per kilowatt hour times the number of kilo­
; watt hours over 1000. You can use a conditional move to set the
; number of hours over 1000· to 0 if the number of hours over 1000
; is negative. Move the number of dollars into one memory location
; and the number of pennies into another

section .data 
	kwh_used: dw 950
	kwh_cost: db 3

section .bss
    dollars: resw 1
	pennies: resw 1

section .text
	global _start

_start: movzx rax, word [kwh_used]
        sub   ax, 1000
        mov   bx, 0
        cmovl ax, bx
        imul  eax, [kwh_cost]
        
        ; after the multiplication we might end up with a value which exceeds 2 bytes. 
        ; Therefore we have to make sure the bits above 2 bytes are moved to the dx register. 
        ; So in short the low order 16 bits of the product are left in the the ax register 
        ; whereas the high order 16 bits are moved to the dx register. We have to to divide the 
        ; dividend dx:ax with a 2 byte register containg the divisor. The quotient will be stored 
        ; in ax register and the remainder in dx register. 
        ; We could also have stored the whole product in the rax/eax register, zeroed the edx register 
        ; which we had to do and divided the dividend with a 4 byte register. The quotient will be 
        ; stored in eax register and remainder in edx register. Our product will not exceed 4 bytes 
        ; which is why we'll use the dx:ax pair for our dividend. Something which might also happen
        ; when performing divison is getting a quotient or remainder which doesn't fit in a r32
        ; register.
        ;
        ; ax(16 bit dividend) / r8(8 bit divisor) = al(quoteent) ah(remainder)
        ; dx:ax(32 bit dividend) / r16(16 bit divisor) = ax(quotient) dx(remainder)
        ; edx:eax(64 bit dividend) / r32(32 bit divisor) = eax(quotient) edx(remainder)
        
        mov   rdx, 0xffff0000
        and   rdx, eax
        ror   rdx, 16
        and   rax, 0xffff
        mov   bx, 100
        div   bx
        
        add   ax, 5

        mov   [dollars], ax
        mov   [pennies], dx

        mov   rax, 60
        mov   rdi, 0
        syscall