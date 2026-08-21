module SpecialAppleBitMap (
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] offsetX,
    input  logic [10:0] offsetY,
    input  logic InsideRectangle,
    input  logic [3:0] digit, 
    
    output logic drawingRequest,
    output logic [7:0] RGBout
);

    logic [9:0] address;
    assign address = {offsetY[4:0], offsetX[4:0]};

    logic [7:0] rom_color;
    localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF;

    lpm_rom #(
        .LPM_WIDTH(8),
        .LPM_WIDTHAD(10),
        .LPM_NUMWORDS(1024),
        .LPM_FILE("RTL/apple.mif"),
        .LPM_TYPE("LPM_ROM"),
        .LPM_ADDRESS_CONTROL("REGISTERED"), 
        .LPM_OUTDATA("UNREGISTERED"), 
        .AUTO_CARRY_CHAINS("ON"),
        .AUTO_CASCADE_BUFFERS("ON"),
        .INTENDED_DEVICE_FAMILY("Cyclone V")  
    ) rom_inst (
        .address(address),
        .inclock(clk),
        .q(rom_color)
    );

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            RGBout <= 8'h00;
        end else begin
            if (InsideRectangle && rom_color != TRANSPARENT_ENCODING) begin
                if (digit == 4'd10) 
                    RGBout <= {rom_color[1:0], rom_color[4:2], rom_color[7:5]}; 
                else if (digit == 4'd11)
                    RGBout <= {rom_color[4:2], rom_color[7:5], rom_color[1:0]}; 
                else if (digit == 4'd12)
                    RGBout <= {rom_color[7:5], rom_color[7:5], rom_color[1:0]}; 
                else
                    RGBout <= rom_color; 
            end else begin
                RGBout <= TRANSPARENT_ENCODING;
            end
        end
    end

    assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0;

endmodule