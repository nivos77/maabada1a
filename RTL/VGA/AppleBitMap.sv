
module AppleBitMap (   
                    input  logic clk,
                    input  logic resetN,
                    input  logic [10:0] offsetX,
                    input  logic [10:0] offsetY,
                    input  logic InsideRectangle,  

                    output logic drawingRequest,
                    output logic [7:0] RGBout
 ) ;


localparam  int OBJECT_NUMBER_OF_Y_BITS = 4;
localparam  int OBJECT_NUMBER_OF_X_BITS = 4;

localparam  logic [10:0] OBJECT_HEIGHT_Y = 11'b1 << OBJECT_NUMBER_OF_Y_BITS ;
localparam  logic [10:0] OBJECT_WIDTH_X = 11'b1 << OBJECT_NUMBER_OF_X_BITS;

logic [7:0] address;
//assign address the top left corner of the bitmap, and then add the offset to get the correct pixel address
assign address = {offsetY[3:0], offsetX[3:0]};
logic   [7:0] color;
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(8),
    .LPM_NUMWORDS(256),
    .LPM_FILE("RTL/apple.mif"),
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

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        RGBout <= 8'h00;
    end else begin
        if (InsideRectangle) begin
            RGBout <= color;
        end else begin
            RGBout <= TRANSPARENT_ENCODING;
        end
    end
end

assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule