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

module SEG7_CORE (

  input wire HCLK,
  input wire HRESETn,
  input wire [31:0] HWDATA,
  input wire [31:0] last_HADDR,
  input wire last_HSEL,
  input wire last_HWRITE,
  input wire [1:0] last_HTRANS,
  
  output wire [31:0] HRDATA,
  //7segment display
  output wire [6:0] seg0,
  output wire [6:0] seg1,
  output wire [6:0] seg2,
  output wire [6:0] seg3

);

  localparam [3:0] DIGIT1_ADDR = 4'h0;
  localparam [3:0] DIGIT2_ADDR = 4'h4;
  localparam [3:0] DIGIT3_ADDR = 4'h8;
  localparam [3:0] DIGIT4_ADDR = 4'hC;

  reg  [3:0] write_enable = 4'b0000;

  wire [7:0] DIGIT1; 
  wire [7:0] DIGIT2;
  wire [7:0] DIGIT3;
  wire [7:0] DIGIT4; 


// Address decoder
  always@(*) 
    begin
	  write_enable = 4'b0000;
      case(last_HADDR[3:0])
          DIGIT1_ADDR : write_enable = 4'b0001;
          DIGIT2_ADDR : write_enable = 4'b0010;
          DIGIT3_ADDR : write_enable = 4'b0100;
          DIGIT4_ADDR : write_enable = 4'b1000;
      endcase
    end
    

  assign HRDATA = (write_enable[0]) ? {24'h000_0000,DIGIT1} :
                  (write_enable[1]) ? {24'h000_0000,DIGIT2} :
                  (write_enable[2]) ? {24'h000_0000,DIGIT3} :
                  (write_enable[3]) ? {24'h000_0000,DIGIT4} :
                   32'h0000_0000;
  
  


// Digit1-4 Register
REG_WE_RST #(8) digit1_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[0]& last_HWRITE & last_HSEL & last_HTRANS[1]),
  .D(HWDATA[7:0]),
  .Q(DIGIT1)
);
REG_WE_RST #(8) digit2_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[1]& last_HWRITE & last_HSEL & last_HTRANS[1]),
  .D(HWDATA[7:0]),
  .Q(DIGIT2)
);
REG_WE_RST #(8) digit3_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[2]& last_HWRITE & last_HSEL & last_HTRANS[1]),
  .D(HWDATA[7:0]),
  .Q(DIGIT3)
);
REG_WE_RST #(8) digit4_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[3]& last_HWRITE & last_HSEL & last_HTRANS[1]),
  .D(HWDATA[7:0]),
  .Q(DIGIT4)
);

// 7Segment Display Decoder
SEG7_DECODER ulightdcd1(
  .DIGIT(DIGIT1),
  .seg(seg0)
);
SEG7_DECODER ulightdcd2(
  .DIGIT(DIGIT2),
  .seg(seg1)
);
SEG7_DECODER ulightdcd3(
  .DIGIT(DIGIT3),
  .seg(seg2)
);
SEG7_DECODER ulightdcd4(
  .DIGIT(DIGIT4),
  .seg(seg3)
);


endmodule



/////////////////////////////////////////////////////////////
//////               Submodule declaration             //////
/////////////////////////////////////////////////////////////

/* 7segment decoder module */
module SEG7_DECODER(
  input wire [7:0] DIGIT,  
  output wire [6:0] seg
);

  wire [6:0] code; 
  wire [6:0] seg_out;

  assign code = DIGIT[6:0];
  assign seg = ~seg_out;      // 7-Segment Display Output (Active Low)

// 7-Segment Display Segment Definitions
  parameter A = 7'b0000001;
  parameter B = 7'b0000010;
  parameter C = 7'b0000100;
  parameter D = 7'b0001000;
  parameter E = 7'b0010000;
  parameter F = 7'b0100000;
  parameter G = 7'b1000000;

// 7-Segment Decoder Logic for Each Digit
  assign seg_out =
    (code == 7'h0) ? A|B|C|D|E|F :     
    (code == 7'h1) ? B|C :             
    (code == 7'h2) ? A|B|G|E|D :
    (code == 7'h3) ? A|B|C|D|G :
		
    (code == 7'h4) ? F|B|G|C :
    (code == 7'h5) ? A|F|G|C|D : 
    (code == 7'h6) ? A|F|G|C|D|E :
    (code == 7'h7) ? A|B|C :
		
    (code == 7'h8) ? A|B|C|D|E|F|G :
    (code == 7'h9) ? A|B|C|D|F|G :
    (code == 7'ha) ? A|F|B|G|E|C :
    (code == 7'hb) ? F|G|C|D|E :
		
    (code == 7'hc) ? G|E|D :
    (code == 7'hd) ? B|C|G|E|D :
    (code == 7'he) ? A|F|G|E|D :
    (code == 7'hf) ? A|F|G|E :
    (code == 7'h10) ? A|B|C|D|E|F|G :		
    (code == 7'h11) ? G :		        
    (code == 7'h12) ? A :				
    (code == 7'h13) ? D :				
        7'b000_0000;

endmodule