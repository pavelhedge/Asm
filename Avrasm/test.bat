@echo off
avrasm2.exe -I D:\!lab\ASM -i D:\!lab\ASM\inc\_macrobaselib.inc -fI -o tmp.hex %1.asm
if not exist %~p1\tmp.hex (
pause=null
exit)
set /p avr_model="What avr?"
avrdude\avrdude.exe -c usbasp -p %avr_model% -B 4 -F -U flash:w:"%~p1\tmp.hex":a
del %~p1\tmp.hex
pause=null