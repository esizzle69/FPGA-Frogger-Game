`include "vga.v"
`include "vga_adapter/vga_pll.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_adapter.v"
`include "ps2keyboard/PS2_Keyboard_Controller.v"
`include "counter.v"
`include "lfsr2.v"

/**
================================================================================
==Main=Test=====================================================================
================================================================================
**/
module main_test ();

    // ### Wires. ###

    wire clk, reset, reset_rnd;
    wire go;

    // wire [1:0] rate;

    wire draw_start, draw_game_over, draw_game_bg, draw_frog;
    wire draw_log_1_1, draw_log_2_1, draw_log_3_1;
    wire draw_score, draw_lives;
    wire frog_erase;
    wire moving_objects;

    wire draw_log_1_2, draw_log_1_3, draw_log_2_2, draw_log_2_3, draw_log_3_2, draw_log_3_3;


    // wire [3:0] score, lives;

    wire done_plotting;

    wire dne_signal_1, dne_signal_2;

    wire plot;
    wire [8:0] x, y;
    wire [2:0] color;

    // VGA wires.
    wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    wire [9:0] VGA_R, VGA_G, VGA_B;

    // ### Datapath and control. ###

    datapath d0 (
        .clk(clk), .reset(reset), .reset_rnd(reset_rnd),

        .draw_start(draw_start), .draw_game_over(draw_game_over),
        .draw_game_bg(draw_game_bg), .draw_frog(draw_frog),
        .draw_log_1_1(draw_log_1_1), .draw_log_2_1(draw_log_2_1), .draw_log_3_1(draw_log_3_1),
        .draw_score(draw_score), .draw_lives(draw_lives), .draw_level(draw_level),
        .moving_objects(moving_objects),
        .frog_erase(frog_erase),
        .reset_game(reset_game),

        .draw_log_1_2(draw_log_1_2), .draw_log_1_3(draw_log_1_3), .draw_log_2_2(draw_log_2_2),
        .draw_log_2_3(draw_log_2_3), .draw_log_3_2(draw_log_3_2), .draw_log_3_3(draw_log_3_3),

        // .rate(rate),

        .ld_frog_loc(ld_frog_loc),

        // .score(score), .lives(lives),

        .frame_tick(frame_tick),

        .left(left), .right(right), .up(up), .down(down),

        .done_plotting(done_plotting),

        .plot(plot), .x(x), .y(y), .color(color),
        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2),
        .win(win), .die(die), .lose(lose)
    );

    control c0 (
        .clk(clk), .reset(reset),

        .go(go), .done_plotting(done_plotting), .space(space),
        .win(win), .die(die), .lose(lose),

        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2),

        .frame_tick(frame_tick),

        .draw_start(draw_start), .draw_game_over(draw_game_over),
        .draw_game_bg(draw_game_bg), .draw_frog(draw_frog),
        .draw_log_1_1(draw_log_1_1), .draw_log_2_1(draw_log_2_1), .draw_log_3_1(draw_log_3_1),
        .draw_score(draw_score), .draw_lives(draw_lives), .draw_level(draw_level),
        .moving_objects(moving_objects),
        .frog_erase(frog_erase),
        .reset_game(reset_game),

        .ld_frog_loc(ld_frog_loc),

        .draw_log_1_2(draw_log_1_2), .draw_log_1_3(draw_log_1_3), .draw_log_2_2(draw_log_2_2),
        .draw_log_2_3(draw_log_2_3), .draw_log_3_2(draw_log_3_2), .draw_log_3_3(draw_log_3_3),

        .current_state(current_state)
    );

        // ### VGA adapter. ###

    vga_adapter #(
        .RESOLUTION("320x240"),
        .MONOCHROME("FALSE"),
        .BITS_PER_COLOUR_CHANNEL(1),
        .BACKGROUND_IMAGE("mif_files/black.mif")
    ) vga (
        .clock(clk), .resetn(!reset),

        // Controlled signals.
        .x(x), .y(y), .colour(color),
        .plot(plot),

        // VGA DAC signals.
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B)
    );

endmodule // main_test
/**
================================================================================
==Main=Test=End=================================================================
================================================================================
**/

/**
================================================================================
==Top=Module====================================================================
================================================================================
**/
module frogger (
    CLOCK_50,
    KEY, SW,
    PS2_CLK, PS2_DAT,
    LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B
);

    // ### FPGA inputs and outputs. ###

    input CLOCK_50;

    // For auxilary input or debugging.
    input [9:0] SW;
    input [3:0] KEY;

    // For keyboard input and output.
    inout PS2_CLK;
    inout PS2_DAT;

    // For auxiliary output or debugging.
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // VGA DAC signals.
    output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    output [9:0] VGA_R, VGA_G, VGA_B;

    // ### Wires. ###

    wire clk = CLOCK_50;
    wire go_key = !KEY[0];
    wire reset = !KEY[3];
    wire reset_rnd = !KEY[1];
    wire enable = !KEY[2];

    // ### Testing. ###
    // wire [3:0] score = SW[3:0];
    // wire [3:0] lives = SW[7:4];
    // wire [1:0] rate = SW[9:8];

    reg go;

    wire draw_start, draw_game_over, draw_game_bg, draw_frog;
    wire draw_log_1_1, draw_log_2_1, draw_log_3_1;
    wire draw_car_1_1, draw_car_2_1, draw_car_3_1;
    wire draw_score, draw_lives;
    wire frog_erase;
    wire moving_objects;

    wire draw_slot_1, draw_slot_2, draw_slot_3, draw_slot_4, draw_slot_5;
    wire draw_log_1_2, draw_log_1_3, draw_log_2_2, draw_log_2_3, draw_log_3_2, draw_log_3_3;
    wire draw_car_1_2, draw_car_1_3, draw_car_2_2, draw_car_2_3, draw_car_3_2, draw_car_3_3;
    wire done_plotting;

    wire frame_tick;
    wire dne_signal_1, dne_signal_2;
    wire ld_frog_loc;

    wire plot;
    wire [8:0] current_x; 								// by monday, was [9:0]
    wire [8:0] current_y;
    wire [2:0] current_color;

    wire win, die, lose;

    // VGA wires.
    wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    wire [9:0] VGA_R, VGA_G, VGA_B;

    // Keyboard wires.
    wire w, a, s, d;
    wire up, left, down, right;
    wire space, enter;

    wire reset_game;

    // wire mov_key_pressed;

    // assign mov_key_pressed = w | a | s | d | up | left | down | right;

    // The output from the counter for the keyboard.
    wire clock_keyboard;

    // Since both w, a, s, d and up, left, down, right are the same controls, the wires can be combined.
    // wire up_c, left_c, down_c, right_c;

    // assign up_c = w || up;
    // assign left_c = a || left;
    // assign down_c = s || down;
    // assign right_c = d || right;

     // ### GO button stuff. ###

	  /*
    reg [1:0] go_state, go_next_state;

    localparam  GS_WAIT_GO = 0,
                GS_GO_1	  = 1,
                GS_GO_2	  = 2,
                GS_WAIT	  = 3;

    always @ (*) begin
        case (go_state)
            GS_WAIT_GO:
                go_next_state = go_key ? GS_GO_1 : GS_WAIT_GO;
            GS_GO_1:
                go_next_state = GS_GO_2;
            GS_GO_2:
                go_next_state = GS_WAIT;
            GS_WAIT:
                go_next_state = !go_key ? GS_WAIT_GO : GS_WAIT;
        endcase
    end

    always @ (*) begin
            go = ((go_state == GS_GO_1) || (go_state == GS_GO_2)) ? 1 : 0;
    end

    always @ (posedge clk) begin
            if (reset)
                go_state <= GS_WAIT_GO;
            else
                go_state <= go_next_state;
    end

    // ### Debug stuff. ###

    wire [5:0] current_state;


     // ### Hex displays. ###
    hex_dec hd0 (.in(current_state), .out(HEX0));

    hex_dec hd1 (.in(go_state), .out(HEX1));
    hex_dec hd2 (.in(go_key), .out(HEX2));
    */
    assign LEDR[9] = win;
    assign LEDR[8] = die;

    assign LEDR[3] = up;
    assign LEDR[2] = left;
    assign LEDR[1] = down;
    assign LEDR[0] = right;

    // ### Datapath and control. ###

    datapath d0 (
        .clk(clk), .reset(reset), .reset_rnd(reset_rnd),

        .draw_start(draw_start), .draw_game_over(draw_game_over),
        .draw_game_bg(draw_game_bg), .draw_frog(draw_frog),

        .draw_log_1_1(draw_log_1_1), .draw_log_2_1(draw_log_2_1), .draw_log_3_1(draw_log_3_1),
        .draw_log_1_2(draw_log_1_2), .draw_log_1_3(draw_log_1_3), .draw_log_2_2(draw_log_2_2),
        .draw_log_2_3(draw_log_2_3), .draw_log_3_2(draw_log_3_2), .draw_log_3_3(draw_log_3_3),
        .draw_car_1_1(draw_car_1_1), .draw_car_2_1(draw_car_2_1), .draw_car_3_1(draw_car_3_1),
        .draw_car_1_2(draw_car_1_2), .draw_car_1_3(draw_car_1_3), .draw_car_2_2(draw_car_2_2),
        .draw_car_2_3(draw_car_2_3), .draw_car_3_2(draw_car_3_2), .draw_car_3_3(draw_car_3_3),

	.draw_slot_1(draw_slot_1), .draw_slot_2(draw_slot_2), .draw_slot_3(draw_slot_3), 
        .draw_slot_4(draw_slot_4), .draw_slot_5(draw_slot_5),

	.draw_score(draw_score), .draw_lives(draw_lives),

        .moving_objects(moving_objects),
        .frog_erase(frog_erase),

        // .rate(rate),

        .ld_frog_loc(ld_frog_loc),
        .reset_game(reset_game),

        // .score(score), .lives(lives),

        .frame_tick(frame_tick),

        .left(left), .right(right), .up(up), .down(down),

        .done_plotting(done_plotting),

        .plot(plot), .x(current_x), .y(current_y), .color(current_color),
        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2),
        .win(win), .die(die), .lose(lose)
    );


    control c0 (
        .clk(clk), .reset(reset),

        .go(go), .done_plotting(done_plotting), .space(space),
        .win(win), .die(die), .lose(lose),

        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2),

        .frame_tick(frame_tick),

        .draw_start(draw_start), .draw_game_over(draw_game_over),
        .draw_game_bg(draw_game_bg), .draw_frog(draw_frog),

        .draw_log_1_1(draw_log_1_1), .draw_log_2_1(draw_log_2_1), .draw_log_3_1(draw_log_3_1),
        .draw_car_1_1(draw_car_1_1), .draw_car_2_1(draw_car_2_1), .draw_car_3_1(draw_car_3_1),
        .draw_score(draw_score), .draw_lives(draw_lives), .moving_objects(moving_objects),
        .frog_erase(frog_erase),

	.reset_game(reset_game),
        .ld_frog_loc(ld_frog_loc),

        .draw_log_1_2(draw_log_1_2), .draw_log_1_3(draw_log_1_3), .draw_log_2_2(draw_log_2_2),
        .draw_log_2_3(draw_log_2_3), .draw_log_3_2(draw_log_3_2), .draw_log_3_3(draw_log_3_3),

		  .draw_slot_1(draw_slot_1), .draw_slot_2(draw_slot_2), .draw_slot_3(draw_slot_3), 
        .draw_slot_4(draw_slot_4), .draw_slot_5(draw_slot_5),

        .current_state(current_state)
    );

    // ### VGA adapter. ###

    vga_adapter #(
        .RESOLUTION("320x240"),
		  .BITS_PER_COLOUR_CHANNEL(1),
        .MONOCHROME("FALSE"),
        .BACKGROUND_IMAGE("mif_files/black.mif")
    ) vga (
        .clock(clk), .resetn(!reset),
        // Controlled signals.
        .x(current_x), .y(current_y), .colour(current_color),
        .plot(plot),
        // VGA DAC signals.
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B)
    );


    // ### Keyboard tracker. ###
    keyboard_tracker #(.PULSE_OR_HOLD(0)) tester(
         .clock(CLOCK_50),
          .reset(!reset),
          .PS2_CLK(PS2_CLK),
          .PS2_DAT(PS2_DAT),
          //.w(up),
          //.a(left),
          //.s(down),
          //.d(right),
          .left(left),
          .right(right),
          .up(up),
          .down(down),
          .space(space),
          .enter(enter)
          );

endmodule // top

/**
================================================================================
==Top=Module=End================================================================
================================================================================
**/


/**
================================================================================
==Datapath======================================================================
================================================================================
**/

module datapath (
    clk, reset, reset_rnd,
    draw_start, draw_game_over, draw_game_bg, draw_frog,
    draw_log_1_1, draw_log_2_1, draw_log_3_1,
    draw_car_1_1, draw_car_2_1, draw_car_3_1,
    draw_score, draw_lives,
    moving_objects,
    frog_erase,
    draw_log_1_2, draw_log_1_3, draw_log_2_2, draw_log_2_3, draw_log_3_2, draw_log_3_3,
    draw_car_1_2, draw_car_1_3, draw_car_2_2, draw_car_2_3, draw_car_3_2, draw_car_3_3,
    draw_slot_1, draw_slot_2, draw_slot_3, draw_slot_4, draw_slot_5,
    ld_frog_loc,
    reset_game,
    frame_tick,
    left, right, up, down,
    done_plotting,
    plot, x, y, color,
    dne_signal_1, dne_signal_2,
    win, die, lose
);

    // ### Inputs, outputs and wires. ###

    input clk, reset, reset_rnd;

    input draw_start, draw_game_over, draw_game_bg, draw_frog;

    input draw_log_1_1, draw_log_2_1, draw_log_3_1;
    input draw_car_1_1, draw_car_2_1, draw_car_3_1;

    input draw_score, draw_lives;

    input moving_objects;

    input frog_erase;

    input draw_log_1_2, draw_log_1_3, draw_log_2_2, draw_log_2_3, draw_log_3_2, draw_log_3_3;
    input draw_car_1_2, draw_car_1_3, draw_car_2_2, draw_car_2_3, draw_car_3_2, draw_car_3_3;

    input draw_slot_1, draw_slot_2, draw_slot_3, draw_slot_4, draw_slot_5;

    input ld_frog_loc;

    input reset_game;

    input left, right, up, down;

    output done_plotting;

    output reg [2:0] color;
    output plot;
    output reg [9:0] x;
    output reg [8:0] y;

    // does not exist signal 1 and 2, alternate usage to prevent timing issues
    output reg dne_signal_1, dne_signal_2;

    wire finish_screen_plotting, finish_character_plotting, finish_river_plotting, finish_frog_plotting, finish_road_plotting;

    assign done_plotting = finish_screen_plotting || finish_character_plotting || finish_river_plotting || finish_frog_plotting || 		
				finish_road_plotting;

    wire [9:0] x_screen, x_character, x_log, x_car, x_frog;
    wire [8:0] y_screen, y_character, y_log, y_car, y_frog;



    output win, die, lose;

    reg [6:0] rate;
    reg [6:0] score, lives;

    assign lose = (lives == 0);

    reg pre_plot;

    wire frog_done;

    assign plot = pre_plot && !frog_done;

    // ### Top left coordinates of frog in the game ###.
    reg [9:0] frog_x;
    reg [8:0] frog_y;

    // ### First row of river objects ###.
    reg [9:0] log_1_1_x, log_1_2_x, log_1_3_x;
    reg [8:0] log_1_1_y, log_1_2_y, log_1_3_y;
    // ### Second row of river objects ###.
    reg [9:0] log_2_1_x, log_2_2_x, log_2_3_x;
    reg [8:0] log_2_1_y, log_2_2_y, log_2_3_y;
    // ### Third row of river objects ###.
    reg [9:0] log_3_1_x, log_3_2_x, log_3_3_x;
    reg [8:0] log_3_1_y, log_3_2_y, log_3_3_y;

    // ### First row of car objects ###.
    reg [9:0] car_1_1_x, car_1_2_x, car_1_3_x;
    reg [8:0] car_1_1_y, car_1_2_y, car_1_3_y;
    // ### Second row of car objects ###.
    reg [9:0] car_2_1_x, car_2_2_x, car_2_3_x;
    reg [8:0] car_2_1_y, car_2_2_y, car_2_3_y;
    // ### Third row of car objects ###.
    reg [9:0] car_3_1_x, car_3_2_x, car_3_3_x;
    reg [8:0] car_3_1_y, car_3_2_y, car_3_3_y;

    // draw log signals
    wire draw_log_1_1, draw_log_1_2, draw_log_1_3, draw_log_2_2, draw_log_2_3, draw_log_3_2, draw_log_3_3;
    // draw car signals
    wire draw_car_1_1, draw_car_1_2, draw_car_1_3, draw_car_2_2, draw_car_2_3, draw_car_3_2, draw_car_3_3;
    // draw major signals
    wire draw, draw_character, draw_log, draw_car, draw_screen;  //

    assign draw = draw_character || draw_log || draw_car || draw_frog || draw_slot_1 || draw_slot_2 || draw_slot_3 || draw_slot_4 || draw_slot_5 || frog_erase;
    //assign draw_score = draw_start || draw_game_over || draw_game_bg;
	 
    assign draw_screen = draw_start || draw_game_over || draw_game_bg;
	 
    assign draw_character = draw_score || draw_lives; 
    assign draw_log = draw_log_1_1|| draw_log_2_1 || draw_log_3_1 ||
      		draw_log_1_2 || draw_log_1_3 ||
      		draw_log_2_2 || draw_log_2_3 ||
      		draw_log_3_2 || draw_log_3_3;
    assign draw_car = draw_car_1_1 || draw_car_2_1 || draw_car_3_1 ||
      		draw_car_1_2 || draw_car_1_3 ||
      		draw_car_2_2 || draw_car_2_3 ||
      		draw_car_3_2 || draw_car_3_3;


    // ### Frog collision detection signals. ###
    // Center of frog is used for these locations, i.e. x = frog_x + 32 /2, y = frog_y + 24 / 2.
    wire on_river;
    wire on_road;
    reg frog_in_1, frog_in_2, frog_in_3, frog_in_4, frog_in_5;

    // if on river or road
    assign on_river = (frog_y > 54) && (frog_y < 139);  //108, 279
    assign on_road = (frog_y >= 139) && (frog_y < 225); //279, 450
    assign win = frog_in_1 && frog_in_2 && frog_in_3 && frog_in_4 && frog_in_5;

    // Check on which river row the frog is.
    wire on_log, on_river_row_1, on_river_row_2, on_river_row_3;
    assign on_river_row_1 = (frog_y > 54) && (frog_y < 82); //108, 165
    assign on_river_row_2 = (frog_y > 82) && (frog_y < 111); //165, 222
    assign on_river_row_3 = (frog_y > 111) && (frog_y < 139); //222, 279 
    
    wire not_on_car, on_road_row_1, on_road_row_2, on_road_row_3;
    assign on_road_row_1 = (frog_y > 139) && (frog_y < 168); //279, 336
    assign on_road_row_2 = (frog_y > 168) && (frog_y < 186); //336, 393
    assign on_road_row_3 = (frog_y > 186) && (frog_y < 225); //393, 450

    reg river_1_2_exists, river_1_3_exists;
    reg river_2_2_exists, river_2_3_exists;
    reg river_3_2_exists, river_3_3_exists;
    reg road_1_2_exists, road_1_3_exists;
    reg road_2_2_exists, road_2_3_exists;
    reg road_3_2_exists, road_3_3_exists;

    // Check whether the frog is on a river object and on which row.
    wire on_log_row_1, on_log_row_2, on_log_row_3;
	 
    assign on_log_row_1 = on_river_row_1 && (
        (frog_x > log_1_1_x[9:0] && frog_x + 32 < log_1_1_x[9:0] + 100) ||
        (river_1_2_exists && frog_x > log_1_2_x[9:0] && frog_x + 32 < log_1_2_x[9:0] + 100) ||
        (river_1_3_exists && frog_x > log_1_3_x[9:0] && frog_x + 32 < log_1_3_x[9:0] + 100));
    assign on_log_row_2 = on_river_row_2 && (
        (frog_x > log_2_1_x[9:0] && frog_x + 32 < log_2_1_x[9:0] + 100) ||
        (river_2_2_exists && frog_x > log_2_2_x[9:0] && frog_x + 32 < log_2_2_x[9:0] + 100) ||
        (river_2_3_exists && frog_x > log_2_3_x[9:0] && frog_x + 32 < log_2_3_x[9:0] + 100));
    assign on_log_row_3 = on_river_row_3 && (
        (frog_x > log_3_1_x[9:0] && frog_x + 32 < log_3_1_x[9:0] + 100) ||
        (river_3_2_exists && frog_x > log_3_2_x[9:0] && frog_x + 32 < log_3_2_x[9:0] + 100) ||
        (river_3_3_exists && frog_x > log_3_3_x[9:0] && frog_x + 32 < log_3_3_x[9:0] + 100));
    assign on_log = on_log_row_1 || on_log_row_2 || on_log_row_3;

    wire on_car_row_1, on_car_row_2, on_car_row_3;
	 
    assign on_car_row_1 = on_road_row_1 && (
        (frog_x > car_1_1_x[9:0] && frog_x + 32 < car_1_1_x[9:0] + 100) ||
        (road_1_2_exists && frog_x > car_1_2_x[9:0] && frog_x + 32 < car_1_2_x[9:0] + 100) ||
        (road_1_3_exists && frog_x > car_1_3_x[9:0] && frog_x + 32 < car_1_3_x[9:0] + 100));
		  
    assign on_car_row_2 = on_road_row_2 && (
        (frog_x > car_2_1_x[9:0] && (frog_x + 32) < (car_2_1_x[9:0] + 100)) ||
        (road_2_2_exists && frog_x > car_2_2_x[9:0] && frog_x + 32 < car_2_2_x[9:0] + 100) ||
        (road_2_3_exists && frog_x > car_2_3_x[9:0] && frog_x + 32 < car_2_3_x[9:0] + 100));
		  
    assign on_car_row_3 = on_road_row_3 && (
        (frog_x > car_3_1_x[9:0] && frog_x + 32 < car_3_1_x[9:0] + 100) ||
        (road_3_2_exists && frog_x > car_3_2_x[9:0] && frog_x + 32 < car_3_2_x[9:0] + 100) ||
        (road_3_3_exists && frog_x > car_3_3_x[9:0] && frog_x + 32 < car_3_3_x[9:0] + 100));
    assign not_on_car = !on_car_row_1 || !on_car_row_2 || !on_car_row_3;

    // condition to die.
    assign die = on_river && !on_log || on_road && !not_on_car;



     // ### Counter to delay the keyboard. ###
    wire [20:0] frame_counter;
    output frame_tick;
    assign frame_tick = frame_counter == 834168;
    counter counter0 (
        .clk(clk),
        .en(1),
        .rst(reset),
        .out(frame_counter)
    );

    // LFSR (Linear feedback shift register), outputs a random 13 bit number
    // bits [5:0] determine if additional random objects are generated
    //
    wire [19:0] rnd_generator;
    // Used for spawning river objects. Minimum distance is min_dist, max is
    // min_dist + 15
    wire [19:0] random_20 = rnd_generator;
    LFSR #(20)
      lfsr0 (
        .i_Clk(clk),
        .i_Enable(1),
        .o_LFSR_Data(rnd_generator),
		  .o_LFSR_Done(lfsr_done)
      );

    // get the 4 least significant bit
    // used in randomly generating river objects

    // ### Timing adjustments. ###
    wire [1:0] frog_x_r, frog_x_l, frog_y_d, frog_y_u;
	 
    assign frog_x_r = right + rate * on_log_row_1 + rate * on_log_row_3;
    assign frog_x_l = left + rate * on_log_row_2;
    assign frog_y_d = down;
    assign frog_y_u = up;

    always @ (posedge clk) begin
        // Plot signal, x and y need to be delayed by one clock cycle
        // due to delay of retrieving data from memory.
        // The x and y offsets specify the top left corner of the sprite
        // that is being drawn.
        pre_plot <= draw;

        // starting coordinates of the frog and river objects
        if (reset || reset_game) begin
            frog_x <= 640 / 2 - 32 / 2; // spawn frog in middle horizontally
            frog_y <= 320 - 24 - 5; // spawn frog a few pixels from the bottom edge
            // reset the data
            // initial rate is 0.5 and increments by 0.5 everytime a win signal is triggered
            rate <= 1;
            lives <= 5;
            score <= 0;

	    // ### First object on river row 1 ###.
            log_1_1_x <= 0;
            log_1_1_y <= 54;
            log_1_1_x <= log_1_1_x << 1; // in case spawn x coordinate is not 0
				river_1_2_exists <= 1;
				log_1_2_x <= 8'd50 + 8'd40 + random_20[4:1];
				log_1_2_x <= log_1_2_x << 1'b1;
				log_1_2_y <= 54;
				river_1_3_exists <= 1;
				log_1_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[5:2];
            log_1_3_x <= log_1_3_x << 1'b1;
            log_1_3_y <= 54;

				log_2_1_x <= 0;
            log_2_1_y <= 83;
				log_2_1_x <= log_2_1_x << 1;
				river_2_2_exists <= 1;
				log_2_2_x <= 8'd50 + 8'd40 + random_20[6:2];
				log_2_2_x <= log_2_2_x << 1'b1;
				log_2_2_y <= 83;
				river_2_3_exists <= 1;
				log_2_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[7:4];
            log_2_3_x <= log_2_3_x << 1'b1;
            log_2_3_y <= 83; //166
	    
				log_3_1_x <= 0;
            log_3_1_y <= 111;
            log_3_1_x <= log_3_1_x << 1;
				river_3_2_exists <= 1;
				log_3_2_x <= 8'd50 + 8'd40 + random_20[8:5];
				log_3_2_x <= log_3_2_x << 1'b1;
				log_3_2_y <= 111;
				river_3_3_exists <= 1;
				log_3_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[9:6];
            log_3_3_x <= log_3_3_x << 1'b1;
            log_3_3_y <= 111; //223
	   
				car_1_1_x <= 0;
            car_1_1_y <= 140;
            car_1_1_x <= car_1_1_x << 1; // in case spawn x coordinate is not 0
				road_1_2_exists <= 1;
				car_1_2_x <= 8'd50 + 8'd40 + random_20[10:7];
				car_1_2_x <= car_1_2_x << 1'b1;
				car_1_2_y <= 140;
				road_1_3_exists <= 1;
			   car_1_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[11:8];
            car_1_3_x <= car_1_3_x << 1'b1;
            car_1_3_y <= 140; //280

				car_2_1_x <= 0;
            car_2_1_y <= 168;
            car_2_1_x <= car_2_1_x << 1;
				road_2_2_exists <= 1;
				car_2_2_x <= 8'd50 + 8'd40 + random_20[12:9];
				car_2_2_x <= car_2_2_x << 1'b1;
				car_2_2_y <= 168;
				road_2_3_exists <= 1;
				car_2_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[13:10];
				car_2_3_x <= car_2_3_x << 1'b1;
				car_2_3_y <= 168; //337
	    
				car_3_1_x <= 0;
            car_3_1_y <= 197; //394
            car_3_1_x <= car_3_1_x << 1;
				road_3_2_exists <= 1;
				car_3_2_x <= 8'd50 + 8'd40 + random_20[14:11]; //100, 80
				car_3_2_x <= car_3_2_x << 1'b1;
				car_3_2_y <= 197; //394
				road_3_3_exists <= 1;
				car_3_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[15:12];//100, 80, 31, 80
            car_3_3_x <= car_3_3_x << 1'b1;
            car_3_3_y <= 197; //394
          
        end else if (draw_log_1_1) begin
            // river object 1 flows right at 60 pixels per second
            // object only moves horizontally
            x <= log_1_1_x[9:0] + x_log;
            y <= log_1_1_y + y_log;
        end else if (draw_log_2_1) begin
            // river object 2 flows left at 60 pixels per second
            // object only moves horizontally
            x <= log_2_1_x[9:0] + x_log;
            y <= log_2_1_y + y_log;
        end else if (draw_log_3_1) begin
            // river object 3 flows right at 60 pixels per second
            // object only moves horizontally
            x <= log_3_1_x[9:0] + x_log;
            y <= log_3_1_y + y_log;
            // move the river object for the next frame
        end else if (draw_log_1_2) begin
            dne_signal_2 <= 0;
            if (river_1_2_exists) begin
              x <= log_1_2_x[9:0] + x_log;
              y <= log_1_2_y + y_log;
            end else begin
              dne_signal_1 <= 1;
            end
        end else if (draw_log_1_3) begin
            dne_signal_1 <= 0;
            if (river_1_3_exists) begin
              x <= log_1_3_x[9:0] + x_log;
              y <= log_1_3_y + y_log;
            end else begin
              dne_signal_2 <= 1;
            end
        end else if (draw_log_2_2) begin
            dne_signal_2 <= 0;
            if (river_2_2_exists) begin
              x <= log_2_2_x[9:0] + x_log;
              y <= log_2_2_y + y_log;
            end else begin
              dne_signal_1 <= 1;
            end
        end else if (draw_log_2_3) begin
            dne_signal_1 <= 0;
            if (river_2_3_exists) begin
              x <= log_2_3_x[9:0] + x_log;
              y <= log_2_3_y + y_log;
            end else begin
              dne_signal_2 <= 1;
            end
        end else if (draw_log_3_2) begin
            dne_signal_2 <= 0;
            if (river_3_2_exists) begin
              x <= log_3_2_x[9:0] + x_log;
              y <= log_3_2_y + y_log;
            end else begin
              dne_signal_1 <= 1;
            end
        end else if(draw_log_3_3) begin
              dne_signal_1 <= 0;
            if(river_3_3_exists) begin
              x <= log_3_3_x[9:0] + x_log;
              y <= log_3_3_y + y_log;
            end else begin
              dne_signal_2 <= 1;
            end
        end else if (draw_car_1_1) begin
            // road object 1 flows right at 60 pixels per second
            // object only moves horizontally
            x <= car_1_1_x[9:0] + x_car;
            y <= car_1_1_y + y_car;
        end else if (draw_car_2_1) begin
            // road object 2 flows left at 60 pixels per second
            // object only moves horizontally
            x <= car_2_1_x[9:0] + x_car;
            y <= car_2_1_y + y_car;
        end else if (draw_car_3_1) begin
            // road object 3 flows right at 60 pixels per second
            // object only moves horizontally
            x <= car_3_1_x[9:0] + x_car;
            y <= car_3_1_y + y_car;
            // move the road object for the next frame
        end else if (draw_car_1_2) begin
            dne_signal_2 <= 0;
            if (road_1_2_exists) begin
              x <= car_1_2_x[9:0] + x_car;
              y <= car_1_2_y + y_car;
            end else begin
              dne_signal_1 <= 1;
            end
        end else if (draw_car_1_3) begin
            dne_signal_1 <= 0;
            if (road_1_3_exists) begin
              x <= car_1_3_x[9:0] + x_car;
              y <= car_1_3_y + y_car;
            end else begin
              dne_signal_2 <= 1;
            end
        end else if (draw_car_2_2) begin
            dne_signal_2 <= 0;
            if (road_2_2_exists) begin
              x <= car_2_2_x[9:0] + x_car;
              y <= car_2_2_y + y_car;
            end else begin
              dne_signal_1 <= 1;
            end
        end else if (draw_car_2_3) begin
            dne_signal_1 <= 0;
            if (road_2_3_exists) begin
              x <= car_2_3_x[9:0] + x_car;
              y <= car_2_3_y + y_car;
            end else begin
              dne_signal_2 <= 1;
            end
        end else if (draw_car_3_2) begin
            dne_signal_2 <= 0;
            if (road_3_2_exists) begin
              x <= car_3_2_x[9:0] + x_car;
              y <= car_3_2_y + y_car;
            end else begin
              dne_signal_1 <= 1;
            end
        end else if (draw_car_3_3) begin
              dne_signal_1 <= 0;
            if (road_3_3_exists) begin
              x <= car_3_3_x[9:0] + x_car;
              y <= car_3_3_y + y_car;
            end else begin
              dne_signal_2 <= 1;
            end

        end else if (draw_score) begin
            x <= 290 + x_character;  //580
            y <= 5 + y_character;   //10
        end else if (draw_lives) begin
            x <= 290 + x_character;  //580
            y <= 20 + y_character;   //41
        //end else if (draw_level) begin
        //    x <= 300 + x_character;
        //    y <= 38 + y_character;
        end else if (draw_frog) begin
            x <= frog_x + x_frog;
            y <= frog_y + y_frog;
	end else if (draw_slot_1 && frog_in_1) begin   // if there are frog in slot 1
	    x <= 4 + x_frog; //8
	    y <= 39 + y_frog; //78
	end else if (draw_slot_2 && frog_in_2) begin   // if there are frog in slot 2
            x <= 78 + x_frog; //156
	    y <= 39 + y_frog;	//78
	end else if (draw_slot_3 && frog_in_3) begin   // if there are frog in slot 3
	    x <= 152 + x_frog; //304
	    y <= 39 + y_frog;  //78
	end else if (draw_slot_4 && frog_in_4) begin   // if there are frog in slot 4
	    x <= 226 + x_frog;  //452
	    y <= 39 + y_frog;   //78
	end else if (draw_slot_5 && frog_in_5) begin   // if there are frog in slot 5
	    x <= 300 + x_frog;  //600
	    y <= 39 + y_frog;   //78
	end else if (moving_objects) begin
            // flows right
            log_1_1_x <= log_1_1_x + rate;
            // flows left
            log_2_1_x <= log_2_1_x - rate;
            // flows right
            log_3_1_x <= log_3_1_x + rate;
	    // flows right
            car_1_1_x <= car_1_1_x - rate;
            // flows left
            car_2_1_x <= car_2_1_x + rate;
            // flows right
            car_3_1_x <= car_3_1_x - rate;

            if(river_1_2_exists) begin
              log_1_2_x <= log_1_2_x + rate;
            end
            if(river_1_3_exists) begin
              log_1_3_x <= log_1_3_x + rate;
            end
            if(river_2_2_exists) begin
              log_2_2_x <= log_2_2_x - rate;
            end
            if(river_2_3_exists) begin
              log_2_3_x <= log_2_3_x - rate;
            end
            if(river_3_2_exists) begin
              log_3_2_x <= log_3_2_x + rate;
            end
            if(river_3_3_exists) begin
              log_3_3_x <= log_3_3_x + rate;
            end
				if(road_1_2_exists) begin
              car_1_2_x <= car_1_2_x + rate;
            end
            if(road_1_3_exists) begin
              car_1_3_x <= car_1_3_x + rate;
            end
            if(road_2_2_exists) begin
              car_2_2_x <= car_2_2_x - rate;
            end
            if(road_2_3_exists) begin
              car_2_3_x <= car_2_3_x - rate;
            end
            if(road_3_2_exists) begin
              car_3_2_x <= car_3_2_x + rate;
            end
            if(road_3_3_exists) begin
              car_3_3_x <= car_3_3_x + rate;
            end

            // check left and right boundaries (max x = resolution width - frog width - 1)
            if ((frog_x + frog_x_r - frog_x_l >= 0) && (frog_x + frog_x_r - frog_x_l <= 320 - 32 - 1)) begin
                // update top left pixel's x coordinate if possible
                frog_x <= frog_x + frog_x_r - frog_x_l;
            end

            // check up and down boundaries (max y = resolution height - frog height - 1)
            if ((frog_y + frog_y_d - frog_y_u >= 54) && (frog_y + frog_y_d - frog_y_u <= 240 - 24 - 1)) begin // 108
                // update top left pixel's y coordinate if possible
                frog_y <= frog_y + frog_y_d - frog_y_u;
            end

	    // check if frog reaches one of the 5 slots
        end else if (draw_screen) begin
            x <= x_screen;
            y <= y_screen;
        end else if ((frog_in_1 + frog_in_2 + frog_in_3 + frog_in_4 + frog_in_5) > score) begin
            score <= score + 1;
            rate <= rate + 1;
            frog_x <= 320 / 2 - 32 / 2; // spawn frog in middle horizontally
            frog_y <= 240 - 15 + 5; // spawn frog a few pixels from the bottom edge
        end

	if (frog_x <= 16 && frog_y <= 108) begin
		frog_in_1 <= 1;
	end else if (frog_x < 82 && frog_x > 74 && frog_y < 54) begin//165, 148, 108
		frog_in_2 <= 1;
	end else if (frog_x < 157 && frog_x > 148 && frog_y < 54) begin// 314, 296, 108
		frog_in_3 <= 1;
	end else if (frog_x < 232 && frog_x > 222 && frog_y < 54) begin// 463, 444, 108
		frog_in_4 <= 1;
	end else if (frog_x < 306 && frog_x > 296 && frog_y < 54) begin//612, 592, 108
		frog_in_5 <= 1;
	end

        if (die) begin
            lives <= lives - 1;
            frog_x <= 320 / 2 - 32 / 2; // spawn frog in middle horizontally
            frog_y <= 240 - 15 + 5; // spawn frog a few pixels from the bottom edge
        end

    end

    // ### Plotters. ###

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(320),
        .MAX_Y(240)
    ) plt_scrn (
        .clk(clk), .en(draw_screen && !done_plotting),
        .x(x_screen), .y(y_screen),
        .done(finish_screen_plotting)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(7),
        .MAX_Y(10)
    ) plt_char (
        .clk(clk), .en((draw_score || draw_lives) && !done_plotting),
        .x(x_character), .y(y_character),
        .done(finish_character_plotting)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(50),
        .MAX_Y(27)
    ) plt_river_obj (
        .clk(clk), .en(draw_log && !done_plotting),
        .x(x_log), .y(y_log),
        .done(finish_river_plotting)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(50),
        .MAX_Y(27)
    ) plt_road_obj (
        .clk(clk), .en(draw_car && !done_plotting),
        .x(x_car), 
		  .y(y_car),
        .done(finish_road_plotting)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(16),
        .MAX_Y(12)
    ) plt_road_obj (
        .clk(clk), .en(draw_frog && !done_plotting),
        .x(x_frog), 
	.y(y_frog),
        .done(finish_road_plotting)
    );


    // ### Start screen. ###

    wire [2:0] scrn_start_color;

    sprite_ram_module #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .RESOLUTION_X(320),
        .RESOLUTION_Y(240),
        .MIF_FILE("graphics/game_start.mif")
    ) srm_scrn_start (
        .clk(clk),
        .x(x_screen), .y(y_screen),
        .color_out(scrn_start_color)
    );

    // ### Game over screen. ###

    wire [2:0] scrn_game_over_color;

    sprite_ram_module #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .RESOLUTION_X(320),
        .RESOLUTION_Y(240),
        .MIF_FILE("graphics/game_over.mif")
    ) srm_scrn_game_over (
        .clk(clk),
        .x(x_screen), .y(y_screen),
        .color_out(scrn_game_over_color)
    );

    // ### Game background screen. ###

    wire [2:0] scrn_game_bg_color;

    sprite_ram_module #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .RESOLUTION_X(320),
        .RESOLUTION_Y(240),
        .MIF_FILE("graphics/game_background.mif")
    ) srm_scrn_game_bg (
        .clk(clk),
        .x(frog_erase ? frog_x + x_frog : x_screen), .y(frog_erase ? frog_y + y_frog : y_screen),
        .color_out(scrn_game_bg_color)
    );

    // ### Frog. ###

    wire [2:0] frog_color;

    sprite_ram_module #(
        .WIDTH_X(6),
        .WIDTH_Y(5),
        .RESOLUTION_X(16),
        .RESOLUTION_Y(12),
        .MIF_FILE("graphics/frog.mif")
    ) srm_frog (
        .clk(clk),
        .x(x_frog), .y(y_frog),
        .color_out(frog_color)
    );

    // ### River objects. ###

    wire [2:0] river_obj_1_color, river_obj_2_color;

    sprite_ram_module #(
        .WIDTH_X(6),
        .WIDTH_Y(5),
        .RESOLUTION_X(50),
        .RESOLUTION_Y(27),
        .MIF_FILE("graphics/log.mif")
    ) srm_river_obj_1 (
        .clk(clk),
        .x(x_log), .y(y_log),
        .color_out(river_obj_1_color)
    );

    sprite_ram_module #(
        .WIDTH_X(6),
        .WIDTH_Y(5),
        .RESOLUTION_X(50),
        .RESOLUTION_Y(37),
        .MIF_FILE("graphics/car.mif")
    ) srm_river_obj_2 (
        .clk(clk),
        .x(x_car), .y(y_car),
        .color_out(river_obj_2_color)
    );

    // ### Score, level and life counters. ###

    wire [2:0] score_color, lives_color, level_color;

    numchar_ram_module score_m (
        .clk(clk),
        .numchar(score),
        .x(x_character), .y(y_character),
        .color_out(score_color)
    );

    numchar_ram_module lives_m (
        .clk(clk),
        .numchar(lives),
        .x(x_character), .y(y_character),
        .color_out(lives_color)
    );

    // ### Color mux. ###
    assign frog_done = draw_frog && frog_color == 0;

    always @ (*) begin
        // Color is set based on which draw signal is high.
        if (draw_start)
            color = scrn_start_color;
        else if (draw_game_over)
            color = scrn_game_over_color;
        else if (draw_game_bg)
            color = scrn_game_bg_color;
        else if (draw_log_1_1)
            color = river_obj_1_color;
        else if (draw_log_2_1)
            color = river_obj_2_color;
        else if (draw_score)
            color = score_color;
        else if (draw_lives)
            color = lives_color;
        else if (frog_erase)
            color = scrn_game_bg_color;
        else if (draw_frog)
            color = frog_color;
	else if (draw_slot_1)
	    color = frog_color;
	else if (draw_slot_2)
	    color = frog_color;
	else if (draw_slot_3)
	    color = frog_color;
	else if (draw_slot_4)
	    color = frog_color;
	else if (draw_slot_5)
	    color = frog_color;
        else
            color = 7;
    end

endmodule

/**
================================================================================
==Datapath=End==================================================================
================================================================================
**/

/**
================================================================================
==Control=======================================================================
================================================================================
**/
module control (
    clk, reset,

    go, done_plotting, space,
    win, die, lose,

    dne_signal_1, dne_signal_2,

    frame_tick,

    draw_start, draw_game_over, draw_game_bg, draw_frog,
    draw_log_1_1, draw_log_2_1, draw_log_3_1,
    draw_car_1_1, draw_car_2_1, draw_car_3_1,
    draw_score, draw_lives,
    moving_objects,
    frog_erase,

    ld_frog_loc,

    reset_game,

    draw_log_1_2, draw_log_1_3, draw_log_2_2, draw_log_2_3, draw_log_3_2, draw_log_3_3,
    draw_car_1_2, draw_car_1_3, draw_car_2_2, draw_car_2_3, draw_car_3_2, draw_car_3_3,

    draw_slot_1, draw_slot_2, draw_slot_3, draw_slot_4, draw_slot_5,

    current_state
);

    input clk, reset;
    input go, done_plotting, space;
    input win, die, lose; 
    input dne_signal_1, dne_signal_2;

    input frame_tick;

    output reg draw_start, draw_game_over, draw_game_bg, draw_frog;

    output reg draw_log_1_1, draw_log_2_1, draw_log_3_1;
    output reg draw_car_1_1, draw_car_2_1, draw_car_3_1;

    output reg draw_score, draw_lives;
    output reg moving_objects;
    output reg frog_erase;
    output reg ld_frog_loc;
    output reg reset_game;

    output reg draw_log_1_2, draw_log_1_3, draw_log_2_2, draw_log_2_3, draw_log_3_2, draw_log_3_3;
    output reg draw_car_1_2, draw_car_1_3, draw_car_2_2, draw_car_2_3, draw_car_3_2, draw_car_3_3;
    output reg draw_slot_1, draw_slot_2, draw_slot_3, draw_slot_4, draw_slot_5;


    output reg [5:0] current_state;

    reg [5:0] next_state;

    // States.
    localparam  S_WAIT_START            = 0,    // Wait before drawing START screen.
                S_draw_start       	= 1,    // Draw START screen.
                S_WAIT_GAME_OVER        = 2,    // Wait before drawing GAME OVER screen.
                S_draw_game_over   	= 3,    // Draw GAME OVER screen.
		S_DRAW_GAME_OVER_LEVEL  = 4,
                S_DRAW_GAME_OVER_SCORE  = 5,
                S_RESET_GAME            = 6,
                S_WAIT_GAME_BG          = 7,    // Wait before drawing game background.
                S_DRAW_GAME_BG          = 8,    // Draw game background.
                S_DRAW_SCORE            = 9,    // Draw score counter.
                S_DRAW_LIVES            = 10,    // Draw lives counter.
		S_DRAW_SLOT_1		= 11,
		S_DRAW_SLOT_2		= 12,
		S_DRAW_SLOT_3		= 13,
		S_DRAW_SLOT_4		= 14,
		S_DRAW_SLOT_5		= 15,
                S_WAIT_RIVER_OBJ        = 16,    // Wait before drawing river objects.
                S_draw_log_1_1     	= 17,    // Draw river object 1.
		S_draw_log_2_1      	= 18,   // Draw river object 2.
                S_draw_log_3_1      	= 19,   // Draw river object 3.A
                S_draw_log_1_2      	= 20,   // Potential river object 2 (1).
                S_draw_log_1_3     	= 21,   // Potential river object 3 (1).
                S_draw_log_2_2      	= 22,   // Potential river object 2 (2).
                S_draw_log_2_3      	= 23,   // Potential river object 3 (2).
                S_draw_log_3_2      	= 24,   // Potential river object 2 (3).
                S_draw_log_3_3      	= 25,   // Potential river object 3 (3).
		S_draw_car_1_1     	= 26,    // Draw river object 1.
		S_draw_car_2_1      	= 27,   // Draw river object 2.
		S_draw_car_3_1      	= 28,   // Draw river object 3.
                S_draw_car_1_2      	= 29,   // Potential river object 2 (1).
                S_draw_car_1_3     	= 30,   // Potential river object 3 (1).  
                S_draw_car_2_2      	= 31,   // Potential river object 2 (2).
                S_draw_car_2_3      	= 32,   // Potential river object 3 (2).
                S_draw_car_3_2      	= 33,   // Potential river object 2 (3).
                S_draw_car_3_3      	= 34,   // Potential river object 3 (3).
                //S_WAIT_FROG             = 32,   // Wait before drawing frog.
                S_DRAW_FROG             = 35,   // Draw frog.
                S_moving_objects        = 36,   // Move objects for the next cycle. (One cycle is from state 4 to 15)
                S_WAIT_FRAME_TICK       = 37;   // Wait for frame tick.


                // S_WAIT_FROG_MOVEMENT    = 13,   // Wait before preceding to movement state.
                // S_FROG_MOVEMENT         = 14;   // Movement state of frog (When key is pressed).
                // S_DRAW_FROG             = 12,   // Draw frog.
                // S_LOAD_FROG_LOC         = 13,   // Wait to erase the frog.
                // S_frog_erase            = 14;   // Erase frog.

    // State table.
    always @(*) begin
        case (current_state)
            S_WAIT_START:
                next_state = S_draw_start;//go ? S_draw_start : S_WAIT_START;
            S_draw_start: 
                next_state = space ? S_DRAW_GAME_BG : S_draw_start;
            S_WAIT_GAME_OVER:
                next_state = go ? S_draw_game_over : S_WAIT_GAME_OVER;
            S_draw_game_over:
                next_state = S_DRAW_GAME_OVER_SCORE;
            S_DRAW_GAME_OVER_SCORE:
                next_state = S_RESET_GAME;
            S_RESET_GAME:
                next_state = space ? S_DRAW_GAME_BG : S_RESET_GAME;
            S_WAIT_GAME_BG: // testing
                next_state = go ? S_DRAW_GAME_BG : S_WAIT_GAME_BG;
            S_DRAW_GAME_BG:
                next_state = done_plotting ? S_DRAW_SCORE : S_DRAW_GAME_BG;
            S_DRAW_SCORE:
                next_state = done_plotting ? S_DRAW_LIVES : S_DRAW_SCORE;
            S_DRAW_LIVES:
                next_state = done_plotting ? S_DRAW_SLOT_1 : S_DRAW_LIVES;
            S_DRAW_SLOT_1:
		next_state = done_plotting ? S_DRAW_SLOT_2 : S_DRAW_SLOT_1;
	    S_DRAW_SLOT_2:
		next_state = done_plotting ? S_DRAW_SLOT_3 : S_DRAW_SLOT_2;
	    S_DRAW_SLOT_3:
		next_state = done_plotting ? S_DRAW_SLOT_4 : S_DRAW_SLOT_3;
	    S_DRAW_SLOT_4:
		next_state = done_plotting ? S_DRAW_SLOT_5 : S_DRAW_SLOT_4;
	    S_DRAW_SLOT_5:
		next_state = done_plotting ? S_draw_log_1_1: S_DRAW_SLOT_5;
                //next_state = done_plotting ? S_draw_log_1_1: S_DRAW_LIVES;
            S_WAIT_RIVER_OBJ:
                next_state = go ? S_draw_log_1_1: S_WAIT_RIVER_OBJ;
            S_draw_log_1_1:
                next_state = done_plotting ? S_draw_log_2_1 : S_draw_log_1_1;
            S_draw_log_2_1:
                next_state = done_plotting ? S_draw_log_3_1 : S_draw_log_2_1;
            S_draw_log_3_1:
                next_state = done_plotting ? S_draw_log_1_2 : S_draw_log_3_1;
            // potential river objects
            S_draw_log_1_2:
                if(dne_signal_1 || done_plotting) begin
                  next_state = S_draw_log_1_3;
                end else begin
                  next_state = S_draw_log_1_2;
                end
                // next_state = done_plotting ? S_draw_log_1_3: S_draw_log_1_2;
            // potential river objects
            S_draw_log_1_3:
              if(dne_signal_2 || done_plotting) begin
                next_state = S_draw_log_2_2;
              end else begin
                next_state = S_draw_log_1_3;
              end
                // next_state = done_plotting ? S_draw_log_2_2 : S_draw_log_1_3;
            S_draw_log_2_2:
              if(dne_signal_1 || done_plotting) begin
                next_state = S_draw_log_2_3;
              end else begin
                next_state = S_draw_log_2_2;
              end
                // next_state = done_plotting ? S_draw_log_2_3 : S_draw_log_2_2;
            S_draw_log_2_3:
              if(dne_signal_2 || done_plotting) begin
                next_state = S_draw_log_3_2;
              end else begin
                next_state = S_draw_log_2_3;
              end
                // next_state = done_plotting ? S_draw_log_3_2 : S_draw_log_2_3;
            S_draw_log_3_2:
              if(dne_signal_1 || done_plotting) begin
                next_state = S_draw_log_3_3;
              end else begin
                next_state = S_draw_log_3_2;
              end
                // next_state = done_plotting ? S_draw_log_3_3 : S_draw_log_3_2;
            S_draw_log_3_3:
              if(dne_signal_2 || done_plotting) begin
                next_state = S_draw_car_1_1;
              end else begin
                next_state = S_draw_log_3_3;
              end
				S_draw_car_1_1:
                next_state = done_plotting ? S_draw_car_2_1 : S_draw_car_1_1;
            S_draw_car_2_1:
                next_state = done_plotting ? S_draw_car_3_1 : S_draw_car_2_1;
            S_draw_car_3_1:
                next_state = done_plotting ? S_draw_car_1_2 : S_draw_car_3_1;
            // potential river objects
            S_draw_car_1_2:
                if(dne_signal_1 || done_plotting) begin
                  next_state = S_draw_car_1_3;
                end else begin
                  next_state = S_draw_car_1_2;
                end
                // next_state = done_plotting ? S_draw_car_1_3: S_draw_car_1_2;
            // potential river objects
            S_draw_car_1_3:
              if(dne_signal_2 || done_plotting) begin
                next_state = S_draw_car_2_2;
              end else begin
                next_state = S_draw_car_1_3;
              end
                // next_state = done_plotting ? S_draw_car_2_2 : S_draw_car_1_3;
            S_draw_car_2_2:
              if(dne_signal_1 || done_plotting) begin
                next_state = S_draw_car_2_3;
              end else begin
                next_state = S_draw_car_2_2;
              end
                // next_state = done_plotting ? S_draw_car_2_3 : S_draw_car_2_2;
            S_draw_car_2_3:
              if(dne_signal_2 || done_plotting) begin
                next_state = S_draw_car_3_2;
              end else begin
                next_state = S_draw_car_2_3;
              end
                // next_state = done_plotting ? S_draw_car_3_2 : S_draw_car_2_3;
            S_draw_car_3_2:
              if(dne_signal_1 || done_plotting) begin
                next_state = S_draw_car_3_3;
              end else begin
                next_state = S_draw_car_3_2;
              end
                // next_state = done_plotting ? S_draw_car_3_3 : S_draw_car_3_2;
            S_draw_car_3_3:
              if(dne_signal_2 || done_plotting) begin
                next_state = S_DRAW_FROG;
              end else begin
                next_state = S_draw_car_3_3;
              end
                // next_state = done_plotting ? S_DRAW_FROG : S_draw_car_3_3;
	    
            // New changes (need to be tested)
            // S_WAIT_FROG:
            //     next_state = go ? S_DRAW_FROG : S_WAIT_FROG;

            S_DRAW_FROG:
                next_state = done_plotting ? S_moving_objects : S_DRAW_FROG;
            S_moving_objects:
                next_state = S_WAIT_FRAME_TICK;
            S_WAIT_FRAME_TICK:
                next_state = frame_tick ? (lose ? S_draw_game_over : S_DRAW_GAME_BG) : S_DRAW_GAME_BG; // was S_WAIT_FRAME_TICK
            // if(done_plotting && mov_key_pressed)
            //   next_state = S_DRAW_GAME_BG;
            // else
            //   next_state = S_DRAW_FROG;

            // S_WAIT_FROG_MOVEMENT:
            //     next_state = go ? S_FROG_MOVEMENT : S_WAIT_FROG_MOVEMENT;
            // S_FROG_MOVEMENT:
            //     next_state = mov_key_pressed ? S_DRAW_GAME_BG : S_FROG_MOVEMENT;

            // S_WAIT_FROG:
            //     next_state = go ? S_frog_erase : S_WAIT_FROG;
            // S_frog_erase:
            //     next_state = done_plotting ? S_LOAD_FROG_LOC: S_frog_erase;
            //    S_LOAD_FROG_LOC:
            //          next_state = S_DRAW_FROG;
            // S_DRAW_FROG:
            //     next_state = frame_tick ? S_frog_erase: S_DRAW_FROG;
        endcase
    end

    // State switching and reset.
    always @ (posedge clk) begin
        if (reset)
            current_state <= S_WAIT_START;
        else
            current_state <= next_state;
    end

    // Output logic.
    always @ (*) begin
        // Reset control signals.
        draw_start = 0;
        draw_game_over = 0;
        draw_game_bg = 0;
	draw_frog = 0;
        draw_score = 0;
        draw_lives = 0;
  
        draw_log_1_1= 0;
        draw_log_2_1 = 0;
        draw_log_3_1 = 0;
	draw_car_1_1 = 0;
	draw_car_2_1 = 0; 
	draw_car_3_1 = 0;
        
        moving_objects = 0;
        frog_erase = 0;
        ld_frog_loc = 0;
        reset_game = 0;

        draw_log_1_2 = 0;
        draw_log_1_3 = 0;
        draw_log_2_2 = 0;
        draw_log_2_3 = 0;
        draw_log_3_2 = 0;
        draw_log_3_3 = 0;
	
	draw_car_1_2 = 0;
        draw_car_1_3 = 0;
        draw_car_2_2 = 0;
        draw_car_2_3 = 0;
        draw_car_3_2 = 0;
        draw_car_3_3 = 0;
	
	draw_slot_1 = 0; 
	draw_slot_2 = 0; 
        draw_slot_3 = 0;
	draw_slot_4 = 0; 
	draw_slot_5 = 0;

        // Set control signals based on state.
        case (current_state)
            S_draw_start: begin
                draw_start = 1;
            end
            S_draw_game_over: begin
                draw_game_over = 1;
            end
	    S_DRAW_GAME_OVER_SCORE: begin
                draw_score = 1;
            end
            S_RESET_GAME: begin
                reset_game = 1;
            end
            S_DRAW_GAME_BG: begin
                draw_game_bg = 1;
            end
            S_DRAW_SCORE: begin
                draw_score = 1;
            end
            S_DRAW_LIVES: begin
                draw_lives = 1;
            end
            S_DRAW_SLOT_1: begin
                draw_slot_1= 1;
            end
            S_DRAW_SLOT_2: begin
                draw_slot_2 = 1;
            end
            S_DRAW_SLOT_3: begin
                draw_slot_3 = 1;
            end
	    S_DRAW_SLOT_4: begin
                draw_slot_4 = 1;
            end
            S_DRAW_SLOT_5: begin
                draw_slot_5 = 1;
            end
            S_draw_log_1_1: begin
                draw_log_1_1= 1;
            end
            S_draw_log_2_1: begin
                draw_log_2_1 = 1;
            end
            S_draw_log_3_1: begin
                draw_log_3_1 = 1;
            end
	    S_draw_car_1_1: begin
                draw_car_1_1= 1;
            end
            S_draw_car_2_1: begin
                draw_car_2_1 = 1;
            end
            S_draw_car_3_1: begin
                draw_car_3_1 = 1;
            end
            S_DRAW_FROG: begin
                draw_frog = 1;
            end
            S_moving_objects: begin
                moving_objects = 1;
            end
            S_draw_log_1_2: begin
                draw_log_1_2 = 1;
            end
            S_draw_log_1_3: begin
                draw_log_1_3= 1;
            end
            S_draw_log_2_2: begin
                draw_log_2_2 = 1;
            end
            S_draw_log_2_3: begin
                draw_log_2_3 = 1;
            end
            S_draw_log_3_2: begin
                draw_log_3_2 = 1;
            end
            S_draw_log_3_3: begin
                draw_log_3_3 = 1;
			   end
            S_draw_car_1_2: begin
                draw_car_1_2 = 1;
            end
            S_draw_car_1_3: begin
                draw_car_1_3= 1;
            end
            S_draw_car_2_2: begin
                draw_car_2_2 = 1;
            end
            S_draw_car_2_3: begin
                draw_car_2_3 = 1;
            end
            S_draw_car_3_2: begin
                draw_car_3_2 = 1;
            end
            S_draw_car_3_3: begin
                draw_car_3_3 = 1;
            end
           

        endcase
    end

endmodule

/**
================================================================================
==Control=End===================================================================
================================================================================
**/

/**
================================================================================
==Hex=Display===================================================================
================================================================================
**/
module hex_dec(in, out);
    input [3:0] in;
    output reg [6:0] out;

    always @(*)
        case (in)
            4'h0: out = 7'b100_0000;
            4'h1: out = 7'b111_1001;
            4'h2: out = 7'b010_0100;
            4'h3: out = 7'b011_0000;
            4'h4: out = 7'b001_1001;
            4'h5: out = 7'b001_0010;
            4'h6: out = 7'b000_0010;
            4'h7: out = 7'b111_1000;
            4'h8: out = 7'b000_0000;
            4'h9: out = 7'b001_1000;
            4'hA: out = 7'b000_1000;
            4'hB: out = 7'b000_0011;
            4'hC: out = 7'b100_0110;
            4'hD: out = 7'b010_0001;
            4'hE: out = 7'b000_0110;
            4'hF: out = 7'b000_1110;
            default: out = 7'h7f;
        endcase
endmodule
/**
================================================================================
==Hex=Display=End===============================================================
================================================================================
**/
