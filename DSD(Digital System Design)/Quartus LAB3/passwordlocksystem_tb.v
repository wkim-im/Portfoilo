`timescale 10ns / 1ns

module passwordlocksystem_tb;
    reg clk_50 = 0;
    reg [3:0] USERIN = 0;
    reg [3:0] KEY = 4'b1111;
    reg rst = 1;

    wire LEDR, LEDG;
    wire [6:0] H0, H1, H2, H3;

    // DUT
    passwordlocksystem dut (
        .clk_50(clk_50),
        .USERIN(USERIN),
        .KEY(KEY),
        .rst(rst),
        .LEDR(LEDR),
        .LEDG(LEDG),
        .H0(H0), .H1(H1), .H2(H2), .H3(H3)
    );

    // 50MHz -> 20ns
    always #1 clk_50 = ~clk_50;

    // KEY press (active-low)
    task press_key(input integer idx);
    begin
        KEY[idx] = 0;
        #300;           // 눌렀다 0.3초 유지
        KEY[idx] = 1;
        #100;           // 뗀 후 기다림
    end
    endtask

    // 입력 시퀀스
    task input_password(input [3:0] d3, input [3:0] d2, input [3:0] d1, input [3:0] d0);
    begin
        USERIN = d3; #300; press_key(3); // 첫 자리
        USERIN = d2; #300; press_key(2); // 둘째 자리
        USERIN = d1; #300; press_key(1); // 셋째 자리
        USERIN = d0; #300; press_key(0); // 넷째 자리
    end
    endtask

    // 메인 시퀀스
    initial begin
        $display("Start simulation");

        // 초기화
        #10; rst = 0;

        // 정답: 01AF
        USERIN = 4'h0; #300;  // IDLE 탈출 조건 충족
        input_password(4'h0, 4'h1, 4'hA, 4'hF);

        // 성공 메시지 출력 대기
        #1000;

        // 리셋
        rst = 1; #10; rst = 0;

        // 오답: 1234
        USERIN = 4'h1; #300;  // IDLE 탈출
        input_password(4'h1, 4'h2, 4'h3, 4'h4);

        // 실패 메시지 출력 대기
        #100000000;

        $display("End simulation");
        $stop;
    end
endmodule
