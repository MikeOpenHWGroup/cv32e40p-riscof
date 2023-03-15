OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

SECTIONS
{
  . = 0x00000080;
  .text :
  {
    *(.text.init)
    . = ALIGN(0x1000);
    *(.text)
    . = ALIGN(0x1000);
    _end = .;
  }

  . = 0x00100000;
  .data :
  {
    . = ALIGN(0x1000);
    *(.data)
    *(.data.string)
    *(.bss)
  }
}
