;###### 												#####
/* ���� ������ ����������� AtTiny45
*/
.include "D:\!lab\asm\inc\tn13def.inc"


;.equ ref_pin	; ��� �������� ����������
;.equ adc_pin	; ��� ������ ���������
.equ btn_pin=2	; ��� ������
.equ out_pin=3	; ��� ������
.equ led_pin=4	; ��� ����������



;######				 INTERRUPTS TABLE 					#####
rjmp	RESET			; Reset Handler
reti;	rjmp EXT_INT0		; IRQ0 Handler
reti;	rjmp PCINT0		; PCINT0 Handler
reti;	rjmp TIM0_OVF		; Timer0 Overflow Handler
reti;	rjmp EE_RDY		; EEPROM Ready Handler
	rjmp ANA_COMP		; Analog Comparator Handler
reti;	rjmp TIM0_COMP		; Timer0 CompareA Handler
reti; 	rjmp TIM0_COMPB	; Timer0 CompareB Handler
reti;	rjmp WATCHDOG		; Watchdog Interrupt Handler
reti;	rjmp ADC_RDY		; ADC Conversion Handler
;######				INCLUDED MODULES					#####

;######				INTERRUPTS HANDLERS				#####


ANA_COMP:
sbi portB, out_pin
sbi portB, led_pin
;cbi ADCSRA, ADEN
;OUTI TCCR0B, 0
reti

;######				SUBROUTINES & FUNCTIONS				#####


;######					MAIN PROGRAM					#####
RESET: 
INITIALIZATION

OUTI DDRB, (1<<out_pin)|(1<<led_pin)	; ���� � ��� ���������� - �� �����
OUTI PORTB, 1<<led_pin|1<<out_pin|1<<btn_pin

; ������������� �����������
OUTI ACSR, 1<<ACIE|2<<ACIS0
 
sei

cycle:
rjmp cycle







	
