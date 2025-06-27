`timescale 1ns/1ps
`include "multiplier.sv"
`include "adder_tree.sv"
`include "accumulator.sv"
`include "mac.sv"

module mac_tb;

    reg clk;
    reg rst;
    reg [3:0] xin [15:0]; //4bit input 16 by 1
    reg [3:0] wbank1 [15:0]; //4bit weight 16 by 1
    reg [3:0] wbank2 [15:0]; //4bit weight 16 by 1
    reg [3:0] wbank3 [15:0]; //4bit weight 16 by 1
    reg [3:0] wbank4 [15:0]; //4bit weight 16 by 1
    wire [13:0] result; // 4x16(weight) x 16x1(x) = 4x1 행 덧셈 => 1 x 1 

    mac mac1 (
        .clk(clk),
        .rst(rst),
        .xin(xin),
        .wbank1(wbank1),
        .wbank2(wbank2),
        .wbank3(wbank3),
        .wbank4(wbank4),
        .result(result)
    );

    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("mac_tb.vcd");
        $dumpvars(0, mac_tb);

        clk = 0;
        rst = 1;
        #10;
        rst = 0;

        for (i = 0; i < 16; i = i + 1) begin  // python 에서의 x1 행렬
            xin[i] = i;
        end
        //python 에서 weight 4 x 16 행렬
        wbank1[0] = 4'd0;  wbank1[1] = 4'd1;  wbank1[2] = 4'd2;  wbank1[3] = 4'd3;
        wbank1[4] = 4'd4;  wbank1[5] = 4'd5;  wbank1[6] = 4'd6;  wbank1[7] = 4'd7;
        wbank1[8] = 4'd8;  wbank1[9] = 4'd9;  wbank1[10] = 4'd10; wbank1[11] = 4'd11;
        wbank1[12] = 4'd12; wbank1[13] = 4'd13; wbank1[14] = 4'd14; wbank1[15] = 4'd15;

        wbank2[0] = 4'd15; wbank2[1] = 4'd14; wbank2[2] = 4'd13; wbank2[3] = 4'd12;
        wbank2[4] = 4'd11; wbank2[5] = 4'd10; wbank2[6] = 4'd9;  wbank2[7] = 4'd8;
        wbank2[8] = 4'd7;  wbank2[9] = 4'd6;  wbank2[10] = 4'd5; wbank2[11] = 4'd4;
        wbank2[12] = 4'd3; wbank2[13] = 4'd2; wbank2[14] = 4'd1; wbank2[15] = 4'd0;

        wbank3[0] = 4'd2;  wbank3[1] = 4'd4;  wbank3[2] = 4'd6;  wbank3[3] = 4'd8;
        wbank3[4] = 4'd10; wbank3[5] = 4'd12; wbank3[6] = 4'd14; wbank3[7] = 4'd2;
        wbank3[8] = 4'd4;  wbank3[9] = 4'd6;  wbank3[10] = 4'd8; wbank3[11] = 4'd10;
        wbank3[12] = 4'd12; wbank3[13] = 4'd14; wbank3[14] = 4'd2; wbank3[15] = 4'd4;

        wbank4[0] = 4'd1;  wbank4[1] = 4'd3;  wbank4[2] = 4'd5;  wbank4[3] = 4'd7;
        wbank4[4] = 4'd9;  wbank4[5] = 4'd11; wbank4[6] = 4'd13; wbank4[7] = 4'd15;
        wbank4[8] = 4'd1;  wbank4[9] = 4'd3;  wbank4[10] = 4'd5; wbank4[11] = 4'd7;
        wbank4[12] = 4'd9; wbank4[13] = 4'd11; wbank4[14] = 4'd13; wbank4[15] = 4'd15;

        #100;
        rst=1;
        #10
        rst=0;
        for (i = 0; i < 16; i = i + 1) begin // python 에서의 x2 행렬
            xin[15 - i] = i;
        end
        #100;
        $display("Final q = %d (%b)", result, result);
        $finish;
    end

endmodule