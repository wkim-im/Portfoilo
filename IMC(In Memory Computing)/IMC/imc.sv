module imc (
    input  wire clk,
    input  wire rst,
    input  wire write_en,            // 외부에서 write 시작 트리거
    input  wire read_en,             // 외부에서 read 시작 트리거
    input  wire mac_en,              // 외부에서 mac 시작 트리거
    input  wire [1:0] bankde,        // 어떤 wbank에 write할지 선택
    input  wire [3:0] Wxin [15:0],   // 4bit data 16개
    input  wire [3:0] Wwbank [15:0], // 4bit data 16개
    output wire [13:0] result
);

    // SRAM 연결 신호
    wire [3:0] Rxin [15:0];
    wire [3:0] Rwbank1 [15:0];
    wire [3:0] Rwbank2 [15:0];
    wire [3:0] Rwbank3 [15:0];
    wire [3:0] Rwbank4 [15:0];

    // SRAM
    sram sram1 (
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .read_en(read_en),
        .bankde(bankde),
        .Wxin(Wxin),
        .Wwbank(Wwbank),
        .Rxin(Rxin),
        .Rwbank1(Rwbank1),
        .Rwbank2(Rwbank2),
        .Rwbank3(Rwbank3),
        .Rwbank4(Rwbank4)
    );

    // MAC
    mac mac1 (
        .clk(clk),
        .rst(rst),
        .mac_en(mac_en),
        .xin(Rxin),
        .wbank1(Rwbank1),
        .wbank2(Rwbank2),
        .wbank3(Rwbank3),
        .wbank4(Rwbank4),
        .result(result)
    );

endmodule
