; ##	Динамическая индикация для N-символьного 7сегментного индикатора с ОК	
/* Необходимо выбрать  число цифр в индикатора number_of_digits и
анодный/катодный порты
.equ number_of_digits=4
.equ anode_port=portB
.equ anode_ddr=DDRB
.equ cathode_port=portC
.equ cathode_ddr=DDRC
Инициализация(указатель X используется только для пересчета цифр дисплея): 
ldi XL, low (digit1)
ldi XH, high (digit1)
ldi temp, 0b11111110
out cathode_port, temp

Рассчитан на работу с готовыми символами в digit1...digit8, т.е. в digit1...digit8
помещаются не цифры, а готовые значения для семисегментника
 */
 
 .equ __display_included__ =1
 
 .MACRO DISPLAY_INIT ; Автоматическая инициализация портов под дисплей
 outi anode_ddr, 0xFF
 outi cathode_ddr, 0xFF>>(8-number_of_digits)
 outi cathode_port, 0xFF>>(8-number_of_digits)
 LDA XX, digit1
 .ENDM
  
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
Т.к. в этом варианте катод подключен через транзистор - активный уровень -высокий, а не низкий. 
Принцип действия простой - загрузили в темп, сдвинули на след. символ, 
выгрузили обратно */
	in temp1, cathode_port		; Обработка общего электрода - выбор цифры
	mov temp2, temp1	; эти две команды сберегают разряды, не используемые
	andi temp2, low(0xFF<<(number_of_digits))	; в индикации от изменений под маской
	lsl temp1				; просто сдвигаем единицу по регистру
	
.if number_of_digits==8			; Если число разрядов - восемь, проверяем
	brsh I_disp_a	 		; единицу по флагу С в SREG 
	ldi temp1, 0x01 		; если убежала - ставим на место
 I_disp_a:
 
.else	sbrc temp1, number_of_digits	; проверяя, чтоб не убежал слишком далеко
	ldi temp1, 0x01 		; если убежал - ставим на место
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



;###### 			8-bit binary to 2-digit BCD 7-seg converter				#####

;
/* Вторая версия подразумевает, что в digit1...digitN пишутся не обозначения знака
в таблице, а само его значение (для упрощения работы)

ldi ZH, high(minutes)
ldi ZL, low(minutes)
ldi YH, high(digit1)
ldi YL, low(digit1)
 	или, с введением макроса lda:
lda ZZ, minutes+1
lda YY, digit1
 */
 .cseg 	Symbol_Table:
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

	.db 0b11111100, 0b01100000	; 0, 1
	.db 0b11011010, 0b11110010	; 2, 3
	.db 0b01100110, 0b10110110	; 4 ,5
	.db 0b10111110, 0b11100000	; 6, 7
	.db 0b11111110, 0b11110110	; 8, 9 

	.db 0b11101110, 0b00111110	; A, b
	.db 0b00011010, 0b01111010	; c, d
	.db 0b10011110, 0b10001110	; E, F


;.ifdef __display_symbol__
;	.db 0b10111100, 0b00101110	; G, h	
;	.db 0b01101110, 0b11101110	; H, A
;	.db 0b11001110, 0b11001110	; P, P
;	.db 0b01110110, 0b00000000 	; Y, blank
;			
;.equ	Symbol_Blank	= 20	; Псевдонимы некоторых спец. символов:
;.equ 	Symbol_HAPPY = 16
;.endif

.ifdef __display_hex__
DISPLAY_HEX:
; Выводит 1 байт в HEX-виде тем же способом, что и следующий вариант. 
ld temp1, Z+
	DISPLAY_HEX_REG:
mov temp2, temp1
swap temp1
andi temp1, 0x0F
andi temp2, 0x0F
rjmp bin2bcd_b
.endif

.ifdef __display_dec__
DISPLAY_DEC:	
/* ВНИМАНИЕ - данный конвертер предназначен для конвертации 8-битного 
двоичного числа из RAM до 99 включительно в две десятичные цифры, которые 
потом записываются в RAM. Повторный запуск - конвертация следующего числа в 
RAM в следующие две цифры, записывающиеся по следующим адресам.
Используется, например, для конвертации минут и часов в часах. */


ld temp1, Z+			; Загрузить первое значение
DISPLAY_DEC_REG:
mov temp2, temp1
clr temp1				; Очистить регистр десятков
bin2bcd_a:
	cpi temp2, 10		; Если число больше 10 - отнять 10
	brlo bin2bcd_b
	subi temp2, 10
	inc temp1			; И прибавить к десяткам 1
	rjmp bin2bcd_a
.endif

.ifdef __display_dec__
.set bin2bcd_temp = 1
.endif
.ifdef __display_hex__
.set bin2bcd_temp = 1
.endif

.ifdef bin2bcd_temp
bin2bcd_b:
push ZL
push ZH
	clr temp3
	LDA ZZ, symbol_table*2
	add ZL, temp1
	adc ZH, temp3
	lpm temp1, Z
	ld temp3, Y
	bst temp3, 0
	bld temp1, 0
	st Y+, temp1
	
	clr temp3
	LDA ZZ, symbol_table*2
	add ZL, temp2
	adc ZH, temp3
	lpm temp2, Z
	ld temp3, Y
	bst temp3, 0
	bld temp1, 0
	st Y+, temp2
pop ZH
pop ZL	
ret
.endif

.ifdef  __display_symbol__
DISPLAY_SYMBOL:		; На случай если нужно вывести символы
/* Если нужно вывести отдельные символы: 
LDA YY digit_number
ldi temp2, symbol_name */
cli	
	clr temp3
	LDA ZZ, symbol_table*2
	add ZL, temp1
	adc ZH, temp3
	lpm temp1, Z
	ld temp3, Y
	bst temp3, 0
	bld temp1, 0
	st Y+, temp1

ret
.endif