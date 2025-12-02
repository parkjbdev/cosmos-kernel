TARGET      = kernel
CROSS_COMPILE ?= aarch64-none-elf-

CC      = $(CROSS_COMPILE)gcc
LD      = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
NM      = $(CROSS_COMPILE)nm

SRC_DIR := src
INC_DIR := include
BUILD_DIR := build

CFLAGS  = -std=c11 -ffreestanding -nostdlib -nostdinc \
          -Wall -Wextra -g -O0 \
          -mcpu=cortex-a53 -march=armv8-a
CFLAGS += -I$(INC_DIR)
LDFLAGS = -T linker.ld -nostdlib

SRC_C = $(wildcard $(SRC_DIR)/*.c)
SRC_S = $(wildcard $(SRC_DIR)/*.S)

OBJ_C   = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC_C))
OBJ_S   = $(patsubst $(SRC_DIR)/%.S, $(BUILD_DIR)/%.o, $(SRC_S))
OBJS    = $(OBJ_S) $(OBJ_C)

# Emulation Settings
QEMU    = qemu-system-aarch64
MACHINE = virt
CPU     = cortex-a53
SMP     = 1
MEMORY  = 512M
UBOOT   = $(PWD)/u-boot/u-boot.bin
KERNEL_LOAD_ADDR = 0x40200000 

.PHONY: all clean dump nm uboot boot

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/$(TARGET).elf: $(OBJS) linker.ld
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

dump: $(BUILD_DIR)/$(TARGET).elf
	$(OBJDUMP) -d $< > $(BUILD_DIR)/$(TARGET).dump

clean:
	rm -rf $(BUILD_DIR)

nm: $(BUILD_DIR)/$(TARGET).elf
	$(NM) $<

uboot: $(BUILD_DIR)/$(TARGET).bin
	$(QEMU) -M $(MACHINE),gic-version=3,virtualization=false \
	  -cpu $(CPU) -smp $(SMP) -m $(MEMORY) \
	  -nographic \
	  -bios '$(UBOOT)' \
	  -device loader,file=$<,addr=$(KERNEL_LOAD_ADDR)

uboot-bootloader:
	cd u-boot && \
	make qemu_arm64_defconfig && \
	make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)

boot: $(BUILD_DIR)/$(TARGET).bin
	$(QEMU) \
	  -M $(MACHINE),gic-version=3,virtualization=false \
	  -cpu $(CPU) -smp $(SMP) -m $(MEMORY) \
	  -nographic \
	  -kernel $<
