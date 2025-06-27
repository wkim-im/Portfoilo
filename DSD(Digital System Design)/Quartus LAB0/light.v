module light (
    output F,
    input X1, X2
);
    assign F = (X1 & ~X2)|(~X1 & X2);
    
endmodule