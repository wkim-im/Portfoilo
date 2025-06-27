                  PRESERVE8
                      THUMB
                    AREA   |.data|, DATA, READWRITE, ALIGN=4
SEC                 DCD    0

                    AREA   |.text|, CODE, READONLY

                    AREA   RESET, DATA, READONLY              ; First 32 WORDS is VECTOR TABLE
                    EXPORT    __Vectors
               
__Vectors           DCD      0x20002000                     ;0x000001FC sp가 이게 맞아? 원래는 0x20002000
                    DCD      Reset_Handler
                    DCD      0           
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    
                    ; External Interrupts
                                      
                    DCD      Timer_Handler
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0
                    DCD      0

	    AREA	|.text|, CODE, READONLY              
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY

                ; set Interrupts

                LDR     R1, =0xE000E400         ;interrupt priority register 
                LDR     R0, =0x00000000         ;0x00 우선순위 high로 설정
                STR     R0, [R1]                ;우선순위 0x00데이터를 R1이 가르키는 주소(interrupt #0)에 저장
                                                ;0xE000E400에는 MSB부터 IRQ3, IRQ2, IRQ1, IRQ0 가 있으며 
                                                ;R0에 저장되어있는 0x00(0000_0000)으로 4개의 interrupt의 우선순위가 00으로 설정됨

                LDR     R0, =0xE000E100         ;interrupt set enable register
                LDR     R1, =0x00000001         ;#0번째의 인터럽트 enable 하기위한 값 load  
                STR     R1, [R0]                ;해당 값을 R0가 가르키는 주소에 저장
                
                ;primask : core가 인터럽트를 받을 수 있게 설정
                MOVS    R0, #0x0                 
                MSR     PRIMASK, R0             ;Clear PRIMASK register

                ; global register setting, 리셋 할때마다 SEC값이 0으로 초기화됨
                LDR     R1, =SEC
                MOVS    R0, #0
                STR     R0, [R1]

                ; segment Reset

                LDR     R1, =0x54000000
                MOVS    R0, #0
                STR     R0, [R1]
                STR     R0, [R1, #4]
                STR     R0, [R1, #8]                
                STR     R0, [R1, #12]

                B       Main

                ENDP

Main            ;main은 한번만 도는건가? 아님 계속 도는건가? -> 계속 돔
                ;configure the Timer
                ;1. set load register with 0x02FA080(0000_0010_1111_1010_0000_1000_0000) 대략 128+8000+32000+64000+128000+256000+512000+2000000
                LDR     R0, =0x52000000     ; 타이머 값 load 레지스터 주소
                LDR     R1, =0x2FAF080      ; R1 레지스터에 0x2FAF080 (50,000,000)값 설정 20ns * 50,000,000 = 1s
                STR     R1, [R0]	    ; 타이머 load 레지스터 주소에 해당하는 메모리에 0x02FA080 값 store(저장) 

                ;2. set control register with HCLK, load value conuting mode, enable
                LDR     R0, =0x52000008     ; 타이머 control 레지스터 주소
                MOVS    R1, #3              ; 0000_0011 = bit[2] HCLK + bit[1](load value counting) + bit[0](enable)설정하기 위한 값
                STR     R1, [R0]            ; 타이머 control 레지스터 주소에 해당하는 메모리에 0000_0011 값 store(저장)

Wait

                B       Wait

Timer_Handler   PROC  ;timer_load register에 저장되어있는 값이 한클럭당 -1 씩 감소하면서 32'h0000_0000이 되면 Timer_handler(timer_irq)가 동작함
                EXPORT  Timer_Handler
                ;push context onto current stack
                PUSH    {R0,R1,R2,R3,LR}

                ;start executing code of interrrupt Handler

                ;1. clear timer irq 해줘야 다시 interrupt 수행가능
                LDR     R0, =0x5200000C     ;interrupt clear register R0에 저장
                LDR     R1, =0x00000001     ;#0 인터럽트를 클리어 하기위한 "1" R1에 데이터 저장
                STR     R1, [R0]            ;R0가 가르키는 주소 clear register에 0x00000001 저장하여 clear

                ;2. add user-defined interrupt handling logic here
                
                MOVS    R1, #1              ; 더할값 1 저장
                MOVS    R2, #0x0F           ; 마스킹할 값 저장
                LDR     R5, =0x00002710     ; #10000 
                LDR     R4, =SEC            ; R4에 SEC주소 가져옴
                LDR     R3,[R4]             ; 값 가져오기
                ADDS    R3, R3, #1          ; 1씩증가
                CMP     R3, R5              ; segment out of range 비교문
                BNE     store_sec           ; segment display 분기점  z=0일때 동작, z=1(R3, R5가 같을때 업데이트됨) 일땐 동작안함.
                MOVS    R3, #0              ; segment 값이 out of range 라면 카운트 초기화
                STR	    R3, [R4]			      ; SEC 초기화
	
store_sec      
                STR     R3, [R4]            ; 다시 저장해야지 위에서 불러옴
                LDR     R0, =0x54000000     ; segment 주소 레지스터
                MOV     R6, R3              ; R6<-R3(SEC count 값 저장)
                MOVS    R2, #10             ; 나눗셈용


                ; 1000의 자리
                MOVS    R7, #0              ; R7 초기값
loop_1000:
                LDR     R5, =0x000003E8
                CMP     R6, R5          ; R6>1000 큰지 판단
                BLT     done_1000       ; 만약 R6<1000이면 done_1000: 분기점으로 넘어감
                SUBS    R6, R6, R5      ; 크다면, R6에 저장된값에서 1000을 빼고 
                ADDS    R7, R7, #1      ; R7에 +1 씩하면서 1000의 자리를 표현
																					  ; ex) 2000이라면 -1000 을 2번 하니 2›가 display
                B       loop_1000       ; 분기점
done_1000
                STR     R7, [R0, #12]       ; seg3(천의 자리)에 저장

                ; 100의 자리
                MOVS    R7, #0              ; 100의자릿수를 나타내기위해 다시 초기화 이후 위 코드처럼 반복
loop_100
                CMP     R6, #100
                BLT     done_100
                SUBS    R6, R6, #100
                ADDS    R7, R7, #1
                B       loop_100
done_100
                STR     R7, [R0, #8]      ; seg2

                ; 10의 자리
                MOVS    R7, #0
loop_10
                CMP     R6, #10
                BLT     done_10
                SUBS    R6, R6, #10
                ADDS    R7, R7, #1
                B       loop_10
done_10
                STR     R7, [R0, #4]      ; seg1

                ; 1의 자리 (남은 R6 그대로)
                STR     R6, [R0]          ; seg0
            
                ;pop the context from the stack
                POP     {R0,R1,R2,R3,PC}
                ENDP

                ALIGN   4       ;align to a word boundary

END
                