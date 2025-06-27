`timescale 10ns/1ps
module TB_RCA_4b;

    reg [3:0] x,y;
    reg c_in;
    wire [3:0] sum;
    wire c_out;

    RCA_4b rca4b1(.SUM(sum),.C_OUT(c_out),.X(x),.Y(y),.C_IN(c_in));

    initial
    begin
        x=4'b0000; y=4'b0000; c_in=1'b0;
        #2 x=4'b0100; y=4'b1000; c_in=1'b0;
        #2 x=4'b0011; y=4'b0111; c_in=1'b1;
        #2 x=4'b1100; y=4'b0101; c_in=1'b0;
        #2 $finish;
    end
    
endmodule