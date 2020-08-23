; "64 Bit Intel Assembly Language Programming for Linux"
;
; p.60 exercise 2.
;
; If we could do floating point division, this exercise would have you
; compute the slope of the line segment connecting 2 points. Instead
; you are to store the difference in x coordinates in 1 memory location
; and the difference in y coordinates in another. The input points are
; integers stored in memory. Leave register rax with the value 1 if
; the line segment it vertical ( infinite or undefined slope ) and 0 if it
; is not. You should use a conditional move to set the value of rax.
;
; I'm going to use rdx instead of rax for the slope value because
; rax is reserved for the system call numbers. At the end of the program
; exit system call is called, if not the computer will continue fetching
; for instructions until it moves to a page which is not allocated for 
; the program which will lead to a segmentation fault. I'm not totally
; sure about the last part but that's how I understood it. The command
; echo $? on linux will show the return value (the slope).
; Echo $? will only display the least significant byte.

section .data
	; this program handles values ranging from -9223372036854775808 to 9223372036854775807
	point1_x: dq  2147483647
	point1_y: dq 127
	point2_x: dq  2147483647
	point2_y: dq -128

section .bss
	x_diff: resq 1
	y_diff: resq 1

section .text
	global _start

        
_start: mov   rax, [point1_x]
        mov   rbx, rax
    	mov   rcx, [point2_x]
    	
        ; calculates the horizontal distance between the points
        sub   rax, rcx
    	sub   rcx, rbx
    	mov   rbx, rcx
        ; we are only interested in the positive result so if the last substraction resulted in a
        ; negative result we switch back to former (positive) result using the conditional cmovs 
        ; instruction which takes action if the sign flag was raised (1 indicates negative result).
        ; In subtraction of 2 two's complement numbers we do have to check for overflow because if 
        ; the latter subtraction resulted in overflow meaning the result had the same sign (+/-) as the
        ; subrahend we use cmovo to switch back to latter (negative) result if cmovs switched earlier to
        ; the former (positive) result. After the subtraction of the signed values we interpret the result 
        ; as an unsigned value. We could also use smaller numbers (32 byte/16 byte/8 byte) and sign 
        ; extended the sign with movsx/movsdx when we mov them from memory to register. That way we 
        ; wouldn't have to check for overflow. 
        cmovs rcx, rax
        cmovo rcx, rbx
        mov   [x_diff], rcx

        ; 1 = vertical slope and 0 = non vertical slope
        mov    rax, 1
        cmovz  rdi, rax
        mov    rax, 0
        cmovnz rdi, rax

        mov    rax, [point1_y]
        mov    rbx, rax
        mov    rcx, [point2_y]

        ; calculates the vertical distance between the points
    	sub    rax, rcx
	    sub    rcx, rbx
        mov    rbx, rcx
        cmovs  rcx, rax
        cmovo  rcx, rbx
        mov    [y_diff], rcx

	    mov    rax, 60
        ;      rdi = either 0 or 1 (return value)
	    syscall
