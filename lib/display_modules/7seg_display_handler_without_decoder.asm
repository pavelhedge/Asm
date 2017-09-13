; ##	������������ ��������� ��� N-����������� 7����������� ���������� � ��	
/* ���������� �������  ����� ���� � ���������� digit_number �
�������/�������� �����
.equ digit_number=4
.equ anode_port=portB
.equ cathode_port=portC
�������������(��������� X ������������ ������ ��� ��������� ���� �������): 
ldi XL, low (digit1)
ldi XH, high (digit1)
ldi temp, 0b11111110
out cathode_port, temp

��������� �� ������ � �������� ��������� � digit1...digit3
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
	
	ld temp, X+				; ��������� �� ������ �������� �������  
	out anode_port, temp		; � ������� �� �������
	
	cpi XL, (low(digit1)+number_of_digits)	; ����� ��������� ����� ��� 
	brlo i_disp_b			 	; ������������� ��� �������� �� �
		ldi XL, low(digit1)			; ��� ��� �������� ������ �������
 	 I_disp_b:				 	; ���� �� �� ����� �� �������
reti


