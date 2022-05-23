SRC = ./src
TB = ./tb
INCLUDE_FILES = ${TB}/*.sv ${SRC}/top.sv ${SRC}/fetch/*.sv ${SRC}/decode/*.sv ${SRC}/execute/*.sv ${SRC}/mem/*.sv

IVERILOG:
	@echo "Compiling source files..."
	iverilog -Wall -g2012 -o work ${INCLUDE_FILES}

IVERILOG_SYNTH:
	@echo "Compiling source files..."
	iverilog -Wall -g2012 -DSYNTH -o work ${INCLUDE_FILES}

VLOG:
	@echo "Compiling source files..."
	vlog -sv ${INCLUDE_FILES}

VLOG_SYNTH:
	@echo "Compiling source files..."
	vlog -sv +define+SYNTH ${INCLUDE_FILES}

clean:
	@echo "Cleaning files..."
	rm -rf __work work transcript
