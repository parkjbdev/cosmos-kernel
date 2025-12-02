ENTRY(_start)

/* 커널이 올라갈 물리 주소 (QEMU virt 기준 DRAM 0x4000_0000 근처 예시) */
KERNEL_LOAD_ADDR = 0x40200000;

PHDRS
{
    segment_ro PT_LOAD FLAGS(4); /* 읽기 전용 */
    segment_rx PT_LOAD FLAGS(5); /* 실행 가능 + 읽기 전용 */
    segment_rw PT_LOAD FLAGS(6); /* 읽기/쓰기 */
    segment_rwx PT_LOAD FLAGS(7); /* 실행 가능 + 읽기/쓰기 */
}

SECTIONS
{
    . = KERNEL_LOAD_ADDR;

    .text : ALIGN(4K) {
        KEEP(*(.text.boot))   /* 부트코드용 섹션 */
        *(.text .text.*)
    }: segment_rx

    .rodata : ALIGN(4K) {
        *(.rodata .rodata.*)
    }: segment_ro

    .data : ALIGN(4K) {
        *(.data .data.*)
    }: segment_rw

    .bss : ALIGN(4K) {
        __bss_start = .;
        *(.bss .bss.* COMMON)
        __bss_end = .;
    }: segment_rw

    /* 심볼용 섹션 (디버깅용) */
    /DISCARD/ : {
        *(.comment)
    }
}
