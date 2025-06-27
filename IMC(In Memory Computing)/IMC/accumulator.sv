module accumulator (
    input  wire        clk,
    input  wire        rst,
    input wire [1:0] cycle,
    input  wire [9:0]  partialsum,
    output reg  [13:0] result
);

    wire [13:0] q_ex;
    reg  [13:0] q;

    // 10bit의 partialsum을 받아 shift 연산해야되므로 14bit으로 extension  
    assign q_ex = (partialsum[9]==1'b1) ? {4'b1111, partialsum} : {4'b0000, partialsum};

    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            q <= 14'd0;
            result <= 14'd0;
        end
        //5번째 clk에 누산된 결과를 확인할 수 있음.
        else begin
            if(cycle==2'd0) begin                
                q <= 14'd0;        // 기존 q 초기화
                result <=(q<<1)+q_ex; // cycle 0일때, 기존 q는 (((q_ex0<<1)+q_ex1)<<1)+q_ex2이고 이를 << 1, cycle=3때 q_ex3이 더해진 값이 출력
            end
            else begin //
                q <= (q << 1) + q_ex; // cycle 1일때, 기존 q는 14'd0이고, cycle=0때 q_ex0가 더해진 값이 저장됨
                                      // cycle 2일때, 기존 q는 q_ex0이고 이를 << 1 , cycle=1때 q_ex1가 더해진 값이 저장됨
                                      // cycle 3일때, 기존 q는 (q_ex0<<1)+q_ex1이고 이를 << 1 , cycle=2때 q_ex2가 더해진 값이 저장됨
            end
        end
    end
endmodule
