#include <avr/io.h>
#include <avr/interrupt.h>
#define F_CPU 16000000UL
#define __DELAY_BACKWARD_COMPATIBLE__
#include <util/delay.h>

volatile int ncount = 0;
#define DO 0
#define RE 1
#define MI 2
#define FA 3
#define SOL 4
#define RA 5
#define SI 6
#define DDO 7
#define REST 8
#define EOS -1
#define ON 0
#define OFF 1
#define N2 1250
#define N4 625
#define N8N16 469
#define N8 313
#define N16 156
#define R 1
#define stage1 0 //첫번째 곡
#define stage2 1 //두번째 곡
#define stage3 2 //세번째 곡
volatile int stage = stage1;

volatile int state, tone,j;

char f_table[] = {17, 43, 66, 77, 97, 114, 117, 137, 255};

// 노래 배열 (3개의 노래)
int song[3][100] = {
	{SOL, MI, REST, MI, SOL, MI, DO, RE, MI, RE, DO, MI, SOL, DDO, SOL, DDO, SOL, DDO, SOL, MI, SOL, RE, FA, MI, RE, DO, EOS},
	{MI,REST,MI,REST,MI,REST,MI,REST,MI,REST,MI,REST,MI,SOL,DO,RE,MI,FA,REST,FA,REST,FA,REST,FA,REST,FA,MI,REST,MI,REST,MI,REST,MI,RE,REST,RE,MI,RE,SOL,MI,REST,MI,REST,MI,REST,MI,REST,MI,REST,MI,REST,MI,SOL,DO,RE,MI,FA,REST,FA,REST,FA,REST,FA,REST,FA,MI,REST,MI,REST,MI,SOL,REST,SOL,FA,RE,DO,EOS},
	{MI,REST,MI,FA,SOL,REST,SOL,FA,MI,RE,DO,REST,DO,RE,MI,REST,MI,RE,REST,RE,MI,REST,MI,FA,SOL,REST,SOL,FA,MI,RE,DO,REST,DO,RE,MI,RE,DO,REST,DO,EOS}};

// 시간 배열
int time[3][100] = {
	{N4, N8, R, N8, N8, N8, N4, N4, N8, N8, N8, N8, N4, N8N16, N16, N8, N8, N8, N8, N4, N4, N8, N8, N8, N8, N4},
	{N4,R,N4,R,N2,R,N4,R,N4,R,N2,R,N4,N4,N4,N4,N2,N4,R,N4,R,N4,R,N4,R,N4,N4,R,N4,R,N4,R,N4,N4,R,N4,N4,N2,N2,N4,R,N4,R,N2,R,N4,R,N4,R,N2,R,N4,N4,N4,N4,N2,N4,R,N4,R,N4,R,N4,R,N4,N4,R,N4,R,N4,N4,R,N4,N4,N4,N2},
	{N4,R,N4,N4,N4,R,N4,N4,N4,N4,N4,R,N4,N4,N4,R,N4,N4,R,N2,N4,R,N4,N4,N4,R,N4,N4,N4,N4,N4,R,N4,N4,N4,N4,N4,R,N2}};

char LED[] = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x00};

ISR(INT4_vect) {
	_delay_ms(50); // 스위치 바운스 방지
	EIFR = 1 << 4; // 바운스 처리
	if ((PINE & 0x10) == 0x10)
		return;// 스위치가 눌려있지 않으면 리턴
	if(stage == stage1){
		stage=stage2;
		j=0;
	}
	else if(stage == stage2){
		stage=stage3;
		j=0;
	}
	else
		stage = stage1;
		j=0;
}

ISR(TIMER0_OVF_vect) {
	TCNT0 = f_table[tone]; // 음계 설정
	if (state == OFF) {
		PORTB |= 1 << 4; // 버저 ON
		state = ON;
		} else {
		PORTB &= ~(1 << 4); // 버저 OFF
		state = OFF;
	}
}

void init_stopfloor(void) {
	DDRE = 0x00; // 스위치 입력 설정
	sei(); // 전역 인터럽트 활성화
	EICRB = 0x02; // 하강 에지 트리거
	EIMSK = 0x10; // INT4 인터럽트 활성화
}

int main() {
	DDRE = 0X00; // 스위치 입력 설정
	sei(); // 전역 인터럽트 활성화
	EICRB = 0X02; // 하강 에지 트리거
	EIMSK = 0X10; // INT4 인터럽트 활성화
	DDRA = 0xff; // LED 출력
	DDRB |= 0x10; // 버저 출력 설정
	TCCR0 = 0x03; // 32분주
	TIMSK = 0x01; // 오버플로우 인터럽트 활성화
	
	while (1) {
		if(stage==stage1){
			tone = song[0][j]; // 현재 음계
			if (tone == EOS) 
			{
				j=0;
			} 
			else 
			{
				PORTA = LED[tone]; // LED 표시
				_delay_ms(time[0][j]); // 음계 지속 시간 대기
				j++; // 다음 음계로 이동
			}

		}
		else if(stage==stage2){
			tone = song[1][j]; // 현재 음계
			if (tone == EOS)
			{
				j=0;
			}
			else
			{
				PORTA = LED[tone]; // LED 표시
				_delay_ms(time[1][j]); // 음계 지속 시간 대기
				j++; // 다음 음계로 이동
			}

		}
		else if(stage==stage3){
			tone = song[2][j]; // 현재 음계
			if (tone == EOS)
			{
				j=0;
			}
			else
			{
				PORTA = LED[tone]; // LED 표시
				_delay_ms(time[2][j]); // 음계 지속 시간 대기
				j++; // 다음 음계로 이동
			}
		}
	}
}