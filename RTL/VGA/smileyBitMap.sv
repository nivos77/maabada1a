// System-Verilog written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 
// UPDATED - Dynamic Rotation based on Movement Direction

module smileyBitMap (   
                    input  logic clk,
                    input  logic resetN,
                    input  logic [10:0] offsetX,
                    input  logic [10:0] offsetY,
                    input  logic InsideRectangle, 
                    input  logic [1:0] direction, 

                    output logic drawingRequest,
                    output logic [7:0] RGBout,
                    output logic [2:0] HitEdgeCode  
 ) ;

// const logic [1:0] DIR_RIGHT = 2'b00;
// const logic [1:0] DIR_LEFT  = 2'b01;
// const logic [1:0] DIR_UP    = 2'b10;
// const logic [1:0] DIR_DOWN  = 2'b11;

localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;

localparam  logic [10:0] OBJECT_HEIGHT_Y = 11'b1 << OBJECT_NUMBER_OF_Y_BITS ;
localparam  logic [10:0] OBJECT_WIDTH_X = 11'b1 << OBJECT_NUMBER_OF_X_BITS;


logic [10:0] mapped_X;
logic [10:0] mapped_Y;

always_comb begin
    case(direction)
        2'b00: begin 
            mapped_X = 11'd31 -offsetY;
            mapped_Y = offsetX;
        end
        2'b01: begin 
            mapped_X = offsetY;
            mapped_Y = 11'd31 -offsetX;
        end
        2'b10: begin
            mapped_X = 11'd31 -offsetX;
            mapped_Y = 11'd31 -offsetY;
        end
        2'b11: begin
            mapped_X = offsetX;
            mapped_Y = offsetY;
        end
        default: begin
            mapped_X = offsetX;
            mapped_Y = offsetY;
        end
    endcase
end


logic [10:0] address;
logic [10:0] HitCodeX ; 
logic [10:0] HitCodeY ; 

assign HitCodeX = mapped_X >> 1; 
assign HitCodeY = mapped_Y >> 1;
assign address = (mapped_Y * OBJECT_WIDTH_X + mapped_X);



logic   [7:0] color;
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
    .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/snake2.mif"),
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

 logic [0:15] [0:15] [2:0] hit_colors = 
          {48'o4433333333333344,     
            48'o4443333333333444,    
            48'o1444333333334442, 
            48'o1144433333344422,
            48'o1114443333444222,
            48'o1111444334442222,
            48'o1111144444422222,
            48'o1111114444222222,
            48'o1111114444222222,
            48'o1111144444422222,
            48'o1111444004442222,
            48'o1114440000444222,
            48'o1144400000044422,
            48'o1444000000004442,
            48'o4440000000000444,
            48'o4400000000000044};
 
 
always_ff@(posedge clk or negedge resetN)
begin
    if(!resetN) begin
        RGBout <=   8'h00;
        HitEdgeCode <= 3'h0;
    end
    else begin
        RGBout <= TRANSPARENT_ENCODING ;
        HitEdgeCode <= 3'h0;

        if (InsideRectangle == 1'b1 ) 
        begin 
            
            RGBout <= color;
            HitEdgeCode <= hit_colors[HitCodeY][HitCodeX];
        
        end     
    end
end

//assign drawingRequest = InsideRectangle;
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule