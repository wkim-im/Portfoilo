module Full_Subtractor (
    input wire X,
    input wire Y,
    input wire BIN,
    output wire DIFF,
    output wire B_OUT
);

    assign DIFF  = X ^ Y ^ BIN;
    assign B_OUT = (~X & Y) | ((~(X ^ Y)) & BIN);

endmodule


module Full_Subtractor (
    input wire X,
    input wire Y,
    input wire BIN,
    output wire DIFF,
    output wire BOUT
);

    assign DIFF = X^Y^BIN;
    assign BOUT = (~Y&BIN)|(~(Y^BIN) & X);
    
endmodule

module Full_Subtractor_gate (
    input wire X,
    input wire Y,
    input wire BIN,
    output wire DIFF,
    output wire BOUT
);

    wire x_xor_y;
    wire not_x;
    wire not_x_and_y;
    wire x_xor_y_bar;
    wire x_xor_y_bar_and_bin;

    xor (x_xor_y,X,Y);
    xor (DIFF,x_xor_y,BIN);
    
    not (not_x,X);
    and (not_x_and_y,not_x,Y);

    not (x_xor_y_bar, x_xor_y);
    and (x_xor_y_bar_and_bin, x_xor_y_bar,BIN);

    or (BOUT, x_xor_y_bar_and_bin,not_x_and_y);
endmodule


module full_subtractor_4bit (
    input wire [3:0] A,
    input wire [3:0] B,
    input wire BIN,                // 초기 borrow in
    output wire [3:0] DIFF,
    output wire BOUT               // 최종 borrow out
);
    wire b1, b2, b3; // 내부 borrow

    full_subtractor_1bit fs0 (
        .X(A[0]), .Y(B[0]), .BIN(BIN),
        .DIFF(DIFF[0]), .BOUT(b1)
    );

    full_subtractor_1bit fs1 (
        .X(A[1]), .Y(B[1]), .BIN(b1),
        .DIFF(DIFF[1]), .BOUT(b2)
    );

    full_subtractor_1bit fs2 (
        .X(A[2]), .Y(B[2]), .BIN(b2),
        .DIFF(DIFF[2]), .BOUT(b3)
    );

    full_subtractor_1bit fs3 (
        .X(A[3]), .Y(B[3]), .BIN(b3),
        .DIFF(DIFF[3]), .BOUT(BOUT)
    );
endmodule


module full_subtractor_4bit (
    input wire[3:0] X,
    input wire[3:0] Y,
    input wire BIN,
    output wire[3:0] DIFF,
    output wire BOUT
);

    assign {BOUT,DIFF} = X-Y-BIN;
    //assign DIFF = X - Y - BIN;
    //assign BOUT = (X < (Y + BIN)) ? 1 : 0;

endmodule