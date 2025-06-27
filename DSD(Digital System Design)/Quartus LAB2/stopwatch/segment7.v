module counter_m (
    input wire clk,
    input wire rst,
    output wire [6:0] hout
);

wire [3:0] out;
counter cnt(.q(out),.clk(clk),.clr(rst));
segment7 seg7(.B(out),.H(hout));

    
endmodule



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

module segment7 (
    input [3:0] B,
    output reg [6:0] H
);

    always @(*) begin
        case (B)
            4'b0000 : H = 7'b1000000; //0 1000000
            4'b0001 : H = 7'b1111001; //1 1111001
            4'b0010 : H = 7'b0100100; //2 0100100
            4'b0011 : H = 7'b0110000; //3 0110000
            4'b0100 : H = 7'b0011001; //4 0011001
            4'b0101 : H = 7'b0010010; //5 0010010
            4'b0110 : H = 7'b0000010; //6 0000010
            4'b0111 : H = 7'b1111000; //7 1111000
            4'b1000 : H = 7'b0000000; //8 0000000
            4'b1001 : H = 7'b0010000; //9 0010000
            4'b1010 : H = 7'b0001000; //A 0001000
            4'b1011 : H = 7'b0000011; //b 0000011
            4'b1100 : H = 7'b1000110; //C 1000110
            4'b1101 : H = 7'b0100001; //d 0100001
            4'b1110 : H = 7'b0000110; //E 0000110
            4'b1111 : H = 7'b0001110; //F 0001110        
            default: H = 7'b1111111;  // all off
        endcase
    end

endmodule