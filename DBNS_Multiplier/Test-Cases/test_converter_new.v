`timescale 1ns/1ps

module test_Converter_new();

parameter HC=3;

reg clk,rst;
reg [15:0] count;
wire[31:0] result;

initial 
begin

clk <= 1;
//count <= 16'b1010_1100_1110_0001;

rst <= 1;
repeat(2) @(negedge clk);
//count<=7890;
//#10
rst <= 0;
repeat(2) @(negedge clk);    
end

always #HC clk<= ~clk;

always@(posedge clk)
begin
//rst <= 0;

count = 3888;
//count[15] = count[0]^count[2]^count[3]^count[5]^count[15];
repeat(20) @(negedge clk); 


end 

DBNS_Converter_new DBNS(.clk(clk),.rst(rst),.REGA(count),.REGC(result));

endmodule 

