// SPDX-License-Identifier: BSD-3-Clause
// Modified for the CV32E40P RISC-V Processor by Mike Thompson

#ifndef _COMPLIANCE_MODEL_H
#define _COMPLIANCE_MODEL_H

#define RVMODEL_DATA_SECTION                                  \
    .pushsection .tohost,"aw",@progbits;                      \
    .align 8; .global tohost; tohost: .dword 0;               \
    .align 8; .global fromhost; fromhost: .dword 0;           \
    .popsection;                                              \
    .align 8; .global begin_regstate; begin_regstate:         \
    .word 128;                                                \
    .align 8; .global end_regstate; end_regstate:             \
    .word 4;

// CV32E40P: the testbench supports a set of "virtual peripherals":
//   - the "signature writer" dumps whatever is written to it to a flat ascii textfile.
//   - the "status flags" virtual peripheral is used to terminate the simulation:
//          - writing 'd123456789 to address 0x2000_0000 signals a PASS.
//          - writing 'd1 to address 0x2000_0000 signals a FAIL.
//
//  localparam int                        MMADDR_SIGBEGIN   = 32'h2000_0008;
//  localparam int                        MMADDR_SIGEND     = 32'h2000_000C;
//  localparam int                        MMADDR_SIGDUMP    = 32'h2000_0010;
 
//#define RVMODEL_HALT                                          \
//    signature_dump:                                           \
//      la   a0, begin_signature;                               \
//      la   a1, end_signature;                                 \
//      li   a2, 0xFFFFFFA4;                                    \
//    signature_dump_loop:                                      \
//      bge  a0, a1, signature_dump_end;                        \
//      lw   t0, 0(a0);                                         \
//      sw   t0, 0(a2);                                         \
//      addi a0, a0, 4;                                         \
//      j    signature_dump_loop;                               \
//    signature_dump_end:                                       \
//      nop;                                                    \
//    terminate_simulation:                                     \
//      li   a0, 0x20000000;                                    \
//      li   a1, 0x075BCD15;                                    \
//      sw   a1, 0(a0);                                         \
//    wait_for_interrupt_that_never_comes:                      \
//      wfi;
#define RVMODEL_HALT                                          \
    signature_dump_setup:                                     \
      li   a0, 0x20000008;                                    \
      la   a1, begin_signature;                               \
      sw   a1, 0(a0);                                         \
      li   a0, 0x2000000C;                                    \
      la   a1, end_signature;                                 \
      sw   a1, 0(a0);                                         \
      li   a0, 0x20000010;                                    \
      li   a1, 0x20000010;                                    \
      sw   a1, 0(a0);                                         \
      nop;                                                    \
    terminate_simulation:                                     \
      li   a0, 0x20000000;                                    \
      li   a1, 0x075BCD15;                                    \
      sw   a1, 0(a0);                                         \
    wait_for_interrupt_that_never_comes:                      \
      wfi;

#define RVMODEL_BOOT

// declare the start of your signature region here. Nothing else to be used here.
#define RVMODEL_DATA_BEGIN                                    \
    RVMODEL_DATA_SECTION                                      \
    .align 4;                                                 \
    .global begin_signature; begin_signature:

// declare the end of the signature region here. Add other target specific contents here.
#define RVMODEL_DATA_END                                      \
    .align 4;                                                 \
    .global end_signature; end_signature:

//RVTEST_IO_INIT
#define RVMODEL_IO_INIT

//RVTEST_IO_WRITE_STR
#define RVMODEL_IO_WRITE_STR(_R, _STR)

//RVTEST_IO_CHECK
#define RVMODEL_IO_CHECK()

//RVTEST_IO_ASSERT_GPR_EQ
#define RVMODEL_IO_ASSERT_GPR_EQ(_S, _R, _I)

//RVTEST_IO_ASSERT_SFPR_EQ
#define RVMODEL_IO_ASSERT_SFPR_EQ(_F, _R, _I)

//RVTEST_IO_ASSERT_DFPR_EQ
#define RVMODEL_IO_ASSERT_DFPR_EQ(_D, _R, _I)

// NEORV32: specify the routine for setting machine software interrupt
#define RVMODEL_SET_MSW_INT                                   \
    machine_irq_msi_set:                                      \
      li   a0, 0xF0000000;                                    \
      li   a1, 0x11111111;                                    \
      sw   a1, 0(a0);

// NEORV32: specify the routine for clearing machine software interrupt
#define RVMODEL_CLEAR_MSW_INT                                 \
    machine_irq_msi_clr:                                      \
      li   a0, 0xF0000000;                                    \
      li   a1, 0x22222222;                                    \
      sw   a1, 0(a0);

// NEORV32: specify the routine for setting machine external interrupt
#define RVMODEL_SET_MEXT_INT                                  \
    machine_irq_mei_set:                                      \
      li   a0, 0xF0000000;                                    \
      li   a1, 0x33333333;                                    \
      sw   a1, 0(a0);

// NEORV32: specify the routine for clearing machine external interrupt
#define RVMODEL_CLEAR_MEXT_INT                                \
    machine_irq_mei_clr:                                      \
      li   a0, 0xF0000000;                                    \
      li   a1, 0x44444444;                                    \
      sw   a1, 0(a0);

// NEORV32: specify the routine for clearing machine timer interrupt
#define RVMODEL_CLEAR_MTIMER_INT                              \
    machine_irq_mti_clr:                                      \
      li   a0, 0xFFFFFF90;                                    \
      li   a1, -1;                                            \
      sw   a1, 0xc(a0);                                       \
      sw   a1, 0x8(a0);


#endif // _COMPLIANCE_MODEL_H
