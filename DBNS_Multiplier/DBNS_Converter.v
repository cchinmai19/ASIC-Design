`timescale 1ns/10ps

module DBNS_Converter_new(clk,rst,REGA,REGC,enable);


`define st0  0
`define st1  1
`define st2  2
`define st3  3
`define st4  4
`define st5  5


input        clk,rst;
input [15:0] REGA;    //GPR

output reg [35:0] REGC;
output reg enable;

reg [3:0] REGS;
reg [15:0] diff;
reg [7:0] i;
reg [15:0] ai, bi;
reg [35:0] x;
reg E;

always @ (posedge clk)
  begin
  if(rst)
    begin
    REGC <= 0;
    REGS = 0;
    diff = 0;
    ai = 5;
    bi = 5;
    i = 0;
    x = 0;
	E = 0;
	enable <= 0;
    end //if()
  else
    begin 
	case(REGS)
			`st0: begin ai = 5;
						bi = 5; 
						diff = REGA;
						i = 0 ; 
						x = 0;
						E = 0;
						REGS = `st2; 
						end
			`st1: begin			
			         if(bi == 0 ) begin 
							if (ai == 0 ) begin 
								E = 1; end
						    else begin 
							bi = 5 ; ai = ai - 1; 
					        end 
					 end else begin 
							bi = bi - 1 ;    
							end 
					 REGS = `st2;
				  end
			`st2: begin
					i = (5 - bi) + (6 * (5 - ai ));
					if(diff >= 3**ai * 2**bi) begin 
					     if (diff == 3**ai * 2**bi)begin 
						E = 1; end	
						REGS = `st3;
					end else begin 
							REGS = `st4;
						   end
				  end 
			`st3: begin
					diff = diff - (3**ai * 2**bi) ; 
					x[i] = 1 ; 
					 if (E == 1 ) begin 
					 REGS = `st5;
					 end else begin
				         REGS = `st1;  
					 end 
				  end 
			`st4: begin
					diff = diff ; 
					x[i] = 0 ; 
					if (E == 1) begin 
					REGS = `st5;
					end else begin 
					REGS = `st1;
					end 
				  end 
			`st5: begin
					REGC <= x;
					REGS = `st0;
					enable <= 1;
			      end
	endcase			  		
	end 
 end 
 
endmodule 
