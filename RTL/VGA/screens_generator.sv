module screens_generator (
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    input  logic [2:0] game_state_out,
    input  logic [1:0] countdown_val,

    output logic screenDR,
    output logic [7:0] screenRGB
);

    localparam INIT_ST      = 3'b000;
    localparam PLAY_ST      = 3'b001;
    localparam DIED_ST      = 3'b010;
    localparam GAME_OVER_ST = 3'b011;
    localparam WIN_ST       = 3'b100;
    localparam COUNTDOWN_ST = 3'b101;

    logic [25:0] timer;
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) timer <= 0;
        else timer <= timer + 1;
    end
    
    logic [4:0] bounce;
    assign bounce = timer[25] ? timer[24:20] : ~timer[24:20];

    logic [10:0] anim_y_enter, anim_y_retry, conf_y;
    assign anim_y_enter = pixelY - bounce;
    assign anim_y_retry = pixelY - bounce;
    assign conf_y = pixelY - timer[24:18];

    logic confetti;
    assign confetti = (((pixelX * 13) ^ (conf_y * 27)) & 11'h1FF) < 2;

    logic [4:0] sy, ey, oy, wy, ry, cy, dy, ty;
    logic [5:0] sx, ex, ox, wx, rx, cx, dx, tx;

    assign sy = (pixelY >= 100 && pixelY < 180) ? ((pixelY - 100) >> 4) : 31;
    assign sx = (pixelX >= 40  && pixelX < 600) ? ((pixelX - 40)  >> 4) : 63;

    assign ey = (anim_y_enter >= 350 && anim_y_enter < 390) ? ((anim_y_enter - 350) >> 3) : 31;
    assign ex = (pixelX >= 56  && pixelX < 584) ? ((pixelX - 56)  >> 3) : 63;

    assign oy = (pixelY >= 80  && pixelY < 120) ? ((pixelY - 80)  >> 3) : 31;
    assign ox = (pixelX >= 80  && pixelX < 560) ? ((pixelX - 80)  >> 3) : 63;

    assign dy = (pixelY >= 160 && pixelY < 256) ? ((pixelY - 160) >> 3) : 31;
    assign dx = (pixelX >= 256 && pixelX < 384) ? ((pixelX - 256) >> 3) : 63;

    assign ry = (anim_y_retry >= 350 && anim_y_retry < 390) ? ((anim_y_retry - 350) >> 3) : 31;
    assign rx = (pixelX >= 180 && pixelX < 460) ? ((pixelX - 180) >> 3) : 63;

    assign wy = (pixelY >= 60  && pixelY < 100) ? ((pixelY - 60)  >> 3) : 31;
    assign wx = (pixelX >= 128 && pixelX < 512) ? ((pixelX - 128) >> 3) : 63;

    assign ty = (pixelY >= 140 && pixelY < 348) ? ((pixelY - 140) >> 4) : 31;
    assign tx = (pixelX >= 192 && pixelX < 448) ? ((pixelX - 192) >> 4) : 63;

    assign cy = (pixelY >= 160 && pixelY < 320) ? ((pixelY - 160) >> 5) : 31;
    assign cx = (pixelX >= 240 && pixelX < 400) ? ((pixelX - 240) >> 5) : 63;

    logic [0:34] snake_row;
    logic [0:65] enter_row;
    logic [0:59] over_row;
    logic [0:15] dizzy_row;
    logic [0:34] retry_row;
    logic [0:47] win_row;
    logic [0:15] trophy_row;
    logic [0:4]  count_row;

    always_comb begin
        case (sy)
            0: snake_row = 35'b01110_0_10001_0_01110_0_10001_0_11111;
            1: snake_row = 35'b10000_0_11001_0_10001_0_10100_0_10000;
            2: snake_row = 35'b01110_0_10101_0_11111_0_11000_0_11110;
            3: snake_row = 35'b00001_0_10011_0_10001_0_10100_0_10000;
            4: snake_row = 35'b01110_0_10001_0_10001_0_10001_0_11111;
            default: snake_row = 35'b0;
        endcase
        
        case (ey)
            0: enter_row = 66'b11110_0_11110_0_11111_0_01110_0_01110_00_11111_0_10001_0_11111_0_11111_0_11110;
            1: enter_row = 66'b10001_0_10001_0_10000_0_10000_0_10000_00_10000_0_11001_0_00100_0_10000_0_10001;
            2: enter_row = 66'b11110_0_11110_0_11110_0_01110_0_01110_00_11110_0_10101_0_00100_0_11110_0_11110;
            3: enter_row = 66'b10000_0_10100_0_10000_0_00001_0_00001_00_10000_0_10011_0_00100_0_10000_0_10100;
            4: enter_row = 66'b10000_0_10010_0_11111_0_01110_0_01110_00_11111_0_10001_0_00100_0_11111_0_10010;
            default: enter_row = 66'b0;
        endcase

        case (oy)
            0: over_row = 60'b01110_0_01110_0_10001_0_11111_000_01110_0_10001_0_11111_0_11110_00;
            1: over_row = 60'b10000_0_10001_0_11011_0_10000_000_10001_0_10001_0_10000_0_10001_00;
            2: over_row = 60'b10111_0_11111_0_10101_0_11110_000_10001_0_10001_0_11110_0_11110_00;
            3: over_row = 60'b10001_0_10001_0_10001_0_10000_000_10001_0_01010_0_10000_0_10100_00;
            4: over_row = 60'b01110_0_10001_0_10001_0_11111_000_01110_0_00100_0_11111_0_10010_00;
            default: over_row = 60'b0;
        endcase

        case (dy)
            0: dizzy_row  = 16'b0000111111110000;
            1: dizzy_row  = 16'b0011000000001100;
            2: dizzy_row  = 16'b0100100000010010;
            3: dizzy_row  = 16'b0100010000100010;
            4: dizzy_row  = 16'b0100001001000010;
            5: dizzy_row  = 16'b0100010000100010;
            6: dizzy_row  = 16'b0100100000010010;
            7: dizzy_row  = 16'b0011000000001100;
            8: dizzy_row  = 16'b0000111111110000;
            9: dizzy_row  = 16'b0000001111000000;
            10: dizzy_row = 16'b0000000110000000;
            11: dizzy_row = 16'b0000011111100000;
            default: dizzy_row = 16'b0;
        endcase

        case (ry)
            0: retry_row = 35'b11110_0_11111_0_11111_0_11110_0_10001_0_01110;
            1: retry_row = 35'b10001_0_10000_0_00100_0_10001_0_10001_0_10001;
            2: retry_row = 35'b11110_0_11110_0_00100_0_11110_0_01110_0_00110;
            3: retry_row = 35'b10100_0_10000_0_00100_0_10100_0_00100_0_00000;
            4: retry_row = 35'b10011_0_11111_0_00100_0_10011_0_00100_0_00100;
            default: retry_row = 35'b0;
        endcase

        case (wy)
            0: win_row = 48'b10001_0_01110_0_10001_000_10001_0_111_0_10001_00;
            1: win_row = 48'b10001_0_10001_0_10001_000_10001_0_010_0_11001_00;
            2: win_row = 48'b01010_0_10001_0_10001_000_10101_0_010_0_10101_00;
            3: win_row = 48'b00100_0_10001_0_10001_000_11011_0_010_0_10011_00;
            4: win_row = 48'b00100_0_01110_0_01110_000_10001_0_111_0_10001_00;
            default: win_row = 48'b0;
        endcase

        case (ty)
            0: trophy_row  = 16'b0011111111111100;
            1: trophy_row  = 16'b0111111111111110;
            2: trophy_row  = 16'b0100111111110010;
            3: trophy_row  = 16'b0100111111110010;
            4: trophy_row  = 16'b0111111111111110;
            5: trophy_row  = 16'b0011111111111100;
            6: trophy_row  = 16'b0000111111110000;
            7: trophy_row  = 16'b0000011111100000;
            8: trophy_row  = 16'b0000001111000000;
            9: trophy_row  = 16'b0000001111000000;
            10: trophy_row = 16'b0000011111100000;
            11: trophy_row = 16'b0001111111111000;
            12: trophy_row = 16'b0011111111111100;
            default: trophy_row = 16'b0;
        endcase

        case (countdown_val)
            2'd1: case (cy)
                0: count_row = 5'b00100;
                1: count_row = 5'b01100;
                2: count_row = 5'b00100;
                3: count_row = 5'b00100;
                4: count_row = 5'b01110;
                default: count_row = 5'b0;
            endcase
            2'd2: case (cy)
                0: count_row = 5'b01110;
                1: count_row = 5'b10001;
                2: count_row = 5'b00110;
                3: count_row = 5'b01000;
                4: count_row = 5'b11111;
                default: count_row = 5'b0;
            endcase
            2'd3: case (cy)
                0: count_row = 5'b01110;
                1: count_row = 5'b10001;
                2: count_row = 5'b00110;
                3: count_row = 5'b10001;
                4: count_row = 5'b01110;
                default: count_row = 5'b0;
            endcase
            default: count_row = 5'b0;
        endcase
    end

    logic draw_snake, draw_enter, draw_over, draw_dizzy, draw_retry, draw_win, draw_trophy, draw_count;
    
    assign draw_snake  = (sy < 5  && sx < 35) ? snake_row[sx]  : 1'b0;
    assign draw_enter  = (ey < 5  && ex < 66) ? enter_row[ex]  : 1'b0;
    assign draw_over   = (oy < 5  && ox < 60) ? over_row[ox]   : 1'b0;
    assign draw_dizzy  = (dy < 12 && dx < 16) ? dizzy_row[dx]  : 1'b0;
    assign draw_retry  = (ry < 5  && rx < 35) ? retry_row[rx]  : 1'b0;
    assign draw_win    = (wy < 5  && wx < 48) ? win_row[wx]    : 1'b0;
    assign draw_trophy = (ty < 13 && tx < 16) ? trophy_row[tx] : 1'b0;
    assign draw_count  = (cy < 5  && cx < 5)  ? count_row[cx]  : 1'b0;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            screenDR  <= 1'b0;
            screenRGB <= 8'h00;
        end
        else begin
            screenDR <= 1'b0; 

            case (game_state_out)
                INIT_ST: begin
                    screenDR <= 1'b1;
                    if (draw_snake)
                        screenRGB <= (pixelY[4]) ? 8'b000_111_00 : 8'b000_100_00; 
                    else if (draw_enter)
                        screenRGB <= 8'b111_111_11;
                    else
                        screenRGB <= (pixelX[4] ^ pixelY[4]) ? 8'b000_010_10 : 8'b000_001_01; 
                end

                GAME_OVER_ST: begin
                    screenDR <= 1'b1;
                    if (draw_over)
                        screenRGB <= 8'b111_111_00;
                    else if (draw_dizzy)
                        screenRGB <= 8'b000_111_00;
                    else if (draw_retry)
                        screenRGB <= 8'b111_111_11;
                    else
                        screenRGB <= ((pixelY + timer[23:20]) % 8 < 4) ? 8'b110_000_00 : 8'b010_000_00; 
                end

                WIN_ST: begin
                    screenDR <= 1'b1;
                    if (draw_win)
                        screenRGB <= 8'b111_111_11;
                    else if (draw_trophy)
                        screenRGB <= (pixelY[4]) ? 8'b111_101_00 : 8'b111_111_00; 
                    else if (confetti)
                        screenRGB <= {pixelX[2:0], pixelY[2:0], 2'b11}; 
                    else
                        screenRGB <= ((pixelX + pixelY + timer[23:18]) % 64 < 32) ? 8'b000_111_11 : 8'b010_011_11;
                end

                COUNTDOWN_ST: begin
                    if (draw_count) begin
                        screenDR <= 1'b1;
                        screenRGB <= 8'b111_111_11;
                    end
                end
            endcase
        end
    end
endmodule