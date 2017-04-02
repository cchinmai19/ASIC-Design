module calculate(USER_CLK,senddata, data, stringdone, ScanValue, valid, ready, calcstate, RESET, lcddata, itishyper, itislcd);
		   
	input					USER_CLK;
	input 					senddata;
	input 		[7:0]		ScanValue;
	input					RESET;
	output reg				stringdone;
	output reg	[7:0]		data;
	output reg				ready;
	output reg				valid;
	output reg 	[3:0]		calcstate;
	output reg	[7:0]		lcddata;
	output reg				itishyper;
	output reg				itislcd;
		
	reg						reqconversion;
	reg			[9:0]		number11, number12, number13;
	reg			[9:0]		number21, number22, number23;
	reg			[9:0]		number1, number2;
	reg			[3:0]		i;
	reg			[7:0]		operation;
	reg			[19:0]	ans;
	wire			[3:0]		D1, D2, D3, D4, D5, D6;
	wire						conversiondone;
	
	reg			[16:0]		j;
		
	initial begin
		i = 0;
		j = 0;
		ready = 1;
		calcstate = 0;
		itishyper<=1;
	end

	BINOtoBCD numconverter(ans, D1, D2, D3, D4, D5, D6, reqconversion, conversiondone);
	
	
	
	
	
	
	
	
	always @(posedge USER_CLK) begin //when Calc requests for senddata
		if(RESET) calcstate<=0;
		case(calcstate)
		
			0 : begin
				valid <= 1;
				ready <= 0;
				calcstate <= 1;
				itishyper<=1;
				itislcd<=1;
				
			end	
				
			1 : begin 
				if (senddata)
				case(ScanValue)
					"0", "1", "2", "3", "4", "5", "6", "7", "8", "9": begin
						ready <= 1;
						valid <= 1;
						number11 <= ScanValue-8'b00110000;
						data <= ScanValue;
						lcddata<=ScanValue;
						calcstate<=2;
						stringdone <= 1;
					end
					"N": begin
						valid <= 1;
						ready <= 0;
						calcstate <= 12;
						stringdone <= 0;
					end
					default: begin calcstate <= 1; valid <= 0;  end
				endcase
				
			end
			2 : begin
				if (senddata)
				case(ScanValue)
					"0", "1", "2", "3", "4", "5", "6", "7", "8", "9": begin
						valid <= 1;
						number12 <= ScanValue-8'b00110000;
						data <= ScanValue;
						lcddata<=ScanValue;
						stringdone <= 1;
						calcstate <= 3;
					end
					"+" , "*" , "<" , ">": begin
						valid <= 1;
						data <= ScanValue;
						lcddata<=ScanValue;
						number1 <= number11;
						operation <= ScanValue;
						calcstate <= 5;
						stringdone <= 1;
					end
					"N": begin
						valid <= 1;
						ready <= 0;
						calcstate <= 12;
						stringdone <= 0;
					end	
					default: begin calcstate <= 2; valid <= 0;  end	
				endcase

			end
			3 : begin 
				if (senddata)
				case(ScanValue)
					"0", "1", "2", "3", "4", "5", "6", "7", "8", "9": begin
						valid <= 1;
						number13 <= ScanValue-8'b00110000;
						data <= ScanValue;
						lcddata<=ScanValue;
						calcstate <= 4;
						stringdone <= 1;
					end
					"+" , "*" , "<" , ">": begin
						valid <= 1;
						data <= ScanValue;
						number1 <= 10*number11+number12;
						operation <= ScanValue;
						lcddata<=ScanValue;
						calcstate <= 5;
						stringdone <= 1;
					end
					"N": begin
						valid <= 1;
						ready <= 0;
						calcstate <= 12;
						stringdone <= 0;
					end	
					default: begin calcstate <= 3; valid <= 0;  end
				endcase
			end
			4 : begin 
				if (senddata)
				case(ScanValue)
					"+" , "*" , "<" , ">": begin
						valid <= 1;
						data <= ScanValue;
						lcddata<=ScanValue;
						number1 <= 100*number11+10*number12+number13;
						operation <= ScanValue;
						calcstate <= 5;
						stringdone <= 1;
					end
					"N": begin
						valid <= 1;
						ready <= 0;
						calcstate <= 12;
						stringdone <= 0;
					end	
					default: begin 
						calcstate <= 4; valid <= 0;
					end
				endcase
			end
			5 : begin
				if (senddata)
				case(ScanValue)
					"0", "1", "2", "3", "4", "5", "6", "7", "8", "9": begin
						valid<=1;
						number21<=ScanValue-8'b00110000;
						data<=ScanValue;
						lcddata<=ScanValue;
						calcstate<=6;
						stringdone<=1;
					end	
					"N": begin
						valid<=1;
						ready<=0;
						calcstate<=12;
						stringdone<=0;
					end
					default: begin calcstate <= 5; valid<=0;  end
				endcase
			end
			6 : begin 
				if (senddata)
				case(ScanValue)
					"0", "1", "2", "3", "4", "5", "6", "7", "8", "9": begin
						valid<=1;
						number22<=ScanValue-8'b00110000;
						data<=ScanValue;
						lcddata<=ScanValue;
						calcstate<=7;
						stringdone<=1;
					end
					"Y": begin
						valid<=1;
						ready<=0;
						data<=ScanValue;
						number2<=number21;
						calcstate<=9;
						stringdone<=0;
					end
					"N": begin
						valid<=1;
						ready<=0;
						calcstate<=12;
						stringdone<=0;
					end
					default: begin calcstate <= 6; valid<=0;  end
				endcase
			end
			7 : begin 
				if (senddata)
				case(ScanValue)
					"0", "1", "2", "3", "4", "5", "6", "7", "8", "9": begin
						valid<=1;
						number23<=ScanValue-8'b00110000;
						data<=ScanValue;
						lcddata<=ScanValue;
						calcstate<=8;
						stringdone<=1;
					end
					"Y": begin
						valid<=1;
						ready<=0;
						data<=ScanValue;
						number2<=10*number21+number22;
						calcstate<=9;
						stringdone<=0;
					end
					"N": begin
						valid<=1;
						ready<=0;
						calcstate<=12;
						stringdone<=0;
					end	
					default: begin calcstate <= 7; valid<=0;  end
				endcase
			end
			8 : begin
				if (senddata)
				case(ScanValue)
					"Y": begin
						valid<=1;
						ready<=0;
						data<=ScanValue;
						number2<=100*number21+10*number22+number23;
						calcstate<=9;
						stringdone<=0;
					end
					"N": begin
						valid<=1;
						ready<=0;
						calcstate<=12;
						stringdone<=0;
					end	
					default: begin calcstate <= 8; valid<=0;  end
				endcase
			end
			9 : begin
				
				case(operation)
					"+": begin ans<=number1+number2; end
					"*": begin ans<=number1*number2; end
					"<": begin
						if (number1<number2) ans<="T";
						else ans<="F";
					end
					">": begin
						 if (number1>number2) ans<="T";
						 else ans<="F";
					end
				endcase
				if (senddata)
				case(i)
				0: begin ready<=1; itishyper<=0; lcddata<= 8'hC0; i<=1; end
				1: begin ready<=1; itishyper<=1; data<="="; lcddata<="="; i<=2; end
				2: begin ready<=0; i<=0; calcstate<=10; end
				default: i<=0;
				endcase
			end
			10: begin
				if (senddata)
				case(ans)
					"T" : begin
						ready<=1;
						case(i)
						0:	begin data<="T"; lcddata<="T"; i<=1; end
						1:	begin data<="R"; lcddata<="R"; i<=2; end
						2:	begin data<="U"; lcddata<="U"; i<=3; end
						3:	begin data<="E"; lcddata<="E"; i<=0; stringdone<=1; calcstate<=13;  end
						default: i<=0;
						endcase
					end
					"F" : begin
						ready<=1;
						case(i)
						0:	begin data<="F"; lcddata<="F"; i<=1; end
						1:	begin data<="A"; lcddata<="A"; i<=2; end
						2:	begin data<="L"; lcddata<="L"; i<=3; end
						3:	begin data<="S"; lcddata<="S"; i<=4; end
						4:	begin data<="E"; lcddata<="E"; i<=0; stringdone<=1; calcstate<=13;  end
						default: i<=0;
						endcase
					end
					default: begin
						case(i)
						0: begin reqconversion<=1; i<=1; end
						1: begin reqconversion<=0; i<=2; end
						2: begin i <= conversiondone ? 3 :2; end
						3: begin
							if (D1!=0) begin
								ready<=1; data<=D1+8'b00110000; lcddata<=D1+8'b00110000;
							end else ready<=0;
							i<=4;
						end
						4: begin
							if (D2!=0 || ready==1) begin
								ready<=1; data<=D2+8'b00110000; lcddata<=D2+8'b00110000;
							end
							i<=5;
						end
						5: begin
							if (D3!=0 || ready==1) begin
								ready<=1; data<=D3+8'b00110000; lcddata<=D3+8'b00110000;
							end
							i<=6;
						end
						6: begin
							if (D4!=0 || ready==1) begin
								ready<=1; data<=D4+8'b00110000; lcddata<=D4+8'b00110000;
							end
							i<=7;
						end
						7: begin
							if (D5!=0 || ready==1) begin
								ready<=1; data<=D5+8'b00110000; lcddata<=D5+8'b00110000;
							end
							i<=8;
						end
						8: begin
							ready<=1; data<=D6+8'b00110000; lcddata<=D6+8'b00110000;
							i<=0; stringdone<=1; calcstate<=13;
						end
						default: i<=0;
						endcase
					end
				endcase
			end
			12: begin
				if (senddata) begin
				ready<=1;
				case(i)
					0:	begin data<="E"; i<=1; itislcd<=0; end
					1:	begin data<="S"; i<=2; end
					2:	begin data<="C"; i<=3; end
					3:	begin data<=8'h0A; i<=4; end
					4:	begin data<=8'h0D; i<=0; itislcd<=1; lcddata<="X"; stringdone<=1; calcstate<=1; end
					default: i<=0;
				endcase
				end
			end
			13: begin
				if (senddata)			
				case(ScanValue)
					"0", "1", "2", "3", "4", "5", "6", "7", "8", "9": begin
						valid<=1;
						case(i)
							0:	begin data<=8'h0A; i<=1; stringdone<=0; itislcd<=0;  end
							1:	begin data<=8'h0D; itislcd<=1; lcddata<="X"; i<=2; end
							2: begin 
								ready<=0;
								if(j<100000) j<=j+1;
								else begin i<=3; j<=0; end
							end		
							3: begin
								ready<=1;
								number11<=ScanValue-8'b00110000;
								itislcd<=1;
								data<=ScanValue;
								lcddata<=ScanValue;
								stringdone<=1;
								calcstate<=2; i<=0; end
							default: i<=0;
						endcase	
					end
					"N": begin
						valid<=1;
						ready<=0;
						calcstate<=12;
						stringdone<=0;
					end	
					default: begin calcstate <= 13; valid<=0;  end	
				endcase
			end
				
		endcase
		
	end
	//end
endmodule			
	