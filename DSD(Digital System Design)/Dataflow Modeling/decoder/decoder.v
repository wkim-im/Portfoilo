module decoder_dataflow (
    input wire s1,
    input wire s0,
    input wire En,
    output wire [3:0] out
);

    assign out[0]=En? (~s1&~s0) : 1'b0;
    assign out[1]=En? (~s1&s0) : 1'b0;
    assign out[2]=En? (s1&~s0) : 1'b0;
    assign out[3]=En? (s1&s0) : 1'b0;

endmodule

module decoder_gate (
    input wire s1,s0,
    input wire En,
    output wire [3:0] out
);
    wire s1b,s0b;
    not n1 (s0b,s0);
    not n2 (s1b,s1);

    and a1 (out[0],En,s0b,s1b);
    and a2 (out[1],En,s0,s1b);
    and a3 (out[2],En,s0b,s1);
    and a4 (out[3],En,s0,s1);

endmodule