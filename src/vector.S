/* vector.S */
.global vectors_start
.global load_vbar

.section .text

/* Context Save 매크로 정의 */
.macro kernel_entry
    /* 스택 공간 확보 (32개 * 8바이트 + 16바이트 여유 = 272 등.. 넉넉히 256+16) */
    sub     sp, sp, #256

    /* 범용 레지스터 x0 ~ x29 저장 (Pair instruction 사용) */
    stp     x0, x1, [sp, #16 * 0]
    stp     x2, x3, [sp, #16 * 1]
    stp     x4, x5, [sp, #16 * 2]
    stp     x6, x7, [sp, #16 * 3]
    stp     x8, x9, [sp, #16 * 4]
    stp     x10, x11, [sp, #16 * 5]
    stp     x12, x13, [sp, #16 * 6]
    stp     x14, x15, [sp, #16 * 7]
    stp     x16, x17, [sp, #16 * 8]
    stp     x18, x19, [sp, #16 * 9]
    stp     x20, x21, [sp, #16 * 10]
    stp     x22, x23, [sp, #16 * 11]
    stp     x24, x25, [sp, #16 * 12]
    stp     x26, x27, [sp, #16 * 13]
    stp     x28, x29, [sp, #16 * 14]

    /* LR(x30), ELR, SPSR 저장 */
    mrs     x21, elr_el1
    mrs     x22, spsr_el1

    str     x30, [sp, #16 * 15]     /* LR 저장 */
    stp     x21, x22, [sp, #16 * 15 + 8] /* ELR, SPSR를 구조체 끝에 저장 */
    /* 주의: 위 오프셋 계산은 C 구조체와 딱 맞아야 함.
       여기선 약식으로 설명했으니 디버깅하며 맞춰야 함.
       가장 쉬운 방법: x0에 현재 sp를 넣어서 인자로 전달 */
.endm

__handle_sync_entry:
    kernel_entry
    mov x0, sp
    bl handle_sync
    b .

/* * ARMv8 벡터 테이블은 반드시 2KB(2^11) 경계에 정렬되어야 함
 */
.align 11
vectors_start:

    /* -------------------------------------------------
     * Current EL with SP0 (사용 안 함, 보통 OS는 SPx 씀)
     * ------------------------------------------------- */
    .align 7  /* 128바이트 간격 맞추기 */
    b   __handle_sync_entry
    .align 7
    b   handle_irq
    .align 7
    b   handle_fiq
    .align 7
    b   handle_error

    /* -------------------------------------------------
     * Current EL with SPx (우리가 있는 곳! EL1)
     * ------------------------------------------------- */
    .align 7
    b   __handle_sync_entry    /* 여기가 핵심: 코드 오류, 잘못된 주소 접근 등 */
    .align 7
    b   handle_irq     /* 타이머, 하드웨어 인터럽트 */
    .align 7
    b   handle_fiq
    .align 7
    b   handle_error

    /* -------------------------------------------------
     * Lower EL using AArch64 (나중에 유저모드 생기면 씀)
     * ------------------------------------------------- */
    .align 7
    b   __handle_sync_entry
    .align 7
    b   handle_irq
    .align 7
    b   handle_fiq
    .align 7
    b   handle_error

    /* -------------------------------------------------
     * Lower EL using AArch32 (32비트 호환, 지금은 무시)
     * ------------------------------------------------- */
    .align 7
    b   handle_sync
    b   __handle_sync_entry
    .align 7
    b   handle_irq
    .align 7
    b   handle_fiq
    .align 7
    b   handle_error

/* VBAR_EL1 레지스터에 테이블 주소를 등록하는 함수 */
load_vbar:
    ldr     x0, =vectors_start
    msr     vbar_el1, x0
    ret

