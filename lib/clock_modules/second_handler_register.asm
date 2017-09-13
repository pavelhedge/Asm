;## 						Time counter (second handler)			
/* 	������� ������, �����, �����, ���� (+���� ������), �������
(���������� ����� ���� � ������ ����� �������������, ��� (������ ����������
��� � �������� flag). ������� �������� - ���������, ���������, �� �������� ��
������������� ��������, ���� �������� - ��������, ��������� ����. ��������  */

SECOND_HANDLER:

inc seconds				
cpi seconds, 60
brcc end_time
clr seconds

inc minutes
cpi minutes, 60
brcc end_time
clr minutes

inc hours
cpi hours, 24
brcc end_time
clr hours

inc days
	lsl day_of_week		; �������� ����� ���� ������ - � ��������  
	sbrc day_of_week, 7	; ���������� ���, ���������� ���� ������
	ldi day_of_week, 1	; ��� ������ �� �������� ��� ������ - ���������
cp days, days_in_month		
brcc end_time
clr days

inc month		
/* ��������, ���������� �� ���������� ���������� ���� � ������.
�.�. 31 ���� � 1,3,5,7 � 8,10,12 �������, �.�. � �������� �� ���� � ������
 ����� ����, ��������� ��� ����� ��������. ������� �������������� ��������
*/				
mov temp, month		 
cpi temp, 1				; ���� ������� - �� ���� � ��������� ����������
breq feb_month		 
ldi days_in_month, 30		; ���� �� ������� - �� ���� ����� 30 ��� 31 
cpi temp, 7				; ���� ������ � ������ - �������������
sbic SREG, 0
	com temp
sbrc temp, 0			; � ���� ����� �������� - �������� �� 31 ���
	inc days_in_month
rjmp end_month
	feb_month:			; ������� ������ �������� ��������������
	ldi days_in_month, 28
	sbrs flag, leap_year	; 28 ���� � ������� ��� � 29 � ����������
	inc days_in_month
end_month:
cpi month, 12
brcc end_time
clr month
	
inc year
cpi year, 100
brcc end_time
clr year

end_time:
ret