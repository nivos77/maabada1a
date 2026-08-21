module game_controller (
    input  logic clk,
    input  logic resetN,
    input  logic startOfFrame,
    input  logic drawing_request_smiley,
    input  logic drawing_request_boarders,
    input  logic drawing_request_tail,
    input  logic action_key,
    input  logic skip_level_key,
    input  logic drawing_request_apple,
    input  logic drawing_request_special,
    input  logic drawing_request_tree,
    input  logic [3:0] special_type_in,
    input  logic drawing_request_portal1,
    input  logic drawing_request_portal2,
    input  logic signed [10:0] head_x,
    input  logic signed [10:0] head_y,
    input  logic signed [10:0] apple_x,
    input  logic signed [10:0] apple_y,
    input  logic signed [10:0] special_apple_x,
    input  logic signed [10:0] special_apple_y,
    input  logic signed [10:0] portal1_x,
    input  logic signed [10:0] portal1_y,
    input  logic signed [10:0] portal2_x,
    input  logic signed [10:0] portal2_y,

    output logic collision,
    output logic SingleHitPulse,
    output logic SpecialHitPulse,
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
    output int         add_tail_amount,
    output logic       shift_pulse,
    output logic [7:0] snake_length,
    output logic       show_player,
    output logic [1:0] countdown_val
);

    logic collision_wall, collision_body, collision_tree;
    logic collision_bad, collision_regular_apple, collision_special_apple;
    logic collision_p1, collision_p2;
    logic bad_hit_detected, apple_hit_detected, special_hit_detected;
    logic p1_hit_detected, p2_hit_detected;

    assign collision_wall = drawing_request_smiley && ((head_x < 32) || (head_x >= 608) || (head_y < 64) || (head_y >= 448));
    assign collision_body = (drawing_request_smiley && drawing_request_tail);
    assign collision_tree = (drawing_request_smiley && drawing_request_tree);
    assign collision_bad = 1'b0; 
    assign collision_regular_apple = (drawing_request_smiley && drawing_request_apple);
    assign collision_special_apple = (drawing_request_smiley && drawing_request_special);
    assign collision_p1 = (drawing_request_smiley && drawing_request_portal1);
    assign collision_p2 = (drawing_request_smiley && drawing_request_portal2);
    assign collision = collision_bad || collision_regular_apple || collision_special_apple || collision_p1 || collision_p2;

    localparam INIT_ST      = 3'b000;
    localparam PLAY_ST      = 3'b001;
    localparam DIED_ST      = 3'b010;
    localparam GAME_OVER_ST = 3'b011;
    localparam WIN_ST       = 3'b100;
    localparam COUNTDOWN_ST = 3'b101;

    logic [2:0] state;
    int apples_eaten, total_score, apple_timer, special_timer, portal_timer; 
    int teleport_cooldown;
    logic [7:0] blink_timer;
    int countdown_timer;

    const int SPECIAL_MAX_TIME = 600; 
    const int PORTAL_MAX_TIME = 900; 
    const int WIN_SCORE_THRESHOLD = 300;

    logic already_won, skip_flag;
    assign night_mode_active = (current_level == 3'd4) ? 1'b1 : 1'b0;
    
    logic signed [10:0] diff_x, diff_y;
    assign diff_x = head_x - apple_x;
    assign diff_y = head_y - apple_y;
    assign bite_animation_trigger = ((diff_x > -32 && diff_x < 32) && (diff_y > -32 && diff_y < 32)) ? 1'b1 : 1'b0;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            bad_hit_detected <= 0; apple_hit_detected <= 0; special_hit_detected <= 0;
            p1_hit_detected <= 0; p2_hit_detected <= 0;
        end else if (startOfFrame) begin
            bad_hit_detected <= 0; apple_hit_detected <= 0; special_hit_detected <= 0;
            p1_hit_detected <= 0; p2_hit_detected <= 0;
        end else begin
            if (collision_p1 && state == PLAY_ST) begin
                p1_hit_detected <= 1;
            end
            else if (collision_p2 && state == PLAY_ST) begin
                p2_hit_detected <= 1;
            end
            else if ((collision_wall || collision_tree || collision_body) && !collision_regular_apple && !collision_special_apple && state == PLAY_ST) begin
                bad_hit_detected <= 1;
            end

            if (collision_regular_apple && state == PLAY_ST) apple_hit_detected <= 1;
            if (collision_special_apple && state == PLAY_ST) special_hit_detected <= 1;
        end
    end

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            state <= INIT_ST;
            current_lives <= 3;
            current_level <= 1;
            apples_eaten <= 0; total_score <= 0; high_score_out <= 0; 
            apple_timer <= 0; portal_timer <= PORTAL_MAX_TIME;
            move_speed <= 10;
            reset_player_pos <= 1; reset_tail <= 1; add_tail_amount <= 0;
            special_apple_active <= 0; special_timer <= 0; num_trees <= 0;
            SingleHitPulse <= 0; SpecialHitPulse <= 0; game_state_out <= 3'b000;
            score_out <= 0; refresh_portals <= 0;
            teleport_to_p1 <= 0; teleport_to_p2 <= 0; teleport_cooldown <= 0;
            already_won <= 0; skip_flag <= 0; show_player <= 1'b1; blink_timer <= 0;
            countdown_val <= 0; countdown_timer <= 0;
        end 
        else if (startOfFrame) begin
            SingleHitPulse <= 0; SpecialHitPulse <= 0; add_tail_amount <= 0;
            reset_player_pos <= 0; reset_tail <= 0; refresh_portals <= 0;
            teleport_to_p1 <= 0; teleport_to_p2 <= 0;
            score_out <= total_score; 

            if (total_score > high_score_out) high_score_out <= total_score;

            case (state)
                INIT_ST: begin
                    blink_timer <= 0; reset_player_pos <= 1; reset_tail <= 1;
                    current_lives <= 3;
                    apples_eaten <= 0; total_score <= 0; apple_timer <= 0;
                    portal_timer <= PORTAL_MAX_TIME; teleport_cooldown <= 0;
                    current_level <= 1; move_speed <= 14; num_trees <= 0;
                    special_apple_active <= 0; special_timer <= 0; refresh_portals <= 1; 
                    already_won <= 0; skip_flag <= 0; show_player <= 1'b0;
                    if (action_key) begin
                        state <= COUNTDOWN_ST; 
                        countdown_val <= 3;
                        countdown_timer <= 60;
                        reset_player_pos <= 0; 
                        reset_tail <= 0;
                    end
                end

                COUNTDOWN_ST: begin
                    show_player <= 1'b1;
                    if (countdown_timer > 0) begin
                        countdown_timer <= countdown_timer - 1;
                    end else begin
                        if (countdown_val > 1) begin
                            countdown_val <= countdown_val - 1;
                            countdown_timer <= 60;
                        end else begin
                            state <= PLAY_ST;
                            countdown_val <= 0;
                        end
                    end
                end

                PLAY_ST: begin
                    apple_timer <= apple_timer + 1; 
                    show_player <= 1'b1; blink_timer <= 0;
                    if (teleport_cooldown > 0) teleport_cooldown <= teleport_cooldown - 1;

                    if (skip_level_key && !skip_flag) begin
                        skip_flag <= 1; 
                        if (current_level == 1) begin total_score <= 40; current_level <= 2; move_speed <= 18; num_trees <= 0; end
                        else if (current_level == 2) begin total_score <= 100; current_level <= 3; move_speed <= 15; num_trees <= 3; end
                        else if (current_level == 3) begin total_score <= 150; current_level <= 4; move_speed <= 12; num_trees <= 4; end
                        else if (current_level == 4) begin total_score <= 220; current_level <= 5; move_speed <= 8; num_trees <= 5; end
                        else if (current_level == 5) begin total_score <= WIN_SCORE_THRESHOLD; end
                    end else if (!skip_level_key) begin
                        skip_flag <= 0; 
                    end

                    if (portal_timer > 0) portal_timer <= portal_timer - 1;
                    else begin
                        if (teleport_cooldown == 0) begin
                            portal_timer <= PORTAL_MAX_TIME; refresh_portals <= 1;
                        end else portal_timer <= 0;
                    end
                    
                    if (special_apple_active) begin
                        if (special_timer > 0) special_timer <= special_timer - 1;
                        else special_apple_active <= 0; 
                    end

                    if (current_level == 5 && total_score >= WIN_SCORE_THRESHOLD && !already_won) begin
                        state <= WIN_ST; already_won <= 1;
                    end
                    else if (p1_hit_detected && teleport_cooldown == 0) begin
                        teleport_to_p2 <= 1; teleport_cooldown <= 30;
                    end
                    else if (p2_hit_detected && teleport_cooldown == 0) begin
                        teleport_to_p1 <= 1; teleport_cooldown <= 30;
                    end
                    else if (bad_hit_detected) begin
                        SingleHitPulse <= 1; add_tail_amount <= 0; 
                        if (current_lives > 1) begin
                            current_lives <= current_lives - 1; state <= DIED_ST;
                        end else begin
                            current_lives <= 0; state <= GAME_OVER_ST;
                        end
                    end 
                    
                    if (apple_hit_detected) begin
                        int points_to_add;
                        if (apple_timer <= 60) points_to_add = 15; 
                        else if (apple_timer <= 120) points_to_add = 10;  
                        else if (apple_timer <= 180) points_to_add = 5;  
                        else points_to_add = 2;  

                        total_score <= total_score + points_to_add; apples_eaten <= apples_eaten + 1;
                        add_tail_amount <= 1; apple_timer <= 0; SingleHitPulse <= 1;

                        if ((total_score + points_to_add) >= 160) begin current_level <= 5; move_speed <= 8; num_trees <= 5; end
                        else if ((total_score + points_to_add) >= 120) begin current_level <= 4; move_speed <= 12; num_trees <= 4; end
                        else if ((total_score + points_to_add) >= 80) begin current_level <= 3; move_speed <= 15; num_trees <= 3; end
                        else if ((total_score + points_to_add) >= 40) begin current_level <= 2; move_speed <= 18; num_trees <= 0; end

                        if ((apples_eaten + 1) % 3 == 0) begin
                            special_apple_active <= 1; special_timer <= SPECIAL_MAX_TIME; SpecialHitPulse <= 1;
                        end
                    end
                    if (special_hit_detected && special_apple_active) begin
                        special_apple_active <= 0; SpecialHitPulse <= 1;
                        if (special_type_in == 4'b1010) begin add_tail_amount <= -3; total_score <= total_score + 8; end 
                        else if (special_type_in == 4'b1011) begin add_tail_amount <= 3; end 
                        else if(special_type_in == 4'b1100) begin reset_tail <= 1; total_score <= total_score + 8; end
                    end
                end

                DIED_ST: begin
                    apple_timer <= 0; reset_tail <= 1; 
                    if (blink_timer < 60) begin
                        blink_timer <= blink_timer + 1;
                        if (blink_timer % 10 == 0) show_player <= !show_player;
                    end 
                    else if (blink_timer < 65) begin
                        blink_timer <= blink_timer + 1; show_player <= 1'b1; reset_player_pos <= 1;
                    end else begin
                        show_player <= 1'b1; blink_timer <= 0; reset_player_pos <= 0; reset_tail <= 0; 
                        state <= COUNTDOWN_ST; 
                        countdown_val <= 3;
                        countdown_timer <= 60;
                    end
                end
                
                GAME_OVER_ST: begin
                    show_player <= 1'b0;
                    if (action_key) state <= INIT_ST;
                end

                WIN_ST: begin
                    if (action_key) state <= INIT_ST;
                end
            endcase

            game_state_out <= state;
        end
    end

    logic signed [10:0] last_saved_x, last_saved_y;
    logic [4:0] frame_counter, target_frames;
    assign target_frames = (move_speed > 0) ? move_speed : 1; 

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            snake_length <= 2; last_saved_x <= 0; last_saved_y <= 0; shift_pulse <= 0; frame_counter <= 0;
        end else begin
            shift_pulse <= 0;
            if (state == INIT_ST || state == DIED_ST || state == COUNTDOWN_ST) begin
                snake_length <= 2; frame_counter <= 0;
            end else if (add_tail_amount != 0 && startOfFrame) begin
                if (snake_length + add_tail_amount > 255) snake_length <= 255;
                else if (snake_length + add_tail_amount < 2) snake_length <= 2;
                else snake_length <= snake_length + add_tail_amount;
            end

            if (reset_player_pos) begin
                last_saved_x <= head_x; last_saved_y <= head_y;
            end else if (state == PLAY_ST && startOfFrame) begin
                if (frame_counter >= target_frames) begin
                    shift_pulse <= 1'b1; frame_counter <= 0;
                end else frame_counter <= frame_counter + 1;
            end
        end
    end
endmodule