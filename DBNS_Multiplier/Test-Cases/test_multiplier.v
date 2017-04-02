`timescale 1ns/1ps

module test_Mult16x16();

parameter HC=3;

reg clk,rst;
reg [15:0] count;
wire[31:0] result;

initial 
begin

clk <= 1;
count <= 16'b1010_1100_1110_0001;

rst <= 1;
repeat(2) @(negedge clk);
rst <= 0;
repeat(1) @(negedge clk);  
  
end

always #HC clk<= ~clk;

always@(posedge clk)
begin

count = count >>1;
count[15] = count[0]^count[2]^count[3]^count[5]^count[15];
repeat(4) @(posedge clk); 

end 

Mult16x16 M1(.clk(clk),.rst(rst),.REGA({count[7:0],count[15:8]}),.REGB(count[15:0]),.REGC(result));

endmodule 

