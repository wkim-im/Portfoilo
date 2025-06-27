module clk_div (
    input wire clk_50,
    input wire rst,
    output reg clk_1 = 0
);

reg [24:0] cnt = 0;

always @(posedge clk_50) begin
    if(rst)begin
        clk_1 <= 0;
        cnt <= 0;
    end
    else if (cnt == 26'd24_999_999) begin
        clk_1 <= ~clk_1;
        cnt <= 0;
    end else begin
        cnt <= cnt + 1;
    end
end

endmodule

