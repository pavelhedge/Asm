; ##	Динамическая индикация для N-символьного 7сегментного индикатора с ОК	
/* Необходимо выбрать  число цифр в индикатора digit_number и
анодный/катодный порты
.equ digit_number=4
.equ anode_port=portB
.equ cathode_port=portC
Инициализация(указатель X используется только для пересчета цифр дисплея): 
ldi XL, low (digit1)
ldi XH, high (digit1)
ldi temp, 0b11111110
out cathode_port, temp

Рассчитан на работу с готовыми символами в digit1...digit3
 */
  
.dseg					; Определим, сколько байт в RAM резервировать
.if number_of_digits==1			; под значения, выводимые на дисплей
digit1: .byte 1
.elif number_of_digits==2
digit1: .byte 1
digit2: .byte 1
.elif number_of_digits==3
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
.elif number_of_digits==4
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
.elif number_of_digits==5
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
digit5: .byte 1
.elif number_of_digits==6
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
digit5: .byte 1
digit6: .byte 1
.elif number_of_digits==7
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
digit5: .byte 1
digit6: .byte 1
digit7: .byte 1
.elif number_of_digits==8
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1
digit5: .byte 1
digit6: .byte 1
digit7: .byte 1 
digit8: .byte 1
.elif number_of_digits>8
.error "Too high number of digits is set"
.endif
	
.cseg

DISPLAY_HANDLER:											
cli
/* Обработчик общего электрода - в данном случае общий катод.
Принцип действия простой - загрузили в темп, сдвинули на след. символ, 
выгрузили обратно */
	in temp1, cathode_port		; Обработка общего электрода - выбор цифры
mov temp2, temp1	; эти две команды сберегают разряды, не используемые
andi temp2, low(0xFF<<(number_of_digits))	; в индикации от изменений под маской
	sec					; флаг нужен, чтоб при rol в 0 бит сдвигалась 1
	rol temp1				; просто сдвигаем ноль по регистру
	
.if number_of_digits==8			; Если число разрядов - восемь, проверяем
	brlo I_disp_a	 		; ноль по флагу С в SREG 
	ldi temp1, 0b11111110 		; если убежал - ставим на место
 I_disp_a:
 
.else	sbrs temp1, number_of_digits	; проверяя, чтоб не убежал слишком далеко
	ldi temp1, 0b11111110 		; если убежал - ставим на место
.endif

andi temp1, 0xFF>>(8-number_of_digits)	; А здесь неиспользуемые разряды
or temp1, temp2			; возвращаются обратно - оп-ля!
	out cathode_port, temp1		; сдвинули - вернули, откуда взяли
/* Обработчик собственно, 7-сегментника (в данном случае анода)
- адрес текущего значения текущей цифры записан в Х (в других операциях 
в этой программе их трогать нельзя!!!)
 */
	
	ld temp, X+				; загружаем из памяти значение текущей  
	out anode_port, temp		; и выводим на дисплей
	
	cpi XL, (low(digit1)+number_of_digits)	; адрес следующей цифры сам 
	brlo i_disp_b			 	; переключается при загрузке из Х
		ldi XL, low(digit1)			; так что остается только следить
 	 I_disp_b:				 	; чтоб он не вышел за пределы
reti


