SHELL := /bin/bash

RTL := rtl/cache_controller.sv
TB  := tb/memory_model.sv tb/cache_tb.sv
SIM := build/cache_sim

.PHONY: help lint sim formal data cover fault-wb fault-wstrb faults regression clean

help:
	@echo "Targets:"
	@echo "  make lint         - Verilator RTL lint"
	@echo "  make sim          - Run directed simulation"
	@echo "  make formal       - Unbounded control/protocol proof"
	@echo "  make data         - Bounded symbolic data-integrity proof"
	@echo "  make cover        - Formal cover proof"
	@echo "  make fault-wb     - Detect wrong-writeback-address bug"
	@echo "  make fault-wstrb  - Detect broken-WSTRB bug"
	@echo "  make faults       - Run both fault injections"
	@echo "  make regression   - Run all correct-design checks"
	@echo "  make clean        - Remove generated artifacts"

lint:
	verilator --lint-only -Wall -Wno-fatal \
		--top-module cache_controller $(RTL)

sim:
	mkdir -p build
	iverilog -g2012 -Wall -s cache_tb \
		-o $(SIM) $(RTL) $(TB)
	vvp $(SIM)

formal:
	cd formal && sby -f cache.sby
	@test -f formal/cache/PASS
	@echo "PASS: unbounded control/protocol proof"

data:
	cd formal && sby -f cache_data.sby
	@test -f formal/cache_data/PASS
	@echo "PASS: bounded symbolic data-integrity proof"

cover:
	cd formal && sby -f cache_cover.sby
	@test -f formal/cache_cover/PASS
	@echo "PASS: formal cover proof"

fault-wb:
	rm -rf formal/cache_bug_wb
	-cd formal && sby -f cache_bug_wb.sby
	@test -f formal/cache_bug_wb/FAIL
	@grep -q "A_EVICT_01_ADDR" formal/cache_bug_wb/FAIL
	@echo "PASS: wrong-writeback-address fault detected"

fault-wstrb:
	rm -rf formal/cache_bug_wstrb
	-cd formal && sby -f cache_bug_wstrb.sby
	@test -f formal/cache_bug_wstrb/FAIL
	@grep -q "F_DATA_02" formal/cache_bug_wstrb/FAIL
	@echo "PASS: broken-WSTRB fault detected"

faults: fault-wb fault-wstrb

regression: lint sim formal data cover
	@echo "PASS: complete correct-design regression"

clean:
	rm -rf build
	rm -rf formal/cache
	rm -rf formal/cache_data
	rm -rf formal/cache_cover
	rm -rf formal/cache_bug_wb
	rm -rf formal/cache_bug_wstrb
