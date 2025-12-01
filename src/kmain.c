// src/kmain.c

#include <stdint.h>

#define UART0_BASE 0x09000000
#define UART0_DR (*((volatile uint32_t *)(UART0_BASE + 0x00)))
#define UART0_FR (*((volatile uint32_t *)(UART0_BASE + 0x18)))
#define UART0_FR_TXFF (1 << 5)

void uart_putc(char c) {
  while (UART0_FR & UART0_FR_TXFF)
    ;
  UART0_DR = (uint32_t)c;
}

void uart_puts(const char *s) {
  while (*s) {
    uart_putc(*s++);
  }
}

void uart_puthex(uint64_t n) {
  const char *hexdigits = "0123456789ABCDEF";
  uart_puts("0x");
  for (int i = 60; i >= 0; i -= 4) {
    uart_putc(hexdigits[(n >> i) & 0xF]);
  }
  uart_puts("\r\n");
}

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

  while (1) {
    __asm__ volatile("wfe");
  }
}
