`define N[0] 7'b1000000; //0 1000000
`define N[1] 7'b1111001; //1 1111001
`define N[2] 7'b0100100; //2 0100100
`define N[3] 7'b0110000; //3 0110000
`define N[4] 7'b0011001; //4 0011001
`define N[5] 7'b0010010; //5 0010010
`define N[6] 7'b0000010; //6 0000010
`define N[7] 7'b1111000; //7 1111000
`define N[8] 7'b0000000; //8 0000000
`define N[9] 7'b0010000; //9 0010000

module rca_7seg_4b (
    input wire [3:0] X,
    input wire [3:0] Y,
    input wire C_IN,
    output wire [6:0] X7,
    output wire [6:0] Y7,
    output wire [6:0] OUT10,
    output wire [6:0] OUT1
    );
    

    wire C_OUT;
    wire [3:0] SUM;
    
    4bit_rca 4brca1(.X(X),.Y(Y),.C_IN(C_IN),.SUM(SUM),.C_OUT(C_OUT));

    7segment segX(.B(X),.H(X7));
    7segment segY(.B(Y),.H(Y7));

    genvar i;
    always @(*) begin
            for (i=0, i<=30 ,i++)begin
            if({COUT,SUM}==i)begin
                OUT10=N[i%10];
                OUT1=N[i%1];
            end
        end
    end

// 여기를 수정했다고 치고고
endmodule


/*
if A+B > 10
    print (10의 자리)
    print (1의 자리)

else 
    print 1의 자리


0000 + 0000 = 00000 // 0+0 = 00
0000 + 0001 = 00001 // 0+1 = 01
..
..
0010 + 1000 = 01010 // 2+8 = 10
..

1111 + 1111 = 11110 // 15 + 15 = 30


case (COUT,SUM)
    5'b00000 : OUT10=N0; OUT1=N0;
    default: 
endcase
*/