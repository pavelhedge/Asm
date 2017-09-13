.nolist
.IFNDEF _MACROBASELIB__INCLUDED_
	.EQU _MACROBASELIB__INCLUDED_ = 1
.else 
	.warning "NOTE: <macrobaselib.inc has been included yet"
	.exit
.endif

;=== BEGIN "macrobaselib.inc" ============================================

; Библиотека базовых Макроопределений,
; расширяющая стандартный набор ассемблерных инструкций микроконтроллеров 
; Atmel AVR (8-bit AVR Instruction Set), и рекомендующая парадигму 
; программирования: с хранением "модели прикладных данных" в ОЗУ (SRAM) и 
; использованием нескольких регистров (РОН) под "временные переменные"...
;---------------------------------------------------------------------------
; Рекомендации по использованию "индексных регистров" в коде:
; * РОН из диапазона R26..R31 лучше не использовать для иных нужд, чем как 
; "индексные регистры" (т.е. не рекомендуется использовать их в качестве 
; "временных переменных").
; При реализации алгоритма функции, в коде, часто удобно использовать 
; инструкции "непрямой пересылки данных": LD/ST, LDD/STD.
; Возникает вопрос выбора: какие при этом лучше использовать 
; "индексные регистры": X, Y, или Z ?
; * Регистр Z лучше не использовать для арифметических преобразований, 
; особенно для "параметров функций" - потому что он требуется для инструкций
; "непрямого перехода" ICALL/IJMP (дальнобойностью до 64K слов), т.е. 
; Z требуется для вызова самой функции. (Напомню, что в семействе МК "ATTiny*" 
; нет инструкций "дальнего перехода" CALL/JMP - поэтому, в них, инструкции 
; ICALL/IJMP становятся единственной возможностью!)
; * А выбирая между X и Y - в первую очередь, лучше использовать Y, т.к. он 
; более функционален: поддерживает также инструкции LDD/STD. (Кроме того,
; Y - чуть ближе к концу файла РОН, что "концептуальнее": меньше вероятность 
; задействования его, в качестве "временного регистра".)
;---------------------------------------------------------------------------
; Основные положения о "временных переменных" (переменных общего
; назначения):
; В коде данной библиотеки, и при работе с ней, регистры R16,R17,R18,R19
; рекомендуется использовать как "временные переменные" - поэтому,
; в вашем прикладном коде, не используйте их для хранения постоянных данных!
; Как сказал DI HALT:
; При вычислениях, регистры можно предварительно заталкивать в стек...
; но я дам тебе лучше другой совет:
; когда пишешь программу, продумывай алгоритм так, чтобы использовать 
; регистры как сплошной TEMP, данные которого актуальны только здесь и сейчас.
; И что с ними будет в следующей процедуре - уже не важно.
; А все перманентные данные - следует сохранять в оперативке (SRAM).
; Совет: вы также можете использовать эти псевдонимы регистров в программе:
.def temp = R16
.def temp1 = R16
.def temp2 = R17
.def temp3 = R18 ; пока не используется данной библиотекой
.def temp4 = R19 ; пока не используется данной библиотекой
.def flag = r19
.def data1 = r24 	; Для передачи данных между прерываниями, подпрограммами 
.def data2 = r25	; и функциями
;##******************************************************************************************
;##;*														
;##;*				 Начальная Инициализация МК					
;##;*														
;##******************************************************************************************

.MACRO INITIALIZATION 	; Начальная инициализация всего, что найдем
	RAMFLUSH
	GPRFLUSH
.ifdef RAMEND
	STACKINIT
.endif

/* Макросы инициализации периферии находятся в коде обработчиков периферии */
.ifdef __display_included__
	DISPLAY_INIT
.endif

.ifdef __key_included__
	KEY_INIT
.endif

.ENDMACRO

;##					; Инициализация Стека						
.MACRO STACKINIT

.if RAMEND>0x0000 ; Только для МК имеющих SRAM...
	LDI temp, Low(RAMEND) ; адрес вершины стека = конец памяти (мл.байт)
	.ifdef SPL
		OUT SPL, temp
	.else
		OUT SP, temp
	.endif

	.ifdef SPHHf
		LDI temp, High(RAMEND) ; адрес вершины стека = конец памяти (ст.байт)
		OUT SPH, temp
	.endif
.else
	.WARNING "This device have not SRAM. Can not initialize Stack!"
.endif //RAMEND
.ENDM

;##						 Очистка памяти						
.MACRO RAMFLUSH
	LDI ZL, Low (SRAM_START) ; Адрес начала ОЗУ в индекс
	LDI ZH, High(SRAM_START)
	CLR temp ; Очищаем R16
LOOP__RAMFLUSH:
	ST Z+, temp ; Сохраняем 0 в ячейку памяти
	CPI ZL, Low (RAMEND+1) ; Достигли конца оперативки?
	BRNE LOOP__RAMFLUSH ; Нет? Крутимся дальше!
	CPI ZH, High(RAMEND+1) ; А старший байт достиг конца?
	BRNE LOOP__RAMFLUSH
.ENDM

;##			 Очистка РОН (Регистров Общего Назначения)				
.MACRO GPRFLUSH
	LDI ZL, 30 ; +-----------------------+
	CLR ZH ; | Очистка РОН (R00-R31) |
	DEC ZL ; | |
	ST Z, ZH ; | [всего 10 байт кода!] |
	BRNE PC-2 ; +-----------------------+
.ENDM

;##						Выключение собаки					
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
;##* 	Автоматические 8/16-битные операции с адресными парами X,Y,Z  		
;##*														
;##******************************************************************************************
.ifndef XX
.equ XX=1
.equ YY=2
.equ ZZ=3
.endif
;@@@@	Универсальная загрузка данных в индексные регистры X, Y, Z	@@@	
/* Загружает 16-битный адрес в индексные регистровые пары.
Т.к. к X, Y, Z компилятор относится очень ревностно, не позволяя обозначать ими 
ничего, пришлось заменить их двойными буквами XX, YY, ZZ
Пример вызова:
LDA XX, adress ; Загрузить 16-битный адрес в регистровую пару X */ 
.MACRO LDA
.if (@0)==1
ldi XL, low (@1)
;.if @1 > 255		; Пусть грузит все, иначе вылазят глюки, когда уже загружено 
ldi XH, high (@1)		; high и не исправляется
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

;######			Сравнение пары X, Y, Z с константой		#####
;			сравнивает 16-битное число с регистровой парой rN, rN+1
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

;##			Сложение регистровой пары с 8/16-битной константой		
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
;##					Перегрузка из ROM в RAM				#####
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
;##* 					Поддержка ВВОДа / ВЫВОДа				
;##*														
;##******************************************************************************************
; Где: РВВ - Регистры Ввода Вывода (I/O registers).
; Универсальный вывод в РВВ (порты): стандартного диапазона адресации (0x00-
; 0x3F), и сверх диапазона ("MEMORY MAPPED": >= 0x60),
; в т.ч. в любую ячейку оперативной памяти (Location < 64K bytes).
;##			 Выгрузка числа @1 в порт @0 (OUTput "Immediate")			
; Пример вызова: OUTI port,byte
; Памятка: портит содержимое регистра TEMP.
.MACRO OUTI
	LDI temp, @1
.if @0 < 0x40
	OUT @0, temp
.else
	STS @0, temp
.endif
.ENDMACRO

;##	 Выгрузка [содержимого] регистра @1 в порт @0 (OUTput from "Register")	
; Пример вызова: OUTR port,register
.MACRO OUTR
.if @0 < 0x40
	OUT @0, @1
.else
	STS @0, @1
.endif
.ENDMACRO

;##	 Загрузка [содержимого] порта @1 в регистр @0 (INput to "Register")		
; Пример вызова: INR register,port
.MACRO INR
.if @1 < 0x40 ; IO
	IN @0, @1
.else ; Memory
	LDS @0, @1
.endif
.ENDM



;##		 Сохранение/Восстановление регистров SREG и TEMP в Стеке.		
; (данные макросы используются парно, обычно, в обработчиках прерываний)
.MACRO PUSHF
	PUSH temp
	IN temp, SREG
	PUSH temp
.ENDM
; Примечание: портит содержимое регистра TEMP на период обработки прерывания
; (между PUSHF..POPF)! Однако же, также и восстанавливает потом (после POPF)
;  - что делает регистр TEMP: "защищённой" доступной "временной переменной", 
; внутри обработчика прерывания.
.MACRO POPF
	POP temp
	OUT SREG, temp
	POP temp
.ENDM
;##---------------------------------------------------------------------------------------------------------------------------------------
; ##			Универсальная манипуляция битами в РВВ (портах):			
;##---------------------------------------------------------------------------------------------------------------------------------------
; с младшими (0x00-0x1F), старшими (0x20-0x3F) адресами,
; и сверх диапазона ("MEMORY MAPPED": >= 0x60)
; ##						SET BIT via REG						
; Пример вызова: SETB byte,bit
; Памятка: портит содержимое регистра TEMP... но при работе с битами младших
; РВВ (0x00-0x1F) - вспомогательный регистр TEMP не используется (сохраняется).
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
; Пример вызова: CLRB byte,bit
; Памятка: портит содержимое регистра TEMP... но при работе с битами младших 
; РВВ (0x00-0x1F) - вспомогательный регистр TEMP не используется (сохраняется).
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
; Пример вызова: INVB byte,bit
; Памятка: портит содержимое регистров TEMP1,TEMP2.
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
; Примечание: "Transfer bit" позволяет Тестировать значение бита и делать 
; условные переходы (BRTS/BRTC).

; Пример вызова: STOREB byte,bit
; Памятка: портит содержимое регистра TEMP.
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
; Пример вызова: LOADB byte,bit
; Памятка: портит содержимое регистра TEMP.
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
;##					Операции с битами через СТЕК				
;##---------------------------------------------------------------------------------------------------------------------------------------
; не требуют "вспомогательных регистров" TEMPx (резервируют их самостоятельно)
; но работают дольше и используют оперативную память (Стек).

;##					 SET BIT via STACK/MEMORY					
; Пример вызова: SETBM byte,bit
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
; Пример вызова: CLRBM byte,bit
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
; Пример вызова: INVBM byte,bit
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
; Пример вызова: STOREBM byte,bit
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
; Пример вызова: LOADBM byte,bit
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
;##* 				Арифметические операции: 8-битные				
;##*														
;##******************************************************************************************


;##		Инкрементация (+1) однойбайтной переменной @0 в памяти		
; Памятка: портит содержимое регистра TEMP.
.MACRO INC8M
	LDS temp, @0
	inc temp
	STS @0, temp
.ENDM

;##		 Декрементация (-1) однойбайтной переменной @0 в памяти		
; Памятка: портит содержимое регистра TEMP.
.MACRO DEC8M
	LDS temp, @0
	dec temp
	STS @0, temp
.ENDM
;##			Обнуление однобайтной переменной @0 в памяти			
; Памятка: портит содержимое регистра TEMP.
.MACRO CLR8M
	CLR temp ; Тут нам нужен ноль...
	STS @0, temp ; Ноль в первый байт счетчика в RAM
.ENDM


;##******************************************************************************************
;##*								/|	r----					
;##* Арифметические операции: 16-битные	 |	|___					
;##*								 |	|___|					
;##******************************************************************************************

;##			 Инкрементация (+1) двухбайтной переменной @0 в RAM 		
; Памятка: портит содержимое регистра TEMP.
.MACRO INC16M
LDS temp, @0
SUBI temp, (-1)
STS @0, temp
LDS temp, @0+1
SBCI temp, (-1)
STS @0+1, temp
.ENDM

;##			Декрементация (-1) двухбайтной переменной @0 в RAM 		
; Памятка: портит содержимое регистра TEMP.
.MACRO DEC16M
LDS temp, @0
SUBI temp, (1)
STS @0, temp
LDS temp, @0+1
SBCI temp, (0)
STS @0+1, temp
.ENDM
; ##			Обнуление двухбайтной переменной @0 в памяти			
; Памятка: портит содержимое регистра TEMP.
.MACRO CLR16M
CLR temp ; Тут нам нужен ноль...
STS @0, temp ; Ноль в первый байт счетчика в RAM
STS @0+1, temp ; Ноль в второй байт счетчика в RAM
.ENDM
;---------------------------------------------------------------------------
; ##			Арифметическое вычитание 16-битной константы @2			
;##					 из регистровой пары @0:@1					
; (Это эмуляция стандартной 16-битной инструкции, которая есть не во всех МК: 
; SBIW YH:YL,0x1234 )
; Пример вызова: SUBI16 YH,YL,0x1234
.MACRO SUBI16 ; Start macro definition
SUBI @1, Low(@2) ; Subtract low byte
SBCI @0, High(@2) ; Subtract high byte
.ENDM ; End macro definition


;##******************************************************************************************
;*##														
;* ##				Арифметические операции: 32-битные				
;*##														
;##******************************************************************************************

;## Инкрементация (+1) четырехбайтной переменной @0 в памяти (по адресу @0 - 
;##					мл.байт, little-endian)
; Памятка: портит содержимое регистра TEMP.
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

;## Декрементация (-1) четырехбайтной переменной @0 в памяти (по адресу @0 - 
;##				мл.байт, little-endian)
; Памятка: портит содержимое регистра TEMP.
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

;##			 Обнуление четырехбайтной переменной @0 в памяти		
; Памятка: портит содержимое регистра TEMP.
.MACRO CLR32M
	CLR temp ; Тут нам нужен ноль...
	STS @0, temp ; Ноль в первый байт счетчика в RAM
	STS @0+1, temp ; Ноль в второй байт счетчика в RAM
	STS @0+2, temp ; Ноль в третий байт счетчика в RAM
	STS @0+3, temp ; Ноль в четвёртый байт счетчика в RAM
.ENDM


;####					ЗАДЕРЖКА_макро				#####
;---------------------------------------------------------------------------
;
; Процедура "тупой задержки" (крутит цикл в CPU)
;
; Величина задержки задаётся 3х байтовым ЧИСЛОм:
; Через регистровые параметры: TEMP1, TEMP2, TEMP3.
; Или, как вариант, фиксирована константно, через макроопределения.
;
; Итоговая задержка:
; Количество тактов CPU, которое тупить = (ЧИСЛО+1) * 5
;
;---------------------------------------------------------------------------
;----- Subroutine Register Variables
.set delay_ms=0
.set delay_us=0

.macro DELAY		; Макрос рассчитывает и предустанавливает задержку 
				; в миллисекундах
	.ifndef clk_freq	; выбор формулы расчета тактов для мс или мкс
	.error "Clk_freq is not defined, delay can't be set"
	.endif

.set Ntakt=(@0*clk_freq)/5000
	
.set hi_byte=(ntakt/65536)		; Расчет значений, вбиваемых в регистры
.set ntakt=(ntakt-hi_byte*65536)	; для получения заданной задержки
.set me_byte=(ntakt/256)			; делим на значение, получаем байт,
.set ntakt=(ntakt-me_byte*256)		; остаток снова делим на значение и т.д.
.set lo_byte=ntakt 				; в общем, нужно будет - разберешься

ldi r16, lo_byte				; Вбиваем полученный результат в регистры
ldi r17, me_byte
ldi r18, hi_byte
delay_a:
SUBI r16, 1 ; Вычитаем 1 (1 такт CPU)
SBCI r17, 0 ; Вычитаем только С (1 такт CPU)
SBCI r18, 0 ; Вычитаем только С (1 такт CPU)
BRCC delay_a ; Если нет переноса - переход (2 такта CPU)
nop

.endmacro


;=== END "macrobaselib.inc" ================================================
; coded by (c) DI HALT, 2008 @ http://easyelectronics.ru/
; coded by (c) Celeron, 2013 @ http://we.easyelectronics.ru/my/Celeron/
.list