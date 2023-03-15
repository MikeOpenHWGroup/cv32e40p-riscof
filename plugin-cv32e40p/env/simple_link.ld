OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

SECTIONS
{
  . = 0x00000080;
  .text : { *(.text) }
  . = 0x20000000;
  .data : { *(.data) }
  .bss : { *(.bss) }
}
