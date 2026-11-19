ENTRY(kernel_entry)

SECTIONS
{
    . = 0x1000;

    .text : {
        *(.entry)
        *(.text*)
    }

    .rodata : {
        *(.rodata*)
    }

    .data : {
        *(.data*)
    }

    .bss : {
        *(COMMON)
        *(.bss*)
    }
}
