`timescale 10ns/1ps
module dff_tb;
    wire q;  // 출력신호
    reg clk; // clk신호
    reg rst; // reset신호
    reg d;   // 입력신호

    dff dff1(.q(q),.clk(clk),.rst(rst),.d(d)); // instantiation

    always  #1 clk=~clk; // 1단위 시간마다, clk 신호 반전

    initial 
    begin
        rst=1'b0; //초기 reset하기위해, rst을 0으로 초기화
        d=1'b0;   //초기 입력d, 0으로 초기화
        clk=1'b0; //초기 clk을 0으로 초기화

        #4 rst=1'b1; // 4unit time이후, rst을 1로 설정, q가 0으로 리셋안됨
        #4 rst=1'b0; d=1'b1; // 4unit time 이후, q를 리셋 하며 입력을 1로 설정
        #4 rst=1'b1; // 4unit time 이후, rst 1로 설정하여 다시 리셋이 안되도록 함
        #5 $finish; // 5unit time 이후, 시뮬레이션 종료
        end
endmodule

