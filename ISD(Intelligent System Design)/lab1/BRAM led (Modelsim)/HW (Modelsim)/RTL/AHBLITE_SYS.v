//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT ("LICENCE") IS A LEGAL AGREEMENT BETWEEN      //
//YOU AND ARM LIMITED ("ARM") FOR THE USE OF THE SOFTWARE EXAMPLE ACCOMPANYING  //
//THIS LICENCE. ARM IS ONLY WILLING TO LICENSE THE SOFTWARE EXAMPLE TO YOU ON   //
//CONDITION THAT YOU ACCEPT ALL OF THE TERMS IN THIS LICENCE. BY INSTALLING OR  //
//OTHERWISE USING OR COPYING THE SOFTWARE EXAMPLE YOU INDICATE THAT YOU AGREE   //
//TO BE BOUND BY ALL OF THE TERMS OF THIS LICENCE. IF YOU DO NOT AGREE TO THE   //
//TERMS OF THIS LICENCE, ARM IS UNWILLING TO LICENSE THE SOFTWARE EXAMPLE TO    //
//YOU AND YOU MAY NOT INSTALL, USE OR COPY THE SOFTWARE EXAMPLE.                //
//                                                                              //
//ARM hereby grants to you, subject to the terms and conditions of this Licence,//
//a non-exclusive, worldwide, non-transferable, copyright licence only to       //
//redistribute and use in source and binary forms, with or without modification,//
//for academic purposes provided the following conditions are met:              //
//a) Redistributions of source code must retain the above copyright notice, this//
//list of conditions and the following disclaimer.                              //
//b) Redistributions in binary form must reproduce the above copyright notice,  //
//this list of conditions and the following disclaimer in the documentation     //
//and/or other materials provided with the distribution.                        //
//                                                                              //
//THIS SOFTWARE EXAMPLE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ARM     //
//EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING     //
//WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR //
//PURPOSE, WITH RESPECT TO THIS SOFTWARE EXAMPLE. IN NO EVENT SHALL ARM BE LIABLE/
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY/
//KIND WHATSOEVER WITH RESPECT TO THE SOFTWARE EXAMPLE. ARM SHALL NOT BE LIABLE //
//FOR ANY CLAIMS, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, //
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE    //
//EXAMPLE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE EXAMPLE. FOR THE AVOIDANCE/
// OF DOUBT, NO PATENT LICENSES ARE BEING LICENSED UNDER THIS LICENSE AGREEMENT.//
//////////////////////////////////////////////////////////////////////////////////


module AHBLITE_SYS(
    //CLOCKS & RESET
	input       wire            CLK,
  input       wire            RESET, 
	output		  wire		        RESET_O,
    
    //TO BOARD LEDs
    output      wire    [7:0] LEDR,
    
    //TO UART
    input       wire          UART_RXD,
    output      wire          UART_TXD,
    output      wire          UART_INQ,

    // Debug
    input       wire          TCK_SWCLK,               // SWD Clk / JTAG TCK
    input       wire          TDI_NC,                  // NC      / JTAG TDI
    inout       wire          TMS_SWDIO,               // SWD I/O / JTAG TMS
    output      wire          TDO_SWO                  // SW  Out / JTAG TDO
);
 
//AHB-LITE SIGNALS 
//Gloal Signals
  wire 			HCLK;
  wire 			HRESETn;

//Address, Control & Write Data Signals
  wire [31:0]		HADDR;
  wire [31:0]		HWDATA;
  wire 				  HWRITE;
  wire [1:0] 		HTRANS;
  wire [2:0] 		HBURST;
  wire 				  HMASTLOCK;
  wire [3:0] 		HPROT;
  wire [2:0] 		HSIZE;

//Transfer Response & Read Data Signals
  wire [31:0] 	HRDATA;
  wire 				  HRESP;
  wire 				  HREADY;

//SELECT SIGNALS
  wire [3:0] 		MUX_SEL;

  wire 				  HSEL_MEM;
  wire 				  HSEL_LED;
  wire 				  HSEL_UART;
  

