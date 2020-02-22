`include "vga.v"
`include "vga_adapter/vga_pll.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_adapter.v"
`include "ps2keyboard/PS2_Keyboard_Controller.v"
`include "counter.v"
`include "lfsr.v"

/**
TopModule
**/
module frogger (
    CLOCK_50,
    KEY, SW,
    PS2_CLK, PS2_DAT,
    LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B
);


    input CLOCK_50;

    input [9:0] SW;
    input [3:0] KEY;

    // For keyboard input and output.
    inout PS2_CLK;
    inout PS2_DAT;

    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // VGA DAC signals.
    output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    output [9:0] VGA_R, VGA_G, VGA_B;

    wire clk = CLOCK_50;
    wire go_key = !KEY[0];
    wire reset = !KEY[3];
    wire reset_rnd = !KEY[1];
    wire enable = !KEY[2];

	 wire current_state;
	 
    reg go;
	 wire reset_game;
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

    wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    wire [9:0] VGA_R, VGA_G, VGA_B;

    wire finish_screen_plotting, finish_score_plotting, finish_lives_plotting, finish_log_plotting, finish_frog_plotting, finish_car_plotting;

    // Keyboard wires.
    wire w, a, s, d;
    wire up, left, down, right;
    wire space, enter;
    wire clock_keyboard;

    assign LEDR[9] = win;
    assign LEDR[8] = die;

    assign LEDR[3] = up;
    assign LEDR[2] = left;
    assign LEDR[1] = down;
    assign LEDR[0] = right;

    //Datapath

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

        .ld_frog_loc(ld_frog_loc),
        .reset_game(reset_game),

        .frame_tick(frame_tick),

        .left(left), .right(right), .up(up), .down(down),

        .plot(plot), .x(current_x), .y(current_y), .color(current_color),
        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2),
        .win(win), .die(die), .lose(lose),
	.finish_screen_plotting(finish_screen_plotting), .finish_score_plotting(finish_score_plotting), .finish_lives_plotting(finish_lives_plotting), 
	.finish_log_plotting(finish_log_plotting), .finish_frog_plotting(finish_frog_plotting), .finish_car_plotting(finish_car_plotting)
    );


    control c0 (
        .clk(clk), .reset(reset),
        .go(go), .space(space),
        .win(win), .die(die), .lose(lose),

		  .finish_screen_plotting(finish_screen_plotting), .finish_score_plotting(finish_score_plotting), .finish_lives_plotting (finish_lives_plotting), 
		  .finish_log_plotting(finish_log_plotting), .finish_frog_plotting(finish_frog_plotting), .finish_car_plotting(finish_car_plotting),

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

		  .draw_car_1_2(draw_car_1_2), .draw_car_1_3(draw_car_1_3), .draw_car_2_2(draw_car_2_2),
        .draw_car_2_3(draw_car_2_3), .draw_car_3_2(draw_car_3_2), .draw_car_3_3(draw_car_3_3),
		  .draw_slot_1(draw_slot_1), .draw_slot_2(draw_slot_2), .draw_slot_3(draw_slot_3), 
        .draw_slot_4(draw_slot_4), .draw_slot_5(draw_slot_5),

        .current_state(current_state)
    );

    //VGA adapter

    vga_adapter #(
        .RESOLUTION("320x240"),
		.BITS_PER_COLOUR_CHANNEL(1),
        .MONOCHROME("FALSE"),
        .BACKGROUND_IMAGE("mif_files/black.mif")
    ) vga (
        .clock(clk), .resetn(!reset),

        .x(current_x), .y(current_y), .colour(current_color),
        .plot(plot),

        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B)
    );


    //Keyboard 
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

endmodule 



/**
Datapath
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
    finish_screen_plotting, finish_score_plotting, finish_lives_plotting, finish_log_plotting, finish_frog_plotting, finish_car_plotting,
    plot, x, y, color,
    dne_signal_1, dne_signal_2,
    win, die, lose
);

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


    output reg [2:0] color;
    output plot;
    output reg [9:0] x;
    output reg [8:0] y;

    output reg dne_signal_1, dne_signal_2;

    output finish_screen_plotting, finish_score_plotting, finish_lives_plotting, finish_log_plotting, finish_frog_plotting, finish_car_plotting;

    wire [8:0] x_screen, x_character, x_lives, x_log, x_car, x_frog;
    wire [8:0] y_screen, y_character, y_lives, y_log, y_car, y_frog;

    output win, die, lose;

    reg [6:0] rate;
    reg [6:0] score, lives;

    assign lose = (lives == 0);

    reg do_plot;

    wire frog_done;

    assign plot = do_plot; 

    //Top left coordinates of frog
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
    // major draw signals
    wire draw, draw_character, draw_log, draw_car, draw_screen; 

    assign draw = draw_screen || draw_character || draw_log || draw_car || draw_frog || draw_slot_1 || draw_slot_2 || draw_slot_3 || draw_slot_4 || draw_slot_5;
	 
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

    wire on_river;
    wire on_road;
    reg frog_in_1, frog_in_2, frog_in_3, frog_in_4, frog_in_5;

    //on river or road
    assign on_river = (frog_y > 54) && (frog_y < 139);  //108, 279
    assign on_road = (frog_y > 138) && (frog_y < 225); //279, 450
    assign win = frog_in_1 && frog_in_2 && frog_in_3 && frog_in_4 && frog_in_5;

    //Check on which row the frog is
    wire on_log, on_river_row_1, on_river_row_2, on_river_row_3;
    assign on_river_row_1 = (frog_y > 54) && (frog_y < 83); //108, 165
    assign on_river_row_2 = (frog_y > 82) && (frog_y < 111); //165, 222
    assign on_river_row_3 = (frog_y > 110) && (frog_y < 139); //222, 279 
    
    wire not_on_car, on_road_row_1, on_road_row_2, on_road_row_3;
    assign on_road_row_1 = (frog_y > 138) && (frog_y < 168); //279, 336
    assign on_road_row_2 = (frog_y > 167) && (frog_y < 196); //336, 393
    assign on_road_row_3 = (frog_y > 195) && (frog_y < 225); //393, 450

    reg river_1_2_exists, river_1_3_exists;
    reg river_2_2_exists, river_2_3_exists;
    reg river_3_2_exists, river_3_3_exists;
    reg road_1_2_exists, road_1_3_exists;
    reg road_2_2_exists, road_2_3_exists;
    reg road_3_2_exists, road_3_3_exists;

    // Check on which log
    wire on_log_row_1, on_log_row_2, on_log_row_3;
	 
    assign on_log_row_1 = on_river_row_1 && (
        (frog_x + 8 > log_1_1_x[9:0] && frog_x + 8 < log_1_1_x[9:0] + 50) ||
        (river_1_2_exists && frog_x + 8 > log_1_2_x[9:0] && frog_x + 8 < log_1_2_x[9:0] + 50) ||
        (river_1_3_exists && frog_x + 8 > log_1_3_x[9:0] && frog_x + 8 < log_1_3_x[9:0] + 50));
    assign on_log_row_2 = on_river_row_2 && (
        (frog_x + 8 > log_2_1_x[9:0] && frog_x + 8 < log_2_1_x[9:0] + 50) ||
        (river_2_2_exists && frog_x + 8 > log_2_2_x[9:0] && frog_x + 8 < log_2_2_x[9:0] + 50) ||
        (river_2_3_exists && frog_x + 8 > log_2_3_x[9:0] && frog_x + 8 < log_2_3_x[9:0] + 50));
    assign on_log_row_3 = on_river_row_3 && (
        (frog_x + 8 > log_3_1_x[9:0] && frog_x + 8 < log_3_1_x[9:0] + 50) ||
        (river_3_2_exists && frog_x + 8 > log_3_2_x[9:0] && frog_x + 8 < log_3_2_x[9:0] + 50) ||
        (river_3_3_exists && frog_x + 8 > log_3_3_x[9:0] && frog_x + 8 < log_3_3_x[9:0] + 50));
    assign on_log = on_log_row_1 || on_log_row_2 || on_log_row_3;

    wire on_car_row_1, on_car_row_2, on_car_row_3;
	 
    assign on_car_row_1 = on_road_row_1 && (
        (frog_x > car_1_1_x[9:0] - 16 && frog_x < car_1_1_x[9:0] + 50) ||
        (road_1_2_exists && frog_x > car_1_2_x[9:0] - 16 && frog_x < car_1_2_x[9:0] + 50) ||
        (road_1_3_exists && frog_x > car_1_3_x[9:0] - 16 && frog_x < car_1_3_x[9:0] + 50));
		  
    assign on_car_row_2 = on_road_row_2 && (
        (frog_x > car_2_1_x[9:0] - 16 && (frog_x) < (car_2_1_x[9:0] + 50)) ||
        (road_2_2_exists && frog_x > car_2_2_x[9:0] - 16 && frog_x < car_2_2_x[9:0] + 50) ||
        (road_2_3_exists && frog_x > car_2_3_x[9:0] - 16 && frog_x < car_2_3_x[9:0] + 50));
		  
    assign on_car_row_3 = on_road_row_3 && (
        (frog_x > car_3_1_x[9:0] - 16 && frog_x < car_3_1_x[9:0] + 50) ||
        (road_3_2_exists && frog_x > car_3_2_x[9:0] - 16 && frog_x < car_3_2_x[9:0] + 50) ||
        (road_3_3_exists && frog_x > car_3_3_x[9:0] - 16 && frog_x < car_3_3_x[9:0] + 50));
    assign not_on_car = !on_car_row_1 || !on_car_row_2 || !on_car_row_3;

    // condition to die.
    assign die = (on_river && !on_log) || (on_road && !not_on_car);


    //Counter to delay the keyboard
    wire [20:0] frame_counter;
    output frame_tick;
    assign frame_tick = frame_counter == 834168; //834168
    counter counter0 (
        .clk(clk),
        .en(1),
        .rst(reset_game || reset),
        .out(frame_counter)
    );

    // LFSR (Linear feedback shift register) to randomly spawn cars and logs.
    wire [19:0] rnd_generator;
    wire [19:0] random_20 = rnd_generator;
    LFSR #(20)
      lfsr0 (
        .i_Clk(clk),
        .i_Enable(1),
        .o_LFSR_Data(rnd_generator),
		  .o_LFSR_Done(lfsr_done)
      );

    wire [2:0] frog_x_r, frog_x_l, frog_y_d, frog_y_u;
	 
    assign frog_x_r = right + rate * on_log_row_1 + rate * on_log_row_3;
    assign frog_x_l = left + rate * on_log_row_2;
    assign frog_y_d = down;
    assign frog_y_u = up;

    wire [3:0]ram_1_2;
    assign ram_1_2 = {random_20[4], random_20[3], random_20[2], random_20[1]};
    

    always @ (posedge clk) begin
        // The x and y offsets specify the top left corner of the sprite
			do_plot <= draw;

        // starting coordinates of the frog and river objects
			if (reset || reset_game) begin
            frog_x <= 320 / 2 - 16 / 2; // spawn frog 
            frog_y <= 240 - 15 + 1; 

            // reset the data
            rate <= 1;
            lives <= 5;
            score <= 0;

			//First object on river row 1
            log_1_1_x <= 0;
            log_1_1_y <= 55;
				river_1_2_exists <= 1;

				log_1_2_x <= 8'd50 + 8'd40 + ram_1_2[3:0];
				log_1_2_y <= 55;
				river_1_3_exists <= 1;

				log_1_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[5:2];
				log_1_3_y <= 55;



				log_2_1_x <= 0;
            log_2_1_y <= 83;
				river_2_2_exists <= 1;

				log_2_2_x <= 8'd50 + 8'd40 + random_20[6:2];
				log_2_2_y <= 83;
				river_2_3_exists <= 1;

				log_2_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[7:4];
            log_2_3_y <= 83; //166
	    


				log_3_1_x <= 0;
            log_3_1_y <= 111;
            river_3_2_exists <= 1;

				log_3_2_x <= 8'd50 + 8'd40 + random_20[8:5];
				log_3_2_y <= 111;
				river_3_3_exists <= 1;

				log_3_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[9:6];
            log_3_3_y <= 111; 
	   


				car_1_1_x <= 0;
            car_1_1_y <= 139;
				road_1_2_exists <= 1;

				car_1_2_x <= 8'd50 + 8'd40 + random_20[10:7];
				car_1_2_y <= 139;
				road_1_3_exists <= 1;

				car_1_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[11:8];
            car_1_3_y <= 139; //280


				car_2_1_x <= 0;
            car_2_1_y <= 168;
				road_2_2_exists <= 1;

				car_2_2_x <= 8'd50 + 8'd40 + random_20[12:9];
				car_2_2_y <= 168;
				road_2_3_exists <= 1;

				car_2_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[13:10];
				car_2_3_y <= 168; //337



				car_3_1_x <= 0;
            car_3_1_y <= 196; //394
				road_3_2_exists <= 1;

				car_3_2_x <= 8'd50 + 8'd40 + random_20[14:11]; //100, 80
				car_3_2_y <= 196; //394
				road_3_3_exists <= 1;

				car_3_3_x <= 8'd50 + 8'd40 + 5'd15 + 8'd40 + random_20[15:12];//100, 80, 31, 80
            car_3_3_y <= 196; //394
          

			end else if (draw_log_1_1) begin
            x <= log_1_1_x[9:0] + x_log;
            y <= log_1_1_y + y_log;
			end else if (draw_log_2_1) begin
            x <= log_2_1_x[9:0] + x_log;
            y <= log_2_1_y + y_log;
			end else if (draw_log_3_1) begin
            x <= log_3_1_x[9:0] + x_log;
            y <= log_3_1_y + y_log;
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
            x <= car_1_1_x[9:0] + x_car;
            y <= car_1_1_y + y_car;
			end else if (draw_car_2_1) begin
            x <= car_2_1_x[9:0] + x_car;
            y <= car_2_1_y + y_car;
			end else if (draw_car_3_1) begin
            x <= car_3_1_x[9:0] + x_car;
            y <= car_3_1_y + y_car;
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
            x <= 290 + x_lives;  //580
            y <= 20 + y_lives;   //41
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
				if (log_1_1_x == 320) begin
					log_1_1_x <= 974;
				end
            // flows left
            log_2_1_x <= log_2_1_x - rate;
				if (log_2_1_x == 973) begin
					log_2_1_x <= 319;
				end
            // flows right
            log_3_1_x <= log_3_1_x + rate;
				if (log_3_1_x == 320) begin
					log_3_1_x <= 974;
				end
				// flows left
            car_1_1_x <= car_1_1_x - rate;
				if (car_1_1_x == 973) begin
					car_1_1_x <= 319;
				end
            // flows right
            car_2_1_x <= car_2_1_x + rate;
				if (log_2_1_x == 320) begin
					log_2_1_x <= 974;
				end
            // flows left
            car_3_1_x <= car_3_1_x - rate;
				if (car_3_1_x == 973) begin
					car_3_1_x <= 319;
				end
            if(river_1_2_exists) begin
					log_1_2_x <= log_1_2_x + rate;
					if (log_1_2_x == 320) begin
						log_1_2_x <= 974;
					end
            end
            if(river_1_3_exists) begin
					log_1_3_x <= log_1_3_x + rate;
					if (log_1_3_x == 320) begin
						log_1_3_x <= 974;
					end
            end
            if(river_2_2_exists) begin
					log_2_2_x <= log_2_2_x - rate;
					if (log_2_2_x == 973) begin
						log_2_2_x <= 319;
					end
            end
            if(river_2_3_exists) begin
					log_2_3_x <= log_2_3_x - rate;
					if (log_2_3_x == 973) begin
						log_2_3_x <= 319;
					end
            end
            if(river_3_2_exists) begin
					log_3_2_x <= log_3_2_x + rate;
					if (log_3_2_x == 320) begin
						log_3_2_x <= 974;
					end
            end
            if(river_3_3_exists) begin
					log_3_3_x <= log_3_3_x + rate;
					if (log_3_3_x == 320) begin
						log_3_3_x <= 974;
					end
            end
				if(road_1_2_exists) begin
					car_1_2_x <= car_1_2_x - rate;
					if (car_1_2_x == 973) begin
						car_1_2_x <= 319;
					end
            end
            if(road_1_3_exists) begin
					car_1_3_x <= car_1_3_x - rate;
					if (car_1_3_x == 973) begin
						car_1_3_x <= 319;
					end
            end
            if(road_2_2_exists) begin
					car_2_2_x <= car_2_2_x + rate;
					if (car_2_2_x == 320) begin
						car_2_2_x <= 974;
					end
            end
            if(road_2_3_exists) begin
					car_2_3_x <= car_2_3_x + rate;
					if (car_2_3_x == 320) begin
						car_2_3_x <= 974;
					end
            end
            if(road_3_2_exists) begin
					car_3_2_x <= car_3_2_x - rate;
					if (car_3_2_x == 973) begin
						car_3_2_x <= 319;
					end
            end
            if(road_3_3_exists) begin
					car_3_3_x <= car_3_3_x - rate;
					if (car_3_3_x == 973) begin
						car_3_3_x <= 319;
					end
            end

            // check left and right boundaries(of next matching move)
            if ((frog_x + frog_x_r - frog_x_l >= 0) && (frog_x + frog_x_r - frog_x_l <= 320 - 16)) begin
                frog_x <= frog_x + frog_x_r - frog_x_l;
            end

            // check up and down boundaries(of next matching move)
            if ((frog_y + frog_y_d - frog_y_u > 54) && (frog_y + frog_y_d - frog_y_u <= 240 - 12)) begin // 108
                frog_y <= frog_y + frog_y_d - frog_y_u;
            end

			end else if (draw_screen) begin
            x <= x_screen;
            y <= y_screen;

	      // check if frog reaches one of the 5 slots
			end else if (frog_in_1 || frog_in_2 || frog_in_3 || frog_in_4 || frog_in_5) begin
            score <= score + 1;
            rate <= rate + 1;
            frog_x <= 320 / 2 - 16 / 2; // spawn frog
            frog_y <= 240 - 15 + 1; 
			end

			if (frog_x >= 0 && frog_x <= 23 - 8 && frog_y < 56) begin
				frog_in_1 <= 1;
			end else if (frog_x < 98 - 8 && frog_x > 73 && frog_y < 56) begin//165, 148, 108
				frog_in_2 <= 1;
			end else if (frog_x < 171 - 8 && frog_x > 147 && frog_y < 56) begin// 314, 296, 108
				frog_in_3 <= 1;
			end else if (frog_x < 245 - 8 && frog_x > 221 && frog_y < 56) begin// 463, 444, 108
				frog_in_4 <= 1;
			end else if (frog_x < 319 && frog_x > 295 && frog_y < 56) begin//612, 592, 108
				frog_in_5 <= 1;
			end

			if (die) begin
            lives <= lives - 1;
            frog_x <= (320 / 2) - (16 / 2); // spawn frog 
            frog_y <= 240 - 15 + 1; 
			end
	 end


    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(320),
        .MAX_Y(240)
    ) plt_scrn (
        .clk(clk), 
        .en(draw_screen),
        .x(x_screen), 
		  .y(y_screen),
        .done(finish_screen_plotting)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(7),
        .MAX_Y(10)
    ) plt_char (
        .clk(clk), .en((draw_score)),
        .x(x_character), 
	.y(y_character),
        //.reset(reset_plot),
        .done(finish_score_plotting)
    );
  
    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(7),
        .MAX_Y(10)
    ) plt_lives (
        .clk(clk), .en((draw_lives)),
        .x(x_lives), 
	.y(y_lives),
        //.reset(reset_plot),
        .done(finish_lives_plotting)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(50),
        .MAX_Y(27)
    ) plt_river_obj (
        .clk(clk), .en(draw_log),
        .x(x_log), .y(y_log),
        //.reset(reset_plot),
        .done(finish_log_plotting)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(50),
        .MAX_Y(27)
    ) plt_road_obj (
        .clk(clk), .en(draw_car),
        .x(x_car), 
	.y(y_car),
        //.reset(reset_plot),
        .done(finish_car_plotting)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(16),
        .MAX_Y(12)
    ) plt_frog_obj (
        .clk(clk), .en(draw_frog || draw_slot_1 || draw_slot_2 || draw_slot_3 || draw_slot_4 || draw_slot_5),
        .x(x_frog), 
	.y(y_frog),
        //.reset(reset_plot),
        .done(finish_frog_plotting)
    );

    // Start screen

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

    //Game over screen

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

    //Game background screen

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

    //Frog

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

    //River objects

    wire [2:0] log_color, car_color;

    sprite_ram_module #(
        .WIDTH_X(6),
        .WIDTH_Y(5),
        .RESOLUTION_X(50),
        .RESOLUTION_Y(27),
        .MIF_FILE("graphics/log.mif")
    ) srm_log (
        .clk(clk),
        .x(x_log), .y(y_log),
        .color_out(log_color)
    );

    sprite_ram_module #(
        .WIDTH_X(6),
        .WIDTH_Y(5),
        .RESOLUTION_X(50),
        .RESOLUTION_Y(37),
        .MIF_FILE("graphics/car.mif")
    ) srm_car (
        .clk(clk),
        .x(x_car), .y(y_car),
        .color_out(car_color)
    );

    //Score, level and life counters

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
        .x(x_lives), .y(y_lives),
        .color_out(lives_color)
    );

    assign frog_done = draw_frog && frog_color == 0;

    always @ (*) begin
        // Color based on which draw signal is high.
        if (draw_start)
            color = scrn_start_color;
        else if (draw_game_over)
            color = scrn_game_over_color;
        else if (draw_game_bg)
            color = scrn_game_bg_color;
        else if (draw_log)
            color = log_color;
        else if (draw_car)
            color = car_color;
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
Control
**/
module control (
    clk, reset,
    finish_screen_plotting, finish_score_plotting, finish_lives_plotting, finish_log_plotting, finish_frog_plotting, finish_car_plotting,
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
    input finish_screen_plotting, finish_score_plotting, finish_lives_plotting, finish_log_plotting, finish_frog_plotting, finish_car_plotting;
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
                S_draw_start       	    = 1,    // Draw START screen.
                S_WAIT_draw_game_over        = 2,    // Wait before drawing GAME OVER screen.
                S_draw_game_over   	    = 3,    // Draw GAME OVER screen.
					 S_DRAW_GAME_OVER_LEVEL  = 4,
                S_DRAW_GAME_OVER_SCORE  = 5,
                S_RESET_GAME            = 6,
                S_WAIT_DRAW_GAME_BG     = 7,    // Wait before drawing game background.
                S_DRAW_GAME_BG          = 8,    // Draw game background.
                S_DRAW_SCORE            = 9,    // Draw score counter.
                S_DRAW_LIVES            = 10,    // Draw lives counter.
					 S_DRAW_SLOT_1		    = 11,
				    S_DRAW_SLOT_2		    = 12,
					 S_DRAW_SLOT_3		    = 13,
				    S_DRAW_SLOT_4		    = 14,
					 S_DRAW_SLOT_5		    = 15,
                S_WAIT_RIVER_OBJ        = 16,        // Wait before drawing river objects.
                S_draw_log_1_1     	    = 17,    // Draw log
					 S_draw_log_2_1      	= 18,  
                S_draw_log_3_1      	= 19,  
                S_draw_log_1_2      	= 20,   
                S_draw_log_1_3     	    = 21,   
                S_draw_log_2_2      	= 22,   
                S_draw_log_2_3      	= 23,   
                S_draw_log_3_2      	= 24,   
                S_draw_log_3_3      	= 25,   
					 S_draw_car_1_1     	    = 26,    // Draw car
					 S_draw_car_2_1      	= 27,   
					 S_draw_car_3_1      	= 28,   
                S_draw_car_1_2      	= 29,   
                S_draw_car_1_3     	    = 30,    
                S_draw_car_2_2      	= 31,  
                S_draw_car_2_3      	= 32,   
                S_draw_car_3_2      	= 33,   
                S_draw_car_3_3      	= 34,   
                S_DRAW_FROG             = 35,   
                S_moving_objects        = 36,   
                S_WAIT_FRAME_TICK       = 37,   
				    S_WAIT_DRAW_SLOT_1	= 38,
					 S_WAIT_DRAW_SLOT_2	= 39,
					 S_WAIT_DRAW_SLOT_3	= 40,
					 S_WAIT_DRAW_SLOT_4	= 41,
					 S_WAIT_DRAW_SLOT_5	= 42,
					 S_WAIT_draw_log_1_1     	    = 43,    // buffer states
					 S_WAIT_draw_log_2_1      	= 44,   
                S_WAIT_draw_log_3_1      	= 45,   
                S_WAIT_draw_log_1_2      	= 46,   
                S_WAIT_draw_log_1_3     	    = 47,  
                S_WAIT_draw_log_2_2      	= 48,   
                S_WAIT_draw_log_2_3      	= 49,   
                S_WAIT_draw_log_3_2      	= 50,   
                S_WAIT_draw_log_3_3      	= 51,  
					 S_WAIT_draw_car_1_1     	    = 52,   
					 S_WAIT_draw_car_2_1      	= 53,   
					 S_WAIT_draw_car_3_1      	= 54,   
                S_WAIT_draw_car_1_2      	= 55,   
                S_WAIT_draw_car_1_3     	    = 56,   
                S_WAIT_draw_car_2_2      	= 57,   
                S_WAIT_draw_car_2_3      	= 58,   
                S_WAIT_draw_car_3_2      	= 59,   
                S_WAIT_draw_car_3_3      	= 60;  

    // State table.
    always @(*) begin
        case (current_state)
            S_WAIT_START:
                next_state = S_draw_start;
            S_draw_start: 
                next_state = space ? S_WAIT_DRAW_GAME_BG : S_draw_start;
            S_WAIT_draw_game_over:
                next_state = S_draw_game_over;
            S_draw_game_over:
                next_state = S_RESET_GAME;
            S_RESET_GAME:
                next_state = space ? S_DRAW_GAME_BG : S_RESET_GAME;
            S_WAIT_DRAW_GAME_BG: 
                next_state = S_DRAW_GAME_BG;
            S_DRAW_GAME_BG:
                next_state = finish_screen_plotting ? S_DRAW_SCORE : S_DRAW_GAME_BG;
            S_DRAW_SCORE:
                next_state = finish_score_plotting ? S_DRAW_LIVES : S_DRAW_SCORE;
            S_DRAW_LIVES:
                next_state = finish_lives_plotting ? S_WAIT_DRAW_SLOT_1 : S_DRAW_LIVES;
			   S_WAIT_DRAW_SLOT_1: 
					next_state = S_DRAW_SLOT_1;
            S_DRAW_SLOT_1:
					next_state = finish_frog_plotting ? S_WAIT_DRAW_SLOT_2 : S_DRAW_SLOT_1;
				S_WAIT_DRAW_SLOT_2:
					next_state = S_DRAW_SLOT_2;
				S_DRAW_SLOT_2:
					next_state = finish_frog_plotting ? S_WAIT_DRAW_SLOT_3 : S_DRAW_SLOT_2;
				S_WAIT_DRAW_SLOT_3:
					next_state = S_DRAW_SLOT_3;
				S_DRAW_SLOT_3:
					next_state = finish_frog_plotting ? S_WAIT_DRAW_SLOT_4 : S_DRAW_SLOT_3;
				S_WAIT_DRAW_SLOT_4:
					next_state = S_DRAW_SLOT_4;
				S_DRAW_SLOT_4:
					next_state = finish_frog_plotting ? S_WAIT_DRAW_SLOT_5 : S_DRAW_SLOT_4;
				S_WAIT_DRAW_SLOT_5:
					next_state = S_DRAW_SLOT_5;
				S_DRAW_SLOT_5:
					next_state = finish_frog_plotting ? S_WAIT_draw_log_1_1: S_DRAW_SLOT_5;
            S_WAIT_draw_log_1_1:
                next_state = S_draw_log_1_1;
            S_draw_log_1_1:
                next_state = finish_log_plotting ? S_WAIT_draw_log_2_1 : S_draw_log_1_1;
				S_WAIT_draw_log_2_1:
                next_state = S_draw_log_2_1;
            S_draw_log_2_1:
                next_state = finish_log_plotting ? S_WAIT_draw_log_3_1 : S_draw_log_2_1;
				S_WAIT_draw_log_3_1:
                next_state = S_draw_log_3_1;
            S_draw_log_3_1:
                next_state = finish_log_plotting ? S_WAIT_draw_log_1_2 : S_draw_log_3_1;
				S_WAIT_draw_log_1_2:
                next_state = S_draw_log_1_2;
            S_draw_log_1_2:
                if(dne_signal_1 || finish_log_plotting) begin
                  next_state = S_WAIT_draw_log_1_3;
                end else begin
                  next_state = S_draw_log_1_2;
                end
				S_WAIT_draw_log_1_3:
                next_state = S_draw_log_1_3;
            S_draw_log_1_3:
              if(dne_signal_2 || finish_log_plotting) begin
                next_state = S_WAIT_draw_log_2_2;
              end else begin
                next_state = S_draw_log_1_3;
              end
				S_WAIT_draw_log_2_2:
                next_state = S_draw_log_2_2;
            S_draw_log_2_2:
              if(dne_signal_1 || finish_log_plotting) begin
                next_state = S_WAIT_draw_log_2_3;
              end else begin
                next_state = S_draw_log_2_2;
              end
            S_WAIT_draw_log_2_3:
                next_state = S_draw_log_2_3;
            S_draw_log_2_3:
              if(dne_signal_2 || finish_log_plotting) begin
                next_state = S_WAIT_draw_log_3_2;
              end else begin
                next_state = S_draw_log_2_3;
              end
            S_WAIT_draw_log_3_2:
                next_state = S_draw_log_3_2;
            S_draw_log_3_2:
              if(dne_signal_1 || finish_log_plotting) begin
                next_state = S_WAIT_draw_log_3_3;
              end else begin
                next_state = S_draw_log_3_2;
              end
            S_WAIT_draw_log_3_3:
                next_state = S_draw_log_3_3;
            S_draw_log_3_3:
              if(dne_signal_2 || finish_log_plotting) begin
                next_state = S_WAIT_draw_car_1_1;
              end else begin
                next_state = S_draw_log_3_3;
              end
				S_WAIT_draw_car_1_1:
                next_state = S_draw_car_1_1;
				S_draw_car_1_1:
                next_state = finish_car_plotting ? S_WAIT_draw_car_2_1 : S_draw_car_1_1;
				S_WAIT_draw_car_2_1:
                next_state = S_draw_car_2_1;
            S_draw_car_2_1:
                next_state = finish_car_plotting ? S_WAIT_draw_car_3_1 : S_draw_car_2_1;
				S_WAIT_draw_car_3_1:
                next_state = S_draw_car_3_1;
            S_draw_car_3_1:
                next_state = finish_car_plotting ? S_WAIT_draw_car_1_2 : S_draw_car_3_1;
				S_WAIT_draw_car_1_2:
                next_state = S_draw_car_1_2;
            S_draw_car_1_2:
                if(dne_signal_1 || finish_car_plotting) begin
                  next_state = S_WAIT_draw_car_1_3;
                end else begin
                  next_state = S_draw_car_1_2;
                end
            S_WAIT_draw_car_1_3:
                next_state = S_draw_car_1_3;
            S_draw_car_1_3:
              if(dne_signal_2 || finish_car_plotting) begin
                next_state = S_WAIT_draw_car_2_2;
              end else begin
                next_state = S_draw_car_1_3;
              end
            S_WAIT_draw_car_2_2:
                next_state = S_draw_car_2_2;
            S_draw_car_2_2:
              if(dne_signal_1 || finish_car_plotting) begin
                next_state = S_WAIT_draw_car_2_3;
              end else begin
                next_state = S_draw_car_2_2;
              end
            S_WAIT_draw_car_2_3:
                next_state = S_draw_car_2_3;
            S_draw_car_2_3:
              if(dne_signal_2 || finish_car_plotting) begin
                next_state = S_WAIT_draw_car_3_2;
              end else begin
                next_state = S_draw_car_2_3;
              end
            S_WAIT_draw_car_3_2:
                next_state = S_draw_car_3_2;
            S_draw_car_3_2:
              if(dne_signal_1 || finish_car_plotting) begin
                next_state = S_WAIT_draw_car_3_3;
              end else begin
                next_state = S_draw_car_3_2;
              end
            S_WAIT_draw_car_3_3:
                next_state = S_draw_car_3_3;
            S_draw_car_3_3:
              if(dne_signal_2 || finish_car_plotting) begin
                next_state = S_DRAW_FROG;
              end else begin
                next_state = S_draw_car_3_3;
              end
            S_DRAW_FROG:
                next_state = finish_frog_plotting ? S_moving_objects : S_DRAW_FROG;
            S_moving_objects:
                next_state = S_WAIT_FRAME_TICK;
            S_WAIT_FRAME_TICK:
                next_state = frame_tick ? (lose ? S_WAIT_draw_game_over : S_DRAW_GAME_BG) :  S_WAIT_FRAME_TICK; 
        endcase
    end

    // state switching
    always @ (posedge clk) begin
        if (reset)
            current_state <= S_WAIT_START;
        else
            current_state <= next_state;
    end

    // Output logic.
    always @ (*) begin
        // Reset signals
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

        // set control signals based on state
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
			   S_WAIT_DRAW_SLOT_1: begin
                draw_lives = 0;
            end
            S_DRAW_SLOT_1: begin
                draw_slot_1 = 1;
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


