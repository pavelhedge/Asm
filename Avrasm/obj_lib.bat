@echo off
if not exist %~pn1.inc (
echo ;Here may be you header file>%~pn1.inc
set T=1 )
if not exist out md out
@echo on
D:\!lab\asm\avrasm\avrasm2.exe -I D:\!lab\ASM -i D:\!lab\ASM\inc\_macrobaselib.inc -i %~fn1.inc -fO -o out\temp.obj %1.asm  
@echo off
if defined T (
del %~fn1.inc
echo.
echo MAN, YOU FORGOT YOUR %~n1.inc HEADER FILE, D'YOU REALLY THINK YOU DON'T NEED IT?
)
pause=null