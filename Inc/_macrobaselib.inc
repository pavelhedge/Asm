.nolist
.IFNDEF _MACROBASELIB__INCLUDED_
	.EQU _MACROBASELIB__INCLUDED_ = 1
.else 
	.warning "NOTE: <macrobaselib.inc has been included yet"
	.exit
.endif

;=== BEGIN "macrobaselib.inc" ============================================

; ���������� ������� ����������������,
; ����������� ����������� ����� ������������ ���������� ����������������� 
; Atmel AVR (8-bit AVR Instruction Set), � ������������� ��������� 
; ����������������: � ��������� "������ ���������� ������" � ��� (SRAM) � 
; �������������� ���������� ��������� (���) ��� "��������� ����������"...
;---------------------------------------------------------------------------
; ������������ �� ������������� "��������� ���������" � ����:
; * ��� �� ��������� R26..R31 ����� �� ������������ ��� ���� ����, ��� ��� 
; "��������� ��������" (�.�. �� ������������� ������������ �� � �������� 
; "��������� ����������").
; ��� ���������� ��������� �������, � ����, ����� ������ ������������ 
; ���������� "�������� ��������� ������": LD/ST, LDD/STD.
; ��������� ������ ������: ����� ��� ���� ����� ������������ 
; "��������� ��������": X, Y, ��� Z ?
; * ������� Z ����� �� ������������ ��� �������������� ��������������, 
; �������� ��� "���������� �������" - ������ ��� �� ��������� ��� ����������
; "��������� ��������" ICALL/IJMP (��������������� �� 64K ����), �.�. 
; Z ��������� ��� ������ ����� �������. (�������, ��� � ��������� �� "ATTiny*" 
; ��� ���������� "�������� ��������" CALL/JMP - �������, � ���, ���������� 
; ICALL/IJMP ���������� ������������ ������������!)
; * � ������� ����� X � Y - � ������ �������, ����� ������������ Y, �.�. �� 
; ����� ������������: ������������ ����� ���������� LDD/STD. (����� ����,
; Y - ���� ����� � ����� ����� ���, ��� "��������������": ������ ����������� 
; �������������� ���, � �������� "���������� ��������".)
;---------------------------------------------------------------------------
; �������� ��������� � "��������� ����������" (���������� ������
; ����������):
; � ���� ������ ����������, � ��� ������ � ���, �������� R16,R17,R18,R19
; ������������� ������������ ��� "��������� ����������" - �������,
; � ����� ���������� ����, �� ����������� �� ��� �������� ���������� ������!
; ��� ������ DI HALT:
; ��� �����������, �������� ����� �������������� ����������� � ����...
; �� � ��� ���� ����� ������ �����:
; ����� ������ ���������, ���������� �������� ���, ����� ������������ 
; �������� ��� �������� TEMP, ������ �������� ��������� ������ ����� � ������.
; � ��� � ���� ����� � ��������� ��������� - ��� �� �����.
; � ��� ������������ ������ - ������� ��������� � ���������� (SRAM).
; �����: �� ����� ������ ������������ ��� ���������� ��������� � ���������:
.def temp = R16
.def temp1 = R16
.def temp2 = R17
.def temp3 = R18 ; ���� �� ������������ ������ �����������
.def temp4 = R19 ; ���� �� ������������ ������ �����������
.def flag = r19
.def data1 = r24 	; ��� �������� ������ ����� ������������, �������������� 
.def data2 = r25	; � ���������
;##******************************************************************************************
;##;*														
;##;*				 ��������� ������������� ��					
;##;*														
;##******************************************************************************************

.MACRO INITIALIZATION 	; ��������� ������������� �����, ��� ������
	RAMFLUSH
	GPRFLUSH
.ifdef RAMEND
	STACKINIT
.endif

/* ������� ������������� ��������� ��������� � ���� ������������ ��������� */
.ifdef __display_included__
	DISPLAY_INIT
.endif

.ifdef __key_included__
	KEY_INIT
.endif

.ENDMACRO

;##					; ������������� �����						
.MACRO STACKINIT

.if RAMEND>0x0000 ; ������ ��� �� ������� SRAM...
	LDI temp, Low(RAMEND) ; ����� ������� ����� = ����� ������ (��.����)
	.ifdef SPL
		OUT SPL, temp
	.else
		OUT SP, temp
	.endif

	.ifdef SPHHf
		LDI temp, High(RAMEND) ; ����� ������� ����� = ����� ������ (��.����)
		OUT SPH, temp
	.endif
.else
	.WARNING "This device have not SRAM. Can not initialize Stack!"
.endif //RAMEND
.ENDM

;##						 ������� ������						
.MACRO RAMFLUSH
	LDI ZL, Low (SRAM_START) ; ����� ������ ��� � ������
	LDI ZH, High(SRAM_START)
	CLR temp ; ������� R16
LOOP__RAMFLUSH:
	ST Z+, temp ; ��������� 0 � ������ ������
	CPI ZL, Low (RAMEND+1) ; �������� ����� ����������?
	BRNE LOOP__RAMFLUSH ; ���? �������� ������!
	CPI ZH, High(RAMEND+1) ; � ������� ���� ������ �����?
	BRNE LOOP__RAMFLUSH
.ENDM

;##			 ������� ��� (��������� ������ ����������)				
.MACRO GPRFLUSH
	LDI ZL, 30 ; +-----------------------+
	CLR ZH ; | ������� ��� (R00-R31) |
	DEC ZL ; | |
	ST Z, ZH ; | [����� 10 ���� ����!] |
	BRNE PC-2 ; +-----------------------+
.ENDM

;##						���������� ������					
; Disable Watchdog timer permanently (ensure)
; (Supported: ATTiny25/45/85)
; Note: If the watchdog timer is not going to be used in the application (fuse must be: 
; "WDTON"=Unprogrammed, "Safety Level 1"), it is important to go through a watchdog 
; disable procedure in the initialization of the device.
; If the Watchdog is accidentally enabled, for example by a runaway pointer or 
; brown-out condition, the device will be reset, which in turn will lead to a new watchdog 
; reset. To avoid this situation, the application software should always clear the WDRF
; flag and the WDE control bit in the initialization routine. (c) Atmel datasheet
.MACRO WDTOFF
	wdr					; Clear WDRF in MCUSR
	ldi temp, (0<<WDRF)		; Write logical one to WDCE and WDE
	out MCUSR, temp			
	in temp, WDTCR
	ori temp, (1<<WDCE)|(1<<WDE); Turn off WDT
	out WDTCR, temp
	ldi temp, (0<<WDE)
	out WDTCR, temp
.ENDM
;##******************************************************************************************
;##*														
;##* 	�������������� 8/16-������ �������� � ��������� ������ X,Y,Z  		
;##*														
;##******************************************************************************************
.ifndef XX
.equ XX=1
.equ YY=2
.equ ZZ=3
.endif
;@@@@	������������� �������� ������ � ��������� �������� X, Y, Z	@@@	
/* ��������� 16-������ ����� � ��������� ����������� ����.
�.�. � X, Y, Z ���������� ��������� ����� ���������, �� �������� ���������� ��� 
������, �������� �������� �� �������� ������� XX, YY, ZZ
������ ������:
LDA XX, adress ; ��������� 16-������ ����� � ����������� ���� X */ 
.MACRO LDA
.if (@0)==1
ldi XL, low (@1)
;.if @1 > 255		; ����� ������ ���, ����� ������� �����, ����� ��� ��������� 
ldi XH, high (@1)		; high � �� ������������
;.endif
.elif (@0)==2
ldi YL, low (@1)
;.if (@1) > 255
ldi YH, high (@1)
;.endif
.elif (@0)==3
ldi ZL, low (@1)
;.if (@1) > 255
ldi ZH, high (@1)
;.endif
.else 
.error "Wrong index register name"
.endif
.endmacro

;######			��������� ���� X, Y, Z � ����������		#####
;			���������� 16-������ ����� � ����������� ����� rN, rN+1
; CPU r16, 13056
.MACRO CPA

