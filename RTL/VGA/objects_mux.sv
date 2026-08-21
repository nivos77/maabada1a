module objects_mux (	
    input logic clk,
    input logic resetN,
    
    input logic smileyDrawingRequest,
    input logic [7:0] smileyRGB,
    input logic bodyDrawingRequest,
    input logic [7:0] bodyRGB,
    input logic appleDrawingRequest,
    input logic [7:0] appleRGB,
    input logic specialDrawingRequest,
    input logic [7:0] specialRGB,
    input logic portal1DrawingRequest,
    input logic [7:0] portal1RGB,
    input logic portal2DrawingRequest,
    input logic [7:0] portal2RGB,
    input logic treeDrawingRequest,
    input logic [7:0] treeRGB,
    input logic HartDrawingRequest,
    input logic [7:0] hartRGB,
    input logic [7:0] backGroundRGB,
    input logic BGDrawingRequest,
    input logic [7:0] RGB_MIF,
    input logic show_player,

    input logic ten_thousandsDR,
    input logic [7:0] ten_thousandsRGB,
    input logic thousandsDR,
    input logic [7:0] thousandsRGB,
    input logic hundredsDR,
    input logic [7:0] hundredsRGB,
    input logic tensDR,
    input logic [7:0] tensRGB,
    input logic onesDR,
    input logic [7:0] onesRGB,
    
    input logic heart1DR,
    input logic [7:0] heart1RGB,
    input logic heart2DR,
    input logic [7:0] heart2RGB,
    input logic heart3DR,
    input logic [7:0] heart3RGB,
    
    input logic level_tensDR,
    input logic [7:0] level_tensRGB,
    input logic level_onesDR,
    input logic [7:0] level_onesRGB,

    input logic screenDR,
    input logic [7:0] screenRGB,
    
    output logic [7:0] RGBOut
);

logic [23:0] color_timer;

always_ff@(posedge clk or negedge resetN) begin
    if(!resetN) begin
        RGBOut <= 8'b0;
        color_timer <= 24'b0;
    end
    else begin
        color_timer <= color_timer + 1'b1;

        if (screenDR == 1'b1)
            RGBOut <= screenRGB;
            
        else if (ten_thousandsDR == 1'b1)
            RGBOut <= 8'hFF;
        else if (thousandsDR == 1'b1)
            RGBOut <= 8'hFF;
        else if (hundredsDR == 1'b1)
            RGBOut <= 8'hFF;
        else if (tensDR == 1'b1)
            RGBOut <= 8'hFF;
        else if (onesDR == 1'b1)
            RGBOut <= 8'hFF;
            
        else if (level_tensDR == 1'b1)
            RGBOut <= 8'hFC;
        else if (level_onesDR == 1'b1)
            RGBOut <= 8'hFC;	
            
        else if (heart3DR == 1'b1)
            RGBOut <= heart3RGB;
        else if (heart2DR == 1'b1)
            RGBOut <= heart2RGB;
        else if (heart1DR == 1'b1)
            RGBOut <= heart1RGB;
            
        else if (smileyDrawingRequest == 1'b1 && show_player == 1'b1)   
            RGBOut <= smileyRGB;
        else if (bodyDrawingRequest == 1'b1 && show_player == 1'b1)
            RGBOut <= bodyRGB;
        else if (specialDrawingRequest == 1'b1) begin
            if (specialRGB == 8'hFF)
                RGBOut <= 8'hFF;
            else
                RGBOut <= specialRGB ^ {color_timer[23:22], color_timer[22:20], 3'b000};
        end
        else if (appleDrawingRequest == 1'b1)
            RGBOut <= appleRGB;
        else if (treeDrawingRequest == 1'b1)
            RGBOut <= treeRGB;
        else if (portal1DrawingRequest == 1'b1)
            RGBOut <= portal1RGB;
        else if (portal2DrawingRequest == 1'b1)
            RGBOut <= portal2RGB;
        else if (HartDrawingRequest == 1'b1)
            RGBOut <= hartRGB;
        else if (BGDrawingRequest == 1'b1)
            RGBOut <= backGroundRGB;
        else 
            RGBOut <= RGB_MIF;
    end 
end
endmodule