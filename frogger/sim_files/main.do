# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns FROGGER.v
vsim -L altera_mf_ver -L altera_mf datapath

force {clk} 		0 0ns, 1 1ns -repeat 2ns
force {reset_game} 	0 0ns, 1 2ns, 0 4ns
force {draw_start} 	1 10ns

run 10000000ns



