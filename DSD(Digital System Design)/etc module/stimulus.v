module stimulus;

    reg x,y,a,b,m;

    initial begin
        $dumpfile("stimulus.vcd");
        $dumpvars(0, stimulus);
    end
    initial
    
        m=1'b0; //begin end로 그룹화할 필요없음

    initial begin
        #5 a=1'b1;
        #10 b=1'b0;
    end

    initial begin
        #10 x=1'b0;
        #25 y=1'b1;
    end

    initial
        #50 $finish
    
endmodule