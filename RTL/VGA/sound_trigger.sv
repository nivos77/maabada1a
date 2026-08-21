module sound_trigger (
    input  logic clk,
    input  logic resetN,
    input  logic SingleHitPulse,
    input  logic SpecialHitPulse,
    
    output logic start_sound,
    output logic [3:0] sound_select
);

    logic prev_single, prev_special;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            start_sound <= 1'b0;
            sound_select <= 4'd0;
            prev_single <= 1'b0;
            prev_special <= 1'b0;
        end else begin
            prev_single <= SingleHitPulse;
            prev_special <= SpecialHitPulse;
            
            start_sound <= 1'b0;

            if (SpecialHitPulse && !prev_special) begin
                start_sound <= 1'b1;
                sound_select <= 4'd2;
            end
            else if (SingleHitPulse && !prev_single) begin
                start_sound <= 1'b1;
                sound_select <= 4'd1;
            end
        end
    end
endmodule