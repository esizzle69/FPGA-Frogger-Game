# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns FROGGER.v
vsim -L altera_mf_ver -L altera_mf frogger
log {/*}
add wave {/*}

force {CLOCK_50} 0 0ns, 1 1ns -repeat 2ns
force {reset} 	0 0ns, 1 90ns, 0 92ns
force {space} 0 0ns, 1 153710ns 


#draw_screen = 1, so color can be assigned
#force {draw_start} 	0 0ns, 1 110ns, 0 153710ns
#force {draw_game_over} 	0 0ns
#force {draw_game_bg} 	0 0ns

#draw score then lives, color can be assigned  140
#force {draw_score} 	0 0ns, 1 153710ns, 0 153850ns
#force {draw_lives} 	0 0ns, 1 153840ns, 0 153980ns

#draw_log = 1, 1850 * 2 every log/car, so color can be assigned  3700
#force {draw_log_1_1} 	0 0ns, 1 153990ns, 0 157690ns  
#force {draw_log_1_2} 	0 0ns, 1 157690ns, 0 161390ns
#force {draw_log_1_3} 	0 0ns, 1 161390ns, 0 165090ns
#force {draw_log_2_1} 	0 0ns
#force {draw_log_2_2} 	0 0ns
#force {draw_log_2_3} 	0 0ns
#force {draw_log_3_1} 	0 0ns
#force {draw_log_3_2} 	0 0ns
#force {draw_log_3_3} 	0 0ns

#force {done_plotting} 	0 0ns

run 1500000ns




