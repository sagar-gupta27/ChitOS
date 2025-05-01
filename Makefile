ASM=nasm
CC=gcc
SRC_DIR=src
BUILD_DIR=build
TOOLS_DIR=tools



.PHONY: all floppy_image kernel bootloader clean always tools_fat

all:floppy_image tools_fat


#tools
tools_fat:$(BUILD_DIR)/tools/fat
$(BUILD_DIR)/tools/fat:always $(TOOLS_DIR)/fat/fat.c
	$(CC) -g -o $(BUILD_DIR)/tools/fat $(TOOLS_DIR)/fat/fat.c
	
	


#Floppy image

floppy_image: $(BUILD_DIR)/main_floppy.img




$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img check.txt "::check.txt"


#bootloader
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) -f bin $(SRC_DIR)/bootloader/boot.asm -o $(BUILD_DIR)/bootloader.bin

#kernel
kernel: $(BUILD_DIR)/kernel.bin
$(BUILD_DIR)/kernel.bin: always
	$(ASM) -f bin $(SRC_DIR)/kernel/main.asm -o $(BUILD_DIR)/kernel.bin



#always
always:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/tools

#clean
clean:
	rm -rf $(BUILD_DIR)/*
	