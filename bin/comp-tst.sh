#!/bin/bash

export BANNER="*******************************************************************************"
export WORK="/home/mike/GitHubRepos/MikeOpenHWGroup/cv32e40p-riscof/add_e40p"
export RISCV_HOME="/opt/riscv"
export RISCV_EXE_PREFIX="$RISCV_HOME/bin/riscv32-unknown-elf-"

export ISA="rv32i_m/I"
export TST="add-01"

while getopts i:t: flag
do
    case "${flag}" in
        i) ISA=${OPTARG};;
        t) TST=${OPTARG};;
    esac
done
echo "ISA: $ISA";
echo "TST: $TST";

echo "$BANNER"
echo "* Removing old compiler outputs"
echo "$BANNER"
rm -f *.hex *.elf *.objdump *.readelf

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
    -T $WORK/plugin-cv32e40p/env/link.ld \
    -I $WORK/plugin-cv32e40p/env/ \
    -I $WORK/riscv-arch-test/riscv-test-suite/env \
       $WORK/riscv-arch-test/riscv-test-suite/$ISA/src/$TST.S \
    -o $TST.elf  \
    -DTEST_CASE_1=True \
    -DXLEN=32 \
    -mabi=ilp32

echo "$BANNER"
echo "* Generating hexfile, readelf and objdump files"
echo "$BANNER"
riscv32-unknown-elf-objcopy -O verilog \
    $TST.elf  \
    $TST.hex

riscv32-unknown-elf-readelf -a $TST.elf > $TST.readelf

riscv32-unknown-elf-objdump \
    -d \
    -M no-aliases \
    -M numeric \
    -S \
    $TST.elf > $TST.objdump

#spike \
#	--isa=rv32imc \
#	+signature=/home/mike/riscof-1.25.3/riscof_work/rv32i_m/C/src/cadd-01.S/dut/DUT-spike.signature \
#	+signature-granularity=4 \
#	my.elf
