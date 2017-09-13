;@@@				Алгоритм умножения 					@@@

/* Перемножается содержимое регистров temp1 (r16) и temp2 (r17), результат помещается 
в регистровую пару r24-r25 */

.include "D:\!lab\asm\inc\tn13def.inc"


.def counter = r19
.dseg
multiply_buffer: .byte 16 	; 16-байтный буфер

.cseg

ldi temp1, 109	
ldi temp2, 222

cp temp2, temp1
brsh I_no_swap
	mov temp3, temp2
	mov temp2, temp1
	mov temp1, temp3
 I_no_swap:
 
 
 ldi counter, 8
 clr temp3
 LDA XX, multiply_buffer
 
 I_multiply_shift_cycle:
 ror temp1
 brsh I_multiply_save
 	st X+, temp2
 	st X+, temp3
 I_multiply_save:
 
 clc
 rol temp2
 rol temp3
  
 dec counter
 brne I_multiply_shift_cycle
 
 I_multiply_add_cycle:
 
 cpi XL, multiply_buffer
 breq I_multiply_end
 
 ld temp3, -X
 ld temp2, -X
 add r24, temp2
 adc r25, temp3
 rjmp I_multiply_add_cycle
 
 I_multiply_end:
 
 cycle:
 rjmp cycle
 

 	
 
