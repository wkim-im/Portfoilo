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
module TIMER_CORE(

  input wire HCLK,
  input wire HRESETn,
  input wire [31:0] HWDATA,
  input wire [31:0] last_HADDR,
  input wire last_HSEL,
  input wire last_HWRITE,
  input wire [1:0] last_HTRANS,
  
  output wire [31:0] HRDATA,
  output wire  timer_irq

);

  localparam [3:0] LDADDR  = 4'h0;   //load register address
  localparam [3:0] VALADDR = 4'h4;  //value register address
  localparam [3:0] CTLADDR = 4'h8;  //control register address
  localparam [3:0] CLRADDR = 4'hC;  //clear register address

  reg  [3:0] write_enable = 4'b0000;

//internal registers
  wire en_prescale;
  wire [31:0] load;
  wire [31:0] value;
  wire [3:0]  control;
  wire        clear;
  wire [31:0] value_next;
  
//Timer control signals
  wire enable;
  wire mode;

  //Prescaled clk signals
  wire timerclk;

// Address decoder
  always@(*) 
    begin
      write_enable = 4'b0000;
      case(last_HADDR[3:0])
          LDADDR  : write_enable = 4'b0001;
          VALADDR : write_enable = 4'b0010;
          CTLADDR : write_enable = 4'b0100;
          CLRADDR : write_enable = 4'b1000;
      endcase
    end
  
  
  assign HRDATA = (write_enable[0] ) ? load :
                  (write_enable[1] ) ? value:
                  (write_enable[2] ) ? control :
                   32'h0000_0000;

  assign enable = control[0];
  assign mode  = control[1];
  assign en_prescale = control[2];
  
// Prescaler 
PRESCALER uprescaler16(
  .inclk(HCLK), 
  .EN(en_prescale),
  .outclk(timerclk)
);
                  

// Load Value Register
REG_WE_RST #(32) load_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[0]& last_HWRITE & last_HSEL & last_HTRANS[1]),
  .D(HWDATA),
  .Q(load)
);

// Current Value Register 
REG_WE_RST #(32) value_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(1'b1),
  .D(value_next),
  .Q(value)
);

// Control Value Register
REG_WE_RST #(4) control_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[2]& last_HWRITE & last_HSEL & last_HTRANS[1]),
  .D(HWDATA[3:0]),
  .Q(control)
); 

// Clear Value Register 
REG_WE_RST #(1) clear_reg(
  .CLK(HCLK),
  .RST(HRESETn),
  .WE(write_enable[3]& last_HWRITE & last_HSEL & last_HTRANS[1]),
  .D(HWDATA[0]),
  .Q(clear)
); 


// 32-bit Counter 
COUNTER ucounter(
  .HCLK(HCLK),
  .HRESETn(HRESETn),
  .enable(enable),
  .mode(mode),
  .clear(clear),
  .timerclk(timerclk),
  .load(load),
  .value(value),
	
  .value_next(value_next),
  .timer_irq(timer_irq)
  );

endmodule


/////////////////////////////////////////////////////////////
//////               Submodule declaration             //////
/////////////////////////////////////////////////////////////

//Prescaler
module PRESCALER
(
  input wire inclk,
  input wire EN,
  output wire outclk
  
);

  wire clk16;
  reg [3:0] counter = 4'b0000;


  always @(posedge inclk)
    counter <= counter + 1'b1;
  
  assign clk16 = (counter == 4'b1111);

  //Prescale clk based on control[2]  01 = 16 ; 00 = 1;
  assign outclk = ((EN) ? clk16 : 1'b1);  //1'b1 signifies HCLK

endmodule



//32bit counter
module COUNTER(
  input wire HCLK,
  input wire HRESETn,
  input wire enable,
  input wire mode,
  input wire clear,
  input wire timerclk,
  input wire [31:0] load,
  input wire [31:0] value,
	
  output reg [31:0] value_next,
  output reg  timer_irq
); 
  localparam st_idle = 1'b0;
  localparam st_count = 1'b1;
  
  reg current_state;
  reg next_state;
  reg timer_irq_next;
  
  
 always @(posedge HCLK, negedge HRESETn)
    if(!HRESETn)
      timer_irq <= 1'b0;
    else
      timer_irq <= timer_irq_next;
           
  //State Machine    
  always @(posedge HCLK, negedge HRESETn)
    if(!HRESETn)
      begin
        current_state <= st_idle;
        //value <= 32'h0000_0000;
      end
    else
      begin
        //value <= value_next;
        current_state <= next_state;
      end
  
  //Timer Operation and Next State logic
  always @*
  begin
    next_state = current_state;
    value_next = value;
    timer_irq_next = (clear) ? 0 : timer_irq;
    case(current_state)
      st_idle:
        if(enable && timerclk)
            begin
              value_next = load;
              next_state = st_count;
            end
      st_count:
        if(enable && timerclk)      //if disabled timer stops
            if(value == 32'h0000_0000)
              begin
                timer_irq_next = 1;
                if(mode == 0)           //If mode=0 timer is free-running counter
                  value_next = value-1;
                else if(mode == 1)      //If mode=1 timer is periodic counter;
                  value_next = load;
              end
            else
              value_next = value-1;
   	 endcase
  end
endmodule
