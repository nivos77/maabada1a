module lives_decoder (
    input  logic [1:0] current_lives,
    output logic heart1_en,
    output logic heart2_en,
    output logic heart3_en
);
    always_comb begin
        heart1_en = (current_lives >= 2'd1);
        heart2_en = (current_lives >= 2'd2);
        heart3_en = (current_lives == 2'd3);
    end
endmodule