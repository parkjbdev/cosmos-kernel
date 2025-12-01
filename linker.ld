ENTRY(_start)

/* 커널이 올라갈 물리 주소 (QEMU virt 기준 DRAM 0x4000_0000 근처 예시) */
KERNEL_LOAD_ADDR = 0x40200000;

SECTIONS
{
    . = KERNEL_LOAD_ADDR;

    .text : ALIGN(4K) {
        KEEP(*(.text.boot))   /* 부트코드용 섹션 */
        *(.text .text.*)
    }

    .rodata : ALIGN(4K) {
        *(.rodata .rodata.*)
    }

    .data : ALIGN(4K) {
        *(.data .data.*)
    }

    .bss : ALIGN(4K) {
        __bss_start = .;
        *(.bss .bss.* COMMON)
        __bss_end = .;
    }

    /* 심볼용 섹션 (디버깅용) */
    /DISCARD/ : {
        *(.comment)
    }
}
