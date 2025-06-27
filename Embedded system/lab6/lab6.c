#include <avr/io.h>
#define F_CPU 16000000UL
#include <util/delay.h>

// 조도 값 기준
#define CDS_10   341   // 조도센서 값이 10 lux일 때 ADC 값 = 10/(20+10) * 1024 (CdS = 20KΩ)
#define CDS_20   450   // 조도센서 값이 20 lux일 때 가상 값 (임의로 가정)
#define CDS_50   550   // 조도센서 값이 50 lux일 때 가상 값 (임의로 가정)
#define CDS_80   650   // 조도센서 값이 80 lux일 때 가상 값 (임의로 가정)
#define CDS_100  703   // 조도센서 값이 100 lux일 때 ADC 값 = 10/(4+10) * 1024 (CdS = 4KΩ)

#define day   1
#define night 0

volatile int state = night; // 상태 플래그
// 미리 선언하면 실제 프로그램은 main() 뒤에 작성 가능
void init_adc(); // ADC 초기화
unsigned short read_adc(); // ADC 값 읽기
void show_adc_led(unsigned short data); // 값에 따라 LED 표시

int main()
{
    unsigned short value;

    DDRA = 0xff; // LED 포트 출력 모드
    DDRF = 0x00; // ADC 포트 입력
    init_adc();  // ADC 초기화

    while(1)
    {
        value = read_adc(); // AD 변환 시작 및 결과 읽어오기 함수
        show_adc_led(value); // 값을 비교하여 LED 디스플레이 함수
    }
}

void init_adc()
{
    ADMUX = 0x40;
    // REFS(1:0) = 01 : AVCC(+5V) 기준 전압 사용
    // ADLAR = 0 : 오른쪽 정렬
    // MUX(3:0) = 0000 : ADC0 사용, 단극 입력

    ADCSRA = 0x87;
    // ADEN = 1 : ADC Enable
    // ADSC = 0 : single conversion (한번만 변환) 모드
    // ADPS(2:0) = 111 : 프리스케일러 128분주, 0.125MHz 주기
}

unsigned short read_adc()
{
    unsigned char adc_low, adc_high;
    unsigned short value;
    ADCSRA |= 0x40; // ADC start conversion, ADSC(비트5) = 1
    while ((ADCSRA & 0x10) != 0x10);
    // ADC 변환 완료 대기 (ADIF) (비트4)
    adc_low = ADCL;  // 변환된 Low 값 읽어오기
    adc_high = ADCH; // 변환된 High 값 읽어오기
    value = (adc_high << 8) | adc_low; // value = High 및 Low 연결 16비트 값
    return value;
}

void show_adc_led(unsigned short value)
{
    int lights_on = 0; // LED 상태 플래그 (0: 꺼짐, 1: 켜짐)

    if(state == night) { // 상태가 night일 때
        if(value <= CDS_10) { // 조도가 10 lux 이하이면 모든 LED 켜짐
            lights_on = 1;
            PORTA = 0xff; // LED 모두 ON
            state = day; // 상태를 day로 변경
        }
        else {
            PORTA = 0x00; // LED 모두 OFF
        }
    }
    else if(lights_on == 0 && value >= CDS_100) { // LED가 꺼져 있고, 조도가 100 lux 이상일 때
        PORTA = 0x00; // 모든 LED 끄기
        state = night; // 상태 night으로 변경
    }
    else { // 상태가 day라면 값에 따라 LED 개수 조절
        if(value <= CDS_10) PORTA = 0xff; // LED 8개 ON
        else if(value <= CDS_20) PORTA = 0x3f; // LED 6개 ON
        else if(value <= CDS_50) PORTA = 0x0f; // LED 4개 ON
        else if(value <= CDS_80) PORTA = 0x03; // LED 2개 ON
        else if(value <= CDS_100) {
            PORTA = 0x00; // LED 0개 ON
            state = night; // 상태 night으로 변경
        }
    }
}
