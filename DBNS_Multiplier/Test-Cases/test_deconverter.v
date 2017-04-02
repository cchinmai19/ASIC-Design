`timescale 1ns/1ps

module test_De_Converter();

parameter HC=3;

reg clk,rst;
reg [15:0] count;
wire[15:0] result;

initial 
begin

clk <= 1;
//count <= 16'b1010_1100_1110_0001;

rst <= 1;
repeat(2) @(negedge clk);
rst <= 0;
repeat(1) @(negedge clk);  
  
end

always #HC clk<= ~clk;

always@(posedge clk)
begin

count = 7890;
//count[15] = count[0]^count[2]^count[3]^count[5]^count[15];
repeat(10) @(negedge clk); 

end 

De_converter De_DBNS(.clk(clk),.rst(rst),.REGA(count),.REGC(result));

endmodule 

