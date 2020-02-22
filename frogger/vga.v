

module sprite_ram_module (
    clk,
    x, y,
    color_out
);

    parameter WIDTH_X = 1;
    parameter WIDTH_Y = 1;
    parameter WIDTH_ADDRESS = WIDTH_X + WIDTH_Y;

    parameter RESOLUTION_X = 1;
    parameter RESOLUTION_Y = 1;

    parameter MIF_FILE = "UNUSED";

    input clk;
    input [WIDTH_X - 1:0] x;
    input [WIDTH_Y - 1:0] y;
    
    output [2:0] color_out;

    wire [WIDTH_ADDRESS - 1:0] address;

    assign address = x + y * RESOLUTION_X;

    altsyncram #(
        .operation_mode ("SINGLE_PORT"),
        .width_a        (3),
        .widthad_a      (WIDTH_ADDRESS),
        .init_file      (MIF_FILE)
    ) ram0 ( 
        .clock0     (clk),
        .address_a  (address),
        .q_a        (color_out)
    );
    
endmodule

module numchar_ram_module (
    clk,
    numchar,
    x, y,
    color_out
);

    input clk;
    input [6:0] numchar; // The number to display.
    input [4:0] x, y;
    
    output [2:0] color_out;

    wire [6:0] x_offset;
    assign x_offset = numchar * 7;   

    sprite_ram_module #(
        .WIDTH_X(7),
        .WIDTH_Y(4),
        .RESOLUTION_X(70),
        .RESOLUTION_Y(10),
        .MIF_FILE("graphics/num.mif")
    ) srm_0 ( 
        .clk(clk),
        .x(x_offset + x), 
	.y(y),
        .color_out(color_out)
    );

endmodule 

module plotter (
    clk, 
    en,
    x, 
    y,
    done
);

    parameter WIDTH_X = 1;
    parameter WIDTH_Y = 1;

    parameter MAX_X = 1;
    parameter MAX_Y = 1;

    input clk, en;

    output reg [WIDTH_X - 1:0] x;
    output reg [WIDTH_Y - 1:0] y;
    
    output reg done; 

    always @ (posedge clk) begin
        // increment on enable
        if (en) begin
            if (x < MAX_X - 1) begin
                x <= x + 1;
            end else begin
                x <= 0;
                y <= y + 1;
            end
        end
        // reset
        if (!en) begin
             x <= 0;
             y <= 0;
        end
        if (x == MAX_X - 1 && y == MAX_Y - 1) begin //x == max_x - 2
            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule 

