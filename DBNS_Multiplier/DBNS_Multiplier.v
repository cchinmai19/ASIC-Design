`timescale 1ns/10ps

module DBNS_Multiplier(clk,rst,REGA,REGB,REGC);

`define st0  0
`define st1  1
`define st2  2
`define st3  3
`define st4  4
`define st5  5

input        clk,rst;
input [15:0] REGA,REGB;    //GPR

output reg [31:0] REGC;

//case variable
reg [3:0] REGS;

//Temporary Variables
reg [7:0] i,j;
wire [35:0] A,B;
reg [2:0] ai, bi,aj,bj ; 
wire enable; 
reg [31:0] x;

always @ (posedge clk)
  begin
	  if(rst)
		begin
		REGS 	<= 0;
		REGC <= 0;
		x 		= 0;
		i 		<= 0;
		j <= 0;
		ai = 0; 
		bi = 0; 
		aj = 0 ; 
		bj = 0 ; 
		end //if()
	  else
		begin 
  
		case(REGS)
		`st0: begin
				if (enable ) begin 
					for (ai = 0 ; ai < 6 ; ai = ai +1 ) begin 
					  for (bi = 0 ; bi < 6 ; bi = bi +1 ) begin 
					    for (aj = 0 ; aj < 6 ; aj = aj +1 ) begin 
					      for (bj = 0 ; bj < 6 ; bj = bj +1 ) begin 
						  i = (5 - bi) + 6 * (5 - ai );
						  j = (5 - bj) + 6 * (5 - aj );
						   if (A[i] == 1 && B[j] == 1) begin
						   x =  x + (3**aj * 2**bj  * B[j] * 3**ai * 2**bi  * A[i] ); end 
						  end 
						end 
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
 DBNS_Converter_new C2(.clk(clk),.rst(rst),.REGA(REGB),.REGC(B), .enable(enable));
 
endmodule 	
