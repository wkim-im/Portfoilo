#include <avr/io.h>
#include <avr/interrupt.h>
#define F_CPU 16000000UL
#define __DELAY_BACKWARD_COMPATIBLE__
#include <util/delay.h>

#define STOP 0
#define RUN 1
#define RESERVE 2

#define  STOP_SPEED 0 //duty cycle 0%값
#define  LOW_SPEED 77 //duty cycle 30%값 (=255*0.3)
#define  MID_SPEED 153 //duty cycle 60%값 (=255*0.6)
#define  HIGH_SPEED 230 //duty cycle 90%값 (=255*0.9)
						//모터제어
						//PB7 = AIN1, PB6 = AIN2, PB5 = PWMA, PB4 = STBY
#define MOTOR_CW 0xb0 // 모터 Forward : AIN1=1, AIN2=0, PWMA=1, STBY=1#define MOTOR_CCW 0x70 //모터 Forward : AIN1=1, AIN2=0, PWMA=1, STBY=1
#define MOTOR_BRAKE 0xd0 // 모터 Reverse : AIN1=0, AIN2=1, PWMA=1, STBY=1
#define MOTOR_STOP 0x30 // 모터 Stop : AIN1=0, AIN2=0, PWMA=1, STBY=1
#define MOTOR_STANDBY 0x00 // 모터 Standby : AIN1=0, AIN2=0, PWMA=0, STBY=0

volatile int state = STOP; //현재 상태를 STOP상태로 초기화
volatile int runcount=1; //SW1누르면 약풍부터 시작하게끔 초기화
volatile int cnt=0; //오버플로 서비스 인터럽트내에서 시간을 세기 위한 변수
int motor_speed[4]={STOP_SPEED,LOW_SPEED,MID_SPEED,HIGH_SPEED}; //각각의 모터 스피드를 배열에 초기화


ISR(INT4_vect) //SW1
{
	_delay_ms(100); // 스위치 바운스 방지
	EIFR = 1 << 4; // 바운스 처리
	if ((PINE & 0x10) == 0x10) //마스킹 방법
	return;// 스위치가 눌려있지 않으면 리턴
	if(state==RUN || state==RESERVE) //RUN상태이거나 RESERVE상태일때 STOP으로 상태변경
	{ 
		state=STOP;
	}
	else //STOP상태이면 RUN상태로 변경
	{
		state = RUN;
	}
}

ISR(INT5_vect) //SW2
{
	_delay_ms(100); // 스위치 바운스 방지
	EIFR = 1 << 5; // 바운스 처리
	if ((PINE & 0x20) == 0x20) //마스킹 방법
	return;// 스위치가 눌려있지 않으면 리턴
	runcount =  ((1+runcount) % 4)==0 ? 1 : (1+runcount) % 4; //1~3 내 숫자 표현(low,mid,high)	
}

ISR(INT6_vect) //SW3
{ //5초 딜레이 후 상태 STOP으로 전환
	_delay_ms(100); // 스위치 바운스 방지
	EIFR = 1 << 6; // 바운스 처리
	if ((PINE & 0x40) == 0x40) //마스킹 방법
	return;// 스위치가 눌려있지 않으면 리턴
	if(state == RUN)
	{	
		state=RESERVE;
	}
}

ISR(TIMER0_OVF_vect){
	if (state==RESERVE)
	{
		if ( cnt < 5000) //루프 동작시 1 [ms] * 5000 = 5 [s]
		{
			cnt++;
		}
		else if (cnt == 5000) { //5초 후 상태를 STOP으로 저장 후 cnt=0으로 초기화
			state=STOP;
			cnt = 0;
		}	
	}
}

int main()
{	DDRE=0x00; //EPORT 입력 설정
	sei(); //SREG 상태 레지스터 I를 1로 설정하여 외부 인터럽트 활성화
	EICRB=0x2a; //INT6,5,4 
	EIMSK=0x70; //INT6,5,4 하강엣지 설정
	DDRA=0x1f; //PORTA 0~4번 led 출력 설정
	DDRB=0xf0; //PORTB 4~7번 출력 설정
	TIMSK = 0x01;   //오버플로우 인터럽트  00000001 설정
	TCCR2=0x6b; //Fast PWM 모드, 64분주 01101011 WGM0 COM1 COM0 WGM1 cs2 cs1 cs0 wgm 11:고속pwm com:10 비교매치해 같아지면 ocr이0되게
	PORTB=MOTOR_CW; //시계방향으로 작동하도록 설정
	TCCR0=0x04; // 64분주로 한클럭당 4[us]
	TCNT0=6; //전체 클럭을 256-6=250으로 설정하여 0~250 내에 클럭이 동작, 250이면 오버플로 1 발생, 250 x 4 [us] = 1000 [us] = 1 [ms]
	
	while(1)
	{
		if(state==STOP) //현재 상태가 STOP이면 motor_speed[0] 저장한 duty cycle(STOP_SPEED)을 OCR2에 입력해 멈춤상태 이며 해당하는 LED ON

		{
			OCR2=motor_speed[0];
			PORTA=1<<0;
		}
		else if(state==RUN) //현재 상태가 RUN 상태이면 motor_speed[] 저장한 duty cycle(LOW_SPEED,MID_SPEED,HIGH_SPEED)을 OCR2에 입력해 동작하면서 해당하는 LED ON
		{
			OCR2=motor_speed[runcount];
			PORTA=1<<runcount;
		}
		else if(state==RESERVE){ //현재 상태가 RESERVE상태이면 motor_speed[] 저장한 duty cycle(LOW_SPEED,MID_SPEED,HIGH_SPEED)을 OCR2에 입력해 동작하면서 해당하는 LED ON
			OCR2=motor_speed[runcount];
			PORTA=1<<runcount|0x10; // A포트의 4번 LED도 같이 ON
		}
	}
}
