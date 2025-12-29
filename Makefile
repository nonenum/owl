ASM nasm

SRC_DIR src
BUILD_DIR build

$(BUILD_DIR)/main_disk.img: $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main_disk.img
	truncate -s 1440k $(BUILD_DIR)/main_disk.img

$(BUILD_DIR)/main.bin: $(SRC_DIR)/owl.asm
	$(ASM) $(SRC_DIR)/owl.asm -f bin -o $(BUILD_DIR)/main.bin
