`include "SR_latch.v"

module TOP;

    wire q, qbar;
    reg set, rst;

    // CLK 포함된 SR 래치 인스턴스화
    SR_latch sr1(
        .Q(q),
        .QBAR(qbar),
        .SBAR(~set),
        .RBAR(~rst)
    );

    // 클럭 생성 (10ns 주기)
    initial
    begin
        $monitor($time,"set=%b reset = %b, q=%b\n",set, rst, q);
        set = 0; rst =0;
        #5 rst =1;
        #5 rst =0;
        #5 rst =1;
    end
    
endmodule

