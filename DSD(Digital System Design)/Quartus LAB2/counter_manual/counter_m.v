module counter_m (
    input wire clk,
    input wire rst,
    output wire [6:0] hout
);

wire [3:0] out;
counter cnt(.q(out),.clk(clk),.clr(rst));
segment7 seg7(.B(out),.H(hout));

    
endmodule