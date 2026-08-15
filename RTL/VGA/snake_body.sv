//snake body module - manages movement and drawing of sanke's tail
module snake_body #(
    parameter int MAX_LENGTH = 16, 
    parameter int OBJECT_SIZE = 32
)(
    input logic clk,
    input logic resetN,
    //vga controller signals
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,

    //smiley_move signals
    input  logic [10:0] head_X,
    input  logic [10:0] head_Y,

    //game logic signals
    input logic shift_pulse,
    input logic [4:0] body_length,

    //object_mux outputs
    output logic bodyDrawingRequest,
    output logic [7:0] bodyRGB
);

    localparam logic [7:0] BODY_COLOR = 8'b000_111_00;//deafult body color is green
    localparam logic [7:0] TRANSPARENT = 8'hFF;
    logic [10:0] body_X [0:MAX_LENGTH-1];
    logic [10:0] body_Y [0:MAX_LENGTH-1];

    //movement logic - shifts the body coordinates to follow the head
    always_ff @(posedge clk or negedge resetN) begin
        if(!resetN) begin
            for(int i = 0; i < MAX_LENGTH; i++) begin
                body_X[i] <= 0;
                body_Y[i] <= 0;
            end
        end else if(shift_pulse) begin
            for(int i = MAX_LENGTH-1; i > 0; i--) begin
                body_X[i] <= body_X[i-1];
                body_Y[i] <= body_Y[i-1];
            end
            body_X[0] <= head_X;
            body_Y[0] <= head_Y;
        end
    end

        //drawing logic - checks if the current pixel is within any of the body segments
    logic body_pixel;
    always_comb begin
        body_pixel = 1'b0;
        for(int i = 1; i < MAX_LENGTH; i++) begin
            if(i <body_length) begin
            if((pixelX >= body_X[i]) && (pixelX < body_X[i] + OBJECT_SIZE) &&
               (pixelY >= body_Y[i]) && (pixelY < body_Y[i] + OBJECT_SIZE)) begin
                body_pixel = 1'b1;
            end
        end
    end
end
    assign bodyDrawingRequest = body_pixel;
    assign bodyRGB = body_pixel ? BODY_COLOR : TRANSPARENT;
endmodule