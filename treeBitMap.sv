module treeBitMap (
    input  logic clk,
    input  logic resetN,
    input  logic [4:0] offsetX,
    input  logic [4:0] offsetY,
    input  logic InsideBody,
    
    output logic [7:0] RGBout,
    output logic drawingRequest
);

    logic [9:0] rom_address;
    logic [7:0] rom_data;

    assign rom_address = {offsetY, offsetX};

    lpm_rom #(
        .LPM_WIDTH(8),
        .LPM_WIDTHAD(10),
        .LPM_NUMWORDS(1024),
        .LPM_FILE("RTL/stump.mif"),
        .LPM_TYPE("LPM_ROM"),
        .LPM_ADDRESS_CONTROL("REGISTERED"),
        .LPM_OUTDATA("UNREGISTERED")
    ) tree_rom (
        .address(rom_address),
        .inclock(clk),
        .q(rom_data)
    );

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            RGBout <= 8'b00000000;
            drawingRequest <= 1'b0;
        end
        else begin
            if (InsideBody && rom_data != 8'hFF) begin
                RGBout <= rom_data;
                drawingRequest <= 1'b1;
            end
            else begin
                RGBout <= 8'b00000000;
                drawingRequest <= 1'b0;
            end
        end
    end

endmodule