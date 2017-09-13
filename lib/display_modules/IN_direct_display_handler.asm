; ##	������������ ��������� ��� 4-����������� �������������� ���������� 
; ##	� ����������� ����������� ��144��1
/* ������������ ������ ���������� ������� �� � ������������ ����������. 10 ����� - ������,
1-8 ����� ������ ����� - ���������� �������. 

.equ display_port=portC
�������������(��������� X ������������ ������ ��� ��������� ���� �������): 
ldi XL, low (digit1)
ldi XH, high (digit1)
ldi temp, 0x10
out display_port, temp
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

.cseg

DISPLAY_HANDLER:
cli 

in temp1, display_port

/* ���������� ������ ��������� - � ������ ������ ����� ����.
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
or temp1, temp2				; ������������ ������� - ��-��!
	out cathode_port, temp1		; �������� - �������, ������ �����
	
/* ���������� �������. */

symbol_IN 	.db 0b00000001, 0b00000010
		.db 0b00000100, 0b00001000
		.db 0b00010000, 0b00100000
		.db 0b01000000, 0b10000000
LDA ZZ, symbol_IN*2
ld temp2, X+
cpi temp2, 8
brlo I_display_less
subi temp2, 8
add ZL, temp2
lpm temp1, Z
ori temp3
out portB, temp3
reti

 I_display_less
add ZL, temp2
lpm temp1, Z
ori temp3
out portD, temp3
reti

 







