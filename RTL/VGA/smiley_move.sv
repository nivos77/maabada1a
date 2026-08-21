module smiley_move (    
                    input  logic clk,
                    input  logic resetN,
                    input  logic startOfFrame, 
                    
                    input  logic up_key,      
                    input  logic down_key,      
                    input  logic left_key,      
                    input  logic right_key, 
                    
                    input  logic reset_player_pos,
                    input  logic teleport_to_p1,
                    input  logic teleport_to_p2,
                    input  int   move_speed, 
                    input  logic shift_pulse,
                    
                    input  logic signed [10:0] portal1_x,
                    input  logic signed [10:0] portal1_y,
                    input  logic signed [10:0] portal2_x,
                    input  logic signed [10:0] portal2_y,
                    
                    output logic signed [10:0] topLeftX, 
                    output logic signed [10:0] topLeftY,
                    output logic [1:0] direction
);

 int topLeftX_tmp; 
 int topLeftY_tmp; 

parameter int INITIAL_X = 320;
parameter int INITIAL_Y = 256;

const logic signed  [10:0]  FIXED_POINT_MULTIPLIER = 64; 

const int   x_FRAME_LEFT    = 0; 
const int   x_FRAME_RIGHT   = 640 * FIXED_POINT_MULTIPLIER; 
const int   y_FRAME_TOP     = 0;
const int   y_FRAME_BOTTOM  = 480 * FIXED_POINT_MULTIPLIER; 

const logic [1:0] DIR_RIGHT = 2'b00;
const logic [1:0] DIR_LEFT  = 2'b01;
const logic [1:0] DIR_UP    = 2'b10;
const logic [1:0] DIR_DOWN  = 2'b11;

enum  logic [2:0] {IDLE_ST, MOVE_ST, START_OF_FRAME_ST, POSITION_CHANGE_ST, POSITION_LIMITS_ST}  SM_Motion;

int Xposition; 
int Yposition;  
logic [1:0] next_direction; 
logic shift_pending;
 
always_ff @(posedge clk or negedge resetN) begin
    if (resetN == 1'b0) begin 
        SM_Motion <= IDLE_ST; 
        Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER; 
        Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER; 
        direction <= DIR_RIGHT;
        next_direction <= DIR_RIGHT;
        shift_pending <= 1'b0;
    end else begin
        if (shift_pulse) shift_pending <= 1'b1;
    
        case(SM_Motion)
            IDLE_ST: begin
                Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER; 
                Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER; 
                if (startOfFrame) SM_Motion <= MOVE_ST;
            end
    
            MOVE_ST:  begin     
                if (up_key && (direction != DIR_DOWN)) next_direction <= DIR_UP;
                else if (down_key && (direction != DIR_UP)) next_direction <= DIR_DOWN;
                else if (left_key && (direction != DIR_RIGHT)) next_direction <= DIR_LEFT;
                else if (right_key && (direction != DIR_LEFT)) next_direction <= DIR_RIGHT;
                if (startOfFrame) SM_Motion <= START_OF_FRAME_ST; 
            end 
        
            START_OF_FRAME_ST: begin      
                SM_Motion <= POSITION_CHANGE_ST; 
            end 
        
            POSITION_CHANGE_ST: begin  
                if (reset_player_pos) begin
                    Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER;
                    Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
                    direction <= DIR_RIGHT;
                    next_direction <= DIR_RIGHT;
                    shift_pending <= 1'b0;
                end
                else if (teleport_to_p1) begin
                    Xposition <= 32 * FIXED_POINT_MULTIPLIER;
                    Yposition <= portal1_y * FIXED_POINT_MULTIPLIER;
                    direction <= DIR_RIGHT;
                    next_direction <= DIR_RIGHT;
                    shift_pending <= 1'b0;
                end
                else if (teleport_to_p2) begin
                    Xposition <= 575 * FIXED_POINT_MULTIPLIER;
                    Yposition <= portal2_y * FIXED_POINT_MULTIPLIER;
                    direction <= DIR_LEFT;
                    next_direction <= DIR_LEFT;
                    shift_pending <= 1'b0;
                end
                else if (shift_pending) begin
                    shift_pending <= 1'b0;
                    direction <= next_direction;
                    if (next_direction == DIR_UP) Yposition <= Yposition - (32 * FIXED_POINT_MULTIPLIER);
                    else if (next_direction == DIR_DOWN) Yposition <= Yposition + (32 * FIXED_POINT_MULTIPLIER);
                    else if (next_direction == DIR_LEFT) Xposition <= Xposition - (32 * FIXED_POINT_MULTIPLIER);
                    else if (next_direction == DIR_RIGHT) Xposition <= Xposition + (32 * FIXED_POINT_MULTIPLIER);
                end
                SM_Motion <= POSITION_LIMITS_ST; 
            end
       
            POSITION_LIMITS_ST: begin  
                if (Xposition < x_FRAME_LEFT) Xposition <= x_FRAME_LEFT; 
                if (Xposition > x_FRAME_RIGHT) Xposition <= x_FRAME_RIGHT; 
                if (Yposition < y_FRAME_TOP) Yposition <= y_FRAME_TOP; 
                if (Yposition > y_FRAME_BOTTOM) Yposition <= y_FRAME_BOTTOM; 
                SM_Motion <= MOVE_ST; 
            end
        endcase  
    end 
end 

assign topLeftX_tmp = Xposition / FIXED_POINT_MULTIPLIER;   
assign topLeftY_tmp = Yposition / FIXED_POINT_MULTIPLIER;   
assign topLeftX = {topLeftX_tmp[10:0]};   
assign topLeftY = {topLeftY_tmp[10:0]};       

endmodule