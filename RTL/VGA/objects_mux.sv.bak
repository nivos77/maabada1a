

// (c) Technion IIT, Department of Electrical Engineering 2026
// Objects Mux - Display Priority Controller (Updated with Portals)



module objects_mux (	
					input		logic	clk,
					input		logic	resetN,
					input		logic	smileyDrawingRequest,
					input		logic	[7:0] smileyRGB,
					input  		logic 	bodyDrawingRequest,
   					 input  	logic 	[7:0] bodyRGB,
					input		logic	appleDrawingRequest,
					input		logic	[7:0] appleRGB,
					input		logic	specialDrawingRequest,
					input		logic	[7:0] specialRGB,
					input		logic	portal1DrawingRequest,
					input		logic	[7:0] portal1RGB,
					input		logic	portal2DrawingRequest,
					input		logic	[7:0] portal2RGB,
					input		logic	HartDrawingRequest,
					input		logic	[7:0] hartRGB,
					input		logic	[7:0] backGroundRGB,
					input		logic	BGDrawingRequest,
					input		logic	[7:0] RGB_MIF,
					input       logic show_player,
					
					
					output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (smileyDrawingRequest == 1'b1 && show_player == 1'b1)   
			RGBOut <= smileyRGB;
			
		else if (bodyDrawingRequest == 1'b1)
			RGBOut <= bodyRGB;
			
		else if (specialDrawingRequest == 1'b1)
			RGBOut <= specialRGB;
			
		else if (appleDrawingRequest == 1'b1)
			RGBOut <= appleRGB;
			
		else if (portal1DrawingRequest == 1'b1)
			RGBOut <= portal1RGB;
			
		else if (portal2DrawingRequest == 1'b1)
			RGBOut <= portal2RGB;
			
		else if (HartDrawingRequest == 1'b1)
			RGBOut <= hartRGB;
			
		else if (BGDrawingRequest == 1'b1)
			RGBOut <= backGroundRGB;
			
		else 
			RGBOut <= RGB_MIF;
	end 
end

endmodule




