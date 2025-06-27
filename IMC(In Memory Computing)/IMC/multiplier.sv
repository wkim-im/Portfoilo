module multiplier (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] activation, 
    input  wire [3:0]  wbank1 [15:0],
    input  wire [3:0]  wbank2 [15:0],
    input  wire [3:0]  wbank3 [15:0],
    input  wire [3:0]  wbank4 [15:0],
    output reg  [3:0]  mul_result [63:0]
);

    integer j;
    //ex) cycle = 0 , mac에서 전달받은 activaiton xin의 MSB 16개를 4개의 weight bank 와 각각 1b(MSB) x 4b (weight1) 곱셈결과를 mul_result에 저장
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (j = 0; j < 64; j = j + 1)
                mul_result[j] <= 4'd0;
        end else begin
            for (j = 0; j < 16; j = j + 1) begin  //총 4bit 짜리 mul_result 64개를 만들어냄
                mul_result[j]      <= activation[j] ? wbank1[j] : 4'd0;
                mul_result[j+16]   <= activation[j] ? wbank2[j] : 4'd0;
                mul_result[j+32]   <= activation[j] ? wbank3[j] : 4'd0;
                mul_result[j+48]   <= activation[j] ? wbank4[j] : 4'd0;
            end
        end
    end

endmodule

/* ex) cycle = 0 , j = 0
activation = [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0]
mul_result[0] = activation[0] ? wbank1: 4'd0  // activation[0]= 0 이니, 4'd0가 저장
mul_result[16] =  // 위와 동일
mul_result[32] =  // 위와 동일
mul_result[48] =  // 위와 동일
*/