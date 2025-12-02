#include "mmu.h"
#include "uart.h"

__attribute__((aligned(4096))) uint64_t l1_table[512];
__attribute__((aligned(4096))) uint64_t l2_table[1024];

extern void enable_mmu_asm(uint64_t table);

void init_mmu(void) {
  /* 1. L1 테이블 설정
   * 0번지(0~1GB) 영역이 L2 테이블을 가리키도록 설정
   * Descriptor 포맷: [Output Addr] | [Table Type(3)] | [Valid(1)]
   */
  uint64_t l2_base = (uint64_t)l2_table;
  l1_table[0] = l2_base | 0x3; // 0x3 = Table Descriptor
  l1_table[1] = (l2_base + 4096) | 0x3;

  /* 2. L2 테이블 채우기 (0~1GB 구간 매핑) */
  for (int i = 0; i < 1024; i++) {
    uint64_t phys_addr = i * 0x200000ul; // 2MB * i
    uint64_t attributes;

    /* QEMU Virt 메모리 맵:
     * 0x09000000: UART (Device)
     * 0x40000000 ~ : RAM (Normal)
     */
    if (phys_addr >= 0x40000000) {
      /* RAM 영역: 캐시 켜기 (Normal Memory) */
      /* Lower Attribute: [AF(1)] | [SH(3)] | [AttrIdx(MT_NORMAL)] */
      attributes = (1ul << 10) | (3ul << 8) | (MT_NORMAL << 2);
    } else {
      /* MMIO 영역 (UART 등): 캐시 끄기 (Device Memory) */
      attributes = (1ul << 10) | (3ul << 8) | (MT_DEVICE_nGnRnE << 2);
    }

    /* Block Descriptor 생성 */
    /* [Phys Addr] | [Attr] | [Block Type(1)] | [Valid(1)] */
    l2_table[i] = phys_addr | attributes | 0x1;
  }

  /* 3. 시스템 레지스터 설정 */
  uart_puts(" [DEBUG] Set MAIR_EL1\n");
  set_mair_el1(MAIR_VALUE);

  uart_puts(" [DEBUG] Set TCR_EL1\n");
  set_tcr_el1(TCR_VALUE);

  uart_puts(" [DEBUG] Set TTBR0_EL1\n");
  set_ttbr0_el1((uint64_t)l1_table); // 테이블 위치 알려줌

  uart_puts(" [DEBUG] L1 Table Addr ");
  uart_puthex((uint64_t)l1_table);
  uart_puts("\n");

  /* 4. MMU 활성화! (가장 떨리는 순간) */
  tlb_flush();
  set_sctlr_el1(SCTLR_VALUE_MMU_ENABLED);
}
