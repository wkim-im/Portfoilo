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

//  --========================================================================--
//  Version and Release Control Information:
//
//  File Name           : AHB2BRAM.v
//  File Revision       : 1.60
//
//  ----------------------------------------------------------------------------
//  Purpose             : Basic AHBLITE Internal Memory Default Size = 16KB
//                        
//  --========================================================================--
module AHBBRAM			// SIZE[Bytes] = 2 ^ MEMWIDTH[Bytes] = 2 ^ MEMWIDTH / 4[Entries]
(
  //Slave Select Signals
  input wire HSEL,
  //Global Signal
  input wire HCLK,
  input wire HRESETn,
  //Address, Control & Write Data
  input wire HREADY,
  input wire HWRITE,
  input wire [1:0] HTRANS,
  input wire [2:0] HSIZE,
  input wire [31:0] HADDR,
  input wire [31:0] HWDATA,
  // Transfer Response & Read Data
  output wire HREADY_MEM,
  output wire [31:0] HRDATA
);

  wire APhase_HSEL;
  wire APhase_HWRITE;
  wire [1:0] APhase_HTRANS;
  wire [2:0] APhase_HSIZE;
  wire [31:0] APhase_HRADDR;
  wire [31:0] APhase_HWADDR;
 
  
// AHB Memory Interface  
MEM_AHB_INTERFACE mem_inter1(
  .HCLK(HCLK),
  .HRESETn(HRESETn),
  .HSEL(HSEL),
  .HREADY(HREADY),
  .HWRITE(HWRITE),
  .HTRANS(HTRANS),
  .HSIZE(HSIZE),
  .HADDR(HADDR),
  .APhase_HSEL(APhase_HSEL),
  .APhase_HWRITE(APhase_HWRITE),
  .APhase_HTRANS(APhase_HTRANS),
  .APhase_HSIZE(APhase_HSIZE),
  .APhase_HRADDR(APhase_HRADDR),
  .APhase_HWADDR(APhase_HWADDR)
);

// Memory Core
MEM_CORE mem1(
  .HCLK(HCLK),
  .APhase_HSEL(APhase_HSEL),
  .APhase_HWRITE(APhase_HWRITE),
  .APhase_HTRANS(APhase_HTRANS),
  .APhase_HSIZE(APhase_HSIZE),
  .APhase_HWADDR(APhase_HWADDR),
  .HADDR(HADDR),
  .HWDATA(HWDATA),
  .HRDATA (HRDATA),
  .HREADY_MEM(HREADY_MEM)
);


endmodule
