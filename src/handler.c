/* handler.c */
#include "uart.h"
#include "debug.h"

void handle_sync(pt_regs *regs) {
  uart_puts("\r\n[EXCEPTION] Synchronous Exception Occurred!\r\n");
  uart_puts(" (e.g., Segmentation Fault, Zero Division, etc.)\r\n");

  uart_puts("ELR_EL1 (PC) : ");
  uart_puthex(regs->elr);
  uart_puts("\r\n");

  uart_puts("SPSR_EL1 : ");
  uart_puthex(regs->spsr);
  uart_puts("\r\n");

  for (int i = 0; i < 30; i++) {
    uart_puthex(regs->x[i]);
    uart_putc(' ');
    if (i % 4 == 3)
      uart_puts("\r\n");
  }

  uart_puts("\r\n System Halted. \r\n");

  while (1)
    ; /* 멈춤 */
}

void handle_irq(void) {
  uart_puts("\r\n[INTERRUPT] IRQ Exception Occurred!\r\n");
  while (1)
    ;
}

void handle_fiq(void) {
  uart_puts("\r\n[INTERRUPT] FIQ Exception Occurred!\r\n");
  while (1)
    ;
}

void handle_error(void) {
  uart_puts("\r\n[ERROR] System Error Exception Occurred!\r\n");
  while (1)
    ;
}
