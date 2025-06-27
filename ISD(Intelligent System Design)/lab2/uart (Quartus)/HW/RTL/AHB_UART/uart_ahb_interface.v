//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT (�LICENCE�) IS A LEGAL AGREEMENT BETWEEN      //
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

module UART_AHB_INTERFACE (
  input wire              HCLK,
  input wire              HRESETn,
  input wire [31:0]       HADDR,
  input wire [31:0]       HWDATA, 
  input wire              HSEL,
  input wire              HWRITE,
  input wire [1:0]        HTRANS,
  input wire              HREADY,
    
  input wire tx_full, 
  input wire rx_empty,
  input wire [7:0] uart_rdata,
  
  output wire [7:0] uart_wdata,
  output wire uart_wr,
  output wire uart_rd,
  output wire [31:0] HRDATA,
  output wire HREADY_UART,
  output wire uart_irq
        
);
  reg [1:0] last_HTRANS;
  reg last_HWRITE;
  reg last_HSEL;
  reg [31:0] last_HADDR;
  
  wire [7:0] status;
  
  
  //Set Registers for AHB Address State
  always @(posedge HCLK or negedge HRESETn)
  begin
    if(!HRESETn) 
    begin
      last_HADDR <= 32'h0000_0000;
      last_HSEL <= 1'b0;
      last_HWRITE <= 1'b0;
      last_HTRANS <= 2'b00;
    end
   else if(HREADY) 
    begin
      last_HADDR <= HADDR;
      last_HSEL <= HSEL;
      last_HWRITE <= HWRITE;
      last_HTRANS <= HTRANS;
    end
  end
  
  
  //If Read and FIFO_RX is empty - wait.
  assign HREADY_UART = ~tx_full;
  
   //Only write last 8 bits of Data
  assign uart_wdata = HWDATA[7:0];
  
  //UART  write select
  assign uart_wr = last_HTRANS[1] & last_HWRITE & last_HSEL& (last_HADDR[7:0]==8'h00);
  
  //UART read select
  assign uart_rd = last_HTRANS[1] & ~last_HWRITE & last_HSEL & (last_HADDR[7:0]==8'h00);
  
  
  // HRDATA: Returns FIFO data or status
  assign HRDATA = (last_HADDR[7:0]==8'h00) ? {24'h0000_00,uart_rdata}:{24'h0000_00,status};      
  assign status = {6'b000000,tx_full,rx_empty};

  assign uart_irq = ~rx_empty;  
  
endmodule