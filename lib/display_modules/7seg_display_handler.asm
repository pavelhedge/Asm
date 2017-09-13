; ##	Динамическая индикация для 4-сивольного семисегментного индикатора	

.def digit1=r4
.def digit2=r5
.def digit3=r6
.def digit4=r7

.cseg 	Symbol_Table:
	.DB	0b11111100	; 0
	.DB	0b01100000	; 1
	.DB	0b11011010	; 2
	.DB	0b11110010	; 3
	.DB	0b01100110	; 4
	.DB	0b10110110	; 5
	.DB	0b10111110	; 6
	.DB	0b11100000	; 7
	.DB	0b11111110	; 8
	.DB	0b11110110	; 9
	.DB	0b11101110	; 10: A
	.DB	0b00111110	; 11: b
	.DB	0b10011100	; 12: C
	.DB	0b01111010	; 13: d
	.DB	0b10011110	; 14: E
	.DB	0b10001110	; 15: F
	.DB	0b00000000	; 16: blank (пусто)
	.DB	0b11000110	; 17: bell up
	.DB	0b00111010	; 18: bell down
	.DB	0b10110110	; 19: "Seconds"-1	(символ заполняет пару индикаторов, используется в "режиме настройки")
	.DB	0b00011010	; 20: "Seconds"-2	(символ заполняет пару индикаторов, используется в "режиме настройки")
	.DB	0b11001100	; 21: "Minutes"-1	(символ заполняет пару индикаторов, используется в "режиме настройки")
	.DB	0b11100100	; 22: "Minutes"-2	(символ заполняет пару индикаторов, используется в "режиме настройки")
	.DB	0b01101110	; 23: "Hours"-1		(символ заполняет пару индикаторов, используется в "режиме настройки")
	.DB	0b00001010	; 24: "Hours"-2		(символ заполняет пару индикаторов, используется в "режиме настройки")
	;	0bABCDEFGH	(примечание: сегмент зажигает "логическая единичка" в разряде)
	;	    76543210	(номера битов, для инструкций манипуляции битами)
	
.equ	SymbolBlank	= 16	; Псевдонимы некоторых спец. символов:
.equ	SymbolBellUp	= 17
.equ	SymbolBellDown	= 18
.equ	SymbolSeconds	= 19
.equ	SymbolMinutes	= 21
.equ	SymbolHours	= 23

DISPLAY_HANDLER:
cli
	sec
	rol cathode
	sbrc cathode, digit_number
	ldi cathode, 0b11111110
	out cathode_port, cathode
	
	ldi ZL, low(symbol_table)
	ldi ZH, high(symbol_table)
	add ZL, digit1
	lpm temp, Z
	out anode_port, temp
reti


