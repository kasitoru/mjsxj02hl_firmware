TEMPORARY_DIR := temp

FIRMWARE_SRC  := firmware
FIRMWARE_DIR  := $(TEMPORARY_DIR)/firmware
FIRMWARE_FILE := demo_hlc6.bin

CROSS_COMPILE := arm-himix100-linux-
CCFLAGS       := -march=armv7-a -mfpu=neon-vfpv4 -funsafe-math-optimizations
LDPATH        := /opt/hisi-linux/x86-arm/arm-himix100-linux/target/usr/app/lib

.SILENT:

all: mkdirs application web pack

application:
	git clone --recurse-submodules "https://github.com/avdeevsv91/mjsxj02hl_application" "$(TEMPORARY_DIR)/application"
	make -C "$(TEMPORARY_DIR)/application" CROSS_COMPILE="$(CROSS_COMPILE)" CCFLAGS="$(CCFLAGS)" LDPATH="$(LDPATH)"
	cp -f $(TEMPORARY_DIR)/application/bin/mjsxj02hl $(FIRMWARE_DIR)/app/bin
	cp -arf $(TEMPORARY_DIR)/application/lib/. $(FIRMWARE_DIR)/app/lib

web:
	git clone "https://github.com/avdeevsv91/mjsxj02hl_web" "$(TEMPORARY_DIR)/web"
	make -C "$(TEMPORARY_DIR)/web" CROSS_COMPILE="$(CROSS_COMPILE)" CCFLAGS="$(CCFLAGS)"
	cp -arf $(TEMPORARY_DIR)/web/bin/. $(FIRMWARE_DIR)/app/bin
	cp -arf $(TEMPORARY_DIR)/web/lib/. $(FIRMWARE_DIR)/app/lib
	cp -arf $(TEMPORARY_DIR)/web/share/. $(FIRMWARE_DIR)/app/share
	cp -arf $(TEMPORARY_DIR)/web/www/. $(FIRMWARE_DIR)/app/www

pack:
	mksquashfs $(FIRMWARE_DIR)/app $(FIRMWARE_DIR)/app.bin -b 131072 -comp xz -Xdict-size 100%
	mksquashfs $(FIRMWARE_DIR)/kback $(FIRMWARE_DIR)/kback.bin -b 131072 -comp xz -Xdict-size 100%
	mksquashfs $(FIRMWARE_DIR)/rootfs $(FIRMWARE_DIR)/rootfs.bin -b 131072 -comp xz -Xdict-size 100%
	./packer.py $(FIRMWARE_DIR)/kernel.bin $(FIRMWARE_DIR)/rootfs.bin $(FIRMWARE_DIR)/app.bin $(FIRMWARE_DIR)/kback.bin $(FIRMWARE_FILE)

unpack:
	./unpacker.py $(FIRMWARE_FILE) $(FIRMWARE_DIR)
	unsquashfs -d $(FIRMWARE_DIR)/app $(FIRMWARE_DIR)/app.bin
	unsquashfs -d $(FIRMWARE_DIR)/kback $(FIRMWARE_DIR)/kback.bin
	unsquashfs -d $(FIRMWARE_DIR)/rootfs $(FIRMWARE_DIR)/rootfs.bin

clean:
	-make -C "$(TEMPORARY_DIR)/application" clean
	-make -C "$(TEMPORARY_DIR)/web" clean
	-rm -rf $(TEMPORARY_DIR)/*
	-rm -f $(FIRMWARE_FILE)

mkdirs: clean
	@[ -n "$(FIRMWARE_VER)" ] || { echo -e "\n\033[31mNo version specified! Building terminated.\033[0m\nUsage: make FIRMWARE_VER=\"x.y.z\"\n"; exit 1; }
	-mkdir -p $(TEMPORARY_DIR)
	cp -rf $(FIRMWARE_SRC) $(FIRMWARE_DIR)
	find $(FIRMWARE_DIR) -type f -name ".gitkeep" -exec rm -f {} \;
	echo $(FIRMWARE_VER) > $(FIRMWARE_DIR)/app/share/.version

