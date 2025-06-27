module mac (
    input  wire clk, 
    input  wire rst,
    input  wire mac_en,
    input  wire [3:0] xin [15:0],
    input  wire [3:0] wbank1 [15:0],
    input  wire [3:0] wbank2 [15:0],
    input  wire [3:0] wbank3 [15:0],
    input  wire [3:0] wbank4 [15:0],
    output wire [13:0] result
);

    reg [1:0] cycle; //xin의 MSB 부터 순차적으로 처리하기위한 변수 신호
    reg [15:0] activation; // MSB -> LSB 처리하기 위한 신호
    wire [3:0] mul_result [63:0]; // ex) xin MSB 16개와 각각 행에 맞는 weight의 곱셉결과 4bit 
    wire [9:0] partialsum; //64개의 4bit 곱셈결과가 adder tree를 통해 더해져 나온 10bit 

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle <= 2'd0;
        end else if (mac_en) begin
            if (cycle < 2'd3) //cycle이 3이하면 1씩 더해져서 0(00) -> 1(01) -> 2(10) -> 3(11) -> 0(00) 의 순서를 만들어냄 
                cycle <= cycle + 1;
            else
                cycle <= 2'd0;
        end
    end

    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin //cycle에 맞는 xin의 bit를 선택 ex) cycle = 0 , i = 0, : activation[0] = xin[0][3] , xin의 첫행의 MSB 저장
            activation[i] = xin[i][3 - cycle];
        end
    end

    multiplier mul1 (
        .clk(clk),
        .rst(rst),
        .activation(activation),
        .wbank1(wbank1),
        .wbank2(wbank2),
        .wbank3(wbank3),
        .wbank4(wbank4),
        .mul_result(mul_result)
    );

    adder_tree adt1 (
        .mul_result(mul_result),
        .partialsum(partialsum)
    );

    accumulator acum1 (
        .clk(clk),
        .rst(rst),
        .cycle(cycle),
        .partialsum(partialsum),
        .result(result)
    );

endmodule
