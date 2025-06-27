module operation (
    input [15:0] A,
    input [15:0] B,
    output reg [15:0] AB_AND,
    output reg [15:0] AB_OR,
    output reg [15:0] AB_XOR
);

    task bitwise_oper;
        input [15:0] a, b;
        output [15:0] ab_and, ab_or, ab_xor;
        begin
            #1 ab_and <= a & b;
            #2 ab_or  <= a | b;
            #1 ab_xor <= a ^ b;
        end
    endtask

    always @(A or B) begin
        bitwise_oper(A, B, AB_AND, AB_OR, AB_XOR);
    end

endmodule