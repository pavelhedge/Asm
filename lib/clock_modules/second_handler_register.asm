;## 						Time counter (second handler)			
/* 	Счетчик секунд, минут, часов, дней (+дней недели), месяцев
(выставляет число дней в месяце также автоматически, лет (ставит високосный
год в регистре flag). Принцип действия - увеличить, проверить, не достигло ли
максимального значения, если достигло - обнулить, увеличить след. величину  */

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
	lsl day_of_week		; Механизм счета дней недели - в регистре  
	sbrc day_of_week, 7	; сдвигается бит, отмечающий день недели
	ldi day_of_week, 1	; Как дойдет до восьмого дня недели - обнулится
cp days, days_in_month		
brcc end_time
clr days

inc month		
/* Мазафака, отвечающая за правильное количество дней в месяце.
Т.к. 31 день в 1,3,5,7 и 8,10,12 месяцах, т.е. в нечетных до июля и четных
 после июля, проверяет эту самую четность. Февраль обрабатывается отдельно
*/				
mov temp, month		 
cpi temp, 1				; если февраль - то идем в отдельный обработчик
breq feb_month		 
ldi days_in_month, 30		; Если не февраль - то дней будет 30 или 31 
cpi temp, 7				; если август и дальше - инвертировать
sbic SREG, 0
	com temp
sbrc temp, 0			; И если число нечетное - докинуть до 31 дня
	inc days_in_month
rjmp end_month
	feb_month:			; Февраль вообще отдельно обрабатывается
	ldi days_in_month, 28
	sbrs flag, leap_year	; 28 дней в обычный год и 29 в високосный
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