//SLAVE READ DATA
  wire [31:0] 		HRDATA_MEM;
  wire [31:0] 		HRDATA_LED;
  wire [31:0] 		HRDATA_UART;

//SLAVE HREADYOUT
  wire 				HREADY_MEM;
  wire 				HREADY_LED;
  wire 				HREADY_UART;

//CM0-DS Sideband signals
  wire [31:0]		IRQ;

// CM-DS Sideband signals
  wire              lockup;
  wire              lockup_reset_req;
  wire              sys_reset_req;

//SYSTEM GENERATES NO ERROR RESPONSE
  assign 			HRESP = 1'b0;

// Interrupt signals
  assign            IRQ = 32'h00000000;

// Reset
  wire              reset_n = RESET;

  assign			RESET_O = RESET;

// AHBUART
 AHBLITE u_AHBUART(
    .HCLK(CLK),
    .HRESTEn(HRESETn),
    .HADDR(HADDR),
    .HTRANS(HTRANS),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HREADY(HREADY),
    .HSEl(HSEL_UART),
    .HREADY_UART(HREADY),
    .HRDATA(HRDATA_UART),
    .RsRX(UART_RXD),
    .RsTx(UART_TXD),
    .uart_irq(UART_INQ)
  );

// Reset synchronizer
  reg  [4:0]     reset_sync_reg;
  assign lockup_reset_req = 1'b0;

  always @(posedge CLK or negedge reset_n)
  begin
      if (!reset_n)
		    reset_sync_reg <= 5'b00000;
      else
      begin
        reset_sync_reg[3:0] <= {reset_sync_reg[2:0], 1'b1};
        reset_sync_reg[4] <= reset_sync_reg[2] &
                            (~(sys_reset_req | (lockup & lockup_reset_req)));
      end
  end

// CPU System Bus
  assign HCLK = CLK;
  assign HRESETn = reset_sync_reg[4];

// Debug signals (DesignStart Cortex-M0 supports only SWD)
  wire dbg_swdo_en;
  wire dbg_swdo;
  wire dbg_swdi;
  assign TMS_SWDIO = dbg_swdo_en ? dbg_swdo : 1'bz;
  assign dbg_swdi = TMS_SWDIO;
  wire cdbgpwrupreq2ack;

// DesignStart simplified integration level
CORTEXM0INTEGRATION u_CORTEXM0INTEGRATION (
    // CLOCK AND RESETS
    .FCLK          (CLK),
    .SCLK          (CLK),
    .HCLK          (CLK),
    .DCLK          (CLK),
    .PORESETn      (reset_sync_reg[2]),
    .DBGRESETn     (reset_sync_reg[3]),
    .HRESETn       (HRESETn),
    .SWCLKTCK      (TCK_SWCLK),
    .nTRST         (1'b1),

    // AHB-LITE MASTER PORT
    .HADDR         (HADDR),
    .HBURST        (HBURST),
    .HMASTLOCK     (HMASTLOCK),
    .HPROT         (HPROT),
    .HSIZE         (HSIZE),
    .HTRANS        (HTRANS),
    .HWDATA        (HWDATA),
    .HWRITE        (HWRITE),
    .HRDATA        (HRDATA),
    .HREADY        (HREADY),
    .HRESP         (HRESP),
    .HMASTER       (),

    // CODE SEQUENTIALITY AND SPECULATION
    .CODENSEQ      (),
    .CODEHINTDE    (),
    .SPECHTRANS    (),

    // DEBUG
    .SWDITMS       (dbg_swdi),
    .TDI           (TDI_NC),
    .SWDO          (dbg_swdo),
    .SWDOEN        (dbg_swdo_en),
    .TDO           (TDO_SWO),
    .nTDOEN        (),
    .DBGRESTART    (1'b0),
    .DBGRESTARTED  (),
    .EDBGRQ        (1'b0),               // External Debug request to CPU
    .HALTED        (),

    // MISC
    .NMI           (1'b0),               // Non-maskable interrupt input
    .IRQ           (IRQ),                // Interrupt request inputs
    .TXEV          (),                   // Event output (SEV executed)
    .RXEV          (1'b0),               // Event input
    .LOCKUP        (lockup),             // Core is locked-up
    .SYSRESETREQ   (sys_reset_req),      // System reset request
    .STCALIB       ({1'b1,               // No alternative clock source
                     1'b0,               // Exact multiple of 10ms from FCLK
                     24'h007A11F}),      // Calibration value for SysTick for 50 MHz source
    .STCLKEN       (1'b0),               // SysTick SCLK clock disable
    .IRQLATENCY    (8'h00),
    .ECOREVNUM     (28'h0),

    // POWER MANAGEMENT
    .GATEHCLK      (),
    .SLEEPING      (),                   // Core and NVIC sleeping
    .SLEEPDEEP     (),
    .WAKEUP        (),
    .WICSENSE      (),
    .SLEEPHOLDREQn (1'b1),
    .SLEEPHOLDACKn (),
    .WICENREQ      (1'b0),
    .WICENACK      (),
    .CDBGPWRUPREQ  (cdbgpwrupreq2ack),
    .CDBGPWRUPACK  (cdbgpwrupreq2ack),

    // SCAN IO
    .SE            (1'b0),
    .RSTBYPASS     (1'b0)
);

//Address Decoder 

AHBDCD uAHBDCD (
	.HADDR(HADDR), 
	.HSEL_S0(HSEL_MEM),
 	.HSEL_S1(HSEL_LED),
	.HSEL_S2(HSEL_UART),
	.HSEL_S3(),
	.HSEL_S4(),
	.HSEL_S5(),
	.HSEL_S6(),
	.HSEL_S7(),
	.HSEL_S8(),
	.HSEL_S9(),
	.HSEL_NOMAP(),
	.MUX_SEL(MUX_SEL[3:0])
);

//Slave to Master Mulitplexor

AHBMUX uAHBMUX (
	.HCLK(HCLK),
	.HRESETn(HRESETn),
	.MUX_SEL(MUX_SEL[3:0]),
	 
	.HRDATA_S0(HRDATA_MEM),
	.HRDATA_S1(HRDATA_LED),
	.HRDATA_S2(HRDATA_UART),
	.HRDATA_S3(32'h00000000),
	.HRDATA_S4(32'h00000000),
	.HRDATA_S5(32'h00000000),
	.HRDATA_S6(32'h00000000),
	.HRDATA_S7(32'h00000000),
	.HRDATA_S8(32'h00000000),
	.HRDATA_S9(32'h00000000),
	.HRDATA_NOMAP(32'hDEADBEEF),
	 
	.HREADY_S0(HREADY_MEM),
	.HREADY_S1(HREADY_LED),
	.HREADY_S2(HREADY_UART),
	.HREADY_S3(1'b1),
	.HREADY_S4(1'b1),
	.HREADY_S5(1'b1),
	.HREADY_S6(1'b1),
	.HREADY_S7(1'b1),
	.HREADY_S8(1'b1),
	.HREADY_S9(1'b1),
	.HREADY_NOMAP(1'b1),
    
	.HRDATA(HRDATA[31:0]),
	.HREADY(HREADY)
);

// AHBLite Peripherals


// AHB-Lite RAM
AHBBRAM uAHBBRAM (
	//AHBLITE Signals
	.HCLK(HCLK), 
	.HRESETn(HRESETn),      
	.HADDR(HADDR),
	.HWDATA(HWDATA[31:0]),
	.HSEL(HSEL_MEM),
	.HWRITE(HWRITE),
	.HTRANS(HTRANS[1:0]), 
	.HSIZE(HSIZE),
	.HREADY(HREADY),
	.HRDATA(HRDATA_MEM), 
	.HREADY_MEM(HREADY_MEM)
);


AHBLED uAHBLED (
   .HCLK(HCLK),
   .HRESETn(HRESETn),
   .HADDR(HADDR),
   .HWDATA(HWDATA),
   .HSEL(HSEL_LED),
   .HWRITE(HWRITE),	
   .HTRANS(HTRANS),
   .HSIZE(HSIZE),
   .HREADY(HREADY),
  
   .HRDATA(HRDATA_LED),
   .HREADY_LED(HREADY_LED),

   .LED(LEDR)
);

   
endmodule
