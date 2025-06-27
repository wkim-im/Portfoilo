#include <avr/io.h>
#define __DELAY_BACKWARD_COMPATIBLE__ // Atmel Studio7에서 _delay_ms()함수의 인수로 정수가 아닌 인수를 사용하는 경우에 선언 필요
#define F_CPU 16000000UL // 16MHz 클럭 동작
#include <util/delay.h> // _delay_ms 함수 포함 헤더

int main(){
    DDRA = 0xff; // PORTA모두를 출력 방향으로 설정
    PORTA = 0x01; // PORTA 0000 0001 led 하나 점등
    while(1){ // 무한 루프 실행
        for(int i = 0; i < 7; i++) // 1칸부터 6칸까지 총 7번 실행
        {
            _delay_ms(500); // 0.5초 딜레이 이후 다음 line 코드 실행
            PORTA=(PORTA << 1); // 초기 설정값 0000 0001에서 left shift 연산 실행 0000 0010
            PORTA += 1; // ex) 0000 0010 비트에 1더하면 0000 0011
        }
        for(int i = 0; i < 7; i++) // 1칸부터 6칸까지 총 7번 실행
        {
            _delay_ms(500); // 0.5초 딜레이 이후 다음 line 코드 실행
            PORTA=(PORTA >> 1); // 첫번째 for문 종료 후 PORTA의 값은 0xff 또는 1111 1111 right shift 연산 실행 0111 1111
        }
    }
}