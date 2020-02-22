# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns FROGGER.v
vsim -L altera_mf_ver -L altera_mf datapath 
log {/*}
add wave {/*}

force {clk} 		0 0ns, 1 1ns -repeat 2ns
force {reset_game} 	0 0ns, 1 100000ns, 0 100011ns
#draw_screen = 1, so color can be assigned

force {draw_slot_5} 	0 0ns, 1 10ns, 0 20ns


#force {draw_start} 	0 0ns, 1 10ns, 0 153610ns
#force {draw_game_over} 	0 0ns
#force {draw_game_bg} 	0 0ns

#draw score then lives, color can be assigned  140
#force {draw_score} 	0 0ns, 1 153610ns, 0 153750ns
#force {draw_lives} 	0 0ns, 1 153750ns, 0 153890ns

#draw_log = 1, 1850 * 2 every log/car, so color can be assigned  3700
force {draw_log_1_1} 	0 0ns, 1 153890ns, 0 157590ns  
force {draw_log_2_1}	0 0ns, 1 157590ns, 0 161290ns
force {draw_log_3_1} 	0 0ns, 1 161290ns, 0 164990ns
force {draw_log_1_2} 	0 0ns, 1 170000ns, 0 173700ns
force {draw_log_2_2} 	0 0ns
force {draw_log_2_3} 	0 0ns
force {draw_log_1_3} 	0 0ns
force {draw_log_3_2} 	0 0ns
force {draw_log_3_3} 	0 0ns

#force {done_plotting} 	0 0ns

run 200000ns




