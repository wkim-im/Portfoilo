
module sram (
    input  wire clk,
    input  wire rst,
    input  wire write_en,
    input  wire read_en,
    input  wire [1:0] bankde,
    input  wire [3:0] Wxin    [15:0],
    input  wire [3:0] Wwbank  [15:0],
    output reg  [3:0] Rxin    [15:0],
    output reg  [3:0] Rwbank1 [15:0],
    output reg  [3:0] Rwbank2 [15:0],
    output reg  [3:0] Rwbank3 [15:0],
    output reg  [3:0] Rwbank4 [15:0]
);

    // 내부 메모리 선언
    reg [3:0] xin_mem     [15:0];
    reg [3:0] wbank1_mem  [15:0];
    reg [3:0] wbank2_mem  [15:0];
    reg [3:0] wbank3_mem  [15:0];
    reg [3:0] wbank4_mem  [15:0];

    integer i;

    // Write Logic
    always @(posedge clk) begin
        if (rst) begin //rst신호 활성화 시,내부 메모리 리셋
            for (i = 0; i < 16; i = i + 1) begin
                xin_mem[i]    <= 4'b0;
                wbank1_mem[i] <= 4'b0;
                wbank2_mem[i] <= 4'b0;
                wbank3_mem[i] <= 4'b0;
                wbank4_mem[i] <= 4'b0;
            end
        end else if (write_en) begin //write_en 활성화 시, 외부에서 입력한 데이터와 decoder 신호에 따라 내부 메모리에 전달
            for (i = 0; i < 16; i = i + 1) begin
                xin_mem[i] <= Wxin[i];
                case (bankde)
                    2'b00: wbank1_mem[i] <= Wwbank[i];
                    2'b01: wbank2_mem[i] <= Wwbank[i];
                    2'b10: wbank3_mem[i] <= Wwbank[i];
                    2'b11: wbank4_mem[i] <= Wwbank[i];
                endcase
            end
        end
    end

    // Read Logic (동기식 read_en 조건으로만 읽음) 
    always @(posedge clk) begin 
        if (read_en) begin //read_en 활성화 시, 내부 저장된 데이터가 출력신호로 전달
            for (i = 0; i < 16; i = i + 1) begin
                Rxin[i]    <= xin_mem[i];
                Rwbank1[i] <= wbank1_mem[i];
                Rwbank2[i] <= wbank2_mem[i];
                Rwbank3[i] <= wbank3_mem[i];
                Rwbank4[i] <= wbank4_mem[i];
            end
        end
    end
//내부 저장된 데이터도 선택된 decoder 마다 1clk read? or 한번에 read?
endmodule