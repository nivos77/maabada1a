

module trees_manager (
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    input  logic [2:0] num_trees,
    input  logic refresh_trees, 
    
    output logic drawing_request,
    output logic [4:0] offsetX,
    output logic [4:0] offsetY
);


    logic [10:0] base_x; 
    logic [10:0] base_y; 
    
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            base_x <= 1;
            base_y <= 1;
        end else begin
		  
            base_x <= (base_x >= 18) ? 1 : base_x + 1;
            if (base_x == 18) begin
				
                base_y <= (base_y >= 13) ? 1 : base_y + 1;
            end
        end
    end

	 
    logic [10:0] tX [0:4];
    logic [10:0] tY [0:4];

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            for (int i=0; i<5; i++) begin
                tX[i] <= 0;
                tY[i] <= 0;
            end
        end 
        else if (refresh_trees) begin
		  
 
            tX[0] <= (((base_x + 0)  % 18) + 1) * 32;
            tY[0] <= (((base_y + 0)  % 11) + 2) * 32;

            tX[1] <= (((base_x + 7)  % 18) + 1) * 32;
            tY[1] <= (((base_y + 5)  % 11) + 2) * 32;

            tX[2] <= (((base_x + 13) % 18) + 1) * 32;
            tY[2] <= (((base_y + 11) % 11) + 2) * 32;

            tX[3] <= (((base_x + 3)  % 18) + 1) * 32;
            tY[3] <= (((base_y + 7)  % 11) + 2) * 32;

            tX[4] <= (((base_x + 17) % 18) + 1) * 32;
            tY[4] <= (((base_y + 2)  % 11) + 2) * 32;
        end
    end

    logic in_tree [0:4];
    
    always_comb begin
        drawing_request = 1'b0;
        offsetX = 0;
        offsetY = 0;
        
        for (int i=0; i<5; i++) begin

		  in_tree[i] = (pixelX >= tX[i] && pixelX < tX[i] + 32 &&
                          pixelY >= tY[i] && pixelY < tY[i] + 32 &&
                          i < num_trees);
                          
            if (in_tree[i]) begin
                drawing_request = 1'b1;
                offsetX = pixelX - tX[i];
                offsetY = pixelY - tY[i];
            end
        end
    end

endmodule