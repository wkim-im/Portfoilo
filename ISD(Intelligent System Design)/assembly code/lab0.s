                  PRESERVE8
                      THUMB
                    AREA   |.data|, DATA, READWRITE, ALIGN=4
						
SEC                 DCD    0

                    AREA   |.text|, CODE, READONLY

                    AREA   RESET, DATA, READONLY              ; First 32 WORDS is VECTOR TABLE
                    EXPORT    __Vectors
               
__Vectors           DCD      0x20002000                     
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
                    DCD      0
              
				AREA	|.text|, CODE, READONLY
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY

                MOVS    R0, #1 ;R0 레지스터에 1 바로 저장 ,이때 255를 넘는 숫자는 바로 복사? 저장은 못함
                MOVS    R1, #2 ;R1 레지스터에 2 바로 저장 ,이때 255를 넘는 숫자는 바로 복사? 저장은 못함
                MOVS    R2, #3 ;R2 레지스터에 3 바로 저장 ,이때 255를 넘는 숫자는 바로 복사? 저장은 못함
                MOVS    R3, #4 ;R3 레지스터에 4 바로 저장 ,이때 255를 넘는 숫자는 바로 복사? 저장은 못함
                MOVS    R4, #5 ;R4 레지스터에 5 바로 저장 ,이때 255를 넘는 숫자는 바로 복사? 저장은 못함
                MOVS    R5, #6 ;R5 레지스터에 6 바로 저장 ,이때 255를 넘는 숫자는 바로 복사? 저장은 못함
                MOVS    R6, #7 ;R6 레지스터에 7 바로 저장 ,이때 255를 넘는 숫자는 바로 복사? 저장은 못함
                MOVS    R7, #8 ;R7 레지스터에 8 바로 저장 ,이때 255를 넘는 숫자는 바로 복사? 저장은 못함

                SUB     SP, SP, #12 ;기존 스택포인터 값 0x20002000 - 12 = 0x20001FF4 을 다시 sp에 저장 
                STR     R5, [SP,#8] ;R5에 저장되어있는값 6을 0x20001ff4 + 8 이 가르키고있는 메모리 주소에 에다가 저장 
                STR     R4, [SP,#4] ;R4에 저장되어있는값 5을 0x20001ff4 + 4 이 가르키고있는 메모리 주소에 에다가 저장
                STR     R6, [SP,#0] ;R6에 저장되어있는값 7을 0x20001ff4 + 0 이 가르키고있는 메모리 주소에 에다가 저장

                ADDS    R4, R0, R1 ; R4에 R0+R1(1+2) 저장 =  3이저장됨
                ADDS    R5, R2, R3 ; R5에 R2+R3(3+4) 저장 =  7이 저장됨
                SUBS    R6, R4, R5 ; R6 = R4 - R5 = -4 저장

                ADDS    R7, R6, #0 ; R7 = R6 + 0 = -4 저장
                LDR     R5, [SP,#8] ;R5에 저장되어있는값 7을 0x20001ff4 + 8 이 가르키고있는 메모리 주소에 에다가 저장
                LDR     R4, [SP,#4] ;R4에 저장되어있는값 3을 0x20001ff4 + 4 이 가르키고있는 메모리 주소에 에다가 저장
                LDR     R6, [SP,#0] ;R6에 저장되어있는값 -4을 0x20001ff4 + 0 이 가르키고있는 메모리 주소에 에다가 저장
                ADDS    SP, SP, #12 ; 기존 스택 포인터로 복귀
                BX      LR ; 기존 함수로 복귀
                ENDP

                ALIGN   4
	END               
