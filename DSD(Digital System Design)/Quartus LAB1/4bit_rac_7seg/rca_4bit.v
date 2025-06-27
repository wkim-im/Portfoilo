module rca_4bit (
    input wire [3:0] X,
    input wire [3:0] Y,
    input wire C_IN,
    output wire [3:0] SUM,
    output wire C_OUT
);
    wire C1, C2, C3;

    full_adder fa0(.A(X[0]),.B(Y[0]),.C_IN(C_IN),.SUM(SUM[0]),.C_OUT(C1));
    full_adder fa1(.A(X[1]),.B(Y[1]),.C_IN(C1),.SUM(SUM[1]),.C_OUT(C2));
    full_adder fa2(.A(X[2]),.B(Y[2]),.C_IN(C2),.SUM(SUM[2]),.C_OUT(C3));
    full_adder fa3(.A(X[3]),.B(Y[3]),.C_IN(C3),.SUM(SUM[3]),.C_OUT(C_OUT));    

endmodule