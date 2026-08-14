//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2025


module square_object (
					input		logic	clk,
					input		logic	resetN,
					input 	logic signed	[10:0] pixelX,
					input 	logic signed	[10:0] pixelY,
					input 	logic signed	[10:0] topLeftX,
					input 	logic	signed [10:0] topLeftY,
					input		logic	enable,
					
					output 	logic	[10:0] offsetX,
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest,
					output	logic	[7:0]	 RGBout
);

parameter int OBJECT_WIDTH_X  = 32;
parameter int OBJECT_HEIGHT_Y = 32;
parameter logic [7:0] OBJECT_COLOR = 8'h03;
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF;

int rightX;
int bottomY;
logic insideBracket;

//////////--------------------------------------------------------------------------------------------------------------=
assign rightX	= (topLeftX + OBJECT_WIDTH_X);
assign bottomY	= (topLeftY + OBJECT_HEIGHT_Y);
assign insideBracket = ( enable && (pixelX >= topLeftX) && (pixelX < rightX)
						        && (pixelY >= topLeftY) && (pixelY < bottomY) );

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING;
		drawingRequest <= 1'b0;
		offsetX	<= 0;
		offsetY	<= 0;
	
		if (insideBracket)
		begin 
			RGBout <= OBJECT_COLOR;
			drawingRequest <= 1'b1;
			offsetX	<= (pixelX - topLeftX);
			offsetY	<= (pixelY - topLeftY);
		end
	end
end 
endmodule