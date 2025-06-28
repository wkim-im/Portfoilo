#include <avr/io.h> // ATmega128 register 정의
#include <avr/interrupt.h> // 인터럽트 서비스 루틴 처리 시 사용
#define F_CPU 16000000UL
#include <util/delay.h>
#define IDLE 0 // IDLE 상태 값
#define STOP 1 // STOP 상태 값
#define GO 2 // GO 상태 값
#define REVERSE 3 // REVERSE 상태값
volatile signed int cur_floor = 0; // ‘현재 층’ 변수 초기화
volatile signed int stop_floor = 0; // ‘STOP 층’ 변수 초기화
volatile int state = IDLE; // state : 현재 상태를 나타내는 전역변수(Global Variable), 처음 시작 시에는 IDLE 상태에서 출발
unsigned char digit[]= {0x3f, 0x06, 0x5b, 0x4f, 0x66,0x6d, 0x7c, 0x07, 0x7f, 0x67}; //0~9
unsigned char fnd_sel[4] = {0x00, 0x02, 0x04, 0x00}; //FND 선택 신호 어레이 4개 FND 중 2번째 3번째 FND만 사용
volatile int rcount = 0; //층 증감 판단 변수 선언

ISR(INT4_vect)
{
	_delay_ms(100); // 스위치 바운스 기간 동안 기다림
	EIFR = 1 << 4; // 그 사이에 바운스에 의하여 생긴 인터럽트는 무효화
	if ((PINE & 0x10)==0x10) // 인터럽트 입력 핀(PE4)을 다시 검사하여
	return; // 눌러진 상태가 아니면(‘1’) 리턴
	if (state == IDLE || state == STOP) // IDLE 또는 STOP 상태라면
	state = GO;
	else // 만약 GO나 REVERSE 상태라면
	{
		state = STOP; //  STOP으로 상태 변경
		stop_floor = cur_floor; // 그리고, “현재 층”을 복사
	}
}

ISR(INT5_vect)
{
	_delay_ms(100); // 스위치 바운스 기간 동안 기다림
	EIFR = 1 << 5; // 그 사이에 바운스에 의하여 생긴 인터럽트는 무효화
	if ((PINE & 0x20)==0x20) // 인터럽트 입력 핀(PE5)을 다시 검사하여
	return; // 눌러진 상태가 아니면(‘1’) 리턴
	state = REVERSE; // 상태(state)를 REVERSE 상태로 변경
	if (rcount == 1) rcount = 0; // rcount가 1이면 짝수로 올라가는 방향으로 설정
	else rcount = 1; // rcount가 0이면 홀수로 내려가는 방향으로 설정
}
void init_stopfloor(void); // main 함수가 call하는 함수는 main 함수보다 먼저 나타나거나 그 타입만 먼저나오고 나중에 call할 경우 유효함
void display_fnd(int); // 마찬가지 이유

int main()
{
	init_stopfloor( );
	while(1)
	{
		if (state == IDLE) // IDLE 상태이면
		display_fnd(cur_floor); // 초기값 0 디스플레이, 0층에 있으나 디스플레이 표시는 안함.
		
		if (state == GO)// GO 상태이면
		{   if(cur_floor==22){ // 22층이면
			rcount=1; // 홀수 입력 -> 층 감소
			}
		else if(cur_floor==-3){ //-3층이면
			rcount=0; // 짝수 입력-> 층 증가
			}
		display_fnd(cur_floor);
		cur_floor += 1 - 2*rcount; //rcount가 1이면 cur_floor는 -1을 계속 더해줘서 층 감소, 0이면 cur_floor는 1을 계속 더해줘서 층 증가 
		}
		else if (state == STOP)// STOP 상태이면
		{
			display_fnd(stop_floor); // 멈춰있는 층 디스플레이

		}
		else if (state == REVERSE){ //REVERSE 상태
			if(cur_floor==22){ //22층이면
				rcount=1; // 홀수입력 -> 층 감소
			}
			else if(cur_floor==-3){ //-3층이면
				rcount=0; // 짝수입력 -> 층 증가
			}
			display_fnd(cur_floor);
			cur_floor += 1 - 2*rcount; //rcount가 1이면 cur_floor는 -1을 계속 더해줘서 층 감소, 0이면 cur_floor는 1을 계속 더해줘서 층 증가
		}
	}
}

void init_stopfloor(void)
{
	DDRC = 0xff; // C 포트는 FND 데이터 신호
	DDRG = 0x0f; // G 포트는 FND 선택 신호
	DDRE = 0x00; // PE4(SW1), PE5(SW2)을 포함한 PE 포트는 입력 신호
	sei(); // SREG 7번 비트(I) 세트
	// sei() 는 “SREG |= 0x80” 와 동일한 기능을 수행
	EICRB = 0x0a; // INT4, INT5 트리거는 하강 에지(Falling Edge)
	EIMSK = 0x30; // INT4, INT5 인터럽트 enable
}

void display_fnd(signed int count) // 이 함수의 1회 수행시간은 약 2000ms(2초) 외의 코드 실행시간은 us단위로 무시
{
	int i, fnd[4]; // 각 자리수의 변수를 다르게 해도 되지만 여기처럼 변수를 어레이로 잡음
	
	if (count==0){ //count가 0이면, 00층이면 아무것도 display 하지 않음
		return;
	}
	else if (count < 0){ //count가 0보다 작으면, 십의 자리FND에 -와 일의 자리 FND에 1~3을 표시하기위함
		fnd[1] = abs(count); // 일 자리 절대값으로 전달
		for (i=0; i<400; i++) // 5ms*400=2000ms == 2초
		{
			if(i%4==2){ 
				PORTC=0x40; //십의 자리 FND에 - display(0100 0000 <- led(g)만 킴)
			}
			else
			PORTC = digit[fnd[i%4]]; //일의 자리 fnd에 절대값 count로 입력받은 일의 자리 display 
			PORTG = fnd_sel[i%4];//일,십의 자리 fnd만 사용
			_delay_ms(5);
		}

	}
	else{
		fnd[2] = count/10; // 십 자리
		fnd[1] = count%10; // 일 자리
				
		if (fnd[2]==0){ //십의 자리가 0일 경우 십의 자리 표시안함
			for (i=0; i<400; i++) // 5ms*400=2000ms == 2초
			{
				PORTC=digit[fnd[1]]; //일의 자리 fnd에 count로 입력받은 일의 자리 display 
				PORTG=0x02; //일의 자리 fnd만 사용
				_delay_ms(5);
			}
			
		}
		else{ // 십의 자리가 존재할때
			for (i=0; i<400; i++) // 5ms*400=2000ms == 2초
			{
				PORTC = digit[fnd[i%4]]; //십, 일의 자리 FND에 입력받은 숫자를 display
				PORTG = fnd_sel[i%4]; //십, 일의자리 FND만 사용 
				_delay_ms(5);
			}
		}
		
	}
}
