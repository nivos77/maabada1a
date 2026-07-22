// (c) Technion IIT, Department of Electrical Engineering 2025 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal MAR 2024   
// good practice code - Dudy MAR 2025  ert
// UPDATED FOR 4-DIRECTIONAL KEYBOARD CONTROL & FSM INTEGRATION

module smiley_move (    
                    input  logic clk,
                    input  logic resetN,
                    input  logic startOfFrame,       //short pulse every start of frame 30Hz 
                    
                    // 4 Directional Keys
                    input  logic up_key,      
                    input  logic down_key,      
                    input  logic left_key,      
                    input  logic right_key, 
                    input  logic turbo,
                    
                    input  logic collision,         //collision if smiley hits an object
                    input  logic [2:0] HitEdgeCode, 
                    
                   
                    input  logic reset_player_pos,
                    input  logic teleport_to_p1,
                    input  logic teleport_to_p2,
                    input  int   move_speed,        // Dynamic speed from FSM
                    
                    
                    output logic signed [10:0] topLeftX, 
                    output logic signed [10:0] topLeftY,
                    output logic [1:0] direction
);

 int topLeftX_tmp; 
 int topLeftY_tmp; 

parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;


parameter int PORTAL1_X = 100;
parameter int PORTAL1_Y = 100;
parameter int PORTAL2_X = 500;
parameter int PORTAL2_Y = 300;

const logic signed  [10:0]  FIXED_POINT_MULTIPLIER = 64; 

// movement limits 
const int   OBJECT_WIDTH_X = 16;
const int   OBJECT_HIGHT_Y = 16;
const int   SafetyMargin   = 2;

const int   x_FRAME_LEFT    = (SafetyMargin)* FIXED_POINT_MULTIPLIER; 
const int   x_FRAME_RIGHT   = (639 - SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int   y_FRAME_TOP     = (SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int   y_FRAME_BOTTOM  = (479 - SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; 

//directional consts
const logic [1:0] DIR_RIGHT = 2'b00;
const logic [1:0] DIR_LEFT  = 2'b01;
const logic [1:0] DIR_UP    = 2'b10;
const logic [1:0] DIR_DOWN  = 2'b11;


enum  logic [2:0] {IDLE_ST,          // initial state
                         MOVE_ST,           // moving no colision 
                         START_OF_FRAME_ST, // startOfFrame activity
                         POSITION_CHANGE_ST,// position interpolate 
                         POSITION_LIMITS_ST // check if inside the frame  
                        }  SM_Motion ;

int Xspeed ; // speed   
int Yspeed ; 
int Xposition ; //position   
int Yposition ;  
int current_speed;
 logic [4:0] hit_reg = 5'b00000;
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

    if (resetN == 1'b0) begin 
        SM_Motion <= IDLE_ST ; 
        Xspeed <= 0 ; 
        Yspeed <= 0 ; 
        
        Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER ; 
        Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER ; 
        hit_reg <= 5'b0 ;   
    end     
    
    else begin
    
        case(SM_Motion)
        
        //------------
            IDLE_ST: begin
        //------------
                Xspeed  <= 0 ; 
                Yspeed  <= 0 ; 
                Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER; 
                Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER; 

                if (startOfFrame) 
                    SM_Motion <= MOVE_ST ;
            end
    
        //------------
            MOVE_ST:  begin     
        //------------
        
                // Convert FSM speed (16 down to 4) to actual pixel velocity (80 up to 200)
                current_speed = (turbo) ? ((24 - move_speed) * 20) : ((24 - move_speed) * 10);
                    
                if (up_key) begin
                    if(direction != DIR_DOWN) begin 
                        direction <= DIR_UP;
                        Yspeed <= -current_speed;
                        Xspeed <= 0;
                    end
                end
                else if (down_key) begin
                    if(direction != DIR_UP) begin 
                        direction <= DIR_DOWN;
                        Yspeed <= current_speed;
                        Xspeed <= 0;
                    end
                end
                else if (left_key) begin
                    if(direction != DIR_RIGHT) begin
                        direction <= DIR_LEFT;
                        Xspeed <= -current_speed;
                        Yspeed <= 0;
                    end
                end
                else if (right_key) begin
                    if(direction != DIR_LEFT) begin
                        direction <= DIR_RIGHT;
                        Xspeed <= current_speed;
                        Yspeed <= 0;
                    end
                end

                if (collision) begin
                    hit_reg[HitEdgeCode] <= 1'b1;
                end
                
                if (startOfFrame)
                    SM_Motion <= START_OF_FRAME_ST ; 
        end 
        
        //------------
            START_OF_FRAME_ST:  begin      
        //------------
            hit_reg <= 5'b00000;                        
            SM_Motion <= POSITION_CHANGE_ST ; 
        end 

        
            POSITION_CHANGE_ST : begin  
        
                
                // OVERRIDE: Check for commands from the Game Controller
                if (reset_player_pos) begin
                    Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER;
                    Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
                    Xspeed <= 0;
                    Yspeed <= 0;
                end
                else if (teleport_to_p1) begin
                    Xposition <= PORTAL1_X * FIXED_POINT_MULTIPLIER;
                    Yposition <= PORTAL1_Y * FIXED_POINT_MULTIPLIER;
                end
                else if (teleport_to_p2) begin
                    Xposition <= PORTAL2_X * FIXED_POINT_MULTIPLIER;
                    Yposition <= PORTAL2_Y * FIXED_POINT_MULTIPLIER;
                end
                else begin
                    // Normal movement
                    Xposition <= Xposition + Xspeed ; 
                    Yposition <= Yposition + Yspeed ;
                end
             
                SM_Motion <= POSITION_LIMITS_ST ; 
            end
        
       
            POSITION_LIMITS_ST : begin  //check if still inside the frame 
        
                if (Xposition < x_FRAME_LEFT) begin
                    Xposition <= x_FRAME_LEFT ; 
                    Xspeed <= 0; 
                end
                if (Xposition > x_FRAME_RIGHT) begin
                    Xposition <= x_FRAME_RIGHT ; 
                    Xspeed <= 0;
                end
                if (Yposition < y_FRAME_TOP) begin
                    Yposition <= y_FRAME_TOP ; 
                    Yspeed <= 0;
                end
                if (Yposition > y_FRAME_BOTTOM) begin
                    Yposition <= y_FRAME_BOTTOM ; 
                    Yspeed <= 0;
                end

                SM_Motion <= MOVE_ST ; 
            end
        
        endcase  
        
    end 

end 

//return from FIXED point trunc back to prame size parameters  
assign  topLeftX_tmp = Xposition / FIXED_POINT_MULTIPLIER ;   
assign  topLeftY_tmp = Yposition / FIXED_POINT_MULTIPLIER ;   

assign  topLeftX = {topLeftX_tmp[10:0]} ;   
assign  topLeftY = {topLeftY_tmp[10:0]} ;       

endmodule