;###### 				CountDown Timer Handler				#####

/* 	Счетчик таймера обратного отсчета. минуты, секунды, часы, дни  
Поддержка косвенной записи в RAM экономит место	*/

TIMER_HANDLER:
cli
ldi YL, low(timer_sec)
ldi YH. high(timer_sec)

ld temp, Y		; ##Секунды#
subi temp, 1
st Y, temp				
brcc end_timer
ldi temp, 59
st Y+, temp

ld temp, Y		; ##Минуты#		
subi temp, 1
st Y, temp				
brcc end_timer
ldi temp, 59
st Y+, temp

ld temp, Y		; ##Часы#
subi temp, 1
st Y, temp				
brcc end_timer
ldi temp, 23
st Y+, temp

ld temp, Y		; ##Дни#
subi temp, 1
st Y, temp
brcc end_timer
clr temp
st Y, temp

cbr flag, (1<<timer_flag)
rcall TIMER_SIGNAL

end_timer:
reti



	
	