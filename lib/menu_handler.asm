;######					MENU_HANDLER					#####

/* � ���� ����������� ��� �������, ����� ����������������� �����������, 
�������� �������, ����� ��������� ������ (�������, �����, ���������� �������)
� ��� �� �������� �����������, �������� � ����� ������.

�.�. ��������� �����, ��� ������ ����, ������������ � �����-����� - �����

�� ������� ������ ������ ������������ ������� ���� 
�� ������� ������� ������ ������ ���������� ����� ��������� ����-�������
(���� ������)--���-�����, �� ��������� - ��������� �����-�����. �����������
������� ����������� �������. ������ ������ ������ ��������. 
������ ����� - ����� 

��� ����� ������ �������, ������� �����������-�������� � ���� ������ ���

����� ����������� ����-�� ��� ����� � 4-7 ����� ����� flag
���� 6-7 - ����� ����������� ����� �� ������, ��������������, ��� 7 ����������,
���������� ������� ��� �������

 mov temp1, flag
 andi temp1, 0b00000011
 LDA YY, digit1
 add Y, temp1
 ldi temp2, symbol_blank
 st Y, temp2
 
 	Menu_flag � ������ �������� �������������, �� �� ����� ���� ���������
 ������� ���� �� digit3 � digit1 ��� ��������� ������� ����� �������. ������� 
 ���� ����� ������ ������������� ��� ��������� ����������� ������ �������
*/
.ifndef current_value
.def current_value=r12
.endif
.ifndef max_value
.def max_value=r13
.endif

.equ date_mode=6
.equ menu_mode=7


MENU_HANDLER:
cli

sbrc menu_flag, menu_mode		; ���� ���� � ������ ���� - ������ �����
	rjmp I_menu_mode_on

tst key_flag					; ���� ������ ��� �� ������� - ��� �� ����
	brne I_menu_a
reti

 I_menu_a:
sbrs key_flag, front_2			; ���� ����� � ������ ������ - ���-�� � �����
	rjmp I_menu_next_key	 	; �������� - ���� ������

;##	����� ����	 
	LDA YY, digit1			
sbrs key_flag, press_2
	rjmp I_menu_showdate_off 	; ���� ������ ������ - �������� ���� 

	LDA ZZ, month
	rcall Bin2BCD
	LDA ZZ, days
	rcall Bin2BCD
	
	lds temp, digit3			; ��������� ����� ����� ����� � ��������
	sbr temp, 1
	sts digit3, temp

	sbr menu_flag, (1<<date_mode)
reti
 I_menu_showdate_off:		 	; ��������, ��� ������ ������ �������� 
	LDA ZZ, minutes
	rcall Bin2BCD
	rcall Bin2BCD
	
	cbr menu_flag, (1<<date_mode)
reti

;##	���� � �������� ����
 I_menu_next_key:		 	; ���� � ���� - ������ ������� - ����-���
sbrs key_flag, front_1
reti
sbrc key_flag, long_1						; �������� - ��������� �������
rjmp I_menu_dayz
sbrs key_flag, press_1

	sbr menu_flag, (1<<menu_mode)	; ��������� �����-�����
	rjmp I_menu_hours_set
reti

 I_menu_dayz:			 	; ��������� ����-�������
	LDA YY, digit1
	LDA ZZ, month
	rcall Bin2BCD
	LDA ZZ, days
	rcall Bin2BCD
	
	lds temp, digit3			; ��������� ����� ����� ����� � ��������
	sbr temp, 1
	sts digit3, temp
	
	sbr menu_flag, (1<<menu_mode|1<<date_mode)	; ��������� ������
	rjmp I_menu_days_set
reti

