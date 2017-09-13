;######				TICKER STRING HANDLER				#####
.dseg 
ticker_string: .byte ticker_string_lenght
; Варианты исполнения - с размещением пойнтера в RAM
;ticker_pointer: .byte 1
.def ticker_pointer = r8
.cseg
/* TICKER_HANDLER:
cli
lda YY, digit1
lda ZZ, ticker_string
add ZL, ticker_pointer

 I_tick:
ld temp, Z+
st Y+, temp
cpi ZL, low(ticker_string+ticker_string_lenght)
brcc I_tick_a
ldi ZL, low (ticker_string)
 I_tick_a:
cpi YL, low (digit1)
brcs I_tick
inc ticker_pointer
mov temp, ticker_pointer
cpi temp, ticker_string_lenght
brcs I_tick_b
clr ticker_pointer
 I_tick_b:
reti */

TICKER_HANDLER:
cli
lda YY, digit1+number_of_digits
lda ZZ, ticker_string
add ZL, ticker_pointer

 I_tick:
.if ((digit1)/256==(digit1+number_of_digits)/256)	; два варианта - для случая, когда 
	subi YL, 2						; YH задействован и только для YL
	ld temp, Y+
	st Y, temp
	cpi YL, digit2
.else 
	sbiw Y, 2
	ld Y+, temp
	st Y, temp
	cpi YL, low(digit2)
	cpc YH, high(digit2)
.endif
brne I_tick 
ld temp, Z
st -Y, temp
inc ticker_pointer
mov temp, ticker_pointer
cpi temp, ticker_string_lenght
brne I_tick_a
clr ticker_pointer
 I_tick_a:
reti