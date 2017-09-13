;######					MENU_HANDLER					#####

/* В меню реализуются все функции, кроме непосредственного отображения, 
подсчета времени, сырой обработки кнопок (нажатие, фронт, длительное нажатие)
А так же подсчета будильников, таймеров и всего такого.

Т.е. настройка часов, все показы даты, поздравлений и всего-всего - здесь

По нажатию второй кнопки показывается текущая дата 
по долгому нажатию первой кнопки включается режим установки дней-месяцев
(дней недели)--лет-веков, по короткому - установка часов-минут. последующие
нажатия переключают разряды. вторая кнопка меняет значения. 
первая долго - выход 

Это самый первый вариант, поэтому будильников-таймеров и дней недели нет

Номер изменяемого чего-то там стоит в 4-7 битах флага flag
биты 6-7 - номер изменяемого знака на экране, соответственно, бит 7 определяет,
изменяются десятки или единицы

 mov temp1, flag
 andi temp1, 0b00000011
 LDA YY, digit1
 add Y, temp1
 ldi temp2, symbol_blank
 st Y, temp2
 
 	Menu_flag с каждым символом увеличивается, но на самом деле отдельные
 символы идут от digit3 к digit1 для получения порядка слева направо. Поэтому 
 биты флага просто инвертируются для получения порядкового номера символа
*/
.ifndef current_value
.def current_value=r12
.endif
.ifndef max_value
.def max_value=r13
.endif

.equ date_mode=6
.equ menu_mode=7


MENU_HANDLER:
cli

sbrc menu_flag, menu_mode		; Если часы в режиме меню - другой пункт
	rjmp I_menu_mode_on

tst key_flag					; Если ничего нет на кнопках - это не сюда
	brne I_menu_a
reti

 I_menu_a:
sbrs key_flag, front_2			; Если фронт у второй кнопки - что-то с датой
	rjmp I_menu_next_key	 	; Отпущена - идем дальше

;##	Показ даты	 
	LDA YY, digit1			
sbrs key_flag, press_2
	rjmp I_menu_showdate_off 	; Если вторая нажата - показать дату 

	LDA ZZ, month
	rcall Bin2BCD
	LDA ZZ, days
	rcall Bin2BCD
	
	lds temp, digit3			; Поставить точку между днями и месяцами
	sbr temp, 1
	sts digit3, temp

	sbr menu_flag, (1<<date_mode)
reti
 I_menu_showdate_off:		 	; Вырубить, как вторая кнопка отпущена 
	LDA ZZ, minutes
	rcall Bin2BCD
	rcall Bin2BCD
	
	cbr menu_flag, (1<<date_mode)
reti

;##	Вход в основное меню
 I_menu_next_key:		 	; Вход в меню - долгое нажатие - дата-год
sbrs key_flag, front_1
reti
sbrc key_flag, long_1						; Короткое - настройка времени
rjmp I_menu_dayz
sbrs key_flag, press_1

	sbr menu_flag, (1<<menu_mode)	; Настройка часов-минут
	rjmp I_menu_hours_set
reti

 I_menu_dayz:			 	; Настройка дней-месяцев
	LDA YY, digit1
	LDA ZZ, month
	rcall Bin2BCD
	LDA ZZ, days
	rcall Bin2BCD
	
	lds temp, digit3			; Поставить точку между днями и месяцами
	sbr temp, 1
	sts digit3, temp
	
	sbr menu_flag, (1<<menu_mode|1<<date_mode)	; Установка флагов
	rjmp I_menu_days_set
reti

