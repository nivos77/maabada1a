module random_portal_Y  
 ( 
	input	logic  clk,
	input	logic  resetN, 
	input	logic  rise,
	output logic unsigned [SIZE_BITS-1:0] dout	
  ) ;

parameter SIZE_BITS = 11; 
parameter unsigned [SIZE_BITS-1:0] MIN_VAL = 64;  
parameter unsigned [SIZE_BITS-1:0] MAX_VAL = 416; 
parameter unsigned [SIZE_BITS-1:0] INIT_VAL = 64; 
parameter unsigned [SIZE_BITS-1:0] STEP = 1; 

	logic unsigned [SIZE_BITS-1:0] counter /* synthesis keep = 1 */;
	logic rise_d /* synthesis keep = 1 */;
	
always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			dout <= ((MAX_VAL+MIN_VAL)>>1) & 11'b11111100000; 
			counter <= INIT_VAL; 
			rise_d <= 1'b0;
		end
		
		else begin
			counter <= counter + STEP; 
			if ( counter >= MAX_VAL ) 
				counter <= MIN_VAL; 
				
			rise_d <= rise;
			if (rise && !rise_d) 
				dout <= counter & 11'b11111100000; 
		end
	end
 
endmodule