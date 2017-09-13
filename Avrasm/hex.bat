@echo off
if not exist %~pn1.inc (
echo ;Here may be you header file>%~pn1.inc
set T=1 )
if not exist out md out
@echo on
D:\!lab\asm\avrasm\avrasm2.exe -I %~p1 -i D:\!lab\ASM\inc\_macrobaselib.inc -fI -o out\%~n1.hex -d out\%~n1.obj -l out\%~n1_list.txt -m out\%~n1_map.txt  %1.asm  
@echo off
if defined T (
del %~fn1.inc
echo.
echo MAN, YOU FORGOT YOUR %~n1.inc HEADER FILE, D'YOU REALLY THINK YOU DON'T NEED IT?
)
pause=null