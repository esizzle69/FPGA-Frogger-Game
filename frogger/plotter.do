# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns vga.v
vsim -L altera_mf_ver -L altera_mf plotter
log {/*}
add wave {/*}


force {clk} 		0 0ns, 1 1ns -repeat 2ns
force {en} 		0 0ns, 1 2ns

run 1500000ns




