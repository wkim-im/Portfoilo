module passwordlocksystem(
    input wire clk_50,
    input wire [3:0] USERIN,
    input wire [3:0] KEY,   // KEY[3]~KEY[0]: 각 자리 확정 버튼
    input wire rst,

    output reg LEDR,
    output reg LEDG,
    output reg [6:0] H0,
    output reg [6:0] H1,
    output reg [6:0] H2,
    output reg [6:0] H3
);

    // FSM 상태 정의
    localparam ST_IDLE   = 4'd0,
               ST_INPUT0 = 4'd1,
               ST_INPUT1 = 4'd2,
               ST_INPUT2 = 4'd3,
               ST_INPUT3 = 4'd4,
               ST_VERIFY = 4'd5,
               ST_SUCCESS= 4'd6,
               ST_FAIL   = 4'd7,
               ST_STOP   = 4'd8;

    reg [3:0] state = ST_IDLE;
    reg [15:0] inputpw = 16'd0; // 비밀번호 저장장치
    wire [15:0] initialpw = 16'b0000_0001_1010_1111; // 01AF

    // clk 0.5Hz 생성 (0.25초마다 토글)
    wire clk_1;
    clk_div_pls clkdiv(.clk_50(clk_50), .clk_1(clk_1));

    wire [6:0] HIN;
    segment7_pls seg7(.B(USERIN), .H(HIN));

    reg [2:0] cnt = 0;

    reg blink = 0;
    // FSM 동기 처리
    always @(posedge clk_1 or posedge rst) begin
        blink <= ~blink;
        if (rst) begin
            state <= ST_IDLE;
            inputpw <= 16'd0;
            LEDR <= 0;
            LEDG <= 0;
            H0 <= 7'b0111111;
            H1 <= 7'b0111111;
            H2 <= 7'b0111111;
            H3 <= 7'b0111111;
            cnt <= 0;
        end else begin
            case (state)
                ST_IDLE: begin
                    H0 <= 7'b0111111;
                    H1 <= 7'b0111111;
                    H2 <= 7'b0111111;
                    H3 <= 7'b0111111;
                    LEDR <= 0;
                    LEDG <= 0;
                    if (|USERIN)begin
                        state <= ST_INPUT0;
                    end
                        
                end
                ST_INPUT0: begin
                    H0 <= blink ? 7'b1111111 : HIN;
                    if (KEY[3]==0) begin
                        H0 <= HIN;
                        inputpw[15:12] <= USERIN;
                        state <= ST_INPUT1;
                    end
                end

                ST_INPUT1: begin
                    H1 <= blink ? 7'b1111111 : HIN;
                    if (KEY[2]==0) begin
                        H1 <= HIN;
                        inputpw[11:8] <= USERIN;
                        state <= ST_INPUT2;
                    end
                end

                ST_INPUT2: begin
                    H2 <= blink ? 7'b1111111 : HIN;
                    if (KEY[1]==0) begin
                        H2 <= HIN;
                        inputpw[7:4] <= USERIN;
                        state <= ST_INPUT3;
                    end
                end

                ST_INPUT3: begin
                    H3 <= blink ? 7'b1111111 : HIN;
                    if (KEY[0]==0) begin
                        H3 <= HIN;
                        inputpw[3:0] <= USERIN;
                        state <= ST_VERIFY;
                    end
                end

                ST_VERIFY: begin
                    if (inputpw == initialpw)
                        state <= ST_SUCCESS;
                    else
                        state <= ST_FAIL;
                    cnt <= 0;
                end

                ST_SUCCESS: begin
                    LEDG <= 1;
                    H0 <= 7'b0001100; //P
                    H1 <= 7'b0001000; //A
                    H2 <= 7'b0001010; //S
                    H3 <= 7'b0001010; //S
                    cnt <= cnt + 1;
                    if (cnt == 6) begin
                        state <= ST_STOP;
                        cnt <= 0;
                    end
                        
                end

                ST_FAIL: begin
                    LEDR <= 1;
                    H0 <= 7'b0001110; //F
                    H1 <= 7'b0001000; //A
                    H2 <= 7'b1001111; //I
                    H3 <= 7'b1000111; //L
                    cnt <= cnt + 1;
                    if (cnt == 6)begin
                        state <= ST_STOP;
                        cnt <= 0;
                    end
                        
                end

                ST_STOP: begin
                    cnt <= cnt + 1;
                    if (cnt == 6) begin
                        state <= ST_IDLE;
                    end
                        
                end

            endcase
        end
    end
endmodule
