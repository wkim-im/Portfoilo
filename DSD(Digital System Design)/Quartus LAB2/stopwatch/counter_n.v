module counter_n (
    output reg [5:0] q,
    input wire clk,
    input wire clr
);
    always @(posedge clk) begin
        if (clr) begin
            q <= 0;
        end
        else if (q == 6'd59) begin
            q <= 0;
        end
        else begin
            q <= q + 1;
        end
    end
endmodule