                  PRESERVE8
                      THUMB

                    AREA   RESET, DATA, READONLY              ; First 32 WORDS is VECTOR TABLE
                    EXPORT    __Vectors
               
__Vectors             DCD      0x20002000                     
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
                    DCD    	0
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
              
                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY
                ; Timer init

                LDR     R0, =0x52000000     ; 타이머 값 load 레지스터 주소
                LDR     R1, =0xFFFFFFFF     ; R1 레지스터에 0xFFFFFFFF 값 설정
                STR     R1, [R0]	    ; 타이머 load 레지스터 주소에 해당하는 메모리에 0xFFFFFFFF 값 store(저장) 

                LDR     R0, =0x52000008     ; 타이머 control 레지스터 주소
                MOVS    R1, #7              ; 0000_0111 = bit[2] prescale(16분주) + bit[1](load value counting) + bit[0](enable)설정하기 위한 값
                STR     R1, [R0]            ; 타이머 control 레지스터 주소에 해당하는 메모리에 0000_0111 값 store(저장)

                LDR     R4, =0x54000000     ; 7segment Digit1 레지스터 주소

                LDR     R5, =0x52000004     ; 현재 타이머 값 레지스터 주소

                LDR     R6, =0x53000000     ; GPIO DATA 레지스터 주소
                LDR     R7, =0x53000004     ; GPIO DIR  레지스터 주소

                MOVS    R3, #0x0F           ; 타이머 현재 값과 마스킹하기 위한 값 저장 
                                            

LOOP    ;C에서 FOR 또는 while 문에 해당
                LDR     R0, [R5]            ; R0에 타이머 현재 레지스터 주소에 해당하는 메모리 값을 load함 
                                            ; ex) 첫번째 loop 0xFFFFFFFF
                                            ;     두번째 loop 0xFFFFFFFE
                                            ;     세번째 loop를 돌면서 down counting ... 무한 루프

                MOVS    R1, R0              ; R0에 저장되어있는 현재 타이머 값을 R1에 저장 또는 복사
		;LSRS	R1, R0, #16         ; quartus용 16bit right shift 한 값 (예시,0x0000FFFF)을 R1에 저장 
                ANDS    R1, R3              ; R1에 저장되어있는 값과 R3에 저장되어있는 값 BIT AND연산 
                                            ; 예시) 0xFFFFFFFF & 0x0000000F = 0x0000000F
                STR     R1, [R4]            ; and 연산된 값을 R4(7segment Digit1 레지스터 주소)가 가르키는 메모리에 저장
                                            ; 예시) 0x0000000F가 저장되며, model sim 파형에서는 seg0 = 0001110(F) 출력
				
		LSRS	R1, R0, #4          ; R0에 저장되어있는 현재 타이머 값을 R1에 4bit right shift 한 값(예시, 0x0FFFFFFF)저장 또는 복사
                ;LSRS   R1, R0, #20         ; quartus용 20bit right shift 한 값 (예시,0x00000FFF)을 R1에 저장 
                ANDS    R1, R3              ; R1에 저장되어있는 값과 R3에 저장되어있는 값 BIT AND연산
                                            ; 예시) 0x0FFFFFFF & 0x0000000F = 0x0000000F
                STR     R1, [R4, #4]        ; and 연산된 값을 R4+4(7segment Digit2 레지스터 주소)가 가르키는 메모리에 저장
                                            ; 예시) 0x0000000F가 저장되며, model sim 파형에서는 seg1 = 0001110(F) 출력
                                            ; modelsim에서 몇클럭 이후에 파형이 출력되는것을 확인할 수 있음(STR 전까지 명령어를 수행하면서 HCLK를 )

		LSRS	R1, R0, #8          ; R0에 저장되어있는 현재 타이머 값을 R1에 8bit right shift 한 값(예시, 0x00FFFFFF)저장 또는 복사
                ;LSRS    R1, R0, #24        ; quartus용 24bit right shift 한 값 (예시,0x000000FF)을 R1에 저장 
                ANDS    R1, R3              ; R1에 저장되어있는 값과 R3에 저장되어있는 값 BIT AND연산
                                            ; 예시) 0x00FFFFFF & 0x0000000F = 0x0000000F
                STR     R1, [R4, #8]        ; and 연산된 값을 R4+8(7segment Digit3 레지스터 주소)가 가르키는 메모리에 저장
                                            ; 예시) 0x0000000F가 저장되며, model sim 파형에서는 seg2 = 0001110(F) 출력

		LSRS	R1, R0, #12         ; R0에 저장되어있는 현재 타이머 값을 R1에 12bit right shift 한 값(예시, 0x000FFFFF)저장 또는 복사
                ;LSRS    R1, R0, #28        ; quartus용 28bit right shift 한 값 (예시,0x0000000F)을 R1에 저장
                ANDS    R1, R3              ; R1에 저장되어있는 값과 R3에 저장되어있는 값 BIT AND연산
                                            ; 예시) 0x000FFFFF & 0x0000000F = 0x0000000F
                STR     R1, [R4, #12]       ; and 연산된 값을 R4+12(7segment Digit4 레지스터 주소)가 가르키는 메모리에 저장
                                            ; 예시) 0x0000000F가 저장되며, model sim 파형에서는 seg3 = 0001110(F) 출력

                MOVS    R2, #0              ; DIR - Read 하기위한 R2에 0값 복사
                STR     R2, [R7]            ; 0값을 R7(GPIO DIR 레지스터 주소)가 가르키는 메모리에 저장(store)
                LDR     R2, [R6]            ; R6(GPIO DATA 레지스터 주소)가 가르키고있는 메모리의 값을 R2레지스터에 저장 (GPIOIN)

                MOVS    R1, #1              ; DIR - Write 하기위한 R1에 1값 복사       
                STR     R1, [R7]            ; 1값을 R7(GPIO DIR 레지스터 주소)가 가르키는 메모리에 저장(store) 
                STR     R2, [R6]            ; R2에 저장되어있는 값을 R6(GPIO DATA레지스터 주소)가 가르키는 메모리에 저장 출력(GPIOOUT)

                B       LOOP

        ALIGN   4
 END 