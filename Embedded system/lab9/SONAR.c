#include <avr/io.h>
#define F_CPU 16000000UL
#include <util/delay.h>
#include <avr/interrupt.h>

#define SOUND_VELOCITY 340UL       // 소리 속도 (m/sec)
#define TRIG 6                      // HC-SR04 Trigger 신호 (출력)
#define ECHO 7                      // HC-SR04 Echo 신호 (입력)
#define INT4 4                      // switch interrupt (bit4, 입력)
#define STATE_0 0                   // 초기 상태
#define STATE_1 1                   // 상태 1
#define STATE_2 2                   // 상태 2

#define NULL 0x00

int distance_1st, distance_2nd, height;        // 1, 2차 거리 측정값과 키 계산값
unsigned char state = STATE_0;                  // state 초기 상태를 STATE_0으로 둔다

// CLCD Command & Data
#define BIT4_LINE2_DOTS8 0x28         // 4 Bit Mode, 2 Lines, 5x8 Dot
#define DISPON_CUROFF_BLKOFF 0x0c      // Display On, Cursor Off, Blink Off
#define DISPOFF_CUROFF_BLKOFF 0x08     // Display Off, Cursor Off, Blink Off
#define INC_NOSHIFT 0x06               // Entry Mode, Cursor Increment, Display No Shift
#define DISPCLR 0x01                   // Display Clear, Address 0 Position, Cursor 0
#define CUR1LINE 0x80                  // Cursor Position Line 1 First
#define CUR2LINE 0xC0                  // Cursor Position Line 2 First
#define CURHOME 0x02                   // Cursor Home

#define E_BIT 0x04                     // Enable Bit #
#define RW_BIT 0x02                    // Read Write Bit #
#define RS_BIT 0x01                    // Register Select Bit #

void CLCD_cmd(char);                 // 명령어 전송 함수
void CLCD_data(char);                // 데이터 Write 함수
void CLCD_puts(char *);              // 문자열 처리 함수
void init_interrupt();               // 인터럽트 초기화
unsigned int read_distance();        // 거리값 읽어오는 함수
void init_CLCD();                    // LCD 초기화 함수
void CLCD_num_display(int);          // CLCD에 숫자 출력 함수

char If_Ready[] = "If on bottom";      // 측정시작 프롬프트(1열)
char Press_Switch[] = "Press Switch";  // 측정시작 프롬프트(2열)
char First[] = "On head";              // 첫번째 측정(머리에서 천장까지)
char Second[] = "Second";              // 두번째 측정(바닥에서 천장까지)
char Height[] = "Your Height : ";      // 높이 계산 및 Display
char CLCD_NUM[] = "000.0";             // 초기값 000.0
char Error[] = "Error !";              // 키가 음수인 경우 에러 표시

int main(void)
{
    DDRE = 0x00;   // SW1 입력 포트
    DDRE = (DDRE | (1<<TRIG)) & ~(1<<ECHO); // TRIG 출력, ECHO 입력
    DDRC = 0xff;   // CLCD PORT(data & command)
    DDRD = 0xff;   // CLCD PORT(control 출력 : RS-bit2, RW-bit3, E-bit4)

    init_interrupt();   // 인터럽트 초기화
    init_CLCD();        // LCD 초기화

    CLCD_cmd(DISPCLR);     // 초기화
    CLCD_cmd(CUR1LINE);    // 첫 번째 라인에
    CLCD_puts(If_Ready);   // Display "If on bottom"(1열)
    CLCD_cmd(CUR2LINE);    // 두 번째 라인에
    CLCD_puts(Press_Switch); // Display "Press_Switch"
    state = STATE_1;       // 상태를 STATE_1로
    while(1)
    {
        // 무한 루프
    }
}

void init_interrupt()
{
    EICRB = 0x02; // INT4 트리거 모드는 하강 에지(Falling Edge)
    EIMSK = 0x10; // INT4 인터럽트 활성화
    SREG |= 0x80; // SREG의 I(Interrupt Enable) 비트(7)를 '1'로 세트
}

