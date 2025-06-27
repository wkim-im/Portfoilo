`timescale 1ns/1ns
`include "operation.v"
module operation_tb;

    // DUT 인스턴스 생성을 위한 reg, wire 정의
    reg [15:0] A, B;
    wire [15:0] AB_AND, AB_OR, AB_XOR;

    // DUT 인스턴스 생성
    operation uut (
        .A(A),
        .B(B),
        .AB_AND(AB_AND),
        .AB_OR(AB_OR),
        .AB_XOR(AB_XOR)
    );

    initial begin
        $monitor("T=%0t | AB_AND=%d AB_OR=%d AB_XOR=%d", $time, AB_AND, AB_OR, AB_XOR);

        // VCD 파일 생성 (파형 확인용)
        $dumpfile("operation_tb.vcd");
        $dumpvars(0, operation_tb);

        // 초기값
        A = 16'd2;
        B = 16'd2;

        #2 A = 16'd3;  // A를 바꿔서 두 번째 always 트리거 유도

        #10 $finish;
    end

endmodule