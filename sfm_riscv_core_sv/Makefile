# SIM tells it which simulator to launch
SIM ?= modelsim
# TOPLEVEL_LANG tells it which HDL the top level file is
TOPLEVEL_LANG = verilog

# VERILOG_SOURCES tells cocotb what all the files are
VERILOG_SOURCES = $(shell pwd)/sfm_riscv_core_sv.sv \
                  $(shell pwd)/sfm_riscv_DP_sv.sv \
                  $(shell pwd)/sfm_riscv_CU_sv.sv \
				  $(shell pwd)/sfm_riscv_ALU_sv.sv \
				  $(shell pwd)/sfm_riscv_byteEnLogic_sv.sv \
				  $(shell pwd)/sfm_riscv_immPro_sv.sv \
				  $(shell pwd)/sfm_riscv_ImmSelMux_sv.sv \
				  $(shell pwd)/sfm_riscv_NbitMux_sv.sv \
				  $(shell pwd)/sfm_riscv_NbitReg_sv.sv \
				  $(shell pwd)/sfm_riscv_PC_sv.sv \
				  $(shell pwd)/sfm_riscv_WbDec_sv.sv \
                  $(shell pwd)/PM_DM.v
				  
# COMPILE_ARGS tells it there is an additional command, that its actually systemVerilog, not just Verilog
COMPILE_ARGS += -sv

# TOPLEVEL tells it which file is actually the top level
COCOTB_TOPLEVEL = sfm_riscv_core_sv
# MODULE tells cocotb which file is the testbench file
COCOTB_TEST_MODULES = test_riscv

# Old line: include $(shell cocotb-config --makefiles)/Makefile.sim

# New Line:
COCOTB_MAKEFILES_DIR = $(shell cygpath -u $(shell cocotb-config --makefiles))
include $(COCOTB_MAKEFILES_DIR)/Makefile.sim
