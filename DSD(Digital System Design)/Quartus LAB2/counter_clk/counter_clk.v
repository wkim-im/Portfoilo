module counter_clk (
    input wire clk_50,
    input wire rst,
    output wire [6:0] hout
);

    wire clk;
    wire [3:0] out;
    clk_div clkdiv(.clk_50(clk_50),.rst(rst),.clk_1(clk));
    counter cnt (.q(out),.clk(clk),.clr(rst));
    segment7 seg7 (.B(out),.H(hout));
    
endmodule