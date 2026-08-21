//
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2025
// generating a number bitmap 

module NumbersBitMap	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] offsetX,
					input 	logic	[10:0] offsetY,
					input		logic	InsideRectangle,
					input 	logic	[3:0] digit,
					
					output	logic				drawingRequest,
					output	logic	[7:0]		RGBout
);

localparam logic[12:0] OBJECT_WIDTH_X = 6'd16;
localparam logic[12:0] OBJECT_WIDTH_Y = 6'd32;
localparam logic[12:0] digit_location_MIF = OBJECT_WIDTH_X * OBJECT_WIDTH_Y;

logic [12:0] address;
logic color;

assign address = ((digit_location_MIF * digit) + (offsetY * OBJECT_WIDTH_X + (offsetX >> 1)));

parameter logic [7:0] digit_color = 8'hff;

lpm_rom #(
    .LPM_WIDTH(1),
    .LPM_WIDTHAD(13),
    .LPM_NUMWORDS(8192),
    .LPM_FILE("RTL/numbers.mif"),
    .LPM_TYPE               ("LPM_ROM"),
    .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
    .LPM_OUTDATA            ("UNREGISTERED"), 
    .AUTO_CARRY_CHAINS      ("ON"),
    .AUTO_CASCADE_BUFFERS   ("ON"),
    .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst (
    .address(address),
    .inclock(clk),
    .q(color)
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		drawingRequest <= 1'b0;
	end
	else begin
		drawingRequest <= 1'b0;
	 	if (InsideRectangle == 1'b1)
			drawingRequest <= (color == 1'b1) ? 1'b1 : 1'b0;
	end 
end

assign RGBout = digit_color;

endmodule