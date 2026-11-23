vlib work
vlog *.sv +cover=sbceft
vsim -voptargs=+acc -coverage FIFO_TOP

add wave -r sim:/top/*

run -all
coverage exclude -src FIFO.sv -scope /FIFO_TOP/fifo_dut -allfalse -line 82 -code b

coverage save FIFO_TOP.ucdb
coverage report -output code_coverage_report.txt -details

coverage report \
-srcfile=FIFO.sv+FIFO_MONITOR.sV+pkg_2.sv+FIFO_INTERFACE.sv \
-details \
-output important_coverage_report.txt
