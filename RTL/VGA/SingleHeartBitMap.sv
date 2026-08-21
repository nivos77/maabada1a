module SingleHeartBitMap (    
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] offsetX,
    input  logic [10:0] offsetY,
    input  logic InsideRectangle,
    output logic drawingRequest,
    output logic [7:0] RGBout 
);

    localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF;
    logic [9:0] address;
    logic [7:0] color;
    assign address = {offsetY[4:0], offsetX[4:0]};

    lpm_rom #(
        .LPM_WIDTH(8),
        .LPM_WIDTHAD(10),
        .LPM_NUMWORDS(1024),
        .LPM_FILE("RTL/heart1.mif"),
        .LPM_TYPE("LPM_ROM"),
        .LPM_ADDRESS_CONTROL("REGISTERED"),
        .LPM_OUTDATA("UNREGISTERED")
    ) rom_inst (
        .address(address),
        .inclock(clk),
        .q(color)
    );

    always_ff@(posedge clk or negedge resetN) begin
        if(!resetN) begin
            RGBout <= TRANSPARENT_ENCODING;
        end
        else begin
            if (InsideRectangle)
                RGBout <= color;
            else
                RGBout <= TRANSPARENT_ENCODING;
        end 
    end

    assign drawingRequest = (RGBout != TRANSPARENT_ENCODING) ? 1'b1 : 1'b0;
endmodule