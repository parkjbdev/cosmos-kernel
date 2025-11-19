TARGET     = kernel
CROSS_COMPILE ?= aarch64-elf-

CC      = $(CROSS_COMPILE)gcc
LD      = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

CFLAGS  = -std=c11 -ffreestanding -nostdlib -nostdinc \
          -Wall -Wextra -g -O2 \
          -mcpu=cortex-a53 -march=armv8-a
LDFLAGS = -T linker.ld -nostdlib

SRC_C   = src/kmain.c
SRC_S   = src/start.S

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
