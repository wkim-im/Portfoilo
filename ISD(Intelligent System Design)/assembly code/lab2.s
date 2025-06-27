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
          
                LDR     R2, =0x51000000
                MOVS    R0, #'S'
                STR     R0, [R2]

                MOVS    R0, #'o'
                STR     R0, [R2]

                MOVS    R0, #'C'
                STR     R0, [R2]

                MOVS    R0, #' '
                STR     R0, [R2]

                MOVS    R0, #'L'
                STR     R0, [R2]

                MOVS    R0, #'A'
                STR     R0, [R2]

                MOVS    R0, #'B'
                STR     R0, [R2]

                ;WaitTx 넣어줘야하긴함
                ;LDR     R1, [R2, #4]      ; UART status 레지스터 가정
                ;TST     R1, #TX_EMPTY
                ;BEQ     WaitTx            ; 비어있을 때까지 대기

                ENDP
                ALIGN   4
	END               
