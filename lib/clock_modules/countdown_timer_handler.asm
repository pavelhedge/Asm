;###### 				CountDown Timer Handler				#####

/* 	Счетчик таймера обратного отсчета. минуты, секунды, часы, дни  */

TIMER_HANDLER:
cli

 	
subi timer_sec, 1		; ##Секунды#			
brcc end_timer
ldi timer_sec, 59		

subi timer_min		; ##Минуты#			
brcc end_timer
ldi timer_min, 59

subi timer_hour		; ##Часы#			
brcc end_timer
ldi timer_hour, 23

		
subi timer_day, 1 ; ##Дни#
brcc end_timer
clr timer_day

cbr flag, (1<<timer_flag)
rcall TIMER_SIGNAL

end_timer:
reti