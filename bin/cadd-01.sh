#!/bin/bash

export BANNER="*******************************************************************************"
export REPO="/home/mike/GitHubRepos/MikeOpenHWGroup/cv32e40p-riscof/add_e40p"
export RISCV_HOME="/opt/riscv"
export RISCV_EXE_PREFIX="$(RISCV_HOME)/bin/riscv32-unknown-elf-"

echo "$BANNER"
echo "* Removing old compiler outputs"
echo "$BANNER"
rm cadd-01.hex cadd-01.elf cadd-01.objdump cadd-01.readelf

echo "$BANNER"
echo "* Compiling Test Program"
echo "$BANNER"
riscv32-unknown-elf-gcc \
    -march=rv32ic \
    -static \
    -mcmodel=medany \
    -fvisibility=hidden \
    -nostdlib \
    -nostartfiles \
    -g \
    -T $REPO/plugin-cv32e40p/env/link.ld \
    -I $REPO/plugin-cv32e40p/env/ \
    -I $REPO/riscv-arch-test/riscv-test-suite/env \
       $REPO/riscv-arch-test/riscv-test-suite/rv32i_m/C/src/cadd-01.S \
    -o cadd-01.elf  \
    -DTEST_CASE_1=True \
    -DXLEN=32 \
    -mabi=ilp32

echo "$BANNER"
echo "* Generating hexfile, readelf and objdump files"
echo "$BANNER"
riscv32-unknown-elf-objcopy -O verilog \
    cadd-01.elf  \
    cadd-01.hex

riscv32-unknown-elf-readelf -a cadd-01.elf > cadd-01.readelf

riscv32-unknown-elf-objdump \
    -d \
    -M no-aliases \
    -M numeric \
    -S \
    cadd-01.elf > cadd-01.objdump

#spike \
#	--isa=rv32imc \
#	+signature=/home/mike/riscof-1.25.3/riscof_work/rv32i_m/C/src/cadd-01.S/dut/DUT-spike.signature \
#	+signature-granularity=4 \
#	my.elf
