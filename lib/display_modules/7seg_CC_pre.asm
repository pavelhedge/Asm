; ##	������������ ��������� ��� N-����������� 7����������� ���������� � ��	
/* ���������� �������  ����� ���� � ���������� number_of_digits �
�������/�������� �����
.equ number_of_digits=4
.equ anode_port=portB
.equ anode_ddr=DDRB
.equ cathode_port=portC
.equ cathode_ddr=DDRC
�������������(��������� X ������������ ������ ��� ��������� ���� �������): 
ldi XL, low (digit1)
ldi XH, high (digit1)
ldi temp, 0b11111110
out cathode_port, temp

��������� �� ������ � �������� ��������� � digit1...digit8, �.�. � digit1...digit8
���������� �� �����, � ������� �������� ��� ���������������
 */
 
 .equ __display_included__ =1
 
 .MACRO DISPLAY_INIT ; �������������� ������������� ������ ��� �������
 outi anode_ddr, 0xFF
 outi cathode_ddr, 0xFF>>(8-number_of_digits)
 outi cathode_port, 0xFF>>(8-number_of_digits)
 LDA XX, digit1
 .ENDM
  
.dseg					; ���������, ������� ���� � RAM �������������
.if number_of_digits==1			; ��� ��������, ��������� �� �������
digit1: .byte 1
.elif number_of_digits==2
digit1: .byte 1
digit2: .byte 1
.elif number_of_digits==3
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
.elif number_of_digits==4
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
.elif number_of_digits==5
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
digit5: .byte 1
.elif number_of_digits==6
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
digit5: .byte 1
digit6: .byte 1
.elif number_of_digits==7
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
digit5: .byte 1
digit6: .byte 1
digit7: .byte 1
.elif number_of_digits==8
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
digit5: .byte 1
digit6: .byte 1
digit7: .byte 1 
digit8: .byte 1
.elif number_of_digits>8
.error "Too high number of digits is set"
.endif
	
.cseg

DISPLAY_HANDLER:											
cli
/* ���������� ������ ��������� - � ������ ������ ����� �����.
�.�. � ���� �������� ����� ��������� ����� ���������� - �������� ������� -�������, � �� ������. 
������� �������� ������� - ��������� � ����, �������� �� ����. ������, 
��������� ������� */
	in temp1, cathode_port		; ��������� ������ ��������� - ����� �����
	mov temp2, temp1	; ��� ��� ������� ��������� �������, �� ������������
	andi temp2, low(0xFF<<(number_of_digits))	; � ��������� �� ��������� ��� ������
	lsl temp1				; ������ �������� ������� �� ��������
	
.if number_of_digits==8			; ���� ����� �������� - ������, ���������
	brsh I_disp_a	 		; ������� �� ����� � � SREG 
	ldi temp1, 0x01 		; ���� ������� - ������ �� �����
 I_disp_a:
 
.else	sbrc temp1, number_of_digits	; ��������, ���� �� ������ ������� ������
	ldi temp1, 0x01 		; ���� ������ - ������ �� �����
.endif

andi temp1, 0xFF>>(8-number_of_digits)	; � ����� �������������� �������
or temp1, temp2			; ������������ ������� - ��-��!
	out cathode_port, temp1		; �������� - �������, ������ �����
/* ���������� ����������, 7-����������� (� ������ ������ �����)
- ����� �������� �������� ������� ����� ������� � � (� ������ ��������� 
� ���� ��������� �� ������� ������!!!)
 */
	
	ld temp, X+				; ��������� �� ������ �������� �������  
	out anode_port, temp		; � ������� �� �������
	
	cpi XL, (low(digit1)+number_of_digits)	; ����� ��������� ����� ��� 
	brlo i_disp_b			 	; ������������� ��� �������� �� �
		ldi XL, low(digit1)			; ��� ��� �������� ������ �������
 	 I_disp_b:				 	; ���� �� �� ����� �� �������
reti



;###### 			8-bit binary to 2-digit BCD 7-seg converter				#####

