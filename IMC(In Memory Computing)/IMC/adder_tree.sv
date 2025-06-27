module adder_tree (
    input  wire [3:0] mul_result [63:0],
    output wire [9:0] partialsum
);

    wire [4:0] level1 [31:0]; // 4bit + 4bit = 5bit 전달하는 32개 wire
    wire [5:0] level2 [15:0]; // 5bit + 5bit = 6bit 전달하는 16개 wire
    wire [6:0] level3 [7:0];  // 6bit + 6bit = 7bit 전달하는 8개 wire
    wire [7:0] level4 [3:0];  // 7bit + 7bit = 8bit 전달하는 4개 wire
    wire [8:0] level5 [1:0];  // 8bit + 8bit = 9bit 전달하는 2개 wire

    genvar i;

    // 64개의 4bit mul_result를 각각 더해  5bit의 32개 결과를 저장
    generate
        for (i = 0; i < 32; i = i + 1) begin : LEVEL1
            assign level1[i] = mul_result[2*i] + mul_result[2*i+1];
        end
    endgenerate

    // 32개의 5bit 결과를 각각 더해  6bit의 16개 결과를 저장
    generate
        for (i = 0; i < 16; i = i + 1) begin : LEVEL2
            assign level2[i] = level1[2*i] + level1[2*i+1];
        end
    endgenerate

     // 16개의 6bit 결과를 각각 더해  7bit의 8개 결과를 저장
    generate
        for (i = 0; i < 8; i = i + 1) begin : LEVEL3
            assign level3[i] = level2[2*i] + level2[2*i+1];
        end
    endgenerate

    // 8개의 7bit 결과를 각각 더해  8bit의 4개 결과를 저장
    generate
        for (i = 0; i < 4; i = i + 1) begin : LEVEL4
            assign level4[i] = level3[2*i] + level3[2*i+1];
        end
    endgenerate

    // 4개의 8bit 결과를 각각 더해  9bit의 2개 결과를 저장
    generate
        for (i = 0; i < 2; i = i + 1) begin : LEVEL5
            assign level5[i] = level4[2*i] + level4[2*i+1];
        end
    endgenerate

    // 최종적으로, 2개의 9it 결과를 각각 더해  10bit의 결과를 저장
    assign partialsum = level5[0] + level5[1];

endmodule