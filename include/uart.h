#include "stdint.h"

#ifndef __UART_H__
#define __UART_H__

#define UART0_BASE 0x09000000
#define UART0_DR (*((volatile uint32_t *)(UART0_BASE + 0x00)))
#define UART0_FR (*((volatile uint32_t *)(UART0_BASE + 0x18)))
#define UART0_FR_TXFF (1 << 5)

void uart_putc(char c);

void uart_puts(const char *s);

void uart_puthex(uint64_t n);

#endif
