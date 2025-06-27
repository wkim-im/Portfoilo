#include <avr/io.h>
#define F_CPU 16000000UL
#include <util/delay.h>

#define NULL 0x00

// CLCD Command & Data
#define BIT4_LINE2_DOTS8 0x28
#define DISPON_CUROFF_BLKOFF 0x0c
#define DISPOFF_CUROFF_BLKOFF 0x08
#define INC_NOSHIFT 0x06
#define DISPCLR 0x01
#define CUR1LINE 0x80
#define CUR2LINE 0xC0
#define CURHOME 0x02

#define E_BIT 0x04
#define RW_BIT 0x02
#define RS_BIT 0x01

void CLCD_cmd(char);
void CLCD_data(char);
void CLCD_puts(char *);
char LINE1[] = "Illumination"; // 1st Line Message

void init_adc();
unsigned short read_adc();
void trans_int(int num)
{
    char trans_ary[20];
    itoa(num, trans_ary, 10);
    CLCD_puts(trans_ary);
    CLCD_puts(" lux ");
}

int main(void)
{
    unsigned short value;

    DDRF = 0x00; // ADC 포트 입력
    DDRC = 0xff; // PORTC : command/data port
    DDRD = 0xff; // PORTD : control port

    init_adc(); // ADC 초기화

    CLCD_cmd(BIT4_LINE2_DOTS8);
    CLCD_cmd(DISPON_CUROFF_BLKOFF);
    CLCD_cmd(INC_NOSHIFT);
    CLCD_cmd(DISPCLR);
    _delay_ms(2);
    CLCD_cmd(CUR1LINE);
    CLCD_puts(LINE1); // Line 1 메시지 출력

    while(1)
    {
        value = read_adc(); // AD 변환 시작 및 결과 읽기
        int luxval = value * 0.05; 
        // iphone 플래시가 50 lux 정도라고함, 플래쉬를 근접해서 조사하였을때 최대 adc값이 근사 1000정도 나옴
        // -> 50 lux 만들기 위해 0.05 곱. 

        CLCD_cmd(CUR2LINE); // Cursor를 Line 2로 이동
        trans_int(luxval); // 조도값(정수)을 문자로 변환하여 CLCD에 표시
        _delay_ms(1000); // 1초 대기
    }
}

void CLCD_puts(char *ptr)
{
    while(*ptr != NULL)
        CLCD_data(*ptr++);
}

void CLCD_data(char data)
{
    PORTD = 0x04; // 00000100, E=0, R/W=0, RS=1
    _delay_us(1);
    PORTD = 0x06; // E=1
    PORTC = data & 0xf0; // upper 4bit
    PORTD = 0x04; // E=0
    _delay_us(2);

    PORTD = 0x04;
    _delay_us(1);
    PORTD = 0x06;
    PORTC = (data << 4) & 0xf0; // lower 4bit
    PORTD = 0x04;
    _delay_ms(1);
}

void CLCD_cmd(char cmd)
{
    PORTD = 0x00; // 00000000, E=0, R/W=0, RS=0
    _delay_us(1);
    PORTD = 0x02; // E=1
    PORTC = cmd & 0xf0; // upper 4bit
    _delay_us(1);
    PORTD = 0x00; // E=0
    _delay_us(2);

    PORTD = 0x00;
    _delay_us(1);
    PORTD = 0x02;
    PORTC = (cmd << 4) & 0xf0; // lower 4bit
    PORTD = 0x00;
    _delay_ms(1);
}

void init_adc()
{
    ADMUX = 0x40;
    ADCSRA = 0x87;
}

unsigned short read_adc()
{
    unsigned char adc_low, adc_high;
    unsigned short value;
    ADCSRA |= 0x40;
    while ((ADCSRA & 0x10) != 0x10);
    adc_low = ADCL;
    adc_high = ADCH;
    value = (adc_high << 8) | adc_low;
    return value;
}
