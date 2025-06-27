`timescale 10ns/1ps

module Full_Subtractor_tb;

    reg X, Y, BIN;
    wire DIFF, B_OUT;

    // DUT 연결
    Full_Subtractor uut (
        .X(X),
        .Y(Y),
        .BIN(BIN),
        .DIFF(DIFF),
        .B_OUT(B_OUT)
    );

    initial begin
        $display("Time\tX\tY\tBIN\t|\tDIFF\tB_OUT");
        $monitor("%0t\t%b\t%b\t%b\t|\t%b\t%b", $time, X, Y, BIN, DIFF, B_OUT);

        // 입력 모든 조합
        {X, Y, BIN} = 3'b000; #10;
        {X, Y, BIN} = 3'b001; #10;
        {X, Y, BIN} = 3'b010; #10;
        {X, Y, BIN} = 3'b011; #10;
        {X, Y, BIN} = 3'b100; #10;
        {X, Y, BIN} = 3'b101; #10;
        {X, Y, BIN} = 3'b110; #10;
        {X, Y, BIN} = 3'b111; #10;

        $finish;
    end

endmodule