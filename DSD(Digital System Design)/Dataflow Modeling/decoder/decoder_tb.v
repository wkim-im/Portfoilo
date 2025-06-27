`timescale 10ns/1ps

module decoder_tb;

    reg EN;
    reg [1:0] IN;
    wire [3:0] D;

    // DUT (Device Under Test)
    decoder uut (
        .EN(EN),
        .IN(IN),
        .OUT(D)
    );

    initial begin

        // 초기값
        EN = 0; IN = 2'b00;
        
        // EN=0 일 때 어떤 IN이든 OUT은 0000
        #10 IN = 2'b01;
        #10 IN = 2'b10;
        #10 IN = 2'b11;

        // EN=1 일 때 IN에 따라 1-hot 출력
        #10 EN = 1; IN = 2'b00;
        #10 IN = 2'b01;
        #10 IN = 2'b10; 
        #10 IN = 2'b11;

        // 시뮬 종료
        #10 $finish;
    end

endmodule
