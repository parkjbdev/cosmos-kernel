#ifndef __MMU_H__
#define __MMU_H__

#include "stdint.h"

void init_mmu(void);

/* MAIR_EL1: 메모리 속성 정의 */
#define MT_DEVICE_nGnRnE    0x0
#define MT_NORMAL_NC        0x1
#define MT_NORMAL           0x2

#define MAIR_VALUE  ( \
    (0x00ul << (MT_DEVICE_nGnRnE * 8)) | \
    (0x44ul << (MT_NORMAL_NC * 8))     | \
    (0xFFul << (MT_NORMAL * 8))          \
)

/* TCR_EL1: 주소 변환 제어 */
#define TCR_T0SZ        (64 - 39)  /* 39-bit Virtual Address (512GB) */
#define TCR_TG0_4K      (0 << 14)  /* 4KB Granule */
#define TCR_IPS_40BIT   (2ul << 32)
#define TCR_EPD1        (1ul << 23)
#define TCR_SH0_INNER   (3 << 12)  /* Shareability */
#define TCR_ORGN0_WBWA  (1 << 10)  /* Outer Cacheability */
#define TCR_IRGN0_WBWA  (1 << 8)   /* Inner Cacheability */

#define TCR_VALUE       (TCR_T0SZ | TCR_TG0_4K | TCR_SH0_INNER | TCR_ORGN0_WBWA | TCR_IRGN0_WBWA | TCR_IPS_40BIT | TCR_EPD1)

/* SCTLR_EL1: 시스템 제어 (MMU 켜기) */
#define SCTLR_MMU_ENABLED   (1 << 0)
#define SCTLR_C_ENABLED     (1 << 2)  /* D-Cache */
#define SCTLR_I_ENABLED     (1 << 12) /* I-Cache */

#define SCTLR_VALUE_MMU_DISABLED    0
#define SCTLR_VALUE_MMU_ENABLED     (SCTLR_MMU_ENABLED | SCTLR_C_ENABLED | SCTLR_I_ENABLED)

/**
 * Assembly Helper Functions
 */
extern void set_ttbr0_el1(uint64_t table);
extern void set_mair_el1(uint64_t mair);
extern void set_tcr_el1(uint64_t tcr);
extern void set_sctlr_el1(uint64_t sctlr);
extern void tlb_flush(void);

#endif

