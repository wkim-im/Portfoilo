module Half_Adder(SUM,CARRY,X,Y);
	output wire SUM,CARRY;
	input wire X,Y;

	and a1(CARRY,X,Y);
	xor xo(SUM,X,Y);

endmodule