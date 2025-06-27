module dff (
    output reg q,   // 1비트 출력 선언
    input wire clk, // clk 입력 신호 선언
    input wire rst, // reset 입력 신호 선언
    input wire d    // 1비트 입력 선언
);
    always @(posedge clk or negedge rst) begin // behavior 구문을 사용하여, clk이 상향엣지일 때 해당 구문 계속 동작함
        if (!rst) begin // rst가 0이면,  q값이 0으로 초기화
            q <= 0;
        end
        else begin // rst가 1이면,  q의 값이 d값으로 덮여씌여짐.
            q <= d;
        end
    end
endmodule