;##						����� ����						
 I_menu_mode_on:
 
 sbrc key_flag, front_2 
 sbrs key_flag, press_2
 rjmp I_menu_ON_next_key
 
 ;##	����� ���� - ��������� �������� ��������� �������				

 LDA YY, digit1			; ��������� ������� ����� �� ������
 mov temp2, menu_flag
 com temp2				; �������� - ������, ��� �� ����� ���� digit1 
 andi temp2, 0b00000011	; ���������, � digit3 - ������
 add YL, temp2
 
 mov ZL, current_value		; ��������� ������� ��������	
 ld temp, Z			
 
 sbrs menu_flag, 0
 rjmp I_menu_decimal_increment
 inc temp
 cp max_value, temp
 brsh I_menu_display
 ldi temp, 1
 sbrc menu_flag, date_mode	; ���� data_mode � ��� 2 =1 - �������� � �������� 0
 sbrs menu_flag, 2		; ���� data_mode � ��� 2 =0 - 1
 clr temp				; ���� �� ���� ��� - 0
 rjmp I_menu_display

 I_menu_decimal_increment: 	; ���� ����� - ����� �������� �������, ������� 
 subi temp, -10			; �������� �� �����. ������� ��� ����������
 cp max_value, temp		; ������������� �������� ����� ��, ��� ���� �
 brsh I_menu_display	 	; �������� �� ������ � ���������� � ��������

 I_menu_decimal_max:	 	; ���� ������ max, �� �������� ������� �� �����  
 subi temp, 10			; � �����, � ����� ���������� ������ - �������� 
 brcc I_menu_decimal_max 	; �������.
 subi temp, -10

 
 I_menu_display: 		
 	st Z, temp			; � Y � Z ��� ������ ������ ����� � ����� �� �����
 	sbrs menu_flag, 0		; �.�. ����� ������� � ������ ����� ��������, ���� 
 	dec YL			; �������� ������� - ������� �������
  	rcall Bin2BCD
 reti
 
  
 ;##	����� ���� - ������� � ������� ��������� (������-����, ����-�����-���)
 
 I_menu_ON_next_key:
 sbrs key_flag, front_1
 reti
 sbrc key_flag, long_1
 rjmp I_menu_exit
 sbrc key_flag, press_1		; ��� ������� - ������������ �� ���������
 reti 					; ���������� �������
 
  	mov temp, menu_flag	; ��������� 4 ���� � flag ������ ���� �������� 
  	andi temp, 0b00001111	; ���������� �������
  	andi menu_flag, 0b11110000	; ������� �������� AND �������� ����,
  	inc temp			; ����� ����������� � � ������� OR 
  	or menu_flag, temp	; ���������� ������� � FLAG
  	sbrc menu_flag, 0	; ���� 1, �� ������ �������� ������� ������ ��������
 reti 
 sbrc menu_flag, date_mode
 rjmp I_menu_date_mode
 sbrs menu_flag, 2
 rjmp I_menu_time_mode

 	clr temp			; � ������, ���� ���� ���� � ������ ������� - 
	sts seconds, temp		; ���������� ������� � ���� � �����
 
 I_menu_exit:	 	; �� ������� "����� �� ����" ���������� ��� ����� 
 clr menu_flag		; ����, ����� ������� ������ � �.�. � ����������  
 reti				; ������� ������ �������

 
 I_menu_time_mode:	 	; ������ ����� ������ �������� ��������� � 
 sbrs menu_flag, 1		; ������ �������� ��������.
 rjmp I_menu_hours_set
 
;##			������			
 ldi temp1, 60
 ldi temp2, low (minutes)
 rjmp I_menu_set_end
 
 ;##			����				
 I_menu_hours_set:
 ldi temp1, 24
 ldi temp2, low(hours)
 rjmp I_menu_set_end
 
 ;##			����				
 I_menu_date_mode:
 sbrc menu_flag, 3
 rjmp I_menu_exit
 sbrc menu_flag, 2
 rjmp I_menu_year_set
 sbrc menu_flag, 1
 rjmp I_menu_month_set
 
 ;##			���				
 I_menu_days_set:
 lds temp1, days_in_month
 ldi temp2, low(days)
 rjmp I_menu_set_end
 
 ;##			������			
 I_menu_month_set:
 ldi temp1, 12
 ldi temp2, low(month)
 rjmp I_menu_set_end
 
 ;##			����				
 I_menu_year_set:
	LDA YY, digit1
  	LDA ZZ, year
  	rcall Bin2BCD
  	rcall Bin2BCD
  	
  	lds temp1, digit3
  	cbr temp1, 1
	sts digit3, temp1
 
 ldi temp1, 100
 ldi temp2, low(year)
 sbrs menu_flag, 1
 ldi temp2, low(century)
 
 I_menu_set_end: 		; ��������� � �����
 mov max_value, temp1
 mov current_value, temp2
 reti
   	