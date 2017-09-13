; ##	Динамическая индикация для 4-символьного газоразрядного индикатора 
; ##	с управлением микросхемой КР144ИД1
/* Используется прямое управление лампами ИН с динамическим включением. 10 пинов - катоды,
1-8 пинов одного порта - управление анодами. 

.equ display_port=portC
Инициализация(указатель X используется только для пересчета цифр дисплея): 
ldi XL, low (digit1)
ldi XH, high (digit1)
ldi temp, 0x10
out display_port, temp
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

in temp1, display_port

/* Обработчик общего электрода - в данном случае общий анод.
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
or temp1, temp2				; возвращаются обратно - оп-ля!
	out cathode_port, temp1		; сдвинули - вернули, откуда взяли
	
/* Обработчик катодов. */

symbol_IN 	.db 0b00000001, 0b00000010
		.db 0b00000100, 0b00001000
		.db 0b00010000, 0b00100000
		.db 0b01000000, 0b10000000
LDA ZZ, symbol_IN*2
ld temp2, X+
cpi temp2, 8
brlo I_display_less
subi temp2, 8
add ZL, temp2
lpm temp1, Z
ori temp3
out portB, temp3
reti

 I_display_less
add ZL, temp2
lpm temp1, Z
ori temp3
out portD, temp3
reti

 







