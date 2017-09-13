;###### 				CountDown Timer Handler				#####

/* 	Счетчик таймера обратного отсчета. минуты, секунды, часы, дни  
Поддержка косвенной записи в RAM экономит место	*/

.dseg

timer_sec: .byte 1
timer_min: .byte 1
timer_hour: .byte 1
timer_day: .byte 1

.cseg
TIM_sub:
	ld temp1, Y	
	subi temp1, 1
	st Y, temp1				
	brcc end_timer
	mov temp1, temp2
	st Y+, temp1
ret

ldi YL, low(timer_sec)	; Задает в Y начальный регистр таймера
ldi YH, high(timer_sec)

TIMER_HANDLER:
cli

ldi temp2, 59	; ##Секунды#
rcall TIM_sub

rcall TIM_sub	; ##Минуты#		

ldi temp2, 23	; ##Часы#
rcall TIM_sub

ldi temp2, 0		; ##Дни#
rcall TIM_sub

;cbr flag, (1<<timer_flag)
;rcall TIMER_SIGNAL

end_timer:
pop temp	; т.к. выход из прерывания TIM_sub был произведен через переход, 
pop temp	; почистим за собой стек
reti

TIMER_SIGNAL:


	
	