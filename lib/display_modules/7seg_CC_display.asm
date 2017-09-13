; ##	Динамическая индикация для N-символьного 7сегментного индикатора с ОК	
/* Необходимо выбрать  число цифр в индикатора number_of_digits и
анодный/катодный порты
.equ number_of_digits=4
.equ anode_port=portB
.equ cathode_port=portC
Инициализация(указатель X используется только для пересчета цифр дисплея): 
ldi XL, low (digit1)
ldi XH, high (digit1)
ldi temp, 0b11111110
out cathode_port, temp
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
	
.cseg 	Symbol_Table:
/*	.db 0b00111011, 0b00111110 	; Буквы А-I
	.db 0b00011010, 0b01111010
	.db 0b10011110, 0b10001110
	.db 0b10111100, 0b00101110
	.db 0b00001100, 0b11111111
*/	
	.db 0b11111100, 0b01100000	; 0, 1
	.db 0b11011010, 0b11110010	; 2, 3
	.db 0b01100110, 0b10110110	; 4 ,5
	.db 0b10111110, 0b11100000	; 6, 7
	.db 0b11111110, 0b11110110	; 8, 9
	.db 0b00000000 			; blank
; Те же цифры, только с точкой	
	.db 0b11111101, 0b01100001	; 0, 1
	.db 0b11011011, 0b11110011	; 2, 3
	.db 0b01100111, 0b10110111	; 4 ,5
	.db 0b10111111, 0b11100001	; 6, 7
	.db 0b11111111, 0b11110111	; 8, 9
	.db 0b00000001 			; blank
HAPPY:
	.db 0b01101110, 0b11101110	; H, A
	.db 0b11001110, 0b11001110	; P, P
	.db 0b01110110, 0b00000000 	; Y, blank
/*	      0baBcDefGh	(примечание: сегмент зажигает "логическая единичка" 
		76543210	(номера битов, для инструкций манипуляции битами)	
					 ---A---
					|	|
					F	B
					|	|
					 ---G---	
					|	|
					E	C
					|	|
					 ---D---	     oH
*/			

.equ	Symbol_Blank	= 10	; Псевдонимы некоторых спец. символов:
.equ 	Symbol_HAPPY = 24

	
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
	
	ldi ZL, low(symbol_table*2)	; Устанавливаем Z на начало таблицы 
	ldi ZH, high(symbol_table*2)	; символов
	ld temp, X+				; загружаем из памяти значение текущей  
	add ZL, temp			; цифры и рассчитываем адрес в таблице 
	lpm temp, Z				; симоволов, загружаем кодировку символа
	out anode_port, temp		; и выводим на дисплей
	
	cpi XL, (low(digit1)+number_of_digits)	; адрес следующей цифры сам 
	brlo i_disp_b			 	; переключается при загрузке из Х
		ldi XL, low(digit1)			; так что остается только следить
 	 I_disp_b:				 	; чтоб он не вышел за пределы
reti


