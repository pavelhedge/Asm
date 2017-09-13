;###### 					Alarm Handler					#####
	
/* 	ѕроверка будильника - в каждый день, отмеченный в alarm_day (единичка
единица в нулевом бите - понедельник, в первом - вторник, ..., в шестом - 
воскресенье, в седьмом - все дни недели  */

.dseg
alarm_min: .byte 1
alarm_hour: .byte 1
alarm_day: .byte 1

.cseg
ldi ZL, low(alarm_min)	; «адает в X начальный регистр будильника
ldi ZH, high(alarm_min)
ldi YL, low(minutes)	; «адает в X начальный регистр часов
ldi YH, high(minutes)

ALARM_HANDLER:
cli

ld temp1, Z+				; ##ћинуты#	
ld temp2, Y+
cp temp1, temp2
brne end_alarm

ld temp1, Z+				; ##„асы#	
ld temp2, Y
cp temp1, temp2
brne end_alarm

ld temp1, Z					; ##ƒни#
tst temp1					; ≈сли в alarm_day ничего не стоит - значит  
breq SINGLE_ALARM			; будильник прозвенит один раз, когда 
sbrc temp1, 7				; врем€ совпадет. ≈сли единица в бите 7 - 
rcall ALARM_SIGNAL			; звонить будет каждый день
lds temp2, day_of_week			; ≈сли регистр не пустой, но бит 7 - 0, то 
and temp1, temp2				; текущий день недели сравниваетс€ по маске
breq end_alarm 				; с дн€ми, заданными в alarm_day
rcall ALARM_SIGNAL
end_alarm:
reti

SINGLE_ALARM:				; ≈диничный звонок отличаетс€ от повтор€ющего-
cbr flag, (1<<alarm_flag)			; с€ только тем, что он снимает флаг будильника
						; за собой
ALARM_SIGNAL:

