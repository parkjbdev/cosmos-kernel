/* vector.S */
.global vectors_start
.global load_vbar

.section .text

/* * ARMv8 벡터 테이블은 반드시 2KB(2^11) 경계에 정렬되어야 함
 */
.align 11
vectors_start:

    /* -------------------------------------------------
     * Current EL with SP0 (사용 안 함, 보통 OS는 SPx 씀)
     * ------------------------------------------------- */
    .align 7  /* 128바이트 간격 맞추기 */
    b   handle_sync
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
    b   handle_sync    /* 여기가 핵심: 코드 오류, 잘못된 주소 접근 등 */
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
    b   handle_sync
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

