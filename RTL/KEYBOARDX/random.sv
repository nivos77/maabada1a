// (c) Technion IIT, Department of Electrical Engineering 2025 
module random 	
 ( 
	input	logic  clk,
	input	logic  resetN, 
	input	logic	 rise,
	output logic unsigned [SIZE_BITS-1:0] dout	
  ) ;

  
parameter SIZE_BITS = 11;
parameter unsigned [SIZE_BITS-1:0] MIN_VAL = 0;  
parameter unsigned [SIZE_BITS-1:0] MAX_VAL = 255;
parameter unsigned [SIZE_BITS-1:0] INIT_VAL = 0;
parameter unsigned [SIZE_BITS-1:0] STEP = 1;

	logic unsigned  [SIZE_BITS-1:0] counter/* synthesis keep = 1 */;
	logic rise_d /* synthesis keep = 1 */;
	
	
always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			dout <= ((MAX_VAL+MIN_VAL)>>1) & ~(SIZE_BITS'(31)); 
			counter <= INIT_VAL;
			rise_d <= 1'b0;
		end
		
		else begin
			counter <= counter + STEP;
			if ( counter >= MAX_VAL )  
				counter <=  MIN_VAL ; 
				
			rise_d <= rise;
			if (rise && !rise_d) // rising edge 
				dout <= counter & ~(SIZE_BITS'(31)); 
		end
	
	end
 
endmodule