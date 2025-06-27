module full_adder (
    input A, B, C_IN,
    output SUM, C_OUT
);
    assign SUM = A ^ B ^ C_IN;
    assign C_OUT = (A & B) | C_IN&(A^B);
endmodule
