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
  
.dseg				
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1

DISPLAY_HANDLER:
cli 

in temp1, display_port

; ����� ���� - ���� 4-7, ������� - ���������� �����
andi temp1, 0xF0
lsl temp1
brcc I_disp_a
	ldi temp1, 0x10
 I_disp_a:
 ; ����� - 4 ����, �������� 0-9 - �����, 10-15 - ���������, ����� �������� �� digits
ld temp2, X+
or temp1, temp2
out display_port, temp1
cpi XL, (low(digit1)+digit_number)
brlo I_disp_b:
	ldi XL, low(digit1)
 I_disp_b:

