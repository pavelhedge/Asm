@echo off
D:\!lab\asm\avrasm\avrasm2.exe -I D:\!lab\ASM -i D:\!lab\ASM\inc\_macrobaselib.inc -fI -o tmp.hex %1.asm
if not exist %~p1\tmp.hex (
pause=null
exit)

:PROGRAM
@echo.
ECHO Enter AVR code or press ENTER to exit
set avr_model=
set /p avr_model=

IF "%avr_model%"=="" exit

D:\!lab\asm\avrasm\avrdude\avrdude.exe -c usbasp -p %avr_model% -B 4 -F -U flash:w:"%~p1\tmp.hex":a

if ERRORLEVEL 1 GOTO PROGRAM
del %~p1\tmp.hex
pause=null