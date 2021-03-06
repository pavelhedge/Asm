; ##	������������ ��������� ��� N-���������� ��������������� ����������	
/* ���������� ������� ����� ������ �������� - � ����� ������ (_CA_mode_)
��� � ����� ������� (_CC_mode_), � ����� ����� ���� � ���������� digit_number
.equ _CA_mode_=1
.equ digit_number=4
 */
.dseg
.IF digit_number=1
	digit1: .byte 1
.ELIF digit_number=2 
	digit1: .byte 1 
digit1: .byte 1
	digit2: .byte 1
.ELIF digit_number=3
	digit1: .byte 1
	digit2: .byte 1
	digit3: .byte 1
.ELIF digit_number=4
	digit1: .byte 1
	digit2: .byte 1
	digit3: .byte 1
	digit4: .byte 1
.ELIF digit_number=5
	digit1: .byte 1
	digit2: .byte 1
	digit3: .byte 1
	digit4: .byte 1
	digit5: .byte 1
.ELIF digit_number=6
	digit1: .byte 1
	digit2: .byte 1
	digit3: .byte 1
	digit4: .byte 1
	digit5: .byte 1
	digit6: .byte 1
.ELIF digit_number=7
	digit1: .byte 1
	digit2: .byte 1
	digit3: .byte 1
	digit4: .byte 1
	digit5: .byte 1
	digit6: .byte 1
	digit7: .byte 1
.ELIF digit_number=8
	digit1: .byte 1
	digit2: .byte 1
	digit3: .byte 1
	digit4: .byte 1
	digit5: .byte 1
	digit6: .byte 1
	digit7: .byte 1
	digit8: .byte 1
	
.IF (_common_anode_mode_=1 | _CA_mode_=1)
ldi temp, 1
out anode_port, temp
.endif


.cseg 	Symbol_Table:
	.DB	0b11111100	; 0
	.DB	0b01100000	; 1
	.DB	0b11011010	; 2
	.DB	0b11110010	; 3
	.DB	0b01100110	; 4
	.DB	0b10110110	; 5
	.DB	0b10111110	; 6
	.DB	0b11100000	; 7
	.DB	0b11111110	; 8
	.DB	0b11110110	; 9
	.DB	0b11101110	; 10: A
	.DB	0b00111110	; 11: b
	.DB	0b10011100	; 12: C
	.DB	0b01111010	; 13: d
	.DB	0b10011110	; 14: E
	.DB	0b10001110	; 15: F
	.DB	0b00000000	; 16: blank (�����)
	.DB	0b11000110	; 17: bell up
	.DB	0b00111010	; 18: bell down
	.DB	0b10110110	; 19: "Seconds"-1	(������ ��������� ���� �����������, ������������ � "������ ���������")
	.DB	0b00011010	; 20: "Seconds"-2	(������ ��������� ���� �����������, ������������ � "������ ���������")
	.DB	0b11001100	; 21: "Minutes"-1	(������ ��������� ���� �����������, ������������ � "������ ���������")
	.DB	0b11100100	; 22: "Minutes"-2	(������ ��������� ���� �����������, ������������ � "������ ���������")
	.DB	0b01101110	; 23: "Hours"-1	(������ ��������� ���� �����������, ������������ � "������ ���������")
	.DB	0b00001010	; 24: "Hours"-2	(������ ��������� ���� �����������, ������������ � "������ ���������")
	;	0bABCDEFGH	(����������: ������� �������� "���������� ��������" � �������)
	;	    76543210	(������ �����, ��� ���������� ����������� ������)

.equ	SymbolBlank	= 16	; ���������� ��������� ����. ��������:
.equ	SymbolBellUp	= 17
.equ	SymbolBellDown	= 18
.equ	SymbolSeconds	= 19
.equ	SymbolMinutes	= 21
.equ	SymbolHours	= 23
	
DISPLAY_HANDLER:
cli
.IF (_common_cathode_mode_=1 | _CC_mode_=1)
	in temp, cathode_port		; 
	sec
	rol temp
	sbrc temp, digit_number
	ldi temp, 0b11111110 
	out cathode_port, temp
	
	ldi ZL, low(symbol_table)
	ldi ZH, high(symbol_table)
	lds temp, digit1	
	add ZL, temp
	lpm temp, Z
	out anode_port, temp
.ELIF (_common_anode_mode_=1 | _CA_mode_=1)
	in temp, anode_port		; 
	lsl temp
	sbrs temp, digit_number
	ldi temp, 1 
	out anode_port, temp
	
	ldi ZL, low(symbol_table)
	ldi ZH, high(symbol_table)
	ldi YL, low (digit1)
	ldi YH, high (digit1)
	mov temp2, flag
	andi temp2, 0b00000111
	inc flag
	cbr flag, 0b00001000
	add YL, temp2
	ld temp1, Y
	add ZL, temp1
	lpm temp1, Z
	out cathode_port, temp1
.ELSE .error "Choose CA or CC mode for 7-seg display"
.ENDIF
reti



