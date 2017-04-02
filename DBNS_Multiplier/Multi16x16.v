`timescale 1ns/10ps

module Mult16x16(clk,rst,
                 REGA,REGB,REGC);
				 
`define st0 0
`define st1 1
`define st2 2
`define st3 3
`define st4 4	

input         clk,rst;	
input[15:0]   REGA,REGB;    
output reg [31:0] REGC;	

wire [15:0] rega,regb;
reg [31:0] regc;
reg [3:0] REGS;

//Temporary Variables

assign rega = REGA;
assign regb = REGB;         
           
always @ (posedge clk)
  begin
  if(rst)
    begin
        REGS = 0;
	regc = 0;
	REGC = 0;
    end 
  else
    begin  	 
		case(REGS)
                          `st0 : begin regc = rega * regb; REGS = `st1; end
			  `st1 : begin REGC = regc; REGS = `st0; end  
		//	  `st0 : begin regc = rega[7:0] * regb[7:0];                  REGS = `st1; end
		//	  `st1 : begin regc[31:16] = rega[15:8] * regb[15:8];         REGS = `st2; end
		//	  `st2 : begin regc = regc + ((rega[15:8] * regb[7:0]) << 8); REGS = `st3; end
		//	  `st3 : begin regc = regc + ((rega[7:0] * regb[15:8]) << 8); REGS = `st4; end
		//	  `st4 : begin REGC = regc; REGS = `st0; end
		endcase
	end
end
 
endmodule 
