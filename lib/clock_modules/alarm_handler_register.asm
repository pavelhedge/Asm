;###### 					Alarm Handler					#####
	
/* 	�������� ���������� - � ������ ����, ���������� � alarm_day (��������
������� � ������� ���� -   */

.dseg
alarm_min: .byte 1
alarm_hour: .byte 1
alarm_day: .byte 1

.cseg
ALARM_HANDLER:
cli

lds temp1, alarm_min			; ##������#	
ld temp2, minutes
cp temp1, temp2
brne end_alarm

ld temp1, alarm_hour			; ##����#	
ld temp2, hours
cp temp1, temp2
brne end_alarm

lds temp1, alarm_day			; ##���#
sbrc, temp1, 7
rcall ALARM_SIGNAL
lds temp2, day_of_week
and temp1, temp2
breq end_alarm

rcall ALARM_SIGNAL

end_alarm:
reti

ALARM_SIGNAL:
sbr flag, (1<<alrm_flag)
