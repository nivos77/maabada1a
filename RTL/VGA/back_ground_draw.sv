//-- feb 2021 add all colors square 
// (c) Technion IIT, Department of Electrical Engineering 2025
// UPDATED: Added Night Mode support & Top Wall Drawing

module  back_ground_draw    (   
                    input   logic   clk,
                    input   logic   resetN,
                    input   logic   [10:0]  pixelX,
                    input   logic   [10:0]  pixelY,
                    input   logic   [18:0]  address,
                    
                    input   logic   night_mode_active, 

                    output  logic   [7:0]   BG_RGB,
                    output  logic           boardersDrawReq, 
                    output  logic   [7:0] MIF_VGA
);

const int   xFrameSize  =   635;
const int   yFrameSize  =   475;
const int   bracketOffset = 32;

logic [2:0] redBits;
logic [2:0] greenBits;
logic [1:0] blueBits;
logic [10:0] shift_pixelX;

localparam logic [2:0] DARK_COLOR = 3'b111 ;// bitmap of a dark color
localparam logic [2:0] LIGHT_COLOR = 3'b000 ;// bitmap of a light color

localparam  int RED_TOP_Y  = 156 ;
localparam  int RED_LEFT_X  = 256 ;
localparam  int GREEN_RIGHT_X  = 32 ;
localparam  int BLUE_BOTTOM_Y  = 300 ;
localparam  int BLUE_RIGHT_X  = 200 ;
 
parameter  logic [10:0] COLOR_MATRIX_TOP_Y  = 100 ; 
parameter  logic [10:0] COLOR_MATRIX_LEFT_X = 100 ;

 lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(19),
     .LPM_NUMWORDS(307200),
    .LPM_FILE("RTL/GrassBG.mif"),
       .LPM_TYPE                ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
        .LPM_OUTDATA            ("UNREGISTERED"), 
        .AUTO_CARRY_CHAINS      ("ON"),
        .AUTO_CASCADE_BUFFERS   ("ON"),
       .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst (
    .address(address),
     .inclock(clk),
    .q(MIF_VGA)
);

logic [9:0] fence_address;
logic [7:0] fence_color;
logic is_side_wall;

assign is_side_wall = (pixelX < 32) || (pixelX >= 608);

assign fence_address = is_side_wall ? {pixelX[4:0], pixelY[4:0]} : {pixelY[4:0], pixelX[4:0]};//visual wall rotation

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),  
    .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/bottomWall.mif"), 
    .LPM_TYPE               ("LPM_ROM"),
    .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
    .LPM_OUTDATA            ("UNREGISTERED"), 
    .AUTO_CARRY_CHAINS      ("ON"),
    .AUTO_CASCADE_BUFFERS   ("ON"),
    .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst_fence (
    .address(fence_address),
    .inclock(clk),
    .q(fence_color)
);

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF;

always_ff@(posedge clk or negedge resetN)
begin
    if(!resetN) begin
        BG_RGB <= 8'h00;
        boardersDrawReq <= 1'b0;
    end 
    else begin
        BG_RGB <= 8'h00;
        boardersDrawReq <= 1'b0;
        
        if ((pixelX < 32) || (pixelX >= 608) || (pixelY >= 448) || (pixelY < 64)) begin
            if (fence_color != TRANSPARENT_ENCODING) begin
                BG_RGB <= fence_color;
                boardersDrawReq <= 1'b1;
            end
        end
    end    
end 
endmodule