;###### 				CountDown Timer Handler				#####

/* 	������� ������� ��������� �������. ������, �������, ����, ���  */

TIMER_HANDLER:
cli

 	
subi timer_sec, 1		; ##�������#			
brcc end_timer
ldi timer_sec, 59		

subi timer_min		; ##������#			
brcc end_timer
ldi timer_min, 59

subi timer_hour		; ##����#			
brcc end_timer
ldi timer_hour, 23

		
subi timer_day, 1 ; ##���#
brcc end_timer
clr timer_day

cbr flag, (1<<timer_flag)
rcall TIMER_SIGNAL

end_timer:
reti