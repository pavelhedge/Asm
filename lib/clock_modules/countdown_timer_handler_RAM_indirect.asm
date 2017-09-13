;###### 				CountDown Timer Handler				#####

/* 	������� ������� ��������� �������. ������, �������, ����, ���  
��������� ��������� ������ � RAM �������� �����	*/

TIMER_HANDLER:
cli
ldi YL, low(timer_sec)
ldi YH. high(timer_sec)

ld temp, Y		; ##�������#
subi temp, 1
st Y, temp				
brcc end_timer
ldi temp, 59
st Y+, temp

ld temp, Y		; ##������#		
subi temp, 1
st Y, temp				
brcc end_timer
ldi temp, 59
st Y+, temp

ld temp, Y		; ##����#
subi temp, 1
st Y, temp				
brcc end_timer
ldi temp, 23
st Y+, temp

ld temp, Y		; ##���#
subi temp, 1
st Y, temp
brcc end_timer
clr temp
st Y, temp

cbr flag, (1<<timer_flag)
rcall TIMER_SIGNAL

end_timer:
reti



	
	