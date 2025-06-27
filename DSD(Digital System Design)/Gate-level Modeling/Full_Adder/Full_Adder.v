module Full_Adder(SUM,C_O,X,Y,C_I);
	output wire SUM,C_O;
	input wire X,Y,C_I;

	wire xy1,s1;
	and a1(xy1,X,Y);
	xor x1(s1,X,Y);

	wire s1ci;
	and a2(s1ci, s1, C_I);
	xor	x2(SUM, s1, C_I);
	or	r1(C_O,s1, s1ci); 

endmodule