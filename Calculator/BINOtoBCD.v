`timescale 1ns / 1ps

module BINOtoBCD(ans, d1, d2, d3, d4, d5, d6 , reqconversion, conversiondone);
	
	input		[19:0]				ans;
	input								reqconversion;
	output	reg		[7:0]		d1;
	output	reg		[7:0]		d2;
	output	reg		[7:0]		d3;
	output	reg		[7:0]		d4;
	output	reg		[7:0]		d5;
	output	reg		[7:0]		d6;
	output	reg					conversiondone;
	
	reg					[43:0]	shift;
	reg					[4:0]		i;
	reg								st;
	
	initial begin
		st=0;
		i=0;
	end
	always @(*) begin
		case(st)
		0: begin
			if(reqconversion==1) begin st=1; conversiondone=0; end
			else st=0;
		end
		1: begin
			shift[43:20]=0; shift[19:0]=ans; i=0;
			while(i<20) begin
				if (shift[23:20]>=5) shift[23:20]=shift[23:20]+3;
				if (shift[27:24]>=5) shift[27:24]=shift[27:24]+3;
				if (shift[31:28]>=5) shift[31:28]=shift[31:28]+3;
				if (shift[35:32]>=5) shift[35:32]=shift[35:32]+3;
				if (shift[39:36]>=5) shift[39:36]=shift[39:36]+3;
				if (shift[43:40]>=5) shift[43:40]=shift[43:40]+3;
				shift = shift << 1;
				i=i+1;
			end
				//default:i=0;
			//endcase	
			d1=shift[43:40];
			d2=shift[39:36];
			d3=shift[35:32];
			d4=shift[31:28];
			d5=shift[27:24];
			d6=shift[23:20];
			conversiondone=1;
		end
		endcase
	end
endmodule	
		
			
			
			
		
