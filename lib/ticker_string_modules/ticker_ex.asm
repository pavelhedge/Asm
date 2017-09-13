;###### 												#####
.include "def\m8def.inc"
.include "macrobaselib.inc"

.equ number_of_digits=6
.equ anode_port=portD
.equ cathode_port=portC
.equ point = 0

.def flag = r20
.equ leap_year = 7
.equ ticker_string_lenght=11


;######				 INTERRUPTS TABLE 					#####
.cseg 
.org 0x00
	rjmp RESET ;External Pin, Power-on Reset, Brown-out Reset, and WDT Reset
reti;	rjmp EXT_INT0 		; External Interrupt Request 0
reti; 	rjmp EXT_INT1		; External Interrupt Request 1
 	rjmp TIM2_COMP 		; Timer/Counter2 Compare Match
	rjmp TIM2_OVF 		; Timer/Counter2 Overflow
reti; 	rjmp TIM1_CAPT 		; Timer/Counter1 Capture Event
reti; 	rjmp TIM1_COMPA 	; Timer/Counter1 Compare Match A
reti;	rjmp TIM1_COMPB 	; Timer/Counter1 Compare Match B
reti;	rjmp TIM1_OVF 		; Timer/Counter1 Overflow
	rjmp TIM0_OVF 		; Timer/Counter0 Overflow
reti; 	rjmp SPI_STC 		; Serial Transfer Complete
reti; 	rjmp USART_RXC 		; USART, Rx Complete
reti;	rjmp USART_DRE	 	; USART Data Register Empty
reti;	rjmp USART_TXC 		; USART, Tx Complete
reti;	rjmp ADC_RDY		; ADC Conversion Complete
reti;	rjmp EE_RDY 		; EEPROM Ready
reti;	rjmp ANA_COMP 		; Analog Comparator
reti;	rjmp TWI 			; Two-wire Serial Interface
reti;	rjmp SPM_RDY 		; Store Program Memory Ready

;######				SUBROUTINES & FUNCTIONS				#####

;.include "2_key.asm"
;.include "second_handler.asm"
;.include "bin2bcd.asm"
.include "7seg_CC_display.asm"
.include "D:\!lab\projects\nixie\asm_clock\ticker_handler.asm"


;######				INTERRUPTS HANDLERS				#####
TIM0_OVF:
rcall DISPLAY_HANDLER
reti

TIM2_OVF:
sbi portB, point
rcall TICKER_HANDLER
reti

TIM2_comp:
cbi portB, point
rcall TICKER_HANDLER
reti



;######					MAIN PROGRAM					#####
RESET: 
STACKINIT

outi DDRD, 0xFF
outi DDRC, 0xFF
outi DDRB, 0x01
outi portB, 0x02
	
outi ASSR, 1<<AS2
outi TCCR2, 4<<CS20
outi OCR2, 127
outi TIMSK, (1<<OCIE2)|(1<<TOIE2)|(1<<TOIE0)
outi TCCR0, (2<<CS00)

/* clr temp				; Вывести все символы
lda YY, ticker_string
 I_lalala:
st Y+, temp
inc temp
cpi temp, ticker_string_lenght
brne I_lalala */ 

lda YY, ticker_string
ldi temp, symbol_blank
st Y+, temp
ldi temp, symbol_happy
st Y+, temp
inc temp
st Y+, temp
inc temp
st Y+, temp
inc temp
st Y+, temp
inc temp
st Y+, temp
ldi temp, symbol_blank
st Y+, temp
ldi temp, 2
st Y+, temp
ldi temp, 0
st Y+, temp
ldi temp, 1
st Y+, temp
ldi temp, 5
st Y+, temp






loop:
sei
nop
rjmp loop
