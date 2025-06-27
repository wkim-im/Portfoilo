module light_tb ;
    wire f;
    reg x1,x2;

    light lite(.F(f),.X1(x1),.X2(x2));

    initial begin
        x1 = 1'b0; x2 = 1'b0;
        #5 x1 = 1'b0; x2 = 1'b1;
        #5 x1 = 1'b1; x2 = 1'b0;
        #5 x1 = 1'b1; x2 = 1'b1;

        #5 $finish;
    end
endmodule