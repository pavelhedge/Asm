;###### 				CountDown Timer Handler				#####

/* 	������� ������� ��������� �������. ������, �������, ����, ���  
��������� ��������� ������ � RAM �������� �����	*/

.dseg

timer_sec: .byte 1
timer_min: .byte 1
timer_hour: .byte 1
timer_day: .byte 1

.cseg
TIM_sub:
	ld temp1, Y	
	subi temp1, 1
	st Y, temp1				
	brcc end_timer
	mov temp1, temp2
	st Y+, temp1
ret

ldi YL, low(timer_sec)	; ������ � Y ��������� ������� �������
ldi YH, high(timer_sec)

TIMER_HANDLER:
cli

ldi temp2, 59	; ##�������#
rcall TIM_sub

rcall TIM_sub	; ##������#		

ldi temp2, 23	; ##����#
rcall TIM_sub

ldi temp2, 0		; ##���#
rcall TIM_sub

;cbr flag, (1<<timer_flag)
;rcall TIMER_SIGNAL

end_timer:
pop temp	; �.�. ����� �� ���������� TIM_sub ��� ���������� ����� �������, 
pop temp	; �������� �� ����� ����
reti

TIMER_SIGNAL:


	
	