.if (@0)==1
cp XL, low(@1)
.if @1>255
ldi temp, high(@1) 
cpc XH, temp
.endif
.elif (@0)==2
cp YL, low(@1)
.if @1>255
ldi temp, high(@1) 
cpc YH, temp
.endif
.elif (@0)==3
cp ZL, low(@1)
.if @1>255
ldi temp, high(@1) 
cpc ZH, temp
.endif
.else
.error "Wrong index register name"
.endif
.endmacro

;##			�������� ����������� ���� � 8/16-������ ����������		
.MACRO ADDA

.if (@0)==1
cp XL, low(@1)
.if @1>255
ldi temp, high(@1) 
cpc XH, temp
.endif
.elif (@0)==2
cp YL, low(@1)
.if @1>255
ldi temp, high(@1) 
cpc YH, temp
.endif
.elif (@0)==3
cp ZL, low(@1)
.if @1>255
ldi temp, high(@1) 
cpc ZH, temp
.endif
.else
.error "Wrong index register name"
.endif
.endmacro


;##******************************************************************************************
;##					���������� �� ROM � RAM				#####
;##******************************************************************************************

.MACRO ROM2RAMLOAD
ldi ZL, low (@1*2)
ldi ZH, high (@1*2)
ldi YL, low (@1)
ldi YH, high (@1)
ldi temp2, @0
load:
lpm temp, Z+
st Y+, temp 
dec temp2
breq load
.endmacro



;##******************************************************************************************
;##*														
;##* 					��������� ����� / ������				
;##*														
;##******************************************************************************************
; ���: ��� - �������� ����� ������ (I/O registers).
; ������������� ����� � ��� (�����): ������������ ��������� ��������� (0x00-
; 0x3F), � ����� ��������� ("MEMORY MAPPED": >= 0x60),
; � �.�. � ����� ������ ����������� ������ (Location < 64K bytes).
;##			 �������� ����� @1 � ���� @0 (OUTput "Immediate")			
; ������ ������: OUTI port,byte
; �������: ������ ���������� �������� TEMP.
.MACRO OUTI
	LDI temp, @1
.if @0 < 0x40
	OUT @0, temp
.else
	STS @0, temp
.endif
.ENDMACRO

;##	 �������� [�����������] �������� @1 � ���� @0 (OUTput from "Register")	
; ������ ������: OUTR port,register
.MACRO OUTR
.if @0 < 0x40
	OUT @0, @1
.else
	STS @0, @1
.endif
.ENDMACRO

;##	 �������� [�����������] ����� @1 � ������� @0 (INput to "Register")		
; ������ ������: INR register,port
.MACRO INR
.if @1 < 0x40 ; IO
	IN @0, @1
.else ; Memory
	LDS @0, @1
.endif
.ENDM



;##		 ����������/�������������� ��������� SREG � TEMP � �����.		
; (������ ������� ������������ �����, ������, � ������������ ����������)
.MACRO PUSHF
	PUSH temp
	IN temp, SREG
	PUSH temp
.ENDM
; ����������: ������ ���������� �������� TEMP �� ������ ��������� ����������
; (����� PUSHF..POPF)! ������ ��, ����� � ��������������� ����� (����� POPF)
;  - ��� ������ ������� TEMP: "����������" ��������� "��������� ����������", 
; ������ ����������� ����������.
.MACRO POPF
	POP temp
	OUT SREG, temp
	POP temp
.ENDM
;##---------------------------------------------------------------------------------------------------------------------------------------
; ##			������������� ����������� ������ � ��� (������):			
;##---------------------------------------------------------------------------------------------------------------------------------------
; � �������� (0x00-0x1F), �������� (0x20-0x3F) ��������,
; � ����� ��������� ("MEMORY MAPPED": >= 0x60)
; ##						SET BIT via REG						
; ������ ������: SETB byte,bit
; �������: ������ ���������� �������� TEMP... �� ��� ������ � ������ �������
; ��� (0x00-0x1F) - ��������������� ������� TEMP �� ������������ (�����������).
.MACRO SETB 		;Arguments: Address, Bit, register
	.if @1>7
		.error "Only values 0-7 allowed for Bit parameter"
	.endif
