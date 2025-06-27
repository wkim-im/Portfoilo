module clk_div_pls (
    input wire clk_50,
    output reg clk_1 = 0
);
    reg [22:0] cnt = 0;

    always @(posedge clk_50) begin
        if (cnt == 12_500_000 - 1) begin  //500000000 1초마다 토글 clk 주기 2초, 25000000 clk주기 1초, 12500000 주기 0.5초, 6250000 주기 0.25초
            clk_1 <= ~clk_1;
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule
