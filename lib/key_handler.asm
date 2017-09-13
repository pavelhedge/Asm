;##					Процедура сканирования кнопок				
/* Сканирует две кнопки и сохраняет результаты в key_flag в формате 

бит 4,5 - текущее состояние кнопки (проверенное)
бит 2,3 - долгое нажатие
бит 0,1 - фронт кнопок */
.equ long_1=2
.equ long_2=3
.equ press_1=4
.equ press_2=5
.equ front_1=0
.equ front_2=1 

.equ press_time=3
.equ long_press_time=3000	; Примерно раз в секунду
.def 	key_cnt = r14 	; Базовый счетный регистр для фильтрации дребезга
.def 	key=r15 		; верхние биты определяют текущее состояние кнопки,
.def 	key_flag=r21	; первые два бита определяют текущее состояние кнопки,
			; вторые два - долгое нажатие, и еще два - индикация фронта
.def counter = r24	; Длинный счетчик, измеряющий время нажатия, r24-r25

.set __keys_included__ =1

.macro KEY_INITIALIZIATION
sbi key_port, 4
sbi key_port, 5
.endmacro
	
KEY_SCAN_HANDLER:	
cli													
	in temp1, key_port	; Получаем "сырое" значение каждый такт 
	com temp1			; Инвертируем значение - заземленная кнопка = 1
	andi temp1, 0b00110000	; оставляем только биты кнопок
	mov temp2, key_flag
	andi temp2, 0b00110000
	cp temp1, temp2	; Если предыдущее состояние равно текущему и это
	brne I_key_not_same 	; ноль - тогда выходим из цикла, это неинтересно
	tst temp1			; Если не равно текущему - идем в обработчик
	breq I_key_exit 		
				
	sbiw counter, 1		; Если равно и не ноль - то уменьшаем счетчик 
	brne I_key_exit	 	; долгого нажатия и проверяем, не обнулился ли он
	brlo I_key_A
	lsr temp1				; Если время пришло - сдвигаем темп на 
	lsr temp1				; позиции флагов долгого нажатия				 
	cbr key_flag, 0b00001100	; и записываем в флаги
	or key_flag, temp1	;
	lsr temp1
	lsr temp1
	or key_flag, temp1
 
 I_key_exit:
reti
 I_key_A:
inc counter
reti
	
 I_key_not_same:		 	; Если получили что-то новое - сравниваем с 
	cp temp1, key		; текущим значением клавиатуры. KEY - непод-
	breq I_key_equal	 	; твержденное значение прошлого раза. 
	mov key, temp1		; Если текущее равно key  - мотаем счетчик, если
	ldi temp2, 3			; не равно - обновляем key и обнуляем счетчик 
	mov key_cnt, temp2
reti
	
 I_key_equal:		 	; Мотаем счетчик (см. выше) 
	dec key_cnt	
	breq I_key_valid	 	; Счетчик вымотан - значение подтверждено
reti

 I_key_valid:		 	; Значение подтверждено	
 sbrs key_flag, long_1		; если хотя бы одно длинное нажатие - 
 sbrc key_flag, long_2		; обратный фронт не ставится
 rjmp I_no_front
         	eor key_flag, temp1
	andi key_flag, 0b00110000
	swap key_flag
	or key_flag, temp1
	ldi r24, low (long_press_time)	; Обнулим счетчик
	ldi r25, high (long_press_time)
reti
 	 I_no_front:
 	 mov key_flag, temp1
reti

