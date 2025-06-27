`timescale 10ns/1ps
module TB_Full_Adder;
    reg x,y,c_i;
    wire sum, c_o;

    Full_Adder fa1(.SUM(sum),.C_O(c_o),.X(x),.Y(y),.C_I(c_i));

    initial
    begin
        x=1'b0; y=1'b0; c_i=1'b0;
        #2
        x=1'b0; y=1'b0; c_i=1'b1;
        #2
        x=1'b0; y=1'b1; c_i=1'b0;
        #2
        x=1'b0; y=1'b1; c_i=1'b1;
        #2
        x=1'b1; y=1'b0; c_i=1'b0;
        #2
        x=1'b1; y=1'b0; c_i=1'b1;
        #2
        x=1'b1; y=1'b1; c_i=1'b0;
        #2
        x=1'b1; y=1'b1; c_i=1'b1;
        #2 $finish;
    end
    
endmodule