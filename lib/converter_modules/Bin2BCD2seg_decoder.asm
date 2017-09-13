;###### 			8-bit binary to 2-digit BCD converter				#####

;
/* ВНИМАНИЕ - данный конвертер предназначен для конвертации 8-битного 
двоичного числа из RAM до 99 включительно в две десятичные цифры, которые 
потом записываются в RAM. Повторный запуск - конвертация следующего числа в 
RAM в следующие две цифры, записывающиеся по следующим адресам.
Используется, например, для конвертации минут и часов в часах. 

Вторая версия подразумевает, что в digit1...digitN пишутся не обозначения знака
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
	.db 0b11111100, 0b01100000	; 0, 1
	.db 0b11011010, 0b11110010	; 2, 3
	.db 0b01100110, 0b10110110	; 4 ,5
	.db 0b10111110, 0b11100000	; 6, 7
	.db 0b11111110, 0b11110110	; 8, 9 
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

.equ	Symbol_Blank	= 15	; Псевдонимы некоторых спец. символов:
.equ 	Symbol_HAPPY = 10



Bin2BCD:
ld temp1, Z+			; Загрузить первое значение
clr temp2				; Очистить регистр десятков
bin2bcd_a:
	cpi temp1, 10		; Если число больше 10 - отнять 10
	brlo bin2bcd_b
	subi temp1, 10
	inc temp2			; И прибавить к десяткам 1
	rjmp bin2bcd_a
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