;##						Режим меню						
 I_menu_mode_on:
 
 sbrc key_flag, front_2 
 sbrs key_flag, press_2
 rjmp I_menu_ON_next_key
 
 ;##	Режим меню - изменение значения параметра времени				

 LDA YY, digit1			; Вычислить текущую цифру на экране
 mov temp2, menu_flag
 com temp2				; Инверсия - потому, что на самом деле digit1 
 andi temp2, 0b00000011	; последняя, а digit3 - первая
 add YL, temp2
 
 mov ZL, current_value		; Загрузить текущее значение	
 ld temp, Z			
 
 sbrs menu_flag, 0
 rjmp I_menu_decimal_increment
 inc temp
 cp max_value, temp
 brsh I_menu_display
 ldi temp, 1
 sbrc menu_flag, date_mode	; Если data_mode и бит 2 =1 - забиваем в значение 0
 sbrs menu_flag, 2		; Если data_mode и бит 2 =0 - 1
 clr temp				; Если не дата мод - 0
 rjmp I_menu_display

 I_menu_decimal_increment: 	; Суть такая - когда меняются десятки, единицы 
 subi temp, -10			; остаются на месте. Поэтому при превышении
 cp max_value, temp		; максимального значения берем то, что есть в
 brsh I_menu_display	 	; единицах на монике и записываем в значение

 I_menu_decimal_max:	 	; Если больше max, то отнимаем десятки до ухода  
 subi temp, 10			; в минус, а потом прибавляем десять - получаем 
 brcc I_menu_decimal_max 	; единицы.
 subi temp, -10

 
 I_menu_display: 		
 	st Z, temp			; В Y и Z уже забиты нужная цифра и отуда ее брать
 	sbrs menu_flag, 0		; т.к. нужно попасть в первую цифру значения, если 
 	dec YL			; меняются десятки - вычесть единицу
  	rcall Bin2BCD
 reti
 
  
 ;##	Режим меню - переход к другому параметру (минуты-часы, день-месяц-год)
 
 I_menu_ON_next_key:
 sbrs key_flag, front_1
 reti
 sbrc key_flag, long_1
 rjmp I_menu_exit
 sbrc key_flag, press_1		; При обычном - переключение на изменение
 reti 					; следующего символа
 
  	mov temp, menu_flag	; Последние 4 бита в flag играют роль счетчика 
  	andi temp, 0b00001111	; изменяемых позиций
  	andi menu_flag, 0b11110000	; сначала обнуляем AND ненужные биты,
  	inc temp			; потом увеличиваем и с помощью OR 
  	or menu_flag, temp	; записываем обратно в FLAG
  	sbrc menu_flag, 0	; Если 1, то просто меняются разряды одного значения
 reti 
 sbrc menu_flag, date_mode
 rjmp I_menu_date_mode
 sbrs menu_flag, 2
 rjmp I_menu_time_mode

 	clr temp			; В случае, если меню было в режиме времени - 
	sts seconds, temp		; установить секунды в ноль и выйти
 
 I_menu_exit:	 	; По команде "выход из меню" обнуляются все флаги 
 clr menu_flag		; меню, флаги фронтов кнопок и т.д. и начинается  
 reti				; обычный отсчет времени

 
 I_menu_time_mode:	 	; Теперь нужно забить значения максимума и 
 sbrs menu_flag, 1		; адреса текущего значения.
 rjmp I_menu_hours_set
 
;##			Минуты			
 ldi temp1, 60
 ldi temp2, low (minutes)
 rjmp I_menu_set_end
 
 ;##			Часы				
 I_menu_hours_set:
 ldi temp1, 24
 ldi temp2, low(hours)
 rjmp I_menu_set_end
 
 ;##			Дата				
 I_menu_date_mode:
 sbrc menu_flag, 3
 rjmp I_menu_exit
 sbrc menu_flag, 2
 rjmp I_menu_year_set
 sbrc menu_flag, 1
 rjmp I_menu_month_set
 
 ;##			Дни				
 I_menu_days_set:
 lds temp1, days_in_month
 ldi temp2, low(days)
 rjmp I_menu_set_end
 
 ;##			Месяцы			
 I_menu_month_set:
 ldi temp1, 12
 ldi temp2, low(month)
 rjmp I_menu_set_end
 
 ;##			Годы				
 I_menu_year_set:
	LDA YY, digit1
  	LDA ZZ, year
  	rcall Bin2BCD
  	rcall Bin2BCD
  	
  	lds temp1, digit3
  	cbr temp1, 1
	sts digit3, temp1
 
 ldi temp1, 100
 ldi temp2, low(year)
 sbrs menu_flag, 1
 ldi temp2, low(century)
 
 I_menu_set_end: 		; Сохранить и выйти
 mov max_value, temp1
 mov current_value, temp2
 reti
   	