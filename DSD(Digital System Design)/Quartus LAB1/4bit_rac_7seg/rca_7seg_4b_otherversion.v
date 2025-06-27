module rca_7seg_4b_otherversion (
    input [3:0] X,
    input [3:0] Y,
    input       C_IN,
    output [6:0] X7,
    output [6:0] Y7,
    output reg [6:0] OUT10,
    output reg [6:0] OUT1
);

    wire [3:0] SUM;
    wire       C_OUT;
    wire [4:0] RESULT;

    assign RESULT = {C_OUT, SUM};

    rca_4bit rca(.X(X), .Y(Y), .C_IN(C_IN), .SUM(SUM), .C_OUT(C_OUT));
    segment7 segX(.B(X), .H(X7));
    segment7 segY(.B(Y), .H(Y7));

    always @(*) begin
        case (RESULT / 10)
            0: OUT10 = 7'b1000000; // 0
            1: OUT10 = 7'b1111001; // 1
            2: OUT10 = 7'b0100100; // 2
            3: OUT10 = 7'b0110000; // 3
            default: OUT10 = 7'b1111111; // off
        endcase

        case (RESULT % 10)
            0: OUT1 = 7'b1000000; // 0
            1: OUT1 = 7'b1111001; // 1
            2: OUT1 = 7'b0100100; // 2
            3: OUT1 = 7'b0110000; // 3
            4: OUT1 = 7'b0011001; // 4
            5: OUT1 = 7'b0010010; // 5
            6: OUT1 = 7'b0000010; // 6
            7: OUT1 = 7'b1111000; // 7
            8: OUT1 = 7'b0000000; // 8
            9: OUT1 = 7'b0010000; // 9
            default: OUT1 = 7'b1111111;
        endcase
    end
endmodule

//위의 코드가 쿼터스에서 %,/ 연산자를 지원해서 동작하는것
//하지만 하드웨어를 기술할때는 아래와 같이 일일히 mapping 하는것이 좋음
/*
module rca_seg (
    input [3:0] X,
    input [3:0] Y,
    input       C_IN,
    output [6:0] X7,
    output [6:0] Y7,
    output reg [6:0] OUT10,
    output reg [6:0] OUT1
);

    wire [3:0] SUM;
    wire       C_OUT;
    wire [4:0] RESULT;

    assign RESULT = {C_OUT, SUM};

    rca_4bit rca(.X(X), .Y(Y), .C_IN(C_IN), .SUM(SUM), .C_OUT(C_OUT));
    segment7 segX(.B(X), .H(X7));
    segment7 segY(.B(Y), .H(Y7));

    always @(*) begin
        case (RESULT)
            5'd0 : begin OUT10 = 7'b1000000; OUT1 = 7'b1000000; end
            5'd1 : begin OUT10 = 7'b1000000; OUT1 = 7'b1111001; end
            5'd2 : begin OUT10 = 7'b1000000; OUT1 = 7'b0100100; end
            5'd3 : begin OUT10 = 7'b1000000; OUT1 = 7'b0110000; end
            5'd4 : begin OUT10 = 7'b1000000; OUT1 = 7'b0011001; end
            5'd5 : begin OUT10 = 7'b1000000; OUT1 = 7'b0010010; end
            5'd6 : begin OUT10 = 7'b1000000; OUT1 = 7'b0000010; end
            5'd7 : begin OUT10 = 7'b1000000; OUT1 = 7'b1111000; end
            5'd8 : begin OUT10 = 7'b1000000; OUT1 = 7'b0000000; end
            5'd9 : begin OUT10 = 7'b1000000; OUT1 = 7'b0010000; end
            5'd10: begin OUT10 = 7'b1111001; OUT1 = 7'b1000000; end
            5'd11: begin OUT10 = 7'b1111001; OUT1 = 7'b1111001; end
            5'd12: begin OUT10 = 7'b1111001; OUT1 = 7'b0100100; end
            5'd13: begin OUT10 = 7'b1111001; OUT1 = 7'b0110000; end
            5'd14: begin OUT10 = 7'b1111001; OUT1 = 7'b0011001; end
            5'd15: begin OUT10 = 7'b1111001; OUT1 = 7'b0010010; end
            5'd16: begin OUT10 = 7'b1111001; OUT1 = 7'b0000010; end
            5'd17: begin OUT10 = 7'b1111001; OUT1 = 7'b1111000; end
            5'd18: begin OUT10 = 7'b1111001; OUT1 = 7'b0000000; end
            5'd19: begin OUT10 = 7'b1111001; OUT1 = 7'b0010000; end
            5'd20: begin OUT10 = 7'b0100100; OUT1 = 7'b1000000; end
            5'd21: begin OUT10 = 7'b0100100; OUT1 = 7'b1111001; end
            5'd22: begin OUT10 = 7'b0100100; OUT1 = 7'b0100100; end
            5'd23: begin OUT10 = 7'b0100100; OUT1 = 7'b0110000; end
            5'd24: begin OUT10 = 7'b0100100; OUT1 = 7'b0011001; end
            5'd25: begin OUT10 = 7'b0100100; OUT1 = 7'b0010010; end
            5'd26: begin OUT10 = 7'b0100100; OUT1 = 7'b0000010; end
            5'd27: begin OUT10 = 7'b0100100; OUT1 = 7'b1111000; end
            5'd28: begin OUT10 = 7'b0100100; OUT1 = 7'b0000000; end
            5'd29: begin OUT10 = 7'b0100100; OUT1 = 7'b0010000; end
            5'd30: begin OUT10 = 7'b0110000; OUT1 = 7'b1000000; end
            5'd31: begin OUT10 = 7'b0110000; OUT1 = 7'b1111001; end
            default: begin OUT10 = 7'b1111111; OUT1 = 7'b1111111; end
        endcase
    end
endmodule
*/