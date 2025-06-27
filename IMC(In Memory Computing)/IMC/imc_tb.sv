`timescale 1ns/1ps
`include "multiplier.sv"
`include "adder_tree.sv"
`include "accumulator.sv"
`include "mac.sv"
`include "imc.sv"
`include "sram.sv"

module imc_tb;

    reg clk;
    reg rst;
    //각 en 신호에 맞는 연산 수행
    reg write_en;
    reg read_en;
    reg mac_en;

    reg [1:0] bankde;        //decoder 신호 sram 모듈에서 사용
    reg [3:0] Wxin [15:0];   //4bit Operand 입력 데이터 16개
    reg [3:0] Wwbank [15:0]; //4bit 가중치 입력 데이터 16개
    wire [13:0] result;

    imc imc1 (
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .read_en(read_en),
        .mac_en(mac_en),
        .bankde(bankde),
        .Wxin(Wxin),
        .Wwbank(Wwbank),
        .result(result)
    );

    always #5 clk = ~clk;

    integer i,j;

    initial begin
        $dumpfile("imc_tb.vcd");
        $dumpvars(0, imc_tb);

        clk = 1;
        rst = 1;
        #10;
        rst = 0;
        write_en = 1;
        // Wxin은 고정
        for (i = 0; i < 16; i = i + 1)
            Wxin[i] = i;

        // wbank1 write
        bankde = 2'b00; 
        for (i = 0; i < 16; i = i + 1)
            Wwbank[i] = i;

        // wbank2 write
        #10 bankde = 2'b01;
        for (i = 0; i < 16; i = i + 1)
            Wwbank[i] = 15 - i;


        // Wbank3 write
        #10 bankde = 2'b10;
        j = 2;
        for (i = 0; i < 16; i = i + 1) begin
            Wwbank[i] = j;
            j = (j == 14) ? 2 : j + 2;
        end

        // Wbank4 write
        #10 bankde = 2'b11;
        j = 1;
        for (i = 0; i < 16; i = i + 1) begin
            Wwbank[i] = j;
            j = (j == 15) ? 1 : j + 2;
        end
        
        #10; write_en = 0;

        // 내부 메모리에 저장된 DATA READ
        read_en = 1; #10; read_en = 0;

        // MAC 연산 시작
        mac_en = 1;

        #100;
        $display("Final result = %d (%b)", result, result);
        $finish;
    end

endmodule


/*control #(.BANK_COUNT(4)) ctrl (
    .clk(clk),
    .rst(rst),
    .start(start),
    .write_mode(write_mode),
    .read_mode(read_mode),
    .mac_mode(mac_mode),
    .bankde(bankde)
);*/