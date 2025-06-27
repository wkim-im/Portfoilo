#include <avr/io.h>
#define __DELAY_BACKWARD_COMPATIBLE__   // Atmel Studio7에서 _delay_ms()함수의 인수로 정수가 아닌 인수를 사용하는 경우에 선언 필요
#define F_CPU 16000000UL                // 16MHz 클럭 동작
#include <util/delay.h>                 // _delay_ms 함수 포함 헤더

int main() {
    DDRA = 0xff;             // PORTA 모듈을 출력 방향으로 설정
    PORTA = 0x01;            // PORTA 0000 0001 led 하나 점등

    while (1) {              // 무한 루프 실행
        // 왼쪽으로 이동
        for (int i = 0; i < 7; i++) { // 1칸부터 6칸까지 총 7번 실행
            _delay_ms(500);           // 0.5초 딜레이
            PORTA = (PORTA << 1);     // left shift 연산 (0000 0010, 0000 0100, ...)
        }

        // 오른쪽으로 이동
        for (int i = 0; i < 7; i++) { // 1칸부터 6칸까지 총 7번 실행
            _delay_ms(500);           // 0.5초 딜레이
            PORTA = (PORTA >> 1);     // right shift 연산
        }
    }
}