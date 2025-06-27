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


module GPIO_CORE(
  input wire HCLK,
  input wire HRESETn,
  input wire [31:0] HWDATA,
  input wire [31:0] last_HADDR,
  input wire last_HWRITE,
  input wire last_HSEL,
  input wire [1:0] last_HTRANS,
  input wire [7:0] GPIOIN,
    
  output wire [7:0] GPIOOUT,
  output wire [31:0] HRDATA
);
  
  localparam [7:0] gpio_data_addr = 8'h00;
  localparam [7:0] gpio_dir_addr = 8'h04;
  
  reg  [1:0] write_enable;
  wire [7:0] gpio_dir;
  wire [7:0] GPIO_REG_IN;
  wire [7:0] GPIO_REG_OUT;
  
// Address decoder
  always@(*)
    begin
      write_enable = 2'b00;
      case(last_HADDR[7:0])
        gpio_data_addr : write_enable = 2'b01;
        gpio_dir_addr  : write_enable = 2'b10;
      endcase
    end

//HRDATA
  assign HRDATA = (!gpio_dir[0]) ? {24'h0000, GPIO_REG_IN} :
                  ( gpio_dir[0]) ? {24'h0000, GPIO_REG_OUT}:
                  32'h0000_0000;

//GPIO OUTPUT 
  assign GPIOOUT = GPIO_REG_OUT;


//Output Data register
REG_WE_RST #(8) o_data_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[0] & gpio_dir[0] & last_HSEL & last_HWRITE & last_HTRANS[1]),
  .D(HWDATA[7:0]),
  .Q(GPIO_REG_OUT)
);
  
//Input Data register
REG_WE_RST #(8) i_data_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(1'b1),
  .D(GPIOIN),
  .Q(GPIO_REG_IN)
);

//Direction register
REG_WE_RST #(8) dir_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[1] & last_HSEL & last_HWRITE & last_HTRANS[1]),
  .D(HWDATA[7:0]),
  .Q(gpio_dir)
);
  
endmodule
  




  

  
  