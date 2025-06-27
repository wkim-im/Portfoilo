/*
#define ENA 4  PB4    OC0
#define ENB 7  PB7    OC2
#define IN1 0  PB0
#define IN2 1  PB1
#define IN3 2  PB2
#define IN4 3  PB3
*/

#define F_CPU 16000000L
#include <avr/io.h>
#include <util/delay.h>

//함수 미리 선언
void init_adc();
unsigned short read_adc(unsigned char channel);
unsigned short smooth_adc(unsigned char channel);
void init_uart0();
void putchar0(char c);
void puts0(char *ps);

void motor_init()
{	
	// Timer/Counter0 설정 (모터 A)/
	TCCR0 = (1 << WGM00) | (1 << WGM01) | (1 << COM01) | (1 << CS02); // Fast PWM, 비반전, 분주비 64
	// Timer/Counter2 설정 (모터 B)
	TCCR2 = (1 << WGM20) | (1 << WGM21) | (1 << COM21) | (1 << CS21) | (1 << CS20); // Fast PWM, 비반전, 분주비 64
}

//전진,후진 반복
int main(){
	DDRF=0x00; // F port 모두 입력으로 설정
	DDRA=0xff; // A port 모두 출력으로 설정
	DDRB=0xff; // B port 모두 출력으로 설정
	motor_init(); //motor 초기화
	init_adc(); //ADC 초기화
	init_uart0(); // urat 초기화
	PORTA=0x80; // PA7번 HIGH -> 적외선센서의 발광부 ON
	PORTB=0x95; //모터의 정방향 출력 (1001 0101) IN1(PB0) : 1, IN2 : 0, IN3 : 1, IN4 : 0, ENA : 1, ENB : 1
	
	char debug_buffer[50]; // adc 평균값 확인 및 디버깅용 버퍼
	
	while(1)
	{	
		unsigned short value1 = smooth_adc(0);  // ADC 채널 0 읽기
		unsigned short value2 = smooth_adc(1);  // ADC 채널 1 읽기
		
		sprintf(debug_buffer, "오른쪽센서: %d, 왼쪽센서: %d\r\n", value1, value2); // uart통신 하여 읽어들이는 값 확인용
		puts0(debug_buffer); // adc값 출력
		_delay_ms(1);
		//이론상 OCR0와 OCR2가 동일 값이면 같은 출력 전압과 속도는 같아야 하지만 Hardware 및 구조상 속도가 다르게 나와 ocr값을 조정하였음.		
		OCR0=54;   //A motor out1,2 쪽(오른쪽 바퀴) 속도제어 63 3.5v, 54일때 2.75v
		OCR2=50;   //B motor out3,4 쪽(왼쪽 바퀴) 속도제어 50 3.53v
		PORTA=0x80;
		if ((value1 < 300) & (value2 < 300)) 
		{
			OCR0 = 54;
			OCR2 = 50;
			PORTA = 0x84;
		}

		else if ((value1 > 500) & (value2 < 300)) 
		{
			OCR0 = 94;
			OCR2 = 50;
			PORTA = 0x82;
		}

		else if ((value1 < 300) & (value2 > 450))
		{
			OCR0 = 54;
			OCR2 = 90;
			PORTA = 0x81;
		}
		
	}
}
// ADC 초기화 함수
void init_adc() {
	ADMUX = 0x40;  // AVCC(+5V) 기준 전압 사용, ADC0 채널 기본 선택
	ADCSRA = 0x87; // ADC 활성화, 프리스케일러 128분주
}
// ADC 값 읽어오는 함수
unsigned short read_adc(unsigned char channel) {
	ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);  // 원하는 채널 선택
	ADCSRA |= (1 << ADSC);  // ADC 변환 시작
	while (!(ADCSRA & (1 << ADIF))) ;  // 변환 완료 대기
	ADCSRA |= (1 << ADIF);  // ADIF 플래그 클리어
	return ADC;  // 16비트 ADC 결과 반환
}

// ADC 이동 평균 필터
unsigned short smooth_adc(unsigned char channel) {
	unsigned long sum = 0;
	for (int i = 0; i < 10; i++) {
		sum += read_adc(channel);  // ADC 값 10번 읽기
		_delay_ms(1);
	}
	return (unsigned short)(sum / 10);  // 평균값 반환
}

// UART 초기화 함수
void init_uart0() {
	UCSR0B = 0x18;  // RX, TX 활성화
	UCSR0C = 0x06;  // 8비트 데이터, 패리티 없음, 1스톱 비트
	UBRR0H = 0;     // 보레이트 상위 바이트
	UBRR0L = 103;   // 9600 보레이트 설정 (F_CPU = 16MHz)
}
// 문자 출력 함수
void putchar0(char c) {
	while (!(UCSR0A & (1 << UDRE0))) ;  // 송신 준비 완료 대기
	UDR0 = c;  // 문자를 송신
}
// 문자열 출력 함수
void puts0(char *ps) {
	while (*ps != '\0') {
		putchar0(*ps++);  // 문자열의 각 문자를 순차적으로 송신
	}
}
