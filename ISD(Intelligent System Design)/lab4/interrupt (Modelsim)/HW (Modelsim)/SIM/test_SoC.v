//----------------------------------------------------------------------------
//The information contained in this file may only be used by a person
//authorised under and to the extent permitted by a subsisting licensing 
//agreement from Arm Limited or its affiliates 
//
//(C) COPYRIGHT 2020 Arm Limited or its affiliates
//ALL RIGHTS RESERVED.
//Licensed under the ARM EDUCATION INTRODUCTION TO COMPUTER ARCHITECTURE 
//EDUCATION KIT END USER LICENSE AGREEMENT.
//See https://www.arm.com/-/media/Files/pdf/education/computer-architecture-education-kit-eula
//
//This entire notice must be reproduced on all copies of this file
//and copies of this file may only be made by a person if such person is
//permitted to do so under the terms of a subsisting license agreement
//from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
`timescale 10ms/1ms
	
module test_SoC();
	// Clock feeds to SoC 
	reg clk = 0;
	reg nreset;  // Active low reset
	// I/O
	wire [7:0] led;
	reg uart_rxd;
	wire uart_txd;
	wire uart_inq;
	wire timer_irq;
	wire [6:0] seg0, seg1, seg2, seg3; // 7segmnet output display port 선언 
	reg  [7:0] gpioin;				   // GPIO input data port 선언
	wire [7:0] gpioout;				   // GPIO output data port 선언
	// Clock generation
	always #1 clk = ~clk;
	// Reset pulse
	initial begin
		nreset <= 0; 					// reset 신호로 모든 값 초기화
		#10;
		nreset <= 1;
	end
	// UART RX default
	initial begin
		uart_rxd <= 1;
	end
	// SoC instantiation
	AHBLITE_SYS SoC (					// AHBLITE_SYS instantiation
		.CLK        (clk),
		.RESET      (nreset),
		.RESET_O    (),
		.LEDR       (led),
		.UART_RXD   (uart_rxd),
		.UART_TXD   (uart_txd),
		.UART_INQ   (uart_inq),
		.TCK_SWCLK  (),
		.TDI_NC     (),
		.TMS_SWDIO  (),
		.TDO_SWO    (),
		.TIMER_IRQ  (timer_irq),
		.seg0         (seg0),			// 7seg digit1과 seg0 port 연결
		.seg1         (seg1),			// 7seg digit2과 seg1 port 연결
		.seg2         (seg2),			// 7seg digit3과 seg2 port 연결
		.seg3         (seg3),			// 7seg digit4과 seg3 port 연결
		.GPIOIN     (gpioin),			// GPIOIN port 연결
		.GPIOOUT    (gpioout));			// GPIOOUT port 연결
	initial begin
		#500000000  $finish;
	end


endmodule 