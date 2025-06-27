module stopwatch (
    input wire clk_50,
    input wire rst,
    output wire [6:0] OUT10,
    output wire [6:0] OUT1
);
    wire clk;
    wire [5:0] out;
    
    clk_div clkd (.clk_50(clk_50),.rst(rst),.clk_1(clk));
    counter_n cnt(.q(out),.clk(clk),.clr(rst));
    segment7 seg10(.B(B1),.H(OUT10));
    segment7 seg1  (.B(B2),.H(OUT1));

    reg [3:0] B1;
    reg [3:0] B2;

    always @(*) begin
        if (out < 10) begin
            B1 = 4'd0;
            B2 = out;
        end else if (out < 20) begin
            B1 = 4'd1;
            B2 = out - 10;
        end else if (out < 30) begin
            B1 = 4'd2;
            B2 = out - 20;
        end else if (out < 40) begin
            B1 = 4'd3;
            B2 = out - 30;
        end else if (out < 50) begin
            B1 = 4'd4;
            B2 = out - 40;
        end else begin
            B1 = 4'd5;
            B2 = out - 50;
        end
    end


endmodule
