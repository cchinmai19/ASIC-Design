`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		University of Rochester
// Engineer: 		Prof. Tolga Soyata
// 
// Create Date:    8/4/2009
// Design Name: 
// Module Name:    Project5: PS2 keyboard/mouse with Piezo
// Project Name: 
// Target Devices: XC5VLX110T
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: To make this work in Hypeterminal, 
//                      set Emulation=Auto Detect ... Backscroll buffer lines =0
//                      Input translation = Standard JIS ... 
//
//////////////////////////////////////////////////////////////////////////////////


module Calc(USER_CLK, GPIO_LED, FPGA_SERIAL1_TX, 
           KEYBOARD_CLK, KEYBOARD_DATA, 
           PIEZO_SPEAKER, 
		   RESET, LCD_FPGA_DB, LCD_FPGA_E, LCD_FPGA_RS, LCD_FPGA_RW);

   input             USER_CLK;
	output reg 	[3:0]	GPIO_LED;
	output            FPGA_SERIAL1_TX;
	input             KEYBOARD_CLK, KEYBOARD_DATA;
	output reg        PIEZO_SPEAKER;
	input					RESET;
	output reg			LCD_FPGA_E, LCD_FPGA_RS, LCD_FPGA_RW;
	output reg [3:0]  LCD_FPGA_DB;

	wire					MLCD_FPGA_E, MLCD_FPGA_RS, MLCD_FPGA_RW;
	wire [3:0]  			MLCD_FPGA_DB;

	reg	   [7:0]	  Lcd_data;
	
	reg					senddata;
	reg 	   	[7:0]	PS2State;

	reg        	[7:0] TX_Data;
	reg               TX_Request;
	wire					Busy;
	reg               KeyClk, KeyData;
	 
	wire     	[7:0] ScanValue;
	wire              CodeValid;
	wire			[7:0]	data;
	wire					stringdone;
	wire					valid;
	wire					ready;
	wire 			[3:0]	calcstate;
	wire			[7:0]	lcddata;
	wire					itishyper;
	wire					itislcd;
	wire					soundsignal;
	reg					startbuzz;
	wire					lcdbusy;
	reg					lcdstrb;
	
	reg i,j;
	
	initial begin
		PS2State=0;
		startbuzz<=0;
		
	end	

	// RS232 transmitter module
	rs232			Transmitter	(USER_CLK, FPGA_SERIAL1_TX, TX_Request, TX_Data, Busy);
	// PS2 keyboard module
	ps2kbd   	Keyboard		(KeyClk, KeyData, ScanValue, CodeValid);
	//calculation module
	calculate	calculateno	(USER_CLK, senddata, data, stringdone, ScanValue, valid, ready, calcstate, RESET, lcddata, itishyper, itislcd);
	//buzzer module
	buzz 			error			(USER_CLK, startbuzz, soundsignal);
	
	LCD 		lcdmodule(USER_CLK, MLCD_FPGA_DB, MLCD_FPGA_E, MLCD_FPGA_RS, MLCD_FPGA_RW, RESET, Lcd_data, lcdstrb, lcdbusy);

	always @(posedge USER_CLK) begin : MainClk
 
		// This is the prevent some IOB issues in the FPGA
		KeyClk <= KEYBOARD_CLK;
		KeyData <= KEYBOARD_DATA;
		LCD_FPGA_DB<=MLCD_FPGA_DB;
		LCD_FPGA_E<=MLCD_FPGA_E;
		LCD_FPGA_RS<=MLCD_FPGA_RS;
		LCD_FPGA_RW<=MLCD_FPGA_RW;
		

		
		case (PS2State)
			// IDLE State, waiting for something to happen
			0:  if(~CodeValid) begin PS2State <= 0; startbuzz<=0; end
				else begin
					case(ScanValue)
						"0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ,"+" , "*" , "<" , ">" , "Y" , "N": 
						begin
							PS2State <= 1; startbuzz<=0;          // valid digit. write it
						end
						default: begin PS2State <= 0; end // no other key is valid in this state
					endcase
				end // if
			// State 1: Send the request to rs232 to write the digit
			1: begin senddata<=1; PS2State <= 2;          end
			//if pressed button is valid go to next state or go back and sound buzzer
			2: begin senddata<=0; PS2State<=3; end
			3:	begin if (valid) PS2State<=4;
				else begin PS2State <= 0; startbuzz<=1; end
			end
			// is calculator ready to send data or it needs some more time for calculation
			4: begin PS2State <= ready ? 5 : 1; end
			//send data to RS232
			
			5: begin
				if(itishyper)
				case(i)
					0: begin TX_Request<=1; TX_Data <= data; i<=1; end
					1: begin TX_Request<=0; i<=0; PS2State<=6; end
					default : i<=0;
				endcase
				
				if(itislcd)
				case(j)
					0: begin lcdstrb<=1; Lcd_data <= lcddata; j<=1; end
					1: begin lcdstrb<=0; j<=0; PS2State<=6; end
					default : j<=0;
				endcase
			end
			// State 3: wait for the rs232 to finish writing the character
			6: begin PS2State <= (Busy|lcdbusy) ? 6 : 7;               end
			7: begin PS2State <= stringdone ? 0 : 1;  end
			default:	PS2State <= 0;
		endcase
		
		PIEZO_SPEAKER <= soundsignal;
		GPIO_LED<=calcstate; 
	end

endmodule
