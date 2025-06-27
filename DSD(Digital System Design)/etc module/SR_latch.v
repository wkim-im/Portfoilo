module SR_latch (Q,QBAR,SBAR,RBAR);
    output wire Q, QBAR;
    input wire SBAR,RBAR;

    nand n1(Q, SBAR, QBAR);
    nand n2(QBAR, RBAR,Q);

endmodule
/*
module SR_latch (
    output wire Q, QBAR,
    input wire SBAR, RBAR,
    input wire CLK
);

    wire S_gated, R_gated;

    // 클럭이 1일 때만 입력 반영되도록 gating
    nand n1(S_gated, SBAR, CLK);
    nand n2(R_gated, RBAR, CLK);

    // 기존 SR 래치 구조
    nand n3(Q, S_gated, QBAR);
    nand n4(QBAR, R_gated, Q);

endmodule
*/