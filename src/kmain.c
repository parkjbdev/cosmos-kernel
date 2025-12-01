// src/kmain.c

#include "stdint.h"
#include "uart.h"

extern void load_vbar(void);

uint64_t get_current_el(void) {
  uint64_t el;
  /* CurrentEL 시스템 레지스터 읽기 */
  __asm__ volatile("mrs %0, CurrentEL" : "=r"(el));
  return el >> 2; /* 하위 2비트는 reserved라 버림 */
}

void kmain(void) {
  uart_puts("Hello from my kernel!\n");

  uart_puts("\n\r");
  uart_puts("--------------------------------\n\r");
  uart_puts(" Boot Successful!\n\r");

  uint64_t el = get_current_el();
  uart_puts(" Current Exception Level: ");
  uart_puthex(el);

  if (el == 1) {
    uart_puts(" -> We are in EL1 (Kernel Mode)\n\r");
  } else if (el == 2) {
    uart_puts(" -> We are in EL2 (Hypervisor Mode)\n\r");
  } else {
    uart_puts(" -> Unknown Level\n\r");
  }
  uart_puts("--------------------------------\n\r");

  /* 1. 벡터 테이블 등록 */
  load_vbar();
  uart_puts(" [INFO] Vector Table Loaded at VBAR_EL1\n\r");

  uart_puts("--------------------------------\n\r");
  uart_puts(" 3 seconds until CRASH TEST...\n\r");
  uart_puts(" [ACTION] Trying Supervisor Call svc #0...\n\r");

  __asm__ __volatile__("svc #0");
  uart_puts(" !! IF YOU SEE THIS, THE TRAP FAILED !!\n\r");

  while (1) {
    __asm__ volatile("wfe");
  }
}
