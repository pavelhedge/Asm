;@@@@			Заброс инфы через сдвиговый регистр			@@@@
mov temp, shift_register
ldi cntr, 8
Shift_begin:
	cbi shift_port, clk
	cbi shift_port, serial
	sbrc temp, 0
	sbi shift_port, serial
	ror temp
	sbi shift_port, clk
	dec cntr
brne Shift_begin

sbi shift_port, rdy

