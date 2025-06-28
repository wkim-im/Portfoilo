#include <avr/io.h>
#define F_CPU 16000000UL   // 시스템 클럭 주파수 16MHz
#include <util/delay.h>

// UART0 초기화 함수
void init_uart0()
{
    UCSRB = 0x18; // RX, TX 활성화
    UCSRC = 0x06; // 8비트 데이터, 패리티 없음, 1스탑 비트
    UBRRH = 0;    // 보레이트 상위 바이트
    UBRRL = 103;  // 9600 보레이트 설정 (F_CPU = 16MHz)
}

// 1문자 송신 함수
void putchar0(char c)
{
    while (!(UCSRA & (1 << UDRE))) ; // 송신 준비 완료 대기
    UDR0 = c; // 문자를 송신
}

// 1문자 수신 함수
char getchar0()
{
    while (!(UCSRA & (1 << RXC))) ; // 수신 완료 대기
    return UDR0; // 수신된 문자 반환
}

// 문자열 송신 함수
void puts0(char *ps)
{
    while (*ps != '\0')
    {
        putchar0(*ps++); // 포인터가 가르키는 문자열 주소가 1씩 증가하며 한 문자씩 송신
    }
}

// 정수 값을 문자열로 변환하여 송신
void trans_int(int num)
{
    char trans_ary[10];
    itoa(num, trans_ary, 10); // 정수를 문자열로 변환
    puts0(trans_ary); // 문자열 출력
}

// 구구단 계산 출력 함수
void gugudan_cal(int num)
{
    trans_int(num);
    char str[] = " 구구단 : ";
    puts0(str); // 구구단 출력 시작 문자열 송신
    puts0("\r\n");

    for (int i = 1; i <= 9; i++)
    {
        trans_int(num); // 단
        putchar0(' ');  // 공백
        putchar0('X');  // 곱셈 기호
        putchar0(' ');  // 공백
        trans_int(i);   // 곱하는 수
        putchar0(' ');  // 공백
        putchar0('=');  // 등호
        putchar0(' ');  // 공백
        trans_int(num * i); // 결과
        puts0("\r\n");
    }
}

int main(void)
{
    char value;

    init_uart0(); // UART 초기화

    while (1)
    {
        puts0("숫자 입력 : ");
        // puts0("\r\n");
        value = getchar0(); // 입력
        putchar0(value);    // 에코 출력
        puts0("\r\n");

        if (value >= '1' && value <= '9') // '1' ~ '9' 문자 처리
        {
            int num = value - '0'; // 문자 -> 정수 변환
            gugudan_cal(num); // 구구단 출력
        }
        else
        {
            puts0("숫자만 입력 가능.\r\n");
        }

        _delay_ms(500);
    }
}