.if @2=0
	
	.if @0>0x3F
		lds  temp, @0
		sbr  temp, (1<<@1)
		sts  @0, temp
	.elif @0>0x1F
		in   temp, @0
		sbr  temp, (1<<@1)
		out  @0, temp
	.else
		sbi  @0, @1
	.endif
.else
	.if @0>0x3F
		lds  @2, @0
		sbr  @2, (1<<@1)
		sts  @0, @2
	.elif @0>0x1F
		in   @2, @0
		sbr  @2, (1<<@1)
		out  @0, @2
	.else
		sbi  @0, @1
	.endif
.endif
.ENDMACRO

;## 						CLEAR BIT via REG					
; ������ ������: CLRB byte,bit
; �������: ������ ���������� �������� TEMP... �� ��� ������ � ������ ������� 
; ��� (0x00-0x1F) - ��������������� ������� TEMP �� ������������ (�����������).
.MACRO CLRB 		;Arguments: Address, Bit,
	.if @1>7
		.error "Only values 0-7 allowed for Bit parameter"
.if @2=0
	.endif
	.if @0>0x3F
		lds  temp, @0
		cbr  temp, (1<<@1)
		sts  @0, temp
	.elif @0>0x1F
		in   temp, @0
		cbr  temp, (1<<@1)
		out  @0, temp
	.else
		cbi  @0, @1
	.endif
.else
	.if @0>0x3F
		lds  @2, @0
		sbr  @2, (1<<@1)
		sts  @0, @2
	.elif @0>0x1F
		in   @2, @0
		sbr  @2, (1<<@1)
		out  @0, @2
	.else
		sbi  @0, @1
	.endif
.endif
.ENDMACRO

;## 						INVERT BIT via REG					
; ������ ������: INVB byte,bit
; �������: ������ ���������� ��������� TEMP1,TEMP2.
.MACRO INVB
.if @0 < 0x40 ; IO
	IN temp1, @0
	LDI temp2, 1<<@1
	EOR temp1, temp2
	OUT @0, temp1
.else ; Memory
	LDS temp1, @0
	LDI temp2, 1<<@1
	EOR temp1, temp2
	STS @0, temp1
.endif
.ENDM

;## 			STORE BIT to "Transfer bit" [T <- Location(bit)] via REG			
; ����������: "Transfer bit" ��������� ����������� �������� ���� � ������ 
; �������� �������� (BRTS/BRTC).

; ������ ������: STOREB byte,bit
; �������: ������ ���������� �������� TEMP.
.MACRO STOREB
.if @0 < 0x40 ; IO
	IN temp, @0
	BST temp, @1
.else ; Memory
	LDS temp, @0
	BST temp, @1
.endif
.ENDM

;## 			LOAD BIT from "Transfer bit" [Location(bit) <- T] via REG		
; ������ ������: LOADB byte,bit
; �������: ������ ���������� �������� TEMP.
.MACRO LOADB
.if @0 < 0x40 ; IO
	N temp, @0
	BLD temp, @1
	OUT @0, temp
.else ; Memory
	LDS temp, @0
	BLD temp, @1
	STS @0, temp
.endif
.ENDM


;##---------------------------------------------------------------------------------------------------------------------------------------
;##					�������� � ������ ����� ����				
;##---------------------------------------------------------------------------------------------------------------------------------------
; �� ������� "��������������� ���������" TEMPx (����������� �� ��������������)
; �� �������� ������ � ���������� ����������� ������ (����).

;##					 SET BIT via STACK/MEMORY					
; ������ ������: SETBM byte,bit
.MACRO SBM
.if @0 < 0x20 ; Low IO
	SBI @0, @1
.elif @0 < 0x40 ; High IO
	PUSH temp
	IN temp, @0
	ORI temp, 1<<@1
	OUT @0, temp
	POP temp
