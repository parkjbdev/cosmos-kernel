// src/kmain.c

#include "mmu.h"
#include "stdint.h"
#include "uart.h"

extern void load_vbar(void);

uint64_t get_current_el(void) {
  uint64_t el;
  __asm__ volatile("mrs %0, CurrentEL" : "=r"(el));
  return el >> 2;
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

  /* 1. Register Vector Table */
  load_vbar();
  uart_puts(" [INFO] Vector Table Loaded at VBAR_EL1\n\r");

  /* Testing SVC */
  // uart_puts("--------------------------------\n\r");
  // uart_puts(" [ACTION] Trying Supervisor Call svc #0...\n\r");
  // __asm__ __volatile__("svc #0");
  // uart_puts(" !! IF YOU SEE THIS, THE TRAP FAILED !!\n\r");

  /* 2. Initialize MMU */
  init_mmu();

  uart_puts(" [SUCCESS] MMU Enabled! D-Cache & I-Cache are ON.\n\r");
  uart_puts(" [CHECK] Accessing RAM to verify...\n\r");

  volatile int *p = (int *)0x45000000;
  *p = 0xCAFE;
  uart_puts(" Write/Read Test:");
  uart_puthex_noprefix(*p);
  uart_puts("\n");

  return;
}
