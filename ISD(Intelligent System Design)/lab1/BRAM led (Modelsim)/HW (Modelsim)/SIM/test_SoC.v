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
	reg 		clk = 0;
	reg         nreset;             // Active low reset

	// LED
	wire	[7:0]	led;
	reg uart_rxd;
	wire uart_txd;
	
	
	// Clock ratio for SoC. 
	// Changing the ratio and phase can produce unpredictable results. 
	always #1 clk = ~clk;

	// nreset input
	initial begin
		nreset   	<= 0;
		#(10)
		nreset   	<= 1;
	end

	initial begin
		uart_rxd <=1;
	end


	// SoC instantiation
	AHBLITE_SYS	SoC (
		.CLK			(clk),
		.RESET			(nreset),
		.RESET_O		(),
		
		//LED
		.LEDR			(led),
		.UART_RXD		(uart_rxd),
		.UART_TXD		(uart_txd),
		
		// ETC
		.TCK_SWCLK		(),
		.TDI_NC			(),
		.TMS_SWDIO		(),
		.TDO_SWO		()
	);
	
	// Siganals dump for debugging
	initial
	begin
//		$shm_open("SoC.shm");
//		$shm_probe("AC");
		#(400000)
		$finish;
	end

endmodule