.else ; Memory
	PUSH temp
	LDS temp, @0
	ORI temp, 1<<@1
	STS @0, temp
	POP temp
.endif
.ENDM

; ##					CLEAR BIT via STACK/MEMORY				
; ������ ������: CLRBM byte,bit
.MACRO CBM
.if @0 < 0x20 ; Low IO
	CBI @0, @1
.elif @0 < 0x40 ; High IO
	PUSH R17
	IN R17, @0
	ANDI R17, ~(1<<@1)
	OUT @0, R17
	POP R17
.else ; Memory
	PUSH R17
	LDS R17, @0
	ANDI R17, ~(1<<@1)
	STS @0, R17
	POP R17
.endif
.ENDM

;##					 INVERT BIT via STACK/MEMORY				
; ������ ������: INVBM byte,bit
.MACRO IBM
.if @0 < 0x40 ; IO
	PUSH R16
	PUSH R17
	IN R16, @0
	LDI R17, 1<<@1
	EOR R17, R16
	OUT @0, R17
	POP R17
	POP R16
.else ; Memory
	PUSH R16
	PUSH R17
	LDS R16, @0
	LDI R17, 1<<@1
	EOR R17, R16
	STS @0, R17
	POP R17
	POP R16
.endif
.ENDM

;##		 STORE BIT to "Transfer bit" [T <- Location(bit)] via STACK/MEMORY		
; ������ ������: STOREBM byte,bit
.MACRO STBM
PUSH R16
.if @0 < 0x40 ; IO
	IN R16, @0
	BST R16, @1
.else ; Memory
	LDS R16, @0
	BST R16, @1
.endif
POP R16
.ENDM

; ##		LOAD BIT from "Transfer bit" [Location(bit) <- T] via STACK/MEMORY	
; ������ ������: LOADBM byte,bit
.MACRO LDBM
PUSH R16
.if @0 < 0x40 ; IO
	IN R16, @0
	BLD R16, @1
	OUT @0, R16
.else ; Memory
	LDS R16, @0
	BLD R16, @1
	STS @0, R16
.endif
POP R16
.ENDM


;##******************************************************************************************
;##*														
;##* 				�������������� ��������: 8-������				
;##*														
;##******************************************************************************************


;##		������������� (+1) ������������ ���������� @0 � ������		
; �������: ������ ���������� �������� TEMP.
.MACRO INC8M
	LDS temp, @0
	inc temp
	STS @0, temp
.ENDM

;##		 ������������� (-1) ������������ ���������� @0 � ������		
; �������: ������ ���������� �������� TEMP.
.MACRO DEC8M
	LDS temp, @0
	dec temp
	STS @0, temp
.ENDM
;##			��������� ����������� ���������� @0 � ������			
; �������: ������ ���������� �������� TEMP.
.MACRO CLR8M
	CLR temp ; ��� ��� ����� ����...
	STS @0, temp ; ���� � ������ ���� �������� � RAM
.ENDM


;##******************************************************************************************
;##*								/|	r----					
;##* �������������� ��������: 16-������	 |	|___					
;##*								 |	|___|					
;##******************************************************************************************

;##			 ������������� (+1) ����������� ���������� @0 � RAM 		
; �������: ������ ���������� �������� TEMP.
.MACRO INC16M
LDS temp, @0
SUBI temp, (-1)
STS @0, temp
LDS temp, @0+1
SBCI temp, (-1)
STS @0+1, temp
.ENDM