void init_CLCD()
{
    _delay_ms(50);             // 전원 인가 후 CLCD 셋업 시간
    PORTC = 0x00;              // 데이터 clear
    CLCD_cmd(BIT4_LINE2_DOTS8);    
    CLCD_cmd(DISPON_CUROFF_BLKOFF);
    CLCD_cmd(INC_NOSHIFT);
    CLCD_cmd(DISPCLR);
    _delay_ms(2);              // 디스플레이 클리어 실행 시간 동안 대기
}

ISR(INT4_vect)
{
    _delay_ms(100); // 스위치 바운스 시간 동안 기다림
    EIFR |= 1<<4;   // 인터럽트 플래그 클리어 (Debouncing)

    if ((PINE & 0x10) == 0x10) return; // 스위치가 ON 상태인지 확인, 아니면 리턴

    if (state == STATE_1)
    {
        CLCD_cmd(DISPCLR);
        CLCD_cmd(CUR1LINE);
        CLCD_puts(First); // Display "On head"(1열)
        CLCD_cmd(CUR2LINE);
        CLCD_puts(Press_Switch); // Display "Press Switch"(2열)
        distance_1st = read_distance(); // 머리에서 천장까지 거리
        state = STATE_2; // 상태 변경
    }
    else
    {
        distance_2nd = read_distance(); // 바닥에서 천장까지 거리
        height = distance_2nd - distance_1st; // 높이 계산
        CLCD_cmd(DISPCLR);
        CLCD_cmd(CUR1LINE);
        CLCD_puts(Height); // Display "Your Height :"
        CLCD_cmd(CUR2LINE);
        if (height < 0)
            CLCD_puts(Error); // 음수면 Error 출력
        else
            CLCD_num_display(height); // 정상일 경우 숫자 출력
    }
}

unsigned int read_distance()
{
    unsigned int distance = 0;
    TCCR1B = 0x03;          // Counter/Timer1 클럭 4us
    PORTE &= ~(1<<TRIG);    // Trig = LOW
    _delay_us(10);
    PORTE |= (1<<TRIG);     // Trig = HIGH
    _delay_us(10);
    PORTE &= ~(1<<TRIG);    // Trig = LOW
    while (!(PINE & (1<<ECHO))); // Echo HIGH 될 때까지 대기
    TCNT1 = 0x0000;         // Timer start
    while (PINE & (1<<ECHO)); // Echo LOW 될 때까지 대기
    TCCR1B = 0x00;          // Timer stop
    distance = (unsigned int)(SOUND_VELOCITY * (TCNT1 * 4 / 2) / 1000); // 거리 계산
    return distance;
}

void CLCD_puts(char *ptr)
{
    while(*ptr != NULL)
        CLCD_data(*ptr++);
}

void CLCD_num_display(int num)
{
    CLCD_NUM[0] = (num/1000)%10 + 0x30;
    CLCD_NUM[1] = (num/100)%10 + 0x30;
    CLCD_NUM[2] = (num/10)%10 + 0x30;
    CLCD_NUM[3] = '.';
    CLCD_NUM[4] = (num%10) + 0x30;
    CLCD_NUM[5] = NULL;
    CLCD_puts(CLCD_NUM);
}

void CLCD_data(char data)
{
    PORTD = 0x04; // RS=1
    _delay_us(1);
    PORTD = 0x14; // Enable High
    PORTC = data & 0xf0; // Upper 4bit
    PORTD = 0x04; // Enable Low
    _delay_us(2);

    PORTD = 0x04;
    _delay_us(1);
    PORTD = 0x14;
    PORTC = (data<<4) & 0xf0; // Lower 4bit
    PORTD = 0x04;
    _delay_ms(1);
}

void CLCD_cmd(char cmd)
{
    PORTD = 0x00; // RS=0
    _delay_us(1);
    PORTD = 0x10; // Enable High
    PORTC = cmd & 0xf0; // Upper 4bit
    _delay_us(2);
    PORTD = 0x00; // Enable Low
    _delay_us(1);

    PORTD = 0x10; // Enable High
    PORTC = (cmd<<4) & 0xf0; // Lower 4bit
    PORTD = 0x00;
    _delay_ms(1);
}
