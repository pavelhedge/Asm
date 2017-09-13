;## 						Time counter (second handler)			
/* 	Счетчик секунд, минут, часов, дней (+дней недели), месяцев (выставляет 
число дней в месяце также автоматически, лет (ставит високосный год в регистре 
flag), веков (ну мало ли). Принцип действия - увеличить, проверить, не достигло ли
максимального значения, если достигло - обнулить, увеличить след. величину  */

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

ldi temp2, 60		; ##Секунды#
rcall RTC_sub

rcall RTC_sub		; ##Минуты#

.ifdef NEW_HOUR		; ##Часы#
	rcall NEW_HOUR
.endif
ldi temp2, 24
rcall RTC_sub	

.ifdef NEW_DAY		; ##Дни#
	rcall NEW_DAY
.endif
	lds temp, day_of_week
	lsl temp			; Механизм счета дней недели - в регистре  
	sbrc temp, 7		; сдвигается бит, отмечающий день недели
	ldi temp, 1			; Как дойдет до восьмого дня недели - обнулится
	sts day_of_week, temp
lds temp2, days_in_month

	ld temp1, Y
	inc temp1
	cp temp1, temp2
	brlo end_time
	ldi temp1, 1
	st Y+, temp1


ld temp1, Y		; ##Месяцы# 
inc temp1		
/* Мазафака, отвечающая за правильное количество дней в месяце.
Т.к. 31 день в 1,3,5,7 и 8,10,12 месяцах, т.е. в нечетных до августа и четных
 после августа, проверяет эту самую четность. Февраль обрабатывается отдельно
 ВНИМАНИЕ: в days_in_month всегда загружается значение на день больше, чем 
 дней в месяце на самом деле, потому что первый день следующего месяца - это
 число дней в этом месяце плюс один день */		 
	cpi temp1, 1			; если февраль - то отдельный обработчик
		breq feb_month		 
	ldi temp2, 30+1		; Если не февраль - то дней будет 30 или 31 
	cpi temp1, 7			; если август и дальше - инвертировать
	brcc I_sec_a
		com temp1
  	 I_sec_a:
	sbrc temp1, 0		; И если число нечетное - докинуть до 31 дня
		inc temp2
	rjmp end_month
feb_month:				; Февраль вообще отдельно обрабатывается
	ldi temp2, 28+1
	sbrs flag, leap_year	; 28 дней в обычный год и 29 в високосный
		inc temp2
end_month:
sts days_in_month, temp2
	ld temp1, Y
	inc temp1
	cpi temp1, 12
	brlo end_time
	ldi temp1, 1
	st Y+, temp1

.ifdef HAPPY_NEW_YEAR		;##Годы# 
	rcall HAPPY_NEW_YEAR
.endif	
ld temp, Y	
inc temp
	cpi temp, 100		; Код, вычисляющий високосный год и ставящий 
	breq I_leap_year_a 	; флаг в регистр флагов - если последние два бита
	sbrc temp, 0		; года - нули, то год високосный
	rjmp end_year	 
	sbrc temp, 1	
	rjmp end_year
	rjmp end_leap
 I_leap_year_a:
	lds temp, century		; Теперь нужно проверить век. Загружаем
	inc temp			; т.к. только что начался новый - обновляем
	sbrc temp, 0		; Если это год 00, т.е. 2100, 2200 и т.д. - это не
	rjmp end_year	 	; високосный год, за исключением каждого 
	sbrc temp, 1		; 4 века. 2400, 2800 - високосные годы
	rjmp end_year
end_leap:		
	sbr flag, (1<<leap_year) 
end_year: 

ldi temp2, 100
rcall RTC_sub
				
rcall RTC_sub				; Ну и ##Века#

end_time:
st Y, temp1				; Запишем новое значение
pop temp
pop temp
ret

RTC_sub:				; Подпрограммка-помощник. Загрузить - увеличить 
	ld temp1, Y			;  - сравнить с максимальным - обнулить-сохранить/
	inc temp1			; добавить и выйти - сохранить
	cp temp1, temp2
	brlo end_time
	clr temp1
	st Y+, temp1
ret
