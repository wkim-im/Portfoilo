#include <avr/io.h>
#include <stdlib.h> // rand() 함수 라이브러리를 포함할 수 있는 정보를 가진 헤더파일 include

#define __DELAY_BACKWARD_COMPATIBLE__ // Atmel Studio7에서 _delay_ms()함수의 인수로 정수가 아닌 인수를 사용하는 경우에 선언 필요
#define F_CPU 16000000UL // 16MHz 클럭 동작
#include <util/delay.h> // _delay_ms 함수 포함 헤더

int main(void)
{
    DDRA=0xff; // PORTA모두를 출력 방향으로 설정
    while (1) // {} 구문 무한 루프 실행
    {
        PORTA=rand()%256; // 0~255 난수 발생 및 LED 표시
        _delay_ms(((rand()%50)+1)*100); // 0.1초~5.0초 까지 1~50 단계 난수 시간 지연 ex) 난수 250 발생 ((250%50)+1)*100 = 100ms == 0.1sec
    }
}