;
/* ������ ������ �������������, ��� � digit1...digitN ������� �� ����������� �����
� �������, � ���� ��� �������� (��� ��������� ������)

ldi ZH, high(minutes)
ldi ZL, low(minutes)
ldi YH, high(digit1)
ldi YL, low(digit1)
 	���, � ��������� ������� lda:
lda ZZ, minutes+1
lda YY, digit1
 */
 .cseg 	Symbol_Table:
 /*	      0baBcDefGh	(����������: ������� �������� "���������� ��������" 
		76543210	(������ �����, ��� ���������� ����������� ������)	
					 ---A---
					|	|
					F	B
					|	|
					 ---G---	
					|	|
					E	C
					|	|
					 ---D---	     oH
*/

	.db 0b11111100, 0b01100000	; 0, 1
	.db 0b11011010, 0b11110010	; 2, 3
	.db 0b01100110, 0b10110110	; 4 ,5
	.db 0b10111110, 0b11100000	; 6, 7
	.db 0b11111110, 0b11110110	; 8, 9 

	.db 0b11101110, 0b00111110	; A, b
	.db 0b00011010, 0b01111010	; c, d
	.db 0b10011110, 0b10001110	; E, F


;.ifdef __display_symbol__
;	.db 0b10111100, 0b00101110	; G, h	
;	.db 0b01101110, 0b11101110	; H, A
;	.db 0b11001110, 0b11001110	; P, P
;	.db 0b01110110, 0b00000000 	; Y, blank
;			
;.equ	Symbol_Blank	= 20	; ���������� ��������� ����. ��������:
;.equ 	Symbol_HAPPY = 16
;.endif

.ifdef __display_hex__
DISPLAY_HEX:
; ������� 1 ���� � HEX-���� ��� �� ��������, ��� � ��������� �������. 
ld temp1, Z+
	DISPLAY_HEX_REG:
mov temp2, temp1
swap temp1
andi temp1, 0x0F
andi temp2, 0x0F
rjmp bin2bcd_b
.endif

.ifdef __display_dec__
DISPLAY_DEC:	
/* �������� - ������ ��������� ������������ ��� ����������� 8-������� 
��������� ����� �� RAM �� 99 ������������ � ��� ���������� �����, ������� 
����� ������������ � RAM. ��������� ������ - ����������� ���������� ����� � 
RAM � ��������� ��� �����, �������������� �� ��������� �������.
������������, ��������, ��� ����������� ����� � ����� � �����. */


ld temp1, Z+			; ��������� ������ ��������
DISPLAY_DEC_REG:
mov temp2, temp1
clr temp1				; �������� ������� ��������
bin2bcd_a:
	cpi temp2, 10		; ���� ����� ������ 10 - ������ 10
	brlo bin2bcd_b
	subi temp2, 10
	inc temp1			; � ��������� � �������� 1
	rjmp bin2bcd_a
.endif

.ifdef __display_dec__
.set bin2bcd_temp = 1
.endif
.ifdef __display_hex__
.set bin2bcd_temp = 1
.endif

.ifdef bin2bcd_temp
bin2bcd_b:
push ZL
push ZH
	clr temp3
	LDA ZZ, symbol_table*2
	add ZL, temp1
	adc ZH, temp3
	lpm temp1, Z
	ld temp3, Y
	bst temp3, 0
	bld temp1, 0
	st Y+, temp1
	
	clr temp3
	LDA ZZ, symbol_table*2
	add ZL, temp2
	adc ZH, temp3
	lpm temp2, Z
	ld temp3, Y
	bst temp3, 0
	bld temp1, 0
	st Y+, temp2
pop ZH
pop ZL	
ret
.endif

.ifdef  __display_symbol__
DISPLAY_SYMBOL:		; �� ������ ���� ����� ������� �������
/* ���� ����� ������� ��������� �������: 
LDA YY digit_number
ldi temp2, symbol_name */
cli	
	clr temp3
	LDA ZZ, symbol_table*2
	add ZL, temp1
	adc ZH, temp3
	lpm temp1, Z
	ld temp3, Y
	bst temp3, 0
	bld temp1, 0
	st Y+, temp1

ret
.endif