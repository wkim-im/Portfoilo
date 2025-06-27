module RCA_4b(SUM,C_OUT,X,Y,C_IN);

    input wire [3:0] X,Y;
    input wire C_IN;
    output wire [3:0] SUM;
    output wire C_OUT;

    wire C1,C2,C3;

    Full_Adder fa1(.SUM(SUM[0]),.C_O(C1),.X(X[0]),.Y(Y[0]),.C_I(C_IN));
    Full_Adder fa2(.SUM(SUM[1]),.C_O(C2),.X(X[1]),.Y(Y[1]),.C_I(C1));
    Full_Adder fa3(.SUM(SUM[2]),.C_O(C3),.X(X[2]),.Y(Y[2]),.C_I(C2));    
    Full_Adder fa4(.SUM(SUM[3]),.C_O(C_OUT),.X(X[3]),.Y(Y[3]),.C_I(C3));

endmodule

/*

 */