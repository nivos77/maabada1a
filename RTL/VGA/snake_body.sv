module snake_body #(
    parameter int MAX_LENGTH = 16, 
    parameter int OBJECT_SIZE = 32
)(
    input logic clk,
    input logic resetN,
    
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,

    input  logic [10:0] head_X,
    input  logic [10:0] head_Y,

    input logic shift_pulse,
    input logic [7:0] body_length,
    input logic reset_tail, 

    output logic [10:0] offsetX,
    output logic [10:0] offsetY,
    output logic InsideRectangle
);

    logic [10:0] body_X [0:MAX_LENGTH-1];
    logic [10:0] body_Y [0:MAX_LENGTH-1];

    always_ff @(posedge clk or negedge resetN) begin
        if(!resetN) begin
            for(int i = 0; i < MAX_LENGTH; i++) begin
                // זורק את הזנב מחוץ למסך באתחול
                body_X[i] <= 11'd1000; 
                body_Y[i] <= 11'd1000;
            end
        end 
        else if (reset_tail) begin
            for(int i = 0; i < MAX_LENGTH; i++) begin
                // זורק את הזנב מחוץ למסך בעת פסילה
                body_X[i] <= 11'd1000; 
                body_Y[i] <= 11'd1000;
            end
        end
        else if(shift_pulse) begin
            for(int i = MAX_LENGTH-1; i > 0; i--) begin
                body_X[i] <= body_X[i-1];
                body_Y[i] <= body_Y[i-1];
            end
            body_X[0] <= head_X;
            body_Y[0] <= head_Y;
        end
    end

    always_comb begin
        InsideRectangle = 1'b0;
        offsetX = 0;
        offsetY = 0;
        for(int i = 0; i < MAX_LENGTH; i++) begin
            if(i < body_length) begin
                if((pixelX >= body_X[i]) && (pixelX < body_X[i] + OBJECT_SIZE) &&
                   (pixelY >= body_Y[i]) && (pixelY < body_Y[i] + OBJECT_SIZE)) begin
                    InsideRectangle = 1'b1;
                    offsetX = pixelX - body_X[i];
                    offsetY = pixelY - body_Y[i];
                end
            end
        end
    end
endmodule