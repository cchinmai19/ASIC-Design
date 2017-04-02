`timescale 1ns/10ps

module test_FPP16b(BUS);

reg [ 7:0]  OPCODE;         //Function register : function[7:4],SRC[3:2],DST[1:0],
reg [ 15:0] REGD;         //Data input

reg        clk,rst;

parameter  LOAD = 4'b0000, MOV = 4'b0001, ADD = 4'b0010, NEG = 4'b0011,
           MAX = 4'b0100, DIV = 4'b0101, MUL = 4'b0110, MAXEXP = 4'b0111,
           SUB = 4'b1000, CLR = 4'b1001;

parameter LOAD_FP0 = 8'b0000XX00,LOAD_FP1 = 8'b0000XX01,LOAD_FP2 = 8'b0000XX10,LOAD_FP3 = 8'b0000XX11,
		  MOVFP0_FP1 = 8'b00010001, NEGFP1_FP3 = 8'b00110111,MAXFP0_FP1 = 8'b01110001, ADDFP1_FP0 = 8'b00100100,
		  MULFP0_FP1 = 8'b01100001, STORE_FP0 = 8'b01000000;

initial
  begin
  clk   <= 1;
  REGD  <= 0;
  OPCODE  <= 0;
  end

 //Tristate Buffer 
 inout [15:0] BUS ;
 wire flag_io;
 wire DataBus;
 
 assign BUS = flag_io ? 16'bzzzzzzzz_zzzzzzzz:REGD ; 

always #1 clk <= ~clk; 	

initial begin 

  rst <= 1;
  repeat(2) @(posedge clk);
  rst <= 0;
  repeat(1) @(posedge clk);  
  
  REGD <= 16'b0011100101000111; //0.66
  OPCODE <= LOAD_FP0;                               
  repeat(5) @(posedge clk);
  
  OPCODE <= MOVFP0_FP1;
  repeat(6) @(posedge clk);
  
  REGD <= 16'b0011110011110000; //1.2345
  OPCODE <= LOAD_FP0;
  repeat(6) @(posedge clk);

  
  OPCODE <= NEGFP1_FP3;                                  
  repeat(6) @(posedge clk);

  OPCODE <= MAXFP0_FP1;                                  
  repeat(8) @(posedge clk); 
  
  OPCODE <= ADDFP1_FP0;
  repeat(8) @(posedge clk);
  
  REGD <= 16'b01000010_11101001;  //3.4555
  OPCODE <= LOAD_FP0;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= MOVFP0_FP1;
  repeat(6) @(posedge clk);
  
  REGD <= 16'b1100011010110110; //-6.712
  OPCODE <= LOAD_FP0;
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP0_FP1;
  repeat(7) @(posedge clk);
  
  OPCODE <= STORE_FP0;
  repeat(6) @(posedge clk);
 

end 	   

FPP_16b DUT(.clk(clk),.rst(rst),.DataBus(BUS),.opcode(OPCODE),.flag(flag_io));

endmodule
