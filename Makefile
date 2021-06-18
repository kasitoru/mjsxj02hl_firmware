# sudo apt install u-boot-tools dbus
# pip install click

INPUT_DIR   := unpacked
OUTPUT_FILE := demo_hlc6.bin

INPUT_FILE := $(OUTPUT_FILE)
OUTPUT_DIR := $(INPUT_DIR)

TEMP_DIR := /tmp/$(shell dbus-uuidgen)

all: clean chmod pack

pack:
	mkdir $(TEMP_DIR)
	mksquashfs $(INPUT_DIR)/app $(TEMP_DIR)/app.bin -b 131072 -comp xz -Xdict-size 100%
	mksquashfs $(INPUT_DIR)/kback $(TEMP_DIR)/kback.bin -b 131072 -comp xz -Xdict-size 100%
	mksquashfs $(INPUT_DIR)/rootfs $(TEMP_DIR)/rootfs.bin -b 131072 -comp xz -Xdict-size 100%
	./packer.py $(INPUT_DIR)/kernel.bin $(TEMP_DIR)/rootfs.bin $(TEMP_DIR)/app.bin $(TEMP_DIR)/kback.bin $(OUTPUT_FILE)
	rm -rf $(TEMP_DIR)

unpack:
	mkdir $(TEMP_DIR) $(OUTPUT_DIR)
	./unpacker.py $(INPUT_FILE) $(TEMP_DIR)
	unsquashfs -d $(OUTPUT_DIR)/app $(TEMP_DIR)/app.bin
	unsquashfs -d $(OUTPUT_DIR)/kback $(TEMP_DIR)/kback.bin
	unsquashfs -d $(OUTPUT_DIR)/rootfs $(TEMP_DIR)/rootfs.bin
	cp $(TEMP_DIR)/kernel.bin $(OUTPUT_DIR)/kernel.bin
	rm -rf $(TEMP_DIR)

chmod:
	# all
	find $(INPUT_DIR) -type f -exec chmod 644 {} \;
	find $(INPUT_DIR) -type d -exec chmod 755 {} \;
	# app
	find $(INPUT_DIR)/app/bin -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/app/drv -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/app/lib -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/app/sbin -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/app/www/cgi-bin -type f -exec chmod 755 {} \;
	# rootfs
	find $(INPUT_DIR)/rootfs/bin -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/rootfs/etc/init.d -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/rootfs/lib -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/rootfs/sbin -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/rootfs/thirdlib -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/rootfs/usr/bin -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/rootfs/usr/sbin -type f -exec chmod 755 {} \;
	find $(INPUT_DIR)/rootfs/usr/share/udhcpc -type f -exec chmod 755 {} \;

clean:
	rm -f $(OUTPUT_FILE)

