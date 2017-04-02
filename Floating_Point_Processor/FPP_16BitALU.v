`timescale 1ns/10ps

module FPP_16bALU(clk,rst,st,DATA,REGA,REGB,ALUFunction,REGOUT,en,flag_io);


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

parameter  LOAD = 4'b0000, MOV = 4'b0001, ADD = 4'b0010, NEG = 4'b0011,
           STORE = 4'b0100, DIV = 4'b0101, MUL = 4'b0110, MAX = 4'b0111,
           SUB = 4'b1000, CLR = 4'b1001;
		   		   
//input registers
input 			clk ,rst,st;
input [15:0] 	DATA;
input [15:0] 	REGA,REGB;
input [3:0]  	ALUFunction;

//output registers
output reg 		en,flag_io;
output reg [15:0] REGOUT;

//Temporary Variables 
reg [4:0] REGS;
reg [3:0] REGF;

//Temporary Addition Variables
reg [4:0]  TempExp;
reg [11:0] TempMatissa;
reg [21:0] TempMul;
reg [4:0]  TempExpA, TempExpB;
reg TempSign;
reg TempSignA, TempSignB,ExpCarry,MatCarry;
reg [11:0] TempValue;

always @(posedge clk) begin
	if (rst) begin 
	en = 0;
	REGOUT = 0;
	REGS = 0;
	REGF = 0;
	TempExp = 0;
	TempMatissa = 0; 
	TempSign = 0; 
	TempValue = 0; 
	TempMul = 0; 
	TempExpA = 0 ; 
	TempSignA = 0; 
	TempSignB = 0;
	TempExpB = 0; 
	ExpCarry = 0;
	MatCarry = 0;
	flag_io = 0;
	end else begin 
	       
			case(REGF)
			     `st0: begin if (st == 1) begin REGF = `st1; flag_io = 0; en = 0; end 
							 else begin REGF = `st0;flag_io = 0; end  
					   end 
			     `st1: begin en = 0;
							case(ALUFunction) 
								LOAD :  begin REGOUT = DATA; flag_io = 0;  REGS = `st0; REGF = `st2;  end 
								MOV   :  begin REGOUT = REGA ; flag_io = 0; REGS = `st0; REGF = `st2;  end 
								ADD   :  begin flag_io = 0;
										   case(REGS)
											`st0: begin //check if it is signed or not
													    if(REGA[15] == REGB[15]) begin 
														REGS = `st1;
														end else begin 
															REGS = `st5; 
														end 
												  end
											`st1: begin // unsigned so check which is a greater number
														if(REGA[14:10] == REGB[14:10]) begin 
														TempMatissa  = {1'b1,REGA[9:0]}+{1'b1, REGB[9:0]};
														TempExp = REGA[14:10];
														TempSign = REGA[15];
														REGS = `st8;
														end else begin 
														   if(REGA[14:10]> REGB[14:10]) begin 
														   TempExp = REGA[14:10] - REGB[14:10];
														   TempSign = REGA[15];
														   REGS = `st3;
														   end else begin 
														   TempExp = REGB[14:10] - REGA[14:10];
														   TempSign = REGB[15];
														   REGS = `st4;
														   end 
														end
												  end
											`st2: begin  //normalise mantissa and exponent
														if (TempMatissa[11]) begin 
														TempValue = TempMatissa >> 1; 
														REGOUT[9:0] = TempValue[9:0];
														REGOUT[14:10] = TempExp +1;
														REGOUT[15] = TempSign;
														REGS = `st0; REGF = `st2;	
														end else begin
															if(TempMatissa[10])begin
															TempValue = TempMatissa;
															REGOUT[9:0] = TempValue[9:0]; 
															REGOUT[14:10] = TempExp ;
															REGOUT[15] = TempSign;
															REGS = `st0; REGF = `st2;end
															else begin 
																if(TempMatissa[9])begin
																TempValue = TempMatissa << 1;
																REGOUT[9:0] = TempValue[9:0]; 
																REGOUT[14:10] = TempExp -1 ;
																REGOUT[15] = TempSign;
																REGS = `st0; REGF = `st2;end
																else begin 
																	if(TempMatissa[8])begin
																	TempValue = TempMatissa << 2;
																	REGOUT[9:0] = TempValue[9:0]; 
																	REGOUT[14:10] = TempExp -2 ;
																	REGOUT[15] = TempSign;
																	REGS = `st0; REGF = `st2;end
																	else begin
																		if(TempMatissa[7])begin
																		TempValue = TempMatissa << 3;
																		REGOUT[9:0] = TempValue[9:0]; 
																		REGOUT[14:10] = TempExp -3 ;
																		REGOUT[15] = TempSign;
																		REGS = `st0; REGF = `st2;end 
																		else begin 
																			if(TempMatissa[6])begin
																			TempValue = TempMatissa << 4;
																			REGOUT[9:0] = TempValue[9:0]; 
																			REGOUT[14:10] = TempExp -4 ;
																			REGOUT[15] = TempSign;
																			REGS = `st0; REGF = `st2;end
																			else begin 
																				if(TempMatissa[5])begin
																				TempValue = TempMatissa << 5;
																				REGOUT[9:0] = TempValue[9:0]; 
																				REGOUT[14:10] = TempExp -5 ;
																				REGOUT[15] = TempSign;
																				REGS = `st0; REGF = `st2;end
																				else begin 
																					if(TempMatissa[4])begin
																					TempValue = TempMatissa << 6;
																					REGOUT[9:0] = TempValue[9:0]; 
																					REGOUT[14:10] = TempExp -6 ;
																					REGOUT[15] = TempSign;
																					REGS = `st0; REGF = `st2;end
																					else begin 
																					TempValue = 12'b000000000000;
																					REGOUT[9:0] = 10'b0000000000; 
																					REGOUT[14:10] = 5'b00000 ;
																					REGOUT[15] = 0;
																					REGS = `st0; REGF = `st2;
																					end 
																				end 
																			end
																		end
																	end 	
																end 	
															end
														end 	
												  end
											`st3: begin 
													TempValue[10:0] = {1'b1, REGB[9:0]} >> TempExp;
													TempMatissa = {1'b1,REGA[9:0]} + TempValue[10:0];
													TempExp = REGA[14:10];
													REGS = `st2;													
												  end
											`st4: begin 
													TempValue[10:0]  = {1'b1,REGA[9:0]} >> TempExp;
													TempMatissa = {1'b1,REGB[9:0]} + TempValue[10:0];
													TempExp = REGB[14:10];
													REGS = `st2;													
												  end
											`st5: begin 
														if(REGA[14:10] == REGB[14:10]) begin 
															if(REGA[9:0] >= REGB[9:0]) begin
															TempExp = REGA[14:10];
															TempMatissa = {1'b1,REGA[9:0]} - {1'b1, REGB[9:0]};
															TempSign = REGA [15];
															REGS = `st8;
															end else begin
															TempExp = REGB[14:10];
															TempMatissa = {1'b1,REGB[9:0]} - {1'b1, REGA[9:0]};
															TempSign = REGB[15];
															REGS = `st8;
															end 
														end else begin 
															if(REGA[14:10] > REGB[14:10]) begin
															TempExp = REGA[14:10] - REGB[14:10];
															TempSign = REGA [15];
															REGS = `st6; 
															end else begin
															TempExp = REGB[14:10]- REGA[14:10];
															TempSign = REGB[15];
															REGS = `st7 ;
															end 
														end
												  end 
											`st6: begin 
													TempValue[10:0]  = {1'b1, REGB[9:0]} >> TempExp;
													TempMatissa = {1'b1,REGA[9:0]} - TempValue[10:0];
													TempExp = REGA[14:10];
													REGS = `st2;													
												  end
											`st7: begin 
													TempValue[10:0]  = {1'b1,REGA[9:0]} >> TempExp;
													TempMatissa = {1'b1,REGB[9:0]} - TempValue[10:0];
													TempExp = REGB[14:10];
													REGS = `st2;													
												  end
										    `st8: begin 
												  REGS = `st2;
												  end 
										   endcase
										 end 
								MUL    :  begin flag_io = 0;
											case(REGS)
												`st0: begin
														TempSign = REGA[15] ^ REGB[15];
														if ((REGA[14:10]  == 4'b0000) || (REGB[14:10]  == 4'b0000)) begin 
															 if(REGB[14:10] == 4'b0000) begin 
															 TempExp = REGA[14:10]; 
															 end else begin 
															 TempExp = REGB[14:10]; end 
														end else begin 
																if(REGA[14:10] > 5'b01111) begin 
																TempExpA = REGA[14:10] - 5'b01111 ; 
																TempSignA = 0;
																end else begin 
																TempExpA = 5'b01111 - REGA[14:10]; 
																TempSignA = 1;
																end	
																if(REGB[14:10] > 5'b01111) begin 
																TempExpB = REGB[14:10] - 5'b01111; 
																TempSignB = 0;
																end else begin 
																TempExpB = 5'b01111 - REGB[14:10] ; 
																TempSignB = 1;
																end	
														end 
														if ((TempSignA == 1) || (TempSignB == 1)) begin 
														   if((TempSignA == 1) && (TempSignB == 1)) begin  
															{ExpCarry,TempExp} = 5'b01111 - TempExpA - TempExpB;
														   end else begin 
																if (TempSignA == 1) begin 
																   {ExpCarry,TempExp} = 5'b01111 - TempExpA + TempExpB;
																end else begin 
																	{ExpCarry,TempExp} = 5'b01111 + TempExpA - TempExpB;
																end 
														   end 
														end else begin 
															{ExpCarry,TempExp} = TempExpA + TempExpB + 5'b01111;
														end 
														TempMul = {1'b1,REGA[9:0]} * {1'b1,REGB[9:0]};
														REGS = `st1;
													  end
												`st1: begin 
												         if (ExpCarry == 1) begin 
														 TempExp = 5'b00000;
														 TempMul = 10'b0000000000;
														 REGS = `st2;
														 end else begin 
														 REGS = `st2;
														 end 
													  end 
												`st2: begin 
														if(TempMul[21]) begin 
															TempMul = TempMul >> 1; 
															TempExp = TempExp +1 ; 
															REGOUT[9:0] = TempMul[19:10];
															REGOUT[14:10] = TempExp;
															REGOUT[15] = TempSign;
															REGS = `st0; REGF = `st2;
														end else begin  
														    if(TempMul[20]) begin 
															REGOUT[9:0] = TempMul[19:10];
															REGOUT[14:10] = TempExp;
															REGOUT[15] = TempSign;
															REGS = `st0; REGF = `st2;
															end else begin 
																if (TempMul[19]) begin 
																    TempMul = TempMul << 1; 
																	REGOUT[9:0] = TempMul[19:10];
																	REGOUT[14:10] = TempExp -1;
																	REGOUT[15] = TempSign;
																	REGS = `st0; REGF = `st2;
																end else begin
																	if (TempMul[18]) begin 
																	TempMul = TempMul << 2; 
																	REGOUT[9:0] = TempMul[19:10];
																	REGOUT[14:10] = TempExp -2;
																	REGOUT[15] = TempSign;
																	REGS = `st0; REGF = `st2;
																	end else begin 
																		if (TempMul[17]) begin
																		TempMul = TempMul << 3; 
																		REGOUT[9:0] = TempMul[19:10];
																		REGOUT[14:10] = TempExp -3;
																		REGOUT[15] = TempSign;
																		REGS = `st0; REGF = `st2; 
																		end else begin 
																			if (TempMul[16]) begin
																			TempMul = TempMul << 4; 
																			REGOUT[9:0] = TempMul[19:10];
																			REGOUT[14:10] = TempExp -4;
																			REGOUT[15] = TempSign;
																			REGS = `st0; REGF = `st2;
																			end else begin 
																				if (TempMul[15]) begin
																			    TempMul = TempMul << 5; 
																				REGOUT[9:0] = TempMul[19:10];
																				REGOUT[14:10] = TempExp -5;
																				REGOUT[15] = TempSign;
																				REGS = `st0; REGF = `st2;
																				end else begin 
																					if (TempMul[14]) begin
																					TempMul = TempMul << 6; 
																					REGOUT[9:0] = TempMul[19:10];
																					REGOUT[14:10] = TempExp -6;
																					REGOUT[15] = TempSign;
																					REGS = `st0; REGF = `st2;
																					end else begin 
																					REGOUT[9:0] = 10'b0000000000;
																					REGOUT[14:10] = 5'b00000;
																					REGOUT[15] = 1'b0;
																					REGS = `st0; REGF = `st2;
																					end
																				end 
																			end
																		end 
																	end 
																end 
															end
														end
													  end
											endcase
										  end 
								NEG    :  begin flag_io = 0;
												REGOUT[15]= ~REGA[15];
												REGOUT[14:0] = REGA[14:0] ;REGS = `st0; REGF = `st2; end  
								MAX    :  begin 
											flag_io = 0;
											 case (REGS)
											 `st0: begin 
														if(REGA[15] != REGB[15]) begin 
														REGS = `st1;
														end else begin 
														REGS = `st2;
														end 
												   end 
											 `st1: begin 
														if(REGA[15] == 1) begin 
														REGOUT = REGB; REGS = `st5; 
														end else begin 
														REGOUT = REGA; REGS = `st5;
														end 
												   end 
											 `st2: begin 
														if(REGA[14:10] == REGB[14:10]) begin 
														REGS = `st3;
														end else begin 
														REGS = `st4;
														end 
												   end 
											 `st3: begin 
														if(REGA[9:0] >= REGB[9:0]) begin 
														REGOUT = REGA; REGS = `st0; REGF = `st2;
														end else begin 
														REGOUT = REGB; REGS = `st0; REGF = `st2;
														end 
												   end
											 `st4: begin 
														if(REGA[14:10] > REGB[14:10]) begin 
														REGOUT = REGA; REGS = `st0; REGF = `st2;
														end else begin 
														REGOUT = REGB; REGS = `st0; REGF = `st2;
														end 
												   end 
											  `st5: begin 
													    REGS = `st0; REGF = `st2;	
													end 
											 endcase               
										 end
								STORE : begin 
								         REGOUT = REGA; flag_io = 1; REGS = `st0; REGF = `st2;
										end
										
							endcase		 
					end 
		`st2: begin
				en = 1; REGF = `st0;
		      end 
		 endcase
	end
end

endmodule 
