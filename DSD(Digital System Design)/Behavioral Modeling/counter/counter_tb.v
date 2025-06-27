module counter_tb;
    wire [3:0] q;
    reg clk, clr;

    counter cnt1(.q(q),.clk(clk),.clr(clr));

    always  #1 clk=~clk;

	initial
	begin
	clk=1'b0; clr=1'b0;

	#4 clr=1'b1;
	#16 clr=1'b0;
	#3 clr=1'b0;
	#1 clr=1'b1;
    #16 $finish;
	end
endmodule