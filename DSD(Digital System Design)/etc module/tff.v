module tff (
    output wire q,
    input wire clk,
    input wire rst
);
    wire nq;
    not n1(nq,q);
    dff df1(.q(q),.clk(clk),.rst(rst),.d(nq));  // d = ~q

endmodule