;##			������������� (-1) ����������� ���������� @0 � RAM 		
; �������: ������ ���������� �������� TEMP.
.MACRO DEC16M
LDS temp, @0
SUBI temp, (1)
STS @0, temp
LDS temp, @0+1
SBCI temp, (0)
STS @0+1, temp
.ENDM
; ##			��������� ����������� ���������� @0 � ������			
; �������: ������ ���������� �������� TEMP.
.MACRO CLR16M
CLR temp ; ��� ��� ����� ����...
STS @0, temp ; ���� � ������ ���� �������� � RAM
STS @0+1, temp ; ���� � ������ ���� �������� � RAM
.ENDM
;---------------------------------------------------------------------------
; ##			�������������� ��������� 16-������ ��������� @2			
;##					 �� ����������� ���� @0:@1					
; (��� �������� ����������� 16-������ ����������, ������� ���� �� �� ���� ��: 
; SBIW YH:YL,0x1234 )
; ������ ������: SUBI16 YH,YL,0x1234
.MACRO SUBI16 ; Start macro definition
SUBI @1, Low(@2) ; Subtract low byte
SBCI @0, High(@2) ; Subtract high byte
.ENDM ; End macro definition


;##******************************************************************************************
;*##														
;* ##				�������������� ��������: 32-������				
;*##														
;##******************************************************************************************

;## ������������� (+1) �������������� ���������� @0 � ������ (�� ������ @0 - 
;##					��.����, little-endian)
; �������: ������ ���������� �������� TEMP.
.MACRO INC32M
	lds temp, @0
	SUBI temp, (-1)
	STS @0, temp
	LDS temp, @0+1
	SBCI temp, (-1)
	STS @0+1, temp
	LDS temp, @0+2
	SBCI temp, (-1)
	STS @0+2, temp
	LDS temp, @0+3
	SBCI temp, (-1)
	STS @0+3, temp
.ENDM

;## ������������� (-1) �������������� ���������� @0 � ������ (�� ������ @0 - 
;##				��.����, little-endian)
; �������: ������ ���������� �������� TEMP.
.MACRO DEC32M
	LDS temp, @0
	SUBI temp, (1)
	STS @0, temp
	LDS temp, @0+1
	SBCI temp, (0)
	STS @0+1, temp
	LDS temp, @0+2
	SBCI temp, (0)
	STS @0+2, temp
	LDS temp, @0+3
	SBCI temp, (0)
	STS @0+3, temp
.ENDM

;##			 ��������� �������������� ���������� @0 � ������		
; �������: ������ ���������� �������� TEMP.
.MACRO CLR32M
	CLR temp ; ��� ��� ����� ����...
	STS @0, temp ; ���� � ������ ���� �������� � RAM
	STS @0+1, temp ; ���� � ������ ���� �������� � RAM
	STS @0+2, temp ; ���� � ������ ���� �������� � RAM
	STS @0+3, temp ; ���� � �������� ���� �������� � RAM
.ENDM


;####					��������_�����				#####
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
;---------------------------------------------------------------------------
;----- Subroutine Register Variables
.set delay_ms=0
.set delay_us=0

.macro DELAY		; ������ ������������ � ����������������� �������� 
				; � �������������
	.ifndef clk_freq	; ����� ������� ������� ������ ��� �� ��� ���
	.error "Clk_freq is not defined, delay can't be set"
	.endif

.set Ntakt=(@0*clk_freq)/5000
	
.set hi_byte=(ntakt/65536)		; ������ ��������, ��������� � ��������
.set ntakt=(ntakt-hi_byte*65536)	; ��� ��������� �������� ��������
.set me_byte=(ntakt/256)			; ����� �� ��������, �������� ����,
.set ntakt=(ntakt-me_byte*256)		; ������� ����� ����� �� �������� � �.�.
.set lo_byte=ntakt 				; � �����, ����� ����� - �����������

ldi r16, lo_byte				; ������� ���������� ��������� � ��������
ldi r17, me_byte
ldi r18, hi_byte
delay_a:
SUBI r16, 1 ; �������� 1 (1 ���� CPU)
SBCI r17, 0 ; �������� ������ � (1 ���� CPU)
SBCI r18, 0 ; �������� ������ � (1 ���� CPU)
BRCC delay_a ; ���� ��� �������� - ������� (2 ����� CPU)
nop

.endmacro


;=== END "macrobaselib.inc" ================================================
; coded by (c) DI HALT, 2008 @ http://easyelectronics.ru/
; coded by (c) Celeron, 2013 @ http://we.easyelectronics.ru/my/Celeron/
.list