SRC = ./src
TB = ./tb
INCLUDE_FILES = ${TB}/top_tb.sv ${SRC}/top.sv ${SRC}/fetch/*.sv

all:
	@echo "Compiling source files..."
	iverilog -Wall -g2012 -o transcript ${INCLUDE_FILES}
	#vlog -sv ${INCLUDE_FILES}

clean:
	@echo "Cleaning files..."
	rm -rf work transcript
