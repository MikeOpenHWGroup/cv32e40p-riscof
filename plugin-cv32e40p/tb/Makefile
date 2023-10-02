# Copyright 2023 OpenHW Group
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Makefile to compile and run the CV32E40P in a simple testbench usign Verilator.
# Adopted from the "core" testbench in CORE-V-VERIF.

MAKE           = make
MAKE_DIR       = $(PWD)
MAKE_PATH     := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
REL_PATH_WORK  = ../..
DATE           = $(shell date +%F)
WAVES          = 0
BANNER        ?= ********************************************************************************

CV_CORE       ?= CV32E40P
CV_CORE_LC     = $(shell echo $(CV_CORE) | tr A-Z a-z)
CV_CORE_UC     = $(shell echo $(CV_CORE) | tr a-z A-Z)
CV_CORE_PKG   := $(REL_PATH_WORK)/$(CV_CORE_LC)

# Test-Program directores.
# Relative path is used for Verilator which cannot seem to handle loooong pathnames.
TEST_PROGRAM_RELPATH ?= $(REL_PATH_WORK)/riscof_work/rv32i_m/privilege/src/misalign-lw-01.S/dut
TEST                 ?= main

# Common output directories
RUN_INDEX               ?= 0
SIM_RESULTS              = simulation_results
SIM_TEST_RESULTS         = $(SIM_RESULTS)/$(TEST)
SIM_RUN_RESULTS          = $(SIM_TEST_RESULTS)/$(RUN_INDEX)
SIM_TEST_PROGRAM_RESULTS = $(SIM_RUN_RESULTS)/test_program
SIM_BSP_RESULTS          = $(SIM_TEST_PROGRAM_RESULTS)/bsp

# verilator configuration
VERILATOR           = verilator
VERI_FLAGS         +=
VERI_COMPILE_FLAGS += -Wno-BLKANDNBLK -Wno-MULTIDRIVEN -Wno-COMBDLY
VERI_TRACE         ?=
VERI_OBJ_DIR       ?= verilator_obj
VERI_LOG_DIR       ?= $(SIM_TEST_PROGRAM_RESULTS)
VERI_CFLAGS        += -O2

# TB source files
TBSRC_HOME  := .
TBSRC_TOP   := $(TBSRC_HOME)/tb_top.sv
TBSRC_CORE  := $(TBSRC_HOME)
TBSRC_PKG   := $(TBSRC_CORE)/tb_riscv/include/perturbation_defines.sv
TBSRC       := $(TBSRC_CORE)/tb_top.sv \
               $(TBSRC_CORE)/riscof_cv32e40p_tb_wrapper.sv \
               $(TBSRC_CORE)/mm_ram.sv \
               $(TBSRC_CORE)/dp_ram.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_random_stall.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_random_interrupt_generator.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_rvalid_stall.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_gnt_stall.sv

TBSRC_VERI  := $(TBSRC_CORE)/tb_top_verilator.sv \
               $(TBSRC_CORE)/riscof_cv32e40p_tb_wrapper.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_rvalid_stall.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_gnt_stall.sv \
               $(TBSRC_CORE)/mm_ram.sv \
               $(TBSRC_CORE)/dp_ram.sv
SIM_LIBS    := $(CORE_V_VERIF)/lib/sim_libs

# RTL source files for the CV32E40P core
CV_CORE_PKG           := $(REL_PATH_WORK)/$(CV_CORE_LC)
CV_CORE_RTLSRC_INCDIR := $(CV_CORE_PKG)/rtl/include
CV_CORE_RTLSRC_PKG    := $(CV_CORE_PKG)/rtl/fpnew/src/fpnew_pkg.sv \
                         $(addprefix $(CV_CORE_RTLSRC_INCDIR)/,\
                         CV_CORE_apu_core_package.sv CV_CORE_defines.sv \
                         CV_CORE_tracer_defines.sv)
