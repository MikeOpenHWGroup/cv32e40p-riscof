# CV32E40P RISCV Compliance using RISCOF

<!--
[![neorv32-riscof](https://img.shields.io/github/actions/workflow/status/stnolting/neorv32-riscof/main.yml?branch=main&longCache=true&style=flat-square&label=neorv32-riscof&logo=Github%20Actions&logoColor=fff)](https://github.com/stnolting/neorv32-riscof/actions/workflows/main.yml)
[![License](https://img.shields.io/github/license/stnolting/neorv32-riscof?longCache=true&style=flat-square&label=License)](https://github.com/stnolting/neorv32-riscof/blob/main/LICENSE)
[![Gitter](https://img.shields.io/badge/Chat-on%20gitter-4db797.svg?longCache=true&style=flat-square&logo=gitter&logoColor=e8ecef)](https://gitter.im/neorv32/community)
-->

1. [Prerequisites](#Prerequisites)
2. [Setup Configuration](#Setup-Configuration)
3. [Device-Under-Test (DUT)](#Device-Under-Test-DUT)

This repository is a port of the "**RISCOF** RISC-V Architectural Test Framework" to test the
[NEORV32 RISC-V Processor](https://github.com/stnolting/neorv32) for compatibility to the RISC-V
user and privileged ISA specifications. **Sail RISC-V** is used as reference model.
Currently, the following tests are supported:

- [x] `rv32i_m\B` - bit-manipulation (`Zba`, `Zbb`, `Zbc`, `Zbs`)
- [x] `rv32i_m\C` - compressed instructions
- [x] `rv32i_m\I` - base integer ISA
- [x] `rv32i_m\M` - hardware multiplication and division
- [x] `rv32i_m\privilege` - privileged machine architecture
- [x] `rv32i_m\Zifencei` - instruction stream synchronization

:bulb: The general structure of this repository was setup according to the
[RISCOF installation guide](https://riscof.readthedocs.io/en/stable/installation.html).


## Prerequisites

Several tools and submodules are required to run this port of the architecture test framework. The repository's
GitHub [Actions workflow](https://github.com/stnolting/neorv32-riscof/blob/main/.github/workflows/main.yml)
takes care of installing all the required packages.

* [neorv32](https://github.com/stnolting/neorv32) submodule - the device under test (DUT)
* [riscv-arch-test](https://github.com/riscv-non-isa/riscv-arch-test) submodule - architecture test cases
* [RISC-V GCC toolchain](https://github.com/riscv/riscv-gnu-toolchain) - recommend you follow the installation specified in RISCOF Quick Start
* [Sail RISC-V](https://github.com/riscv/sail-riscv) - the reference model (pre-built binary in the[`bin`](https://github.com/stnolting/neorv32-riscof/tree/main/bin) folder)
* [RISCOF](https://github.com/riscv-software-src/riscof) - the architecture test framework

TODO: You will also need a SystemVerilog simulator.

The framework (running all tests) is invoked via a single shell script **run.sh** that returns 0 if all tests were executed successfully or 1 if there were _any_ errors.
The exit code of this script is used to determine the overall success of the GitHub Actions workflow.

[[back to top](#CV32E40P-RISCV-Compliance-using-RISCOF)]


## Setup Configuration

The RISCOF **config.ini** is used to configure
the plugins to be used: the device-under-test ("DUT") and the reference model ("REF").
The ISA, debug and platform specifications, which define target-specific configurations like available ISA
extensions, ISA spec. versions and platform modules (like MTIME), are defined by `YAML` files in the according
plugin folder.

* DUT: `cv32e40p` in [`plugin-cv32e40p`](https://github.com/MikeOpenHWGroup/cv32e40p-riscof/tree/main/plugin-cv32e40p)
* REF: `sail_cSim` in [`plugin-sail_cSim`](https://github.com/MikeOpenHWGroup/cv32e40p-riscof/tree/main/plugin-sail_cSim)

Each plugin folder also provides low-level _environment_ files like linker scripts (to generate an executable
matching the target's memory layout) and platform-specific code (for example to initialize the target and
to dump the final test signatures/results).

The official [RISC-V architecture tests](https://github.com/riscv-non-isa/riscv-arch-test) repository
provides test cases for all (ratified) RISC-V ISA extensions (user and privilege ISA). Each test case checks
a single instruction or core feature and is compiled into a plugin-specific executable
using a [prebuilt RISC-V GCC toolchain](https://github.com/stnolting/riscv-gcc-prebuilt).

The reference data is generated by the **Sail RISC-V Model**.
This data is compared against the results of the DUT.
<!-- TODO:
The final test report is made available as CSS-flavored HTML file via the [GitHib actions artifact](https://github.com/OpenHWGroup/cv32e40p-riscof/actions).
-->

:bulb: Prebuilt _sail-riscv_ binaries for 64-bit Linux are available in the
[`bin`](https://github.com/stnolting/neorv32-riscof/tree/main/bin) folder.

[[back to top](#CV32E40P-RISCV-Compliance-using-RISCOF)]

## Device-Under-Test (DUT)

The [`sim`](https://github.com/stnolting/neorv32-riscof/tree/main/sim) folder provides a simple VHDL testbench
and shell scripts to simulate the NEORV32 processor using **GHDL**. The testbench provides generics to configure the
DUT's RISC-V ISA extensions and also to pass a plain ASCII HEX file, which represents the actual executable
to be executed ("memory initialization file"). This file generated from a test-specific ELF file that is compiled
by the folder's makefile. The makefile uses the default software framework from the NEORV32 submodule (more
specific: the image generator) to generate a memory initialization file from a compiled ELF file.

The testbench implements _four_ CPU-external memory modules that get initialized with the actual
executable. Each memory module implements a_physical memory size of 512kB resulting in a total memory size of 2MB (the
largest test case executable comes from the `I/jal` test case with approx. 1.7MB). This "splitting" is required as GHDL has
problems handling large objects (see https://github.com/ghdl/ghdl/issues/1592). The memories are attached to the processor
via its external Wishbone bus interface and are mapped to the core's reset address at `0x00000000`.

:books: The "simulation mode" feature of the processor's UART0 module is used to _dump_ the test result data
(= the _test signature_) to a file. More information regarding the UART simulation mode can be found in the
[NEORV32 online documentation](https://stnolting.github.io/neorv32/).

The testbench also provides a "trigger mechanism" to quit the current simulation using VHDL08's `finish`
statement. Quitting the simulation is triggered by writing `0xCAFECAFE` to address `0xF0000000`, which
is implemented (software) by the DUT-specific plugin environment module.

The simulation scripts and the makefile for generating the memory initialization file are invoked from a DUT-
specific Python script in the DUT's plugin folder
(-> [`plugin-neorv32/riscof_neorv32.py`](https://github.com/stnolting/neorv32-riscof/blob/main/plugin-neorv32/riscof_neorv32.py)).
This Python script makes extensive use of shell commands to move and execute files and scripts.

[[back to top](#CV32E40P-RISCV-Compliance-using-RISCOF)]
