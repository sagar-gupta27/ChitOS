ASM=nasm

SRC_DIR=src
BUILD_DIR=build
				
$(BUILD_DIR)/bios.bin: $(SRC_DIR)/bios.asm
		mkdir -p $(BUILD_DIR)
		$(ASM) $(SRC_DIR)/bios.asm -f bin -o $(BUILD_DIR)/bios.bin

run:bios.bin
	qemu-system-i386 -bios bios.bin
