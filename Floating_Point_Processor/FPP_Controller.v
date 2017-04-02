`timescale 1ns/10ps

module FPP16b_controller(BUS);

reg [ 7:0]  OPCODE;         //Function register : function[7:4],SRC[3:2],DST[1:0],
reg [ 15:0] REGD;         //Data input

reg        clk,rst;

parameter  LOAD = 4'b0000, MOV = 4'b0001, ADD = 4'b0010, NEG = 4'b0011,
           MAX = 4'b0100, DIV = 4'b0101, MUL = 4'b0110, MAXEXP = 4'b0111,
           SUB = 4'b1000, CLR = 4'b1001;

//opcode parameters 
// Number of cycles load=6, store=6 , neg=6 , max=8, mul=7, add =8
		   
parameter 	LOAD_FP0 = 8'b0000XX00,LOAD_FP1 = 8'b0000XX01,
			LOAD_FP2 = 8'b0000XX10,LOAD_FP3 = 8'b0000XX11,	  
			MOVFP0_FP1 = 8'b00010001,MOVFP2_FP1 = 8'b00011001,
			MOVFP0_FP2 = 8'b00010010,MOVFP3_FP2 = 8'b00011110,
			MULFP0_FP1 = 8'b01100001,MULFP0_FP2 = 8'b01100010,
			MULFP1_FP2 = 8'b01100110,MULFP1_FP3 = 8'b01100111,
			MULFP2_FP2 = 8'b01101010,MULFP2_FP0 = 8'b01101000,
			MULFP1_FP0 = 8'b01100100,MULFP2_FP3 = 8'b01101011,
			ADDFP2_FP3 = 8'b00101011,ADDFP3_FP2 = 8'b00101110, 
			ADDFP0_FP1 = 8'b00100001,ADDFP3_FP0 = 8'b00101100,
			ADDFP0_FP3 = 8'b00100011,
			NEGFP3_FP3 = 8'b00111111,STORE_FP0 = 8'b01000000 ; 

//x , y and theta values 

parameter x = 16'b0100011100000000, y = 16'b0101000001000000, 
		theta = 16'b0011101000000000;// (0.75) // x =7 , y =34, theta in rad = 0.523599  16'b1011100000110000(0.523599)
		  
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
  
  //calculating Sin theta
  
  REGD <= theta; //0.523599 rad
  OPCODE <= LOAD_FP0;                               
  repeat(5) @(posedge clk);
  
  OPCODE <= MOVFP0_FP1;
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP0_FP1;
  repeat(8) @(posedge clk); // theta^2 0_01101_0001100010
  
  OPCODE <= MULFP0_FP1;
  repeat(8) @(posedge clk); //theta^3 0_01100_0010010110  
  
  REGD <= 16'b1_01100_0101010101 ; //-1/3! = -0.1666666
  OPCODE <= LOAD_FP2;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP1_FP2;
  repeat(8) @(posedge clk); // FP2 = theta^3 *(-1/3!) 1_01001_1000011100 
  
  OPCODE <= MULFP0_FP1;
  repeat(8) @(posedge clk); // FP1 = theta^4 0_01011_0011001101
  
  OPCODE <= MULFP0_FP1;
  repeat(8) @(posedge clk); //FP1 = theta^5 0_01010_0100000110
  
  REGD <= 16'b0_01000_0001000100 ; // 1/5! = 0.008333 
  OPCODE <= LOAD_FP3;
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP1_FP3;
  repeat(8) @(posedge clk); //FP3 = theta^5 *(1/5!) 0_00011_0101011011 
  
  OPCODE <= ADDFP3_FP2;
  repeat(9) @(posedge clk); // FP2 = theta^3 *(-1/3!) + theta^5 *(-1/5!) 1_01001_1000001101 ( 1_01001_1000000111)
  
  OPCODE <= MULFP0_FP1;
  repeat(8) @(posedge clk); // FP1 = theta^6 0_01001_0101000110 (0_01001_0101000010)
  
  OPCODE <= MULFP0_FP1;
  repeat(8) @(posedge clk); //FP1 = theta^7 0_01000_0110000101 (0_01000_0110000001)
  
  REGD <= 16'b1_00010_1010000000  ; // -1/7! = -0.00019841269 
  OPCODE <= LOAD_FP3;
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP1_FP3;
  repeat(8) @(posedge clk); //FP3 = theta^7 *(-1/7!) //00000 ****
  
  OPCODE <= ADDFP3_FP2;
  repeat(9) @(posedge clk); //1_01001_1000001010
//  FP2 = theta^3 *(-1/3!) + theta^5 *(1/5!) +  theta^7 *(-1/7!) 
  
  OPCODE <= MOVFP2_FP1;
  repeat(6) @(posedge clk);
  
  OPCODE <= ADDFP0_FP1; //0_01110_0000000000
  repeat(9) @(posedge clk); //FP1 = sin(theta) FP0 = theta
  
  // calculating cos theta 
  
  OPCODE <= MOVFP0_FP2;
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP0_FP2;
  repeat(8) @(posedge clk); // FP2 = theta^2 FP0 = theta 0_01101_0001100010
  
  REGD <= 16'b1_01110_0000000000   ; // -1/2! = -0.5 1_01110_0000000000
  OPCODE <= LOAD_FP3;
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP2_FP3;
  repeat(8) @(posedge clk); //FP3 = theta^2 *(-1/2!) 1_01100_00011000010
  
  OPCODE <= MULFP0_FP2;
  repeat(8) @(posedge clk); // FP2 = theta^3 0_01100_0010010110
  
  OPCODE <= MULFP0_FP2;
  repeat(8) @(posedge clk); // FP2 = theta^4 0_01011_0011001101
  
  REGD <= 16'b0_01010_0101010101   ; // +1/4! = 0.04166666 
  OPCODE <= LOAD_FP0;
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP0_FP2;
  repeat(8) @(posedge clk); // FP2 = theta^4 *1/4! 0_00110_1001101001 (0_00110_1001100110)
  
  OPCODE <= ADDFP2_FP3; //1_01100_0001001001
  repeat(9) @(posedge clk); // FP3 = theta^2 *(-1/2!) + theta^4 *(1/4!) 
  
  REGD <= theta; //7
  OPCODE <= LOAD_FP0;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= MOVFP0_FP2;
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP0_FP2;
  repeat(8) @(posedge clk); // FP2 = theta^2 0_01101_0001100010
  
  OPCODE <= MULFP0_FP2;
  repeat(8) @(posedge clk); // FP2 = theta^3 0_01100_0010010110
  
  OPCODE <= MULFP2_FP2;
  repeat(8) @(posedge clk); // FP2 = theta^6 0_01001_0101000001
  
  REGD <= 16'b1_00101_0110110000; //-0.001388888 = -1/6!
  OPCODE <= LOAD_FP0;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP0_FP2;
  repeat(8) @(posedge clk); // FP2 = - theta^6 * 1/6! //0
  
  OPCODE <= ADDFP2_FP3;//1_01100_0001001001
  repeat(9) @(posedge clk); // FP3 = theta^2 *(-1/2!) + theta^4 *(1/4!) + - theta^6 * 1/6!
  
  REGD <= 16'b0011110000000000; //1
  OPCODE <= LOAD_FP0;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= ADDFP0_FP3; // 0_01110_1011101101
  repeat(9) @(posedge clk); // FP3 = 1 + theta^2 *(-1/2!) + theta^4 *(1/4!) + - theta^6 * 1/6!
  
  OPCODE <= MOVFP3_FP2;
  repeat(6) @(posedge clk); // FP1 = Sin(theta) FP2 = Cos(theta)
  
  // calculating rotation angle x'
  
  REGD <= x; //7
  OPCODE <= LOAD_FP0;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP2_FP0;
  repeat(8) @(posedge clk); // FP0 = xcos(theta) 0_10001_1000001111
  
  REGD <= y; //34
  OPCODE <= LOAD_FP3;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= NEGFP3_FP3;                                  
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP1_FP3;
  repeat(8) @(posedge clk); // FP3 = -ySin(theta) 1_10011_0001000000
  
  OPCODE <= ADDFP3_FP0;
  repeat(9) @(posedge clk); // FP0 = x' 1_10010_0101111000
  
  OPCODE <= STORE_FP0;
  repeat(6) @(posedge clk);
  
  //calculating y'
  
   
  REGD <= x; //7
  OPCODE <= LOAD_FP0;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP1_FP0;
  repeat(8) @(posedge clk); // FP0 = xSin(theta) 0_10000_1100000000
  
  REGD <= y; //34
  OPCODE <= LOAD_FP3;                               
  repeat(6) @(posedge clk);
  
  OPCODE <= MULFP2_FP3;
  repeat(8) @(posedge clk); // FP3 = yCos(theta) 0_10011_1101011001
  
  OPCODE <= ADDFP3_FP0;
  repeat(9) @(posedge clk); // FP0 = y' 0_01110_1011101011
  
  OPCODE <= STORE_FP0;
  repeat(6) @(posedge clk);
	

end 	   

FPP_16b DUT(.clk(clk),.rst(rst),.DataBus(BUS),.opcode(OPCODE),.flag(flag_io));

endmodule
