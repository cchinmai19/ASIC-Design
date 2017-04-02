module buzz(USER_CLK,startbuzz,PIEZO_SPEAKER);
	
	input				USER_CLK;
	input 			startbuzz;
	output	reg	PIEZO_SPEAKER;
	
	parameter   	NoteLa = 213636;
	
	reg   [17:0]   Ctr;
	reg	[3:0]		i;
	reg	[5:0]		count;
	
	initial begin
		i=0;
		count=0;
	end	
	
	always @(posedge USER_CLK) begin
		case(i)
		0: begin
			if (startbuzz) i<=1; //if invalid key is pressed
			else begin i<=0; count<=0; end // otherwise stay here
		end
		1: begin
			
			if (count<60) begin //repeat 30 times
				i<=1;
				if(Ctr >= NoteLa) begin
					PIEZO_SPEAKER <= ~PIEZO_SPEAKER;
					Ctr <= 0;
					count<=count+1;
				end else begin
					Ctr <= Ctr+1;
				end	
			end else i<=0;	
		
		end
		endcase
	
	end //end always loop
endmodule	