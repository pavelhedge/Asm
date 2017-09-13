;######				TICKER STRING HANDLER				#####
.dseg 
ticker_string: .byte ticker_string_lenght

.def ticker_pointer = r8
.cseg

TICKER_HANDLER:
cli
lda YY, digit1+number_of_digits
lda ZZ, ticker_string
add ZL, ticker_pointer

 I_tick:
.if ((digit1)/256==(digit1+number_of_digits)/256)	; два варианта - для случая, когда 
	subi Y, 2						; YH задействован и только для YL
	ld Y+, temp
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
cpi temp, ticker_string_length
brne I_tick_a
clr ticker_pointer
 I_tick_a:
reti