#include "uart.h"

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
}

void uart_puthex_noprefix(uint64_t n) {
  const char *hexdigits = "0123456789ABCDEF";
  uart_puts("0x");
  for (int i = 60; i >= 0; i -= 4) {
    int k = hexdigits[(n >> i) & 0xF];

    if (k != '0')
      uart_putc(k);
  }
  if (n == 0) uart_putc('0');
}
