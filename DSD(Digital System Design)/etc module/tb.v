`timescale 1ns/1ns
module tb;

  reg [3:0] a, b;

  initial begin
    $dumpfile("tb.vcd");      // VCD 파일 이름
    $dumpvars(0, tb);           // tb 모듈 내 모든 변수 기록

    $monitor("Time=%0t : a=%0d, b=%0d", $time, a, b);

    // 블로킹 할당 테스트
    a = 0; b = 0;
    #5 a = a + 1;   // a = 1
    #5 b = a + 1;   // b = 2
    #10;

    // 넌블로킹 할당 테스트
    a = 0; b = 0;
    #5 a <= a + 1;  // 예약
    #5 b <= a + 1;  // 예약 시점에 a는 0
    #10;

    $finish; // 시뮬레이션 종료
  end

endmodule
