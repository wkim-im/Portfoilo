`timescale 10ns/1ps
module TB_Half_Adder;

	reg x,y;
	wire sum,carry;

	Half_Adder ha1(.SUM(sum),.CARRY(carry),.X(x),.Y(y));
	
	initial
	begin
	x=1'b0; y=1'b0;
	#2 x=1'b0; y=1'b1;
	#2 x=1'b1; y=1'b0;
	#2 x=1'b1; y=1'b1;
	#2 $finish;
	end
endmodule