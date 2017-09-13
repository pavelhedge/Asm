;##					��������� ������������ ������				
/* ��������� ��� ������ � ��������� ���������� � key_flag � ������� 

��� 4,5 - ������� ��������� ������ (�����������)
��� 2,3 - ������ �������
��� 0,1 - ����� ������ */
.equ long_1=2
.equ long_2=3
.equ press_1=4
.equ press_2=5
.equ front_1=0
.equ front_2=1 

.equ press_time=3
.equ long_press_time=3000	; �������� ��� � �������
.def 	key_cnt = r14 	; ������� ������� ������� ��� ���������� ��������
.def 	key=r15 		; ������� ���� ���������� ������� ��������� ������,
.def 	key_flag=r21	; ������ ��� ���� ���������� ������� ��������� ������,
			; ������ ��� - ������ �������, � ��� ��� - ��������� ������
.def counter = r24	; ������� �������, ���������� ����� �������, r24-r25

.set __keys_included__ =1

.macro KEY_INITIALIZIATION
sbi key_port, 4
sbi key_port, 5
.endmacro
	
KEY_SCAN_HANDLER:	
cli													
	in temp1, key_port	; �������� "�����" �������� ������ ���� 
	com temp1			; ����������� �������� - ����������� ������ = 1
	andi temp1, 0b00110000	; ��������� ������ ���� ������
	mov temp2, key_flag
	andi temp2, 0b00110000
	cp temp1, temp2	; ���� ���������� ��������� ����� �������� � ���
	brne I_key_not_same 	; ���� - ����� ������� �� �����, ��� �����������
	tst temp1			; ���� �� ����� �������� - ���� � ����������
	breq I_key_exit 		
				
	sbiw counter, 1		; ���� ����� � �� ���� - �� ��������� ������� 
	brne I_key_exit	 	; ������� ������� � ���������, �� ��������� �� ��
	brlo I_key_A
	lsr temp1				; ���� ����� ������ - �������� ���� �� 
	lsr temp1				; ������� ������ ������� �������				 
	cbr key_flag, 0b00001100	; � ���������� � �����
	or key_flag, temp1	;
	lsr temp1
	lsr temp1
	or key_flag, temp1
 
 I_key_exit:
reti
 I_key_A:
inc counter
reti
	
 I_key_not_same:		 	; ���� �������� ���-�� ����� - ���������� � 
	cp temp1, key		; ������� ��������� ����������. KEY - �����-
	breq I_key_equal	 	; ����������� �������� �������� ����. 
	mov key, temp1		; ���� ������� ����� key  - ������ �������, ����
	ldi temp2, 3			; �� ����� - ��������� key � �������� ������� 
	mov key_cnt, temp2
reti
	
 I_key_equal:		 	; ������ ������� (��. ����) 
	dec key_cnt	
	breq I_key_valid	 	; ������� ������� - �������� ������������
reti

 I_key_valid:		 	; �������� ������������	
 sbrs key_flag, long_1		; ���� ���� �� ���� ������� ������� - 
 sbrc key_flag, long_2		; �������� ����� �� ��������
 rjmp I_no_front
         	eor key_flag, temp1
	andi key_flag, 0b00110000
	swap key_flag
	or key_flag, temp1
	ldi r24, low (long_press_time)	; ������� �������
	ldi r25, high (long_press_time)
reti
 	 I_no_front:
 	 mov key_flag, temp1
reti

