ASM = nasm

SRC_DIR = src
BUILD_DIR = build

.PHONY: all floppy_img kernel bootloader clean always

floppy_img: $(BUILD_DIR)/main_disk.img

$(BUILD_DIR)/main_disk.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_disk.img bs=512 count=2880
	mkfs.fat -F 12 -n "OWLS" $(BUILD_DIR)/main_disk.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_disk.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_disk.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin

always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

run:
	qemu-system-i386 -fda build/main_disk.img
