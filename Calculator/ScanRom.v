`timescale 1ns / 1ps
module ScanRom(ScanValue, ScanCode);
    output reg [7:0]   ScanValue;
	 input      [7:0]   ScanCode;

    always @(ScanCode) begin
       case (ScanCode)
		    8'h70  : ScanValue = "0";
		    8'h69  : ScanValue = "1";
		    8'h72  : ScanValue = "2";
		    8'h7A  : ScanValue = "3";
		    8'h6B  : ScanValue = "4";
		    8'h73  : ScanValue = "5";
		    8'h74  : ScanValue = "6";
		    8'h6C  : ScanValue = "7";
		    8'h75  : ScanValue = "8";
		    8'h7D  : ScanValue = "9";
		    8'h79  : ScanValue = "+";
		    8'h7C  : ScanValue = "*";
		    8'h49  : ScanValue = ">";
		    8'h41  : ScanValue = "<";
		    8'h5A  : ScanValue = "Y";
		    8'h76  : ScanValue = "N";
			 default: ScanValue = 8'hFF;
		 endcase
	 end
endmodule


