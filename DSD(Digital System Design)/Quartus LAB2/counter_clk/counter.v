module counter (
    output reg [3:0] q,
    input wire clk,
    input wire clr
);
    always @(posedge clk) begin
        if (clr) begin   // 수정 
            q <= 0;
        end
        else if (q==4'b1001) begin
            q <= 4'b0000;
        end
        else begin
            q <= q + 4'b0001;
        end
    end
endmodule