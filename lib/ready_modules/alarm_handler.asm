;###### 					Alarm Handler					#####
	
/* 	�������� ���������� - � ������ ����, ���������� � alarm_day (��������
������� � ������� ���� - �����������, � ������ - �������, ..., � ������ - 
�����������, � ������� - ��� ��� ������  */

.dseg
alarm_min: .byte 1
alarm_hour: .byte 1
alarm_day: .byte 1

.cseg
ldi ZL, low(alarm_min)	; ������ � X ��������� ������� ����������
ldi ZH, high(alarm_min)
ldi YL, low(minutes)	; ������ � X ��������� ������� �����
ldi YH, high(minutes)

ALARM_HANDLER:
cli

ld temp1, Z+				; ##������#	
ld temp2, Y+
cp temp1, temp2
brne end_alarm

ld temp1, Z+				; ##����#	
ld temp2, Y
cp temp1, temp2
brne end_alarm

ld temp1, Z					; ##���#
tst temp1					; ���� � alarm_day ������ �� ����� - ������  
breq SINGLE_ALARM			; ��������� ��������� ���� ���, ����� 
sbrc temp1, 7				; ����� ��������. ���� ������� � ���� 7 - 
rcall ALARM_SIGNAL			; ������� ����� ������ ����
lds temp2, day_of_week			; ���� ������� �� ������, �� ��� 7 - 0, �� 
and temp1, temp2				; ������� ���� ������ ������������ �� �����
breq end_alarm 				; � �����, ��������� � alarm_day
rcall ALARM_SIGNAL
end_alarm:
reti

SINGLE_ALARM:				; ��������� ������ ���������� �� ������������-
cbr flag, (1<<alarm_flag)			; �� ������ ���, ��� �� ������� ���� ����������
						; �� �����
ALARM_SIGNAL:

