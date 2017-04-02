`timescale 1ns/10ps

module De_converter(clk,rst,REGA,REGC);

`define st0  0
`define st1  1
`define st2  2
`define st3  3
`define st4  4
`define st5  5

input        clk,rst;
input [15:0] REGA;    //GPR

output reg [15:0] REGC;

//case variable
reg [3:0] REGS;

//Temporary Variables
reg [7:0] i;
wire [35:0] A;
reg [2:0] ai, bi; 
wire enable; 
reg [15:0] x;

always @ (posedge clk)
  begin
	  if(rst)
		begin
		REGS 	<= 0;
		REGC <= 0;
		x 		= 0;
		i 		<= 0;
		ai = 0; 
		bi = 0; 
		end 
	  else
		begin 
  
		case(REGS)
		`st0: begin
				if (enable ) begin 
					for (ai = 0 ; ai < 6 ; ai = ai +1 ) begin 
					  for (bi = 0 ; bi < 6 ; bi = bi +1 ) begin  
						  i = (5 - bi) + 6 * (5 - ai );
						   x = x +  3**ai * 2**bi  * A[i] ;
						  end 
						end 
				REGS <= `st1; 
				end 
			  end 
			  
			  
		`st1: begin
				REGC <= x;  
			  end
		endcase
		end
  end
  
 DBNS_Converter_new C1(.clk(clk),.rst(rst),.REGA(REGA),.REGC(A), .enable(enable));
 
endmodule 	
