MEMORY 
{
  image (rwx) : ORIGIN = 0x00000000, LENGTH = 0xFFFFFFFF
  scratch_x (rwx) : ORIGIN = 0x20040000, LENGTH = 4k 
  scratch_y (rwx) : ORIGIN = 0x20041000, LENGTH = 4k
}

_heap_size = 0x4000;

ENTRY(main)

SECTIONS
{
    .text :
    {
        . = ALIGN(16);
        *(.text) 
        *(.text*)
        *(.rel.text*)
        *(.glue_7)
        *(.glue_7t)
        *(.eh_frame)
        KEEP(*(.init))
        KEEP(*(.fini))
        *(.rodata)
        *(.rodata*)
        . = ALIGN(16);
    } >image

    .data :
    {
        *(.ram_vector_table)
        . = ALIGN(4);
        . = ALIGN(16);
        PROVIDE_HIDDEN(__mutex_array_start = .);
        KEEP(*(SORT(.mutex_array.*)))
        KEEP(*(.mutex_array))
        PROVIDE_HIDDEN(__mutex_array_end = .);
        
        . = ALIGN(16);
        PROVIDE_HIDDEN(__preinit_array_start = .);
        KEEP(*(SORT(.preinit_array.*)))
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN(__preinit_array_end = .);
        
        . = ALIGN(16);
        PROVIDE_HIDDEN(__init_array_start = .);
        KEEP(*(SORT(.preinit_array.*)));
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN(__init_array_end = .);

        . = ALIGN(16);
        PROVIDE_HIDDEN(__fini_array_start = .);
        *(SORT(.fini_array.*))
        *(.fini_array)
        PROVIDE_HIDDEN(__fini_array_end = .);

        . = ALIGN(16);
        *(.time_critical)
        *(.time_critical*)
        *(.data)
        *(.data*)
        
        . = ALIGN(16);
        PROVIDE(end = .);
        . = . + _heap_size;
        . = ALIGN(16);
    } >image

    .bss :
    {
        . = ALIGN(16);
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(16);
    } >image

    .got :
    {
        *(.got*)
    } >image

    .ARM.exidx :
    {
        *(.ARM.exidx*)
    } >image

    .ARM.extab.t : 
    {
        *(.ARM.extab*)
    } >image

    .stack1_dummy (COPY):
    {
      *(.stack1*)
    } > scratch_x

    .stack_dummy (COPY):
    {
      *(.stack*)
    } > scratch_y 

    __StackTop = ORIGIN(scratch_y) + LENGTH(scratch_y);
    __StackBottom = __StackTop - SIZEOF(.stack_dummy);
    __StackLimit = ORIGIN(scratch_y);
}