CV_CORE_RTLSRC        := $(filter-out $(CV_CORE_PKG)/rtl/$(CV_CORE_LC)_register_file_latch.sv, \
                         $(wildcard $(CV_CORE_PKG)/rtl/*.sv))
CV_CORE_MANIFEST      := $(CV_CORE_PKG)/cv32e40p_manifest.flist

export DESIGN_RTL_DIR = $(CV_CORE_PKG)/rtl

###############################################################################
.DEFAULT_GOAL := sanity-veri-run

all: clean_all sanity-veri-run

###############################################################################
# Rule to generate hex (loadable by simulators) from elf
#    $@ is the file being generated.
#    $< is first prerequiste.
#    $^ is all prerequistes.
#    $* is file_name (w/o extension) of target

RISCV_HOME       ?= /opt/riscv
RISCV_EXE_PREFIX ?= $(RISCV_HOME)/bin/riscv32-unknown-elf-

%.hex: %.elf
	@echo "$(BANNER)"
	@echo "* Generating hexfile, readelf and objdump files"
	@echo "$(BANNER)"
	$(RISCV_EXE_PREFIX)objcopy -O verilog \
		$< \
		$@
	$(RISCV_EXE_PREFIX)readelf -a $< > $*.readelf
	$(RISCV_EXE_PREFIX)objdump \
		-d \
		-M no-aliases \
		-M numeric \
		-S \
		$*.elf > $*.objdump


###############################################################################
# Verilator

# We first test if the user wants to to vcd dumping. This hacky part is required
# because we need to conditionally compile the testbench (-DVCD_TRACE) and pass
# the --trace flags to the verilator call
#ifeq ($(findstring +vcd,$(VERI_FLAGS)),+vcd)

ifneq (${WAVES}, 0)
VERI_TRACE="--trace"
VERI_CFLAGS+="-DVCD_TRACE"
endif

verilate: testbench_verilator

sanity-veri-run:
	make veri-test

testbench_verilator: $(TBSRC_VERI) $(TBSRC_PKG)
	@echo "$(BANNER)"
	@echo "* Compiling CORE TB and CV32E40P with Verilator"
	@echo "$(BANNER)"
	$(VERILATOR) --cc --sv --exe \
		$(VERI_TRACE) \
		--Wno-lint --Wno-UNOPTFLAT \
		--Wno-MODDUP --top-module \
		tb_top_verilator $(TBSRC_VERI) \
		-f $(CV_CORE_MANIFEST) \
		$(CV_CORE_PKG)/bhv/$(CV_CORE_LC)_core_log.sv \
		$(TBSRC_CORE)/tb_top_verilator.cpp --Mdir $(VERI_OBJ_DIR) \
		-CFLAGS "-std=gnu++11 $(VERI_CFLAGS)" \
		$(VERI_COMPILE_FLAGS)
	$(MAKE) -C $(VERI_OBJ_DIR) -f Vtb_top_verilator.mk
	mkdir -p $(SIM_RESULTS)
	mkdir -p $(SIM_TEST_RESULTS)
	mv $(VERI_OBJ_DIR)/Vtb_top_verilator $(SIM_TEST_RESULTS)/verilator_executable

veri-test: verilate $(TEST_PROGRAM_RELPATH)/$(TEST).hex
	@echo "$(BANNER)"
	@echo "* Running with Verilator: logfile in $(SIM_TEST_RESULTS)/$(TEST).log"
	@echo "$(BANNER)"
	mkdir -p $(VERI_LOG_DIR)
	$(SIM_TEST_RESULTS)/verilator_executable \
		$(VERI_FLAGS) \
		"+firmware=$(TEST_PROGRAM_RELPATH)/$(TEST).hex" \
		"+signature=$(TEST).sig" \
		| tee $(VERI_LOG_DIR)/$(TEST).log

###############################################################################
# clean up simulation results
# verilator specific cleanup

clean: clean_all

clean_all: verilate-clean clean-sim-results

veri-clean: verilate-clean

verilate-clean:
	if [ -d $(SIM_RESULTS) ]; then rm -r $(SIM_RESULTS); fi
	if [ -d $(VERI_OBJ_DIR) ]; then rm -r $(VERI_OBJ_DIR); fi
	if [ -e memory_dump.bin ]; then rm memory_dump.bin; fi
	rm -rf testbench_verilator
	rm -rf *.sig

clean-sim-results:
	rm -rf $(SIM_RESULTS)

#endend
