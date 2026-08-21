module score_to_BCD (
    input  logic [31:0] score_in, 
    output logic [3:0] ones,
    output logic [3:0] tens,
    output logic [3:0] hundreds,
    output logic [3:0] thousands,
    output logic [3:0] ten_thousands
);
    always_comb begin
        ones          = score_in % 10;
        tens          = (score_in / 10) % 10;
        hundreds      = (score_in / 100) % 10;
        thousands     = (score_in / 1000) % 10;
        ten_thousands = (score_in / 10000) % 10;
    end
endmodule