
#define F_CPU 16000000UL // CPU 클록 값 = 16 MHz
#define F_SCK 40000UL // SCK 클록 값 = 40 KHz
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#define ON 1 // 버저 ON
#define OFF 0 // 버저 OFF
#define DO_DATA 17 // ‘도’ 음을 내기 위한 TCNT0 값
volatile int state = OFF; //초기 상태를 OFF
#define LM75A_ADDR 0x98 // 0b10011000, 원래 7비트를 1비트 left shift한 값
#define LM75A_TEMP_REG 0

volatile int value_int, buzzer =OFF;
void init_twi_port();
int read_twi_2byte_nopreset(char reg);
void display_FND(int value);

ISR(TIMER0_OVF_vect) // Timer/Counter0 오버플로우 인터럽트 서비스 루틴
{
	TCNT0 = DO_DATA; // TCNT0 초기화 (DO 음을 만들기 위한)
	if (buzzer == ON)
	{
		if (state == OFF)
		{
			PORTB |= 1 << 4; // 버저 포트 ON
			state = ON;
		}
		else
		{
			PORTB &= ~(1 << 4); // 버저 포트 OFF
			state = OFF;
		}
	}
	
}

int main()
{
	DDRB |= 0x10; // 버저 연결 포트(PB4) 출력 설정
	TCCR0 = 0x03; // 프리스케일러 32분주
	TIMSK = 0x01; // 오버플로우 인터럽트 활성화, TOIE0 비트 세트
	sei(); // 전역 인터럽트 활성화
	TCNT0 = DO_DATA;
	int i;
	int temperature;
	init_twi_port(); // TWI 및 포트 초기화
	DDRB |= 0x10;
	while (1) // 온도값 읽어 FND 디스플레이
	{
		for (i=0; i<30; i++)
		{
			if (i == 0)			// 억세스시간(300ms) 동안 기다리기
								// 위하여 30번에 1번만 실제로 억세스함
			temperature = read_twi_2byte_nopreset(LM75A_TEMP_REG);
			display_FND(temperature); // 1번 디스플레이에 약 10ms 소요
			if (value_int >=23 || value_int <18)		//23도 이상, 18도 미만 시 버저가 작동하도록,
			buzzer = ON;		//조건에 맞다면 buzzer가 인터럽스 서비스 루틴을 통해 작동
			else
			buzzer = OFF;		//아니면 OFF
		}
		
	}
}
void init_twi_port()
{
	DDRC = 0xff; DDRG = 0xff; // FND 출력 세팅
	TWSR = TWSR & 0xfc; // Prescaler 값 = 00 (1배)
	TWBR = (F_CPU/F_SCK - 16) / 2; // 공식 참조, bit rate 설정
}
int read_twi_2byte_nopreset(char reg)
{
	char high_byte, low_byte;
	TWCR = (1 << TWINT) | (1<<TWSTA) | (1<<TWEN);			// START 전송
	while (((TWCR & (1 << TWINT)) == 0x00) || (TWSR & 0xf8) != 0x08) ;
															// START 상태 검사, 이후 ACK 및 상태검사
	TWDR = LM75A_ADDR | 0;				// SLA+W 준비, W=0
	TWCR = (1 << TWINT) | (1 << TWEN);	// SLA+W 전송
	while (((TWCR & (1 << TWINT)) == 0x00) || (TWSR & 0xf8) != 0x18) ;
	TWDR = reg;							// LM75A Reg 값 준비
	TWCR = (1 << TWINT) | (1 << TWEN); // LM75A Reg 값 전송
	while (((TWCR & (1 << TWINT)) == 0x00) || (TWSR & 0xf8) != 0x28) ;
	TWCR = (1 << TWINT) | (1<<TWSTA) | (1<<TWEN); // RESTART 전송
	while (((TWCR & (1 << TWINT)) == 0x00) || (TWSR & 0xf8) != 0x10) ;
	//RESTART 상태 검사, 이후 ACK,NO_ACK 상태 검사
	TWDR = LM75A_ADDR | 1; // SLA+R 준비, R=1
	TWCR = (1 << TWINT) | (1 << TWEN); // SLA+R 전송
	while (((TWCR & (1 << TWINT)) == 0x00) || (TWSR & 0xf8) != 0x40) ;
	TWCR = (1 << TWINT) | (1 << TWEN | 1 << TWEA); // 1st DATA 준비
	while(((TWCR & (1 << TWINT)) == 0x00) || (TWSR & 0xf8) != 0x50) ;
	high_byte = TWDR; // 1st DATA 수신
	TWCR = (1 << TWINT) | (1 << TWEN); // 2nd DATA 준비
	while(((TWCR & (1 << TWINT)) == 0x00) || (TWSR & 0xf8) != 0x58) ;
	low_byte = TWDR; // 2nd DATA 수신
	TWCR = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN); // STOP 전송
	while ((TWCR & (1 << TWSTO))) ; // STOP 확인
	return((high_byte<<8) | low_byte); // 수신 DATA 리턴
}
void display_FND(int value)
{
	char digit[12] = {0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d,
	0x7c, 0x07, 0x7f, 0x67, 0x00, 0x40 };
	char fnd_sel[4] = {0x01, 0x02, 0x04, 0x08};
	int value_deci, num[4], i;
	if ((value & 0x8000) != 0x8000) // Sign 비트 체크
	num[3] = 10; // 양수인 경우는 디스플레이 없음
	else
	{
		num[3] = 11; // 음수인 경우는 ‘-’ 디스플레이
		value = (~value)+1; // 2’s Compliment 값을 취함
	}
	value_int = (value & 0x7f00) >> 8; // High Byte bit6~0 값 (정수 값)
	value_deci = (value & 0x0080); // Low Byte bit7 값 (소수 첫째자리 값)
	num[2] = (value_int / 10) % 10;
	num[1] = value_int % 10;
	num[0] = (value_deci == 0x80) ? 5 : 0; // 소수 첫째자리가 1이면 0.5에 해당하므로
	// 5를 디스플레이
	for(i=0; i<4; i++)
	{
		PORTC = digit[num[i]];
		PORTG = fnd_sel[i];
		if (i==1)
		PORTC |= 0x80; // 왼쪽에서 3번째 FND에는 소수점(.)을 찍음
		if (i%2)
		_delay_ms(2); // 2번은 2ms 지연
		else
		_delay_ms(3); // 2번은 3ms 지연, 총 10ms 지연
	}
}

