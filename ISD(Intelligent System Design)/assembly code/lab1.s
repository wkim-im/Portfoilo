;------------------------------------------------------------------------------------------------------
; A Simple SoC  Application
; Toggle LEDs at a given frequency. 
;------------------------------------------------------------------------------------------------------



; Vector Table Mapped to Address 0 at Reset
; Reset_Handler부터 시작해서 LED를 0x55(홀수), 0xAA(짝수) 교차로 출력하여 점등하는 패턴을 구현

						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY	  			; First 32 WORDS is VECTOR TABLE
        				EXPORT 	__Vectors	;vector talbe 관련련
					    ;32개의 인터럽트 핸들러 주소, 부팅하면서 32개의 word(128byte)를 읽어옴 == 4byte(32bit)x32
						;16K Internal Memory
__Vectors		    	DCD		0x20000200		;sp 초기값 코어, 부팅시 SP=*(0x00000000)(code.hex의 4줄을 리틀엔디안으로 읽어옴)
        				DCD		Reset_Handler	;리셋 핸들러 주소, 부팅시 첫 실행지점
        				DCD		0  			
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				
        				;16K External Interrupts
						        				
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0

                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY
;code.hex파일을 보면 4byte X32 = 128line까지 인터럽트, 129line부터 아래의 명령어가 존재
;reset후 처음 실행되는 코드, Again 라벨 시작점
AGAIN		   	LDR 	R1, =0x50000000				;R1에 LED 메모리 주소 로드(LED slave 주소, Write to LED with value 0x55)
				LDR		R0, =0x55					;R0에 LED를 키기위한 값 0101_0101 값 로드
				STR		R0, [R1]  					;R0의 데이터를 R1이 가르키는 주소에 저장(store), 레지스터 -> 메모리에 저장



				LDR		R0, =0x10				    ;0x10 = 16 반복횟수 설정
Loop			SUBS	R0,R0,#1					;R0=R0-1 수행
				BNE Loop1							;R0가 0이 아니면 다시 R0=R0-1수행. 총 16회 반복하며 Delay 생성

				LDR 	R1, =0x50000000				;R1에 LED 메모리 주소 로드(LED slave 주소, Write to LED with value 0xAA)
				LDR		R0, =0xAA				 	;R0에 LED를 키기위한 값 1010_1010 값 로드
				STR		R0, [R1]					;R0의 데이터를 R1이 가르키는 주소에 저장(store), 레지스터 -> 메모리에 저장

				LDR		R0, =0x10					;0x10 = 16 반복횟수 설정
Loop1			SUBS	R0,R0,#1					;R0=R0-1 수행
				BNE Loop1							;R0가 0이 아니면 다시 R0=R0-1수행. 총 16회 반복하며 Delay 생성

				B AGAIN 							;Again 라벨로 점프
				ENDP


				ALIGN 		4						; Align to a word boundary, 다음에 오는 데이터나 명령어를 4byte 주소에 맞춰 정렬

		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
; 16회 루프 동안 홀수번째 led가 켜지고, 다음 16회 루프 동안 짝수번째 led 켜짐. 이후, 반복 
