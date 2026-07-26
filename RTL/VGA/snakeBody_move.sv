

module snakeBody_move (    
                    input  logic clk,
                    input  logic resetN,
                    input  logic startOfFrame,       //short pulse every start of frame 30Hz 
                    
                    
                    input logic signed [10:0] headTopLeftX, 
                    input logic signed [10:0] headTopLeftY,
						  input logic [4:0] length,
						  input  logic update_body_tick,
						  input  logic [10:0] pixelX,
						  input  logic [10:0] pixelY,

						  
                    input  int   move_speed,        // Dynamic speed from FSM
                    output logic drawingRequest,
                    
);

//body dimensions
	 localparam int MAX_LENGTH = 16; 
    localparam int OBJECT_WIDTH_X = 16;
    localparam int OBJECT_HIGHT_Y = 16;
	 
//links positions
	 logic [10:0] body_X [0:MAX_LENGTH-1];
    logic [10:0] body_Y [0:MAX_LENGTH-1];
	 
	 always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin

            for (int i = 0; i < MAX_LENGTH; i++) begin
                body_X[i] <= 11'd2000; 
                body_Y[i] <= 11'd2000;
            end
        end
        else if (update_body_tick) begin

 
            for (int i = MAX_LENGTH - 1; i > 0; i--) begin
                body_X[i] <= body_X[i-1];
                body_Y[i] <= body_Y[i-1];
            end
            

            body_X[0] <= head_topLeftX;
            body_Y[0] <= head_topLeftY;
        end
    end 
	 
endmodule
	 
	 
	 
	 