module alu (
    output reg [3:0] OUT,
    input wire [2:0] sel,
    input wire [3:0] IN0,
    input wire [3:0] IN1
);
    always @(sel,IN0,IN1) begin // always @* 또는 always @(*) 사용 가능
    case (sel)
      3'b000 : OUT = IN0;
      3'b001 : OUT = IN0+IN1;
      3'b010 : OUT = IN0-IN1;
      3'b011 : OUT = IN0/IN1;
      3'b100 : OUT = IN0%IN1;
      3'b101 : OUT = IN0<<1;
      3'b110 : OUT = IN0>>1;
      3'b111 : OUT = (IN0>IN1);
      default: OUT = 4'b0000;
    endcase        
    end
    
endmodule

/* Verilog에서 case는 **절차적 문(statement)**이기 때문에,
절차적 블록(procedural block) 안에서만 의미 있게 동작한다.

절차적 블록이란?
always @(...) begin ... end

initial begin ... end

이런 블록 안에서만 case, if, for 같은 절차적 문장이 유효함. */