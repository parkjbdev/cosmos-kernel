TARGET     = kernel
CROSS_COMPILE ?= aarch64-none-elf-

CC      = $(CROSS_COMPILE)gcc
LD      = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
NM      = $(CROSS_COMPILE)nm

SRC_DIR := src
INC_DIR := include
BUILD_DIR := bin

CFLAGS  = -std=c11 -ffreestanding -nostdlib -nostdinc \
          -Wall -Wextra -g -O0 \
          -mcpu=cortex-a53 -march=armv8-a
CFLAGS += -I$(INC_DIR)
LDFLAGS = -T linker.ld -nostdlib

SRC_C = $(wildcard $(SRC_DIR)/*.c)
SRC_S = $(wildcard $(SRC_DIR)/*.S)

OBJ_C   = $(SRC_C:.c=.o)
OBJ_S   = $(SRC_S:.S=.o)
OBJS    = $(OBJ_S) $(OBJ_C)

.PHONY: all clean dump

all: $(TARGET).elf $(TARGET).bin

$(TARGET).elf: $(OBJS) linker.ld
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

dump: $(TARGET).elf
	$(OBJDUMP) -d $(TARGET).elf > $(TARGET).dump

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin $(TARGET).dump

nm: $(TARGET).elf
	$(NM) $(TARGET).elf

.PHONY: all clean nm dump
