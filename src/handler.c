/* handler.c */
#include "uart.h"

void handle_sync(void) {
    uart_puts("\r\n[EXCEPTION] Synchronous Exception Occurred!\r\n");
    uart_puts(" (e.g., Segmentation Fault, Zero Division, etc.)\r\n");
    while(1); /* 멈춤 */
}

void handle_irq(void) {
    uart_puts("\r\n[INTERRUPT] IRQ Exception Occurred!\r\n");
    while(1);
}

void handle_fiq(void) {
    uart_puts("\r\n[INTERRUPT] FIQ Exception Occurred!\r\n");
    while(1);
}

void handle_error(void) {
    uart_puts("\r\n[ERROR] System Error Exception Occurred!\r\n");
    while(1);
}

