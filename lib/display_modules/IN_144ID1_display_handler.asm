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
  
.dseg				
digit1: .byte 1
digit2: .byte 1
digit3: .byte 1
digit4: .byte 1

DISPLAY_HANDLER:
cli 

in temp1, display_port

; общий анод - биты 4-7, единица - включенная цифра
andi temp1, 0xF0
lsl temp1
brcc I_disp_a
	ldi temp1, 0x10
 I_disp_a:
 ; катод - 4 бита, значения 0-9 - цифры, 10-15 - выключить, берем напрямую из digits
ld temp2, X+
or temp1, temp2
out display_port, temp1
cpi XL, (low(digit1)+digit_number)
brlo I_disp_b:
	ldi XL, low(digit1)
 I_disp_b:

