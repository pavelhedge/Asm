.nolist
.IFNDEF _GENPROCLIB__INCLUDED_
	.EQU _GENPROCLIB__INCLUDED_ = 1
	.message "NOTE: <genproclib.inc> (ver.1.0 beta) have included, only once!"
.else
	.warning "NOTE: <genproclib.inc> has been included yet!"
	.exit
.endif

.ifndef _MACROBASELIB__INCLUDED_
	.include "macrobaselib.inc" ; ���������� ������� ���������������� (���������)
.endif
;=== BEGIN "genproclib.inc" ================================================
; ���������� ����������� ������ ����������
;---------------------------------------------------------------------------
; ��������! � ������� �� ���� ��������, ��� ����������� �� ������ ���������� -
; ������ � ���������, ���������� � ������� ���� ��������� - �.�. �������� �����!
; �������, � ������ ����� ������ ���� �������� ������ �� ���������, ������� ������� ������������!
; (�������������� ��� ������� /*...����������������...*/, ��� ��������� ����������� �������� ����������.)
; �������, ����, �������� ����������� ������ ��� ������ ��� ������ ����:
;##	.EQU _GPL_EE_ = 1		; ��������� ������/������ ������ EEPROM
;##	.equ _GPL_ESQ_=1		; ��������� ������/������ �������� EEPROM
;##	.EQU _GPL_DEL_ = 1	; ��������� ��������� ��������
;##	.EQU _GPL_RAND_ = 1	; ��������� ��������������� ����� (����)
;##	.EQU _GPL_TIM0_ = 1 	; ��������� ��������� ��� Timer/Counter0
;---------------------------------------------------------------------------
; ������������ �� ������������� "��������� ���������" � ����:
; * ��� �� ��������� R26..R31 ����� �� ������������ ��� ���� ����, ��� ��� "��������� ��������" (�.�. �� ������������� ������������ �� � �������� "��������� ����������").
; ��� ���������� ��������� �������, � ����, ����� ������ ������������ ���������� "�������� ��������� ������": LD/ST, LDD/STD.
; ��������� ������ ������: ����� ��� ���� ����� ������������ "��������� ��������": X, Y, ��� Z ?
; * ������� Z ����� �� ������������ ��� �������������� ��������������, �������� ��� "���������� �������" - ������ ��� �� ��������� ��� ���������� "��������� ��������" ICALL/IJMP (��������������� �� 64K ����), �.�. Z ��������� ��� ������ ����� �������. (�������, ��� � ��������� �� "ATTiny*" ��� ���������� "�������� ��������" CALL/JMP - �������, � ���, ���������� ICALL/IJMP ���������� ������������ ������������!)
; * � ������� ����� X � Y - � ������ �������, ����� ������������ Y, �.�. �� ����� ������������: ������������ ����� ���������� LDD/STD. (����� ����, Y - ���� ����� � ����� ����� ���, ��� "��������������": ������ ����������� �������������� ���, � �������� "���������� ��������".)
;---------------------------------------------------------------------------
; �������� ��������� � "��������� ����������" (���������� ������ ����������):
; � ���� ������ ����������, � ��� ������ � ���, �������� R16,R17,R18,R19
; ������������� ������������ ��� "��������� ����������" - �������,
; � ����� ���������� ����, �� ����������� �� ��� �������� ���������� ������!
; ��� ������ DI HALT:
; ��� �����������, �������� ����� �������������� ����������� � ����...
; �� � ��� ���� ����� ������ �����:
; ����� ������ ���������, ���������� �������� ���, ����� ������������ ��������
; ��� �������� TEMP, ������ �������� ��������� ������ ����� � ������.
; � ��� � ���� ����� � ��������� ��������� - ��� �� �����.
; � ��� ������������ ������ - ������� ��������� � ���������� (SRAM).
; �����: �� ����� ������ ������������ ��� ���������� ��������� � ����� ���������:
;.def temp = R16 ; (���������� � macrobaselib.inc)
;.def temp1 = R16 ; (���������� � macrobaselib.inc)
;.def temp2 = R17 ; (���������� � macrobaselib.inc)
;.def temp3 = R18 ; (���������� � macrobaselib.inc)
;.def temp4 = R19 ; ���� �� ������������ ������ �����������
;---------------------------------------------------------------------------

;##******************************************************************************************
;##*														
;##*				 ������ / ������ ������ EEPROM					
;##*														
;##******************************************************************************************

.IFDEF _GPL_EE_ ; ����� ��� ���? ������� ��������� ���������

; ���� � �� �� ����, ��� ������� �������, � ������ �����������������:
.ifdef EEPE
	.equ EepromWriteEnableBit = EEPE;
.else
	.ifdef EEWE
		.equ EepromWriteEnableBit = EEWE;
	.endif
.endif

.ifdef EEMPE
	.equ EepromMasterWriteEnableBit = EEMPE;
.else
	.ifdef EEMWE
		.equ EepromMasterWriteEnableBit = EEMWE;
	.endif
.endif

.ifndef EEARL
	.ifdef EEAR
		.equ EEARL = EEAR ; ��� ����� ������� ��
	.endif
.endif
;---------------------------------------------------------------------------
;
;##	EEPROM_WRITE		 �������� ���� ������ � ������ EEPROM			
; (Tested on: ATMega16, ATTiny25/45/85)
;
; ��������: ��. http://easyelectronics.ru/avr-uchebnyj-kurs-ispolzovanie-eeprom.html
; ������ ������:
; LDI EepromAddressLow, 0 ; ��������� ����� ������� ������ EEPROM
; LDI EepromAddressHigh, 0 ;
; LDI EepromDataByte, 45 ; � ����� �������� � ��� ����� 45
; RCALL EEPROM_WRITE ; �������� ��������� ������.

;----- Subroutine Register Variables
.def EepromDataByte = R22 ; (�������, �� ��������)
.def EepromAddressLow = R23 ; (�������, �� ��������)
.def EepromAddressHigh = R24 ; (�������, �� ��������)
; �������: ����� ����������/������ ���������� �������� TEMP.
;----- Code
EEPROM_WRITE:
	SBIC EECR, EepromWriteEnableBit ; ���� ���������� ������ � ������:
	RJMP EEPROM_WRITE ; �������� � ����� �� ��� ���, ���� �� ��������� ����...
;=== ������ ����������� ������
cli
.ifdef EEPM0
.ifdef EEPM1
; �� ������ ������� ��������� ��� ���������������� ����� ���������������� EEPROM:
	CBI EECR, EEPM0 ; Set Programming mode = "Atomic Byte Programming" (erase + write)
	CBI EECR, EEPM1 ; (Note: If the EEPMn bits are zero, writing EEPE (within four cycles after EEMPE is written) will trigger the erase/write operation. Both the erase and write cycle are done...)
.endif
.endif

OUT EEARL, EepromAddressLow ; ��������� ����� (������� ����)
.ifdef EEARH
	OUT EEARH, EepromAddressHigh ; ��������� ����� (������� ����)
.endif
OUT EEDR, EepromDataByte ; � ���� ������, ������� ��� ����� ��������
SBI EECR, EepromMasterWriteEnableBit ; ������� ��������������
SBI EECR, EepromWriteEnableBit ; �������� ������ ����� (Note: bit remains set until the erase and write opera-tions are completed)
OUTR SREG, temp ; Restore global interrupt flag
;=== ����� ����������� ������
ret ; ������� �� ���������
;---------------------------------------------------------------------------
;
;##	EEPROM_READ		 ��������� ���� ������ �� ������ EEPROM			
; (Tested on: ATMega16, ATTiny25/45/85)
;
; ��������: ��. http://easyelectronics.ru/avr-uchebnyj-kurs-ispolzovanie-eeprom.html
; ������ ������:
; LDI EepromAddressLow,0 ; ��������� ����� ������� ������
; LDI EepromAddressHigh,0 ; EEPROM �� ������� ����� ��������� ����
; RCALL EEPROM_READ ; �������� ��������� ������. ����� �������
; ; � EepromDataByte ����� ��������� ����.
;
;---------------------------------------------------------------------------
;----- Subroutine Register Variables
;.def EepromDataByte = ��.���� ; (��������)
;.def EepromAddressLow = ��.���� ; (�������, �� ��������)
;.def EepromAddressHigh = ��.���� ; (�������, �� ��������)
;----- Code
EEPROM_READ:
	SBIC EECR, EepromWriteEnableBit ; ���� ���� ����� ��������� ������� ������:
	RJMP EEPROM_READ ; �������� � ����� �� ��� ���, ���� �� ��������� ����...
	OUT EEARL, EepromAddressLow ; ��������� ����� ������ ������ (������� ����)
.ifdef EEARH
	OUT EEARH, EepromAddressHigh ; ��������� ����� ������ ������ (������� ����)
.endif
	SBI EECR, EERE ; �������� ������ �����
	IN EepromDataByte, EEDR ; �������� �� �������� ������ ���������
	RET
.endif


;##----------------------------------------------------------------------------------------------------------------------------------------
;## ���������� ���������, ������� ��������� ���������� ����� ������ ������:	
;##		EEPROM_WRITE_SEQUENCE			EEPROM_READ_SEQUENCE	
;##----------------------------------------------------------------------------------------------------------------------------------------

.IFDEF _GPL_EEPROM_SEQ_		;������� ���������� ���������

; EEPROM_WRITE_SEQUENCE (from SRAM to EEPROM) - �������� ������ ���� �� ��� � ����������������� ������ EEPROM.
; EEPROM_READ_SEQUENCE (from EEPROM to SRAM) - ��������� ������ ���� �� ����������������� ������ EEPROM � ���.

;----- Subroutine Register Variables
;.def EepromAddressLow = ��.���� ; ������ ������� � EEPROM-������
;.def EepromAddressHigh = ��.���� ;
.def SramAddressLow = R28 ; YL ; ������ ������� � SRAM-������
.def SramAddressHigh = R29 ; YH ;
.def PumpBytesCount = R25 ; ���������� ����, ������� ����������� (������ �������)
; �������: ����� ����������/������ ���������� ��������� TEMP � EepromDataByte (�������������).
;----- Code
EEPROM_WRITE_SEQUENCE:
TST PumpBytesCount ; �������� �� ������: ���� ������� ��� �������?
BREQ EXIT__EEPROM_WRITE_SEQUENCE
LOOP__EEPROM_WRITE_SEQUENCE:
LD EepromDataByte, Y+ ; ������ ���� ���� �� SRAM � �������������� ����� SramAddress*
RCALL EEPROM_WRITE ; ��������� ��� � EEPROM, �� ������ EepromAddress*
SUBI EepromAddressLow, (-1) ; �������������� ����� ����� EepromAddress*
SBCI EepromAddressHigh,(-1)
DEC PumpBytesCount ; �������������� ������� "���������� ����, ������� �����������"
BRNE LOOP__EEPROM_WRITE_SEQUENCE ; ����������, ���� �� ������ ���� � ��������
EXIT__EEPROM_WRITE_SEQUENCE:
RET
;----- Code
EEPROM_READ_SEQUENCE:
TST PumpBytesCount ; �������� �� ������: ���� ������� ��� �������?
BREQ EXIT__EEPROM_READ_SEQUENCE
LOOP__EEPROM_READ_SEQUENCE:
RCALL EEPROM_READ ; ������ ���� ���� �� EEPROM, �� ������ EepromAddress*
ST Y+, EepromDataByte ; ��������� ��� � SRAM � �������������� ����� SramAddress*
SUBI EepromAddressLow, (-1) ; �������������� ����� ����� EepromAddress*
SBCI EepromAddressHigh,(-1)
DEC PumpBytesCount ; �������������� ������� "���������� ����, ������� �����������"
BRNE LOOP__EEPROM_READ_SEQUENCE ; ����������, ���� �� ������ ���� � ��������
EXIT__EEPROM_READ_SEQUENCE:
RET
.ENDIF


;##******************************************************************************************
;##														
;##*						 ��������� ��������					
;##*														
;##******************************************************************************************

.IFDEF _GPL_DELAY_
;---------------------------------------------------------------------------
;
; ��������� "����� ��������" (������ ���� � CPU)
;
; �������� �������� ������� 3� �������� ������:
; ����� ����������� ���������: TEMP1, TEMP2, TEMP3.
; ���, ��� �������, ����������� ����������, ����� ����������������.
;
; �������� ��������:
; ���������� ������ CPU, ������� ������ = (�����+1) * 5
;
.def low_byte=r16
.def med_byte=r17
.def high_byte=r18
;---------------------------------------------------------------------------
;----- Subroutine Register Variables
; �������� �������� ������� ����� ����������� ���������:
DUMB_DELAY:
SUBI r16, 1 ; �������� 1 (1 ���� CPU)
SBCI r17, 0 ; �������� ������ � (1 ���� CPU)
SBCI r18, 0 ; �������� ������ � (1 ���� CPU)
BRCC DUMB_DELAY ; ���� ��� �������� - ������� (2 ����� CPU)
RET

;##����������� ������, �������������� � ������������������� �������� � 
;##		 ������������� ��� ������������� ��� CPU_DELAY

;��������: ��� ������������� ����� ������� ����� ���������� ������� 
; ������������ ���������� � ��������� ##	.equ clk_freq=8000
; ������ �������������:
;##	set delay_ms=30
;##	delay

;##	set delay_us=100
;##	delay

.set delay_ms=0
.set delay_us=0

.macro DELAY		; ������ ������������ � ����������������� �������� 
				; � �����- ��� �������������
	.ifndef clk_freq	; ����� ������� ������� ������ ��� �� ��� ���
	.error "Clk_freq is not defined, delay can't be set"
	.endif

.if delay_ms!=0
	.if delay_us!=0
		.error "Both us and ms delays are set - choose single one"
	.else
		.set Ntakt=(delay_ms*clk_freq)/5
	.endif
.elif delay_us!=0
	.set Ntakt=(delay_ms*clk_freq)/5000
.else
	.error  "Delay time isn't set"
.endif

.set delay_ms=0				; ����� ������� ������ ���� �� ���� 
.set delay_us=0				; ������ � ��������� ���
	
.set hi_byte=(ntakt/65536)		; ������ ��������, ��������� � ��������
.set ntakt=(ntakt-hi_byte*65536)	; ��� ��������� �������� ��������
.set me_byte=(ntakt/256)			; ����� �� ��������, �������� ����,
.set ntakt=(ntakt-me_byte*256)		; ������� ����� ����� �� �������� � �.�.
.set lo_byte=ntakt 				; � �����, ����� ����� - �����������

ldi r16, lo_byte				; ������� ���������� ��������� � ��������
ldi r17, me_byte
ldi r18, hi_byte

rcall DUMB_DELAY				; ��������� �������
.endm

.ENDIF
;##******************************************************************************************
;##*														
;##*				 ��������� ��������������� ����� (����)			
;##*														
;##******************************************************************************************
;---------------------------------------------------------------------------
.IFDEF _GPL_RAND_
;
; ���������� ��������� ��������������� ����� (�������� �������������������)
; ���������� ��������: RNDii = (RNDi * 5 + 3) {MOD 256}
;
;
; ������� �������������:
; 1) ��������� "��������" �������� RandomNumber.
; 2) CALL RANDOM
; 3) ��������� ��������� ��������������� ����� �� �������� RandomNumber.
; 4) CALL RANDOM
; 5) ��������� ��������� ��������������� ����� �� �������� RandomNumber.
; 6) ...
;
;---------------------------------------------------------------------------
;----- Subroutine Register Variables
.def RandomNumber = R15 ; ����� ������������ �������� �������� �����
; �������: ����� ����������/������ ���������� �������� TEMP.
;----- Code
RANDOM:
; RandomNumber *= 17 (����������� ���������� ���������)
MOV temp, RandomNumber ; x1
LSL temp ; x2
LSL temp ; x4
ADD RandomNumber, temp ; x(16+1) === 0b00010001
; RandomNumber += 53
inc RandomNumber, (-53) ; ����: -(-53) = +53
; � �����: RandomNumber = (RandomNumber * 17 + 53) % 256
RET
.ENDIF


;***************************************************************************
;*
;* ��������� ��������� ��� Timer/Counter0
;*
;***************************************************************************
.IFDEF _GPL_TIM0_
; ���� � �� �� ����, ��� ������� �������, � ������ �����������������:
.ifndef PSRSYNC
.ifdef PSR10
.equ PSRSYNC = PSR10
.else
.ifdef PSR0
.equ PSRSYNC = PSR0
.endif
.endif
.endif
;---------------------------------------------------------------------------
;
; ���������: "�������� Timer/Counter0 (������� � ������������)"
; (Tested on: ATTiny25/45/85)
;
;---------------------------------------------------------------------------
;----- Subroutine Register Variables
; ��� ����������.
; �������: ����� ����������/������ ���������� �������� TEMP.
;----- Code
TIMER0_RESET:
;=== �������� ������� �������:
.ifndef TCNT0L
; � ������ 8-���������� Timer/Counter0
OUTI TCNT0, 0 ; ��������� �������� ��������
.else
; � ������ 16-���������� Timer/Counter0
; Note: To do a 16-bit write, the high byte must be written before the low byte. For a 16-bit read, the low byte must be read before the high byte.
; It is important to notice that accessing 16-bit registers are atomic operations. Aware interrupts, use cli/sei!
OUTI TCNT0H, High(0)
OUTI TCNT0L, Low (0) ; ��������� �������� ��������
.endif
;=== �������� ������������:
.ifdef TSM
SETB GTCCR, TSM ; Synchronization Mode ON
.endif
SETB GTCCR, PSRSYNC ; Prescaler Reset Request
.ifdef TSM
CLRB GTCCR, TSM ; Synchronization Mode OFF and GO reset! (Note: When the TSM bit is written to zero, the PSR0 bit is cleared by hardware, and the timer/counter start counting.)
.endif
RET
.ENDIF
;=== END "genproclib.inc" ==================================================
; coded by (c) Celeron, 2014 @ http://we.easyelectronics.ru/my/Celeron/
.list