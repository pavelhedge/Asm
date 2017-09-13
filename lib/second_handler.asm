;## 						Time counter (second handler)			
/* 	������� ������, �����, �����, ���� (+���� ������), ������� (���������� 
����� ���� � ������ ����� �������������, ��� (������ ���������� ��� � �������� 
flag), ����� (�� ���� ��). ������� �������� - ���������, ���������, �� �������� ��
������������� ��������, ���� �������� - ��������, ��������� ����. ��������  */

.dseg
seconds: .byte 1
minutes: .byte 1
hours: .byte 1
days: .byte 1
month: .byte 1
year: .byte 1
century: .byte 1
day_of_week: .byte 1
days_in_month: .byte 1

.cseg

SECOND_HANDLER:

ldi YL, low(seconds)
ldi YH, high(seconds)

ldi temp2, 60		; ##�������#
rcall RTC_sub

rcall RTC_sub		; ##������#

.ifdef NEW_HOUR		; ##����#
	rcall NEW_HOUR
.endif
ldi temp2, 24
rcall RTC_sub	

.ifdef NEW_DAY		; ##���#
	rcall NEW_DAY
.endif
	lds temp, day_of_week
	lsl temp			; �������� ����� ���� ������ - � ��������  
	sbrc temp, 7		; ���������� ���, ���������� ���� ������
	ldi temp, 1			; ��� ������ �� �������� ��� ������ - ���������
	sts day_of_week, temp
lds temp2, days_in_month

	ld temp1, Y
	inc temp1
	cp temp1, temp2
	brlo end_time
	ldi temp1, 1
	st Y+, temp1


ld temp1, Y		; ##������# 
inc temp1		
/* ��������, ���������� �� ���������� ���������� ���� � ������.
�.�. 31 ���� � 1,3,5,7 � 8,10,12 �������, �.�. � �������� �� ������� � ������
 ����� �������, ��������� ��� ����� ��������. ������� �������������� ��������
 ��������: � days_in_month ������ ����������� �������� �� ���� ������, ��� 
 ���� � ������ �� ����� ����, ������ ��� ������ ���� ���������� ������ - ���
 ����� ���� � ���� ������ ���� ���� ���� */		 
	cpi temp1, 1			; ���� ������� - �� ��������� ����������
		breq feb_month		 
	ldi temp2, 30+1		; ���� �� ������� - �� ���� ����� 30 ��� 31 
	cpi temp1, 7			; ���� ������ � ������ - �������������
	brcc I_sec_a
		com temp1
  	 I_sec_a:
	sbrc temp1, 0		; � ���� ����� �������� - �������� �� 31 ���
		inc temp2
	rjmp end_month
feb_month:				; ������� ������ �������� ��������������
	ldi temp2, 28+1
	sbrs flag, leap_year	; 28 ���� � ������� ��� � 29 � ����������
		inc temp2
end_month:
sts days_in_month, temp2
	ld temp1, Y
	inc temp1
	cpi temp1, 12
	brlo end_time
	ldi temp1, 1
	st Y+, temp1

.ifdef HAPPY_NEW_YEAR		;##����# 
	rcall HAPPY_NEW_YEAR
.endif	
ld temp, Y	
inc temp
	cpi temp, 100		; ���, ����������� ���������� ��� � �������� 
	breq I_leap_year_a 	; ���� � ������� ������ - ���� ��������� ��� ����
	sbrc temp, 0		; ���� - ����, �� ��� ����������
	rjmp end_year	 
	sbrc temp, 1	
	rjmp end_year
	rjmp end_leap
 I_leap_year_a:
	lds temp, century		; ������ ����� ��������� ���. ���������
	inc temp			; �.�. ������ ��� ������� ����� - ���������
	sbrc temp, 0		; ���� ��� ��� 00, �.�. 2100, 2200 � �.�. - ��� ��
	rjmp end_year	 	; ���������� ���, �� ����������� ������� 
	sbrc temp, 1		; 4 ����. 2400, 2800 - ���������� ����
	rjmp end_year
end_leap:		
	sbr flag, (1<<leap_year) 
end_year: 

ldi temp2, 100
rcall RTC_sub
				
rcall RTC_sub				; �� � ##����#

end_time:
st Y, temp1				; ������� ����� ��������
pop temp
pop temp
ret

RTC_sub:				; �������������-��������. ��������� - ��������� 
	ld temp1, Y			;  - �������� � ������������ - ��������-���������/
	inc temp1			; �������� � ����� - ���������
	cp temp1, temp2
	brlo end_time
	clr temp1
	st Y+, temp1
ret
