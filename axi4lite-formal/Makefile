SHELL := /bin/sh

BUILD_DIR := build
SIM_BIN   := $(BUILD_DIR)/axi4lite_sim
RTL       := rtl/axi4lite_regs.sv
TB        := sim/axi4lite_tb.sv

.PHONY: all regression lint yosys-check sim wave prove cover formal audit clean

all: regression

regression: lint yosys-check sim prove cover

$(BUILD_DIR): ; mkdir -p $(BUILD_DIR)

$(SIM_BIN): $(RTL) $(TB) | $(BUILD_DIR) ; iverilog -g2012 -Wall -s axi4lite_tb -o $(SIM_BIN) $(RTL) $(TB)

lint: ; verilator --lint-only -Wall --Wno-fatal $(RTL)

yosys-check: ; yosys -p "read_verilog -sv $(RTL); hierarchy -top axi4lite_regs; proc; check"

sim: $(SIM_BIN) ; vvp $(SIM_BIN)

wave: sim ; gtkwave $(BUILD_DIR)/axi4lite.vcd &

prove: ; cd formal && sby -f axi4lite.sby prove

cover: ; cd formal && sby -f axi4lite.sby cover

formal: prove cover

audit: ; cd formal && sby -f axi4lite_assumption_audit.sby; status=$$?; if [ $$status -eq 2 ]; then echo "EXPECTED FAIL: master assumptions are necessary"; else echo "Unexpected audit status: $$status"; exit 1; fi

clean: ; rm -rf $(BUILD_DIR) formal/axi4lite formal/axi4lite_prove formal/axi4lite_cover formal/axi4lite_assumption_audit formal/axi4lite_bug_bvalid formal/axi4lite_bug_rdata formal/axi4lite_bug_wstrb