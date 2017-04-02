	`timescale 1ns/10ps

module FPP_16b(clk,rst,DataBus,opcode,flag);

`define st0 0
`define st1 1
`define st2 2
`define st3 3
`define st4 4
`define st5 5
`define st6 6
`define st7 7
`define st8 8
`define st9 9
`define st10 10
`define st11 11
`define st12 12
`define st13 13
`define st14 14
`define st15 15


input          clk,rst;
inout [15:0]   DataBus;
input [7:0]    opcode; // function[7:4],SRC[3:2],DST[1:0],

output flag;

//state register
reg [3:0] state;

//general purpose register
reg  [15:0] FP0,FP1,FP2,FP3; 
reg  [15:0] REGA,REGB; //rega temporary src regb destination
wire [15:0] DST;  // temp source and destination 

reg st;
wire enable;

//Tristate Buffeer
wire flag_io;
reg [15:0] LoadValue; 

assign flag = flag_io;
assign DataBus = flag_io ? LoadValue : 16'bzzzz_zzzz_zzzz_zzzz;
		   
always @(posedge clk) begin 
	if (rst) begin 
	FP0  = 0;
	FP1  = 0;
	FP2  = 0;
	FP3  = 0;
    REGA = 0;
	REGB = 0; 
	LoadValue = 0; 
	st = 0;	
	state = 0;
	end 
	else begin 
	
		case (state)
		`st0: begin 
				case(opcode[3:0])
				`st0: begin REGA = FP0; REGB = FP0; end 
				`st1: begin REGA = FP0; REGB = FP1; end
				`st2: begin REGA = FP0; REGB = FP2; end 
				`st3: begin REGA = FP0; REGB = FP3; end
				`st4: begin REGA = FP1; REGB = FP0; end 
				`st5: begin REGA = FP1; REGB = FP1; end 
				`st6: begin REGA = FP1; REGB = FP2; end
				`st7: begin REGA = FP1; REGB = FP3; end
				`st8: begin REGA = FP2; REGB = FP0; end
				`st9: begin REGA = FP2; REGB = FP1; end
				`st10: begin REGA = FP2; REGB = FP2; end
				`st11: begin REGA = FP2; REGB = FP3; end
				`st12: begin REGA = FP3; REGB = FP0; end
				`st13: begin REGA = FP3; REGB = FP1; end
				`st14: begin REGA = FP3; REGB = FP2; end
				`st15: begin REGA = FP3; REGB = FP3; end
				endcase 
				st = 1; state = `st1;
			  end 
		`st1: begin  st = 0 ; state = `st2;  end
		`st2: begin
				if(enable == 1) begin 
				    if (flag_io) begin 
					LoadValue = DST;
					end 
					case(opcode[1:0])
					`st0: begin FP0 = DST; end 
					`st1: begin FP1 = DST; end
					`st2: begin FP2 = DST; end 
					`st3: begin FP3 = DST; end
					endcase 
					st = 0; state = `st3; 
				end else begin st = 0; state = `st2; end 
			  end 
		`st3: begin 
			if(enable == 1) begin 
			 state = `st0;  end
			else begin 
			 state = `st3;
			end  
		      end
		//`st2: begin end 
		endcase
	end 
end 

FPP_16bALU  ALU(.clk(clk),.rst(rst),.st(st),.DATA(DataBus),.REGA(REGA),.REGB(REGB),.ALUFunction(opcode[7:4]),.REGOUT(DST),.en(enable),.flag_io(flag_io)) ;	   		   
		   
endmodule		   
