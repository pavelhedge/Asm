; ##	������������ ��������� ��� N-����������� 7����������� ���������� � ��	
/* ���������� �������  ����� ���� � ���������� number_of_digits �
�������/�������� �����
.equ number_of_digits=4
.equ anode_port=portB
.equ cathode_port=portC
�������������(��������� X ������������ ������ ��� ��������� ���� �������): 
ldi XL, low (digit1)
ldi XH, high (digit1)
ldi temp, 0b11111110
out cathode_port, temp
 */
  
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
	
.cseg 	Symbol_Table:
/*	.db 0b00111011, 0b00111110 	; ����� �-I
	.db 0b00011010, 0b01111010
	.db 0b10011110, 0b10001110
	.db 0b10111100, 0b00101110
	.db 0b00001100, 0b11111111
*/	
	.db 0b11111100, 0b01100000	; 0, 1
	.db 0b11011010, 0b11110010	; 2, 3
	.db 0b01100110, 0b10110110	; 4 ,5
	.db 0b10111110, 0b11100000	; 6, 7
	.db 0b11111110, 0b11110110	; 8, 9
	.db 0b00000000 			; blank
; �� �� �����, ������ � ������	
	.db 0b11111101, 0b01100001	; 0, 1
	.db 0b11011011, 0b11110011	; 2, 3
	.db 0b01100111, 0b10110111	; 4 ,5
	.db 0b10111111, 0b11100001	; 6, 7
	.db 0b11111111, 0b11110111	; 8, 9
	.db 0b00000001 			; blank
HAPPY:
	.db 0b01101110, 0b11101110	; H, A
	.db 0b11001110, 0b11001110	; P, P
	.db 0b01110110, 0b00000000 	; Y, blank
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

.equ	Symbol_Blank	= 10	; ���������� ��������� ����. ��������:
.equ 	Symbol_HAPPY = 24

	
DISPLAY_HANDLER:											
cli
/* ���������� ������ ��������� - � ������ ������ ����� �����.
������� �������� ������� - ��������� � ����, �������� �� ����. ������, 
��������� ������� */
	in temp1, cathode_port		; ��������� ������ ��������� - ����� �����
mov temp2, temp1	; ��� ��� ������� ��������� �������, �� ������������
andi temp2, low(0xFF<<(number_of_digits))	; � ��������� �� ��������� ��� ������
	sec					; ���� �����, ���� ��� rol � 0 ��� ���������� 1
	rol temp1				; ������ �������� ���� �� ��������
	
.if number_of_digits==8			; ���� ����� �������� - ������, ���������
	brlo I_disp_a	 		; ���� �� ����� � � SREG 
	ldi temp1, 0b11111110 		; ���� ������ - ������ �� �����
 I_disp_a:
 
.else	sbrs temp1, number_of_digits	; ��������, ���� �� ������ ������� ������
	ldi temp1, 0b11111110 		; ���� ������ - ������ �� �����
.endif

andi temp1, 0xFF>>(8-number_of_digits)	; � ����� �������������� �������
or temp1, temp2			; ������������ ������� - ��-��!
	out cathode_port, temp1		; �������� - �������, ������ �����
/* ���������� ����������, 7-����������� (� ������ ������ �����)
- ����� �������� �������� ������� ����� ������� � � (� ������ ��������� 
� ���� ��������� �� ������� ������!!!)
 */
	
	ldi ZL, low(symbol_table*2)	; ������������� Z �� ������ ������� 
	ldi ZH, high(symbol_table*2)	; ��������
	ld temp, X+				; ��������� �� ������ �������� �������  
	add ZL, temp			; ����� � ������������ ����� � ������� 
	lpm temp, Z				; ���������, ��������� ��������� �������
	out anode_port, temp		; � ������� �� �������
	
	cpi XL, (low(digit1)+number_of_digits)	; ����� ��������� ����� ��� 
	brlo i_disp_b			 	; ������������� ��� �������� �� �
		ldi XL, low(digit1)			; ��� ��� �������� ������ �������
 	 I_disp_b:				 	; ���� �� �� ����� �� �������
reti


