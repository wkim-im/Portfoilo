module counter (
    output reg [3:0] q, //조정정
    input wire clk,
    input wire clr
);
    always @(posedge clk) begin
        if (!clr)begin
            q <= 0;
        end
        
        else if (q == 4'd15) begin
            q <= 0;
        end
        
        else begin
            q <= q + 1;
        end
    end
endmodule