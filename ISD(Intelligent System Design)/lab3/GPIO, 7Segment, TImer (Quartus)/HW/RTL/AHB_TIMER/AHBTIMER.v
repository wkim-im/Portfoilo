//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT (밚ICENCE? IS A LEGAL AGREEMENT BETWEEN      //
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

module AHBTIMER(
	//Inputs
	input wire HCLK,
    input wire HRESETn,
    input wire [31:0] HADDR,
    input wire [31:0] HWDATA,
	input wire HSEL,
	input wire HWRITE,
    input wire [1:0] HTRANS,
    input wire HREADY,
  
	//Output
	output wire [31:0] HRDATA,
	output wire HREADY_TIMER,
	output wire timer_irq
);

 //AHB Registers
  
  wire [31:0] last_HADDR;
  wire last_HSEL;
  wire last_HWRITE;
  wire [1:0] last_HTRANS;

  // AHBLITE TIMER INTERFACE 
  AHB_TIMER_INTERFACE timer_inter (
	.HCLK(HCLK),
	.HRESETn(HRESETn),
	.HREADY(HREADY),
    .HADDR(HADDR),
	.HWRITE(HWRITE),
	.HSEL(HSEL),
	.HTRANS(HTRANS),

	.last_HADDR(last_HADDR),
	.last_HSEL(last_HSEL),
    .last_HWRITE(last_HWRITE),
	.last_HTRANS(last_HTRANS),
	.HREADY_TIMER(HREADY_TIMER)
  );

  TIMER_CORE timer_core(
    .HCLK(HCLK),
    .HRESETn(HRESETn),
	.HWDATA(HWDATA),
    .last_HADDR(last_HADDR),
	.last_HSEL(last_HSEL),
    .last_HWRITE(last_HWRITE),
    .last_HTRANS(last_HTRANS),
	
    .HRDATA(HRDATA),
    .timer_irq(timer_irq)
  );
  
endmodule