#ifndef __DEBUG_H__
#define __DEBUG_H__

#include "stdint.h"

typedef struct {
  uint64_t x[30];
  uint64_t lr; // x30
  uint64_t elr;
  uint64_t spsr;
} __attribute__((packed)) pt_regs;

#endif
