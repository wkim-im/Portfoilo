module alu_tb;
    wire [3:0] out;
    reg [2:0] sel;
    reg [3:0] in0;
    reg [3:0] in1;

    alu alu1(.OUT(out),.sel(sel),.IN0(in0),.IN1(in1));

    initial begin
        in0=4'b0101; in1=4'b0011;
        sel=3'b000;
        #2 sel=3'b000;
        #2 sel=3'b001;
        #2 sel=3'b010;
        #2 sel=3'b011;
        #2 sel=3'b100;
        #2 sel=3'b101;
        #2 sel=3'b110;
        #2 sel=3'b111;
        #2 $finish;
    end
endmodule

//alu 수정중입니다 수정하고있는데??