
module LCD(CLK_27, LCD_FPGA_DB, LCD_FPGA_E, LCD_FPGA_RS, LCD_FPGA_RW, RESET, Lcd_data, lcdstrb, MBusy);

    input                 CLK_27;
    input                 RESET;
    output     [3:0]      LCD_FPGA_DB;
    output reg            LCD_FPGA_RW;
    output 		          LCD_FPGA_E, LCD_FPGA_RS;
	input	   [7:0]	  Lcd_data;
   input					lcdstrb;
	parameter Idle = 0,   LS1=1,   LS2=2,  LS3=3,   LS4=4,   LS5=5,   LS6=6,
              LS7=7,      LS8=8,   LS9=9,  LS10=10, LS11=11, LS12=12, LS13=13,
			     LS14=14,    LS15=15, LS16=16;
			 

    reg        [3:0]      CS, NS;    // Current state , next state
    reg                   Pon_Dly;
    wire                  Busy;
	 output reg					MBusy;
    
    reg					[7:0]		Data;
	 reg                   Strb, RS;


	initial begin
		NS<=1;
	end	
	
    LCD_write L1( .Clk(CLK_27),   .Strb(Strb),  .Reset(RESET),        .D_in(Data), .D_out(LCD_FPGA_DB), 
	               .E(LCD_FPGA_E), .Busy(Busy),  .RS_out(LCD_FPGA_RS), .RS(RS) );

    
	 always @(posedge CLK_27) begin
	    
		 if(RESET) begin
		    CS <= LS1;
	    end else begin 
		    CS <= NS;
	    end

    end


    always @(*) begin
	
	     RS <= 0;                    // RS=0 is Command Mode
	     LCD_FPGA_RW <= 0;           // Always write.
	     Data <= 0;
	     Strb <= 0;
		  MBusy<=Busy;
	     //NS <= Idle;
        case(CS)
	        //Idle:	begin
			//	         if(Pon_Dly) NS <= LS1;
			//	         else NS <= Idle;
			//         end
	         LS1:  begin
				         Data <= 8'b0010_1000; // Configure LCD in 2 line mode
				         Strb <= 1;
				         NS <= LS2;
			         end
	         LS2:  begin
                     NS <= LS3;
			         end
	         LS3:  begin
				         if(Busy)  begin 
					         NS <= LS3;
				         end	else
						      NS <= LS4;
			         end
	         LS4:  begin
				         Data <= 8'b0000_1111;   // 8'h0F is Cursor ON, display ON, blink ON 
				         Strb <= 1;
				         NS <= LS5;
			         end
	         LS5:  begin
				         if(Busy) begin
					         NS <= LS5;
				         end else
                        NS <= LS6;
			         end
	         LS6:  begin
         				Data <= 8'b0000_0001;   // Clear display. Cursor home
			         	Strb <= 1;
				         NS <= LS7;
			         end
            LS7:  begin
				         if(Busy) begin
					         NS <= LS7;
					      end else
                        NS <= LS8;
			         end
	         LS8:  begin
				         Data <= 8'b0000_0110;   // No shift, increment
				         Strb <= 1;
				         NS <= LS9;
			         end
	         LS9:  begin
                     if(Busy) begin
							   NS <= LS9;
							end else
                        NS <= LS10;
			         end
	        LS10:  begin                     // Up until now, we were in command mode
				        
						  if(lcdstrb) begin 
							if(Lcd_data=="X") begin
								Data<=8'b0000_0001;
							end else if (Lcd_data==8'hC0) begin
								Data<=8'hC0;
							end else begin
								RS <= 1;                // RS=1 shifts to Data mode
								Data <= Lcd_data;       // Write next data byte
							end
							Strb<=1;
							NS <= LS9;
						end else NS <= LS10;	
			         end
	     default:  NS <= Idle;			
        endcase
    end
 

 
endmodule
