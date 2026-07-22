module game_controller (
    input  logic clk,
    input  logic resetN,
    input  logic startOfFrame,
    input  logic drawing_request_smiley,
    input  logic drawing_request_boarders,
    input  logic drawing_request_number,
    input  logic action_key,
    input  logic skip_level_key,
    input  logic drawing_request_apple,
    input  logic drawing_request_special,
    input  logic drawing_request_tree,
    input  logic [1:0] special_type_in,
    input  logic drawing_request_portal1,
    input  logic drawing_request_portal2,
    input  logic signed [11:0] head_x,
    input  logic signed [11:0] head_y,
    input  logic signed [11:0] apple_x,
    input  logic signed [11:0] apple_y,

    output logic collision,
    output logic SingleHitPulse,
    output logic [2:0] game_state_out,
    output logic [2:0] current_level,
    output logic [1:0] current_lives,
    output logic       reset_player_pos,
    output logic       reset_tail,
    output logic       special_apple_active,
    output logic [2:0] num_trees,
    output logic       bite_animation_trigger,
    output int         score_out,
    output int         high_score_out,
    output logic       night_mode_active,
    output logic       refresh_portals,
    output logic       teleport_to_p1,
    output logic       teleport_to_p2,
    output int         move_speed,
    output int         add_tail_amount
);

    // --- COLLISION DETECTION ---
    logic collision_wall, collision_body, collision_tree;
    logic collision_bad;
    logic collision_regular_apple, collision_special_apple;
    logic collision_p1, collision_p2;

    assign collision_wall = (drawing_request_smiley && drawing_request_boarders);
    assign collision_body = (drawing_request_smiley && drawing_request_number);
    assign collision_tree = (drawing_request_smiley && drawing_request_tree);

    // assign collision_bad = (collision_wall || collision_body || collision_tree);
	 assign collision_bad = 1'b0; // GOD MODE 
    assign collision_regular_apple = (drawing_request_smiley && drawing_request_apple);
    assign collision_special_apple = (drawing_request_smiley && drawing_request_special);

    assign collision_p1 = (drawing_request_smiley && drawing_request_portal1);
    assign collision_p2 = (drawing_request_smiley && drawing_request_portal2);

    assign collision = collision_bad || collision_regular_apple || collision_special_apple || collision_p1 || collision_p2;

    // --- LATCHES ---
    logic bad_hit_detected;
    logic apple_hit_detected;
    logic special_hit_detected;
    logic p1_hit_detected;
    logic p2_hit_detected;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            bad_hit_detected <= 0;
            apple_hit_detected <= 0;
            special_hit_detected <= 0;
            p1_hit_detected <= 0;
            p2_hit_detected <= 0;
        end else begin
            if (startOfFrame) begin
                bad_hit_detected <= 0;
                apple_hit_detected <= 0;
                special_hit_detected <= 0;
                p1_hit_detected <= 0;
                p2_hit_detected <= 0;
            end else begin
                if (collision_bad)           bad_hit_detected <= 1;
                if (collision_regular_apple) apple_hit_detected <= 1;
                if (collision_special_apple) special_hit_detected <= 1;
                if (collision_p1)            p1_hit_detected <= 1;
                if (collision_p2)            p2_hit_detected <= 1;
            end
        end
    end

    // --- BITE ANIMATION TRIGGER ---
    logic signed [11:0] diff_x;
    logic signed [11:0] diff_y;
    assign diff_x = head_x - apple_x;
    assign diff_y = head_y - apple_y;

    assign bite_animation_trigger = ((diff_x > -32 && diff_x < 32) && (diff_y > -32 && diff_y < 32)) ? 1'b1 : 1'b0;

    // --- FSM STATES ---
    localparam INIT_ST      = 3'b000;
    localparam PLAY_ST      = 3'b001;
    localparam DIED_ST      = 3'b010;
    localparam GAME_OVER_ST = 3'b011;
    localparam WIN_ST       = 3'b100;

    logic [2:0] state;

    
    int apples_eaten;
    int total_score;
    int apple_timer;  
    int special_timer; 
    int portal_timer; 

    const int SPECIAL_MAX_TIME = 600; 
    const int PORTAL_MAX_TIME = 900; 
    const int WIN_SCORE_THRESHOLD = 170; 

    logic already_won;
    logic skip_flag;

    assign night_mode_active = (current_level == 3'd4) ? 1'b1 : 1'b0;

    
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            state <= INIT_ST;
            current_lives <= 3;
            current_level <= 1;
            apples_eaten <= 0;
            total_score <= 0;
            high_score_out <= 0; 
            apple_timer <= 0;
            portal_timer <= 0;
            move_speed <= 16;
            reset_player_pos <= 1;
            reset_tail <= 1;
            add_tail_amount <= 0;
            special_apple_active <= 0;
            special_timer <= 0;
            num_trees <= 0;
            SingleHitPulse <= 0;
            game_state_out <= 3'b000;
            score_out <= 0;
            refresh_portals <= 0;
            teleport_to_p1 <= 0;
            teleport_to_p2 <= 0;
            already_won <= 0;
            skip_flag <= 0;
        end 
        else if (startOfFrame) begin
            
            SingleHitPulse <= 0;
            add_tail_amount <= 0;
            reset_player_pos <= 0;
            reset_tail <= 0;
            refresh_portals <= 0;
            teleport_to_p1 <= 0;
            teleport_to_p2 <= 0;
            score_out <= total_score; 

            if (total_score > high_score_out) begin
                high_score_out <= total_score;
            end

            case (state)
                INIT_ST: begin
                    reset_player_pos <= 1;
                    reset_tail <= 1;
                    current_lives <= 3;
                    apples_eaten <= 0;
                    total_score <= 0;
                    apple_timer <= 0;
                    portal_timer <= PORTAL_MAX_TIME;
                    current_level <= 1;
                    move_speed <= 16; 
                    num_trees <= 0;
                    special_apple_active <= 0;
                    special_timer <= 0;
                    refresh_portals <= 1; 
                    already_won <= 0;
                    skip_flag <= 0;
                    
                    if (action_key) begin
                        state <= PLAY_ST;
                        reset_player_pos <= 0;
                        reset_tail <= 0;
                    end
                end

                PLAY_ST: begin
                    apple_timer <= apple_timer + 1; 
                    
                    if (skip_level_key && !skip_flag) begin
                        skip_flag <= 1; 
                        if (current_level == 1) begin 
                            total_score <= 30; current_level <= 2; move_speed <= 13; num_trees <= 0; 
                        end
                        else if (current_level == 2) begin 
                            total_score <= 60; current_level <= 3; move_speed <= 10; num_trees <= 3; 
                        end
                        else if (current_level == 3) begin 
                            total_score <= 90; current_level <= 4; move_speed <= 7; num_trees <= 4; 
                        end
                        else if (current_level == 4) begin 
                            total_score <= 120; current_level <= 5; move_speed <= 4; num_trees <= 5; 
                        end
                        else if (current_level == 5) begin 
                            total_score <= WIN_SCORE_THRESHOLD; 
                        end
                    end 
                    else if (!skip_level_key) begin
                        skip_flag <= 0; 
                    end

                    if (portal_timer > 0) begin
                        portal_timer--;
                    end else begin
                        portal_timer <= PORTAL_MAX_TIME;
                        refresh_portals <= 1; 
                    end
                    
                    if (special_apple_active) begin
                        if (special_timer > 0) begin
                            special_timer--;
                        end else begin
                            special_apple_active <= 0; 
                        end
                    end

                    if (current_level == 5 && total_score >= WIN_SCORE_THRESHOLD && !already_won) begin
                        state <= WIN_ST;
                        already_won <= 1;
                    end
                    else if (bad_hit_detected) begin
                        SingleHitPulse <= 1;
                        add_tail_amount <= 3; 
                        if (current_lives > 1) begin
                            current_lives <= current_lives - 1;
                            state <= DIED_ST;
                        end else begin
                            current_lives <= 0;
                            state <= GAME_OVER_ST;
                        end
                    end 
                    else if (p1_hit_detected) begin
                        teleport_to_p2 <= 1; 
                    end
                    else if (p2_hit_detected) begin
                        teleport_to_p1 <= 1; 
                    end
                    else if (apple_hit_detected) begin
                        int points_to_add;
                        
                        if (apple_timer <= 60)       points_to_add = 10; 
                        else if (apple_timer <= 120) points_to_add = 5;  
                        else if (apple_timer <= 180) points_to_add = 3;  
                        else                         points_to_add = 1;  
                        
                        total_score <= total_score + points_to_add;
                        apples_eaten <= apples_eaten + 1;
                        add_tail_amount <= 1; 
                        apple_timer <= 0; 
                        
                        if ((total_score + points_to_add) >= 120) begin 
                            current_level <= 5; move_speed <= 4; num_trees <= 5; 
                        end
                        else if ((total_score + points_to_add) >= 90) begin 
                            current_level <= 4; move_speed <= 7; num_trees <= 4; 
                        end
                        else if ((total_score + points_to_add) >= 60) begin 
                            current_level <= 3; move_speed <= 10; num_trees <= 3; 
                        end
                        else if ((total_score + points_to_add) >= 30) begin 
                            current_level <= 2; move_speed <= 13; num_trees <= 0; 
                        end
                        
                        if ((apples_eaten + 1) % 5 == 0) begin
                            special_apple_active <= 1;
                            special_timer <= SPECIAL_MAX_TIME;
                        end
                    end
                    else if (special_hit_detected && special_apple_active) begin
                        special_apple_active <= 0; 
                        
                        if (special_type_in == 2'b00) begin
                            add_tail_amount <= -3; 
                            total_score <= total_score + 15; 
                        end else if (special_type_in == 2'b01) begin
                            add_tail_amount <= 3; 
                        end else if (special_type_in == 2'b10) begin
                            reset_tail <= 1; 
                            total_score <= total_score + 20;
                        end
                    end
                end

                DIED_ST: begin
                    reset_player_pos <= 1;
                    apple_timer <= 0;
						  if (action_key) begin
                        state <= PLAY_ST;
                    end
                end

                GAME_OVER_ST: begin
                    if (action_key) begin
                        state <= INIT_ST;
                    end
                end
                
                WIN_ST: begin
                    if (action_key) begin
                        state <= INIT_ST;
                    end
                end
            endcase
            
            game_state_out <= state;
        end
    end

endmodule