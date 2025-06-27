module rcc_wtff (
    output wire [3:0] Q,
    input wire clk,
    input wire rst
);
    tff t1(.q(Q[0]), .clk(clk),   .rst(rst));  // LSB: clk 기준 토글
    tff t2(.q(Q[1]), .clk(Q[0]), .rst(rst));  // Q[0]이 clk 역할
    tff t3(.q(Q[2]), .clk(Q[1]), .rst(rst));  // Q[1]이 clk 역할
    tff t4(.q(Q[3]), .clk(Q[2]), .rst(rst));  // Q[2]이 clk 역할
endmodule
