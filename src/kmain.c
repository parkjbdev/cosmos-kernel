// src/kmain.c

#include <stdint.h>

void kmain(void) {
    while (1) {
        __asm__ volatile("wfe");
    }
}
