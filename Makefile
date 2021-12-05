BRANCH                := main

ZLIB_VERSION          := 1.2.11
OPENSSL_VERSION       := 1.1.1l
CURL_VERSION          := 7.80.0

TEMPORARY_DIR         := temp

FIRMWARE_SRC          := firmware
FIRMWARE_DIR          := $(TEMPORARY_DIR)/firmware
FIRMWARE_FILE         := demo_hlc6.bin

CROSS_COMPILE         := arm-himix100-linux
CCFLAGS               := -march=armv7-a -mfpu=neon-vfpv4 -funsafe-math-optimizations
LDPATH                := /opt/hisi-linux/x86-arm/arm-himix100-linux/target/usr/app/lib

.SILENT:
all: mkdirs install-libs application web curl chmod pack

application:
	git clone --recurse-submodules --branch "$(BRANCH)" "https://github.com/kasitoru/mjsxj02hl_application" "$(TEMPORARY_DIR)/application"
	make -C "$(TEMPORARY_DIR)/application" CROSS_COMPILE="$(CROSS_COMPILE)-" CCFLAGS="$(CCFLAGS)" LDPATH="$(LDPATH)"
	cp -f $(TEMPORARY_DIR)/application/bin/mjsxj02hl $(FIRMWARE_DIR)/app/bin
	cp -arf $(TEMPORARY_DIR)/application/lib/. $(FIRMWARE_DIR)/app/lib

web:
	git clone --branch "$(BRANCH)" "https://github.com/kasitoru/mjsxj02hl_web" "$(TEMPORARY_DIR)/web"
	make -C "$(TEMPORARY_DIR)/web" CROSS_COMPILE="$(CROSS_COMPILE)-" CCFLAGS="$(CCFLAGS)"
	cp -arf $(TEMPORARY_DIR)/web/bin/. $(FIRMWARE_DIR)/app/bin
	cp -arf $(TEMPORARY_DIR)/web/lib/. $(FIRMWARE_DIR)/app/lib
	cp -arf $(TEMPORARY_DIR)/web/share/. $(FIRMWARE_DIR)/app/share
	cp -arf $(TEMPORARY_DIR)/web/www/. $(FIRMWARE_DIR)/app/www

zlib:
	wget -O "$(TEMPORARY_DIR)/zlib-$(ZLIB_VERSION).tar.gz" "http://www.zlib.net/zlib-$(ZLIB_VERSION).tar.gz"
	tar -xf $(TEMPORARY_DIR)/zlib-$(ZLIB_VERSION).tar.gz -C $(TEMPORARY_DIR) && mv $(TEMPORARY_DIR)/zlib-$(ZLIB_VERSION) $(TEMPORARY_DIR)/zlib
	cd $(TEMPORARY_DIR)/zlib && CROSS_PREFIX="$(CROSS_COMPILE)-" CFLAGS="$(CCFLAGS)" ./configure
	make -C "$(TEMPORARY_DIR)/zlib"
	cp -fP $(TEMPORARY_DIR)/zlib/libz.so* $(FIRMWARE_DIR)/rootfs/thirdlib
	cp -fP $(TEMPORARY_DIR)/zlib/libz.so* $(LDPATH)

openssl: zlib
	wget -O "$(TEMPORARY_DIR)/openssl-$(OPENSSL_VERSION).tar.gz" "https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz"
	tar -xf $(TEMPORARY_DIR)/openssl-$(OPENSSL_VERSION).tar.gz -C $(TEMPORARY_DIR) && mv $(TEMPORARY_DIR)/openssl-$(OPENSSL_VERSION) $(TEMPORARY_DIR)/openssl
	cd $(TEMPORARY_DIR)/openssl && ./Configure linux-armv4 shared zlib no-hw no-afalgeng no-async no-aria no-asm no-autoerrinit no-autoload-config no-bf no-blake2 no-camellia no-capieng no-cast no-chacha no-cmac no-cms no-comp no-ct no-deprecated no-dgram no-dso no-dtls no-dynamic-engine no-ec no-ec2m no-ecdh no-ecdsa no-err no-filenames no-gost no-makedepend no-mdc2 no-multiblock no-pinshared no-ocb no-poly1305 no-posix-io no-psk no-rc2 no-rc4 no-rdrand no-rfc3779 no-rmd160 no-scrypt no-seed no-siphash no-sm2 no-sm3 no-sm4 no-srtp no-sse2 no-ssl no-static-engine no-tests no-threads no-ts no-whirlpool no-idea no-srp
	make -C "$(TEMPORARY_DIR)/openssl" CROSS_COMPILE="$(CROSS_COMPILE)-" CFLAGS="$(CCFLAGS)" LDFLAGS="-L$(LDPATH)"
	cp -fP $(TEMPORARY_DIR)/openssl/libcrypto.so* $(FIRMWARE_DIR)/rootfs/thirdlib
	cp -fP $(TEMPORARY_DIR)/openssl/libssl.so* $(FIRMWARE_DIR)/rootfs/thirdlib
	cp -fP $(TEMPORARY_DIR)/openssl/libcrypto.so* $(LDPATH)
	cp -fP $(TEMPORARY_DIR)/openssl/libssl.so* $(LDPATH)

curl: openssl zlib
	wget -O "$(FIRMWARE_DIR)/rootfs/usr/local/cacert.pem" "https://curl.haxx.se/ca/cacert.pem"
	wget -O "$(TEMPORARY_DIR)/curl-$(CURL_VERSION).tar.gz" "https://curl.se/download/curl-$(CURL_VERSION).tar.gz"
	tar -xf $(TEMPORARY_DIR)/curl-$(CURL_VERSION).tar.gz -C $(TEMPORARY_DIR) && mv $(TEMPORARY_DIR)/curl-$(CURL_VERSION) $(TEMPORARY_DIR)/curl
	cd $(TEMPORARY_DIR)/curl && ./configure --host="$(CROSS_COMPILE)" CC="$(CROSS_COMPILE)-gcc" CFLAGS="$(CCFLAGS)" LDFLAGS="-L$(LDPATH)" --enable-shared --disable-static --disable-manual --disable-libcurl-option --with-openssl --with-zlib --disable-ipv6 --disable-dict --disable-file --disable-ftp --disable-gopher --disable-imap --disable-mqtt --disable-pop3 --disable-rtsp --disable-smtp --disable-telnet --disable-tftp --disable-smb --with-ca-bundle=/usr/local/cacert.pem
	make -C "$(TEMPORARY_DIR)/curl"
	cp -f $(TEMPORARY_DIR)/curl/src/.libs/curl $(FIRMWARE_DIR)/rootfs/bin
	ln -fs ../../bin/curl $(FIRMWARE_DIR)/rootfs/usr/bin/curl
	cp -fP $(TEMPORARY_DIR)/curl/lib/.libs/libcurl.so* $(FIRMWARE_DIR)/rootfs/thirdlib
	cp -fP $(TEMPORARY_DIR)/curl/lib/.libs/libcurl.so* $(LDPATH)

chmod:
	# all
	-find $(FIRMWARE_DIR) -type f -exec chmod 644 {} \;
	-find $(FIRMWARE_DIR) -type d -exec chmod 755 {} \;
	# app
	-find $(FIRMWARE_DIR)/app/bin -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/app/drv -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/app/lib -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/app/sbin -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/app/www/cgi-bin -type f -exec chmod 755 {} \;
	# rootfs
	-find $(FIRMWARE_DIR)/rootfs/bin -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/rootfs/etc/init.d -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/rootfs/lib -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/rootfs/sbin -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/rootfs/thirdlib -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/rootfs/usr/bin -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/rootfs/usr/sbin -type f -exec chmod 755 {} \;
	-find $(FIRMWARE_DIR)/rootfs/usr/share/udhcpc -type f -exec chmod 755 {} \;

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
	-make -C "$(TEMPORARY_DIR)/zlib" clean
	-make -C "$(TEMPORARY_DIR)/openssl" clean
	-make -C "$(TEMPORARY_DIR)/curl" clean
	-rm -rf $(TEMPORARY_DIR)/*
	-rm -f $(FIRMWARE_FILE)

mkdirs: clean
	@[ -n "$(FIRMWARE_VER)" ] || { echo -e "\n\033[31mNo version specified! Building terminated.\033[0m\nUsage: make FIRMWARE_VER=\"x.y.z\"\n"; exit 1; }
	-mkdir -p $(TEMPORARY_DIR)
	cp -rf $(FIRMWARE_SRC) $(FIRMWARE_DIR)
	find $(FIRMWARE_DIR) -type f -name ".gitkeep" -exec rm -f {} \;
ifeq ("$(BRANCH)", "main")
	$(eval FIRMWARE_VERB = $(FIRMWARE_VER))
else
	$(eval FIRMWARE_VERB = $(FIRMWARE_VER)-$(BRANCH))
endif
	echo $(FIRMWARE_VERB) > $(FIRMWARE_DIR)/app/share/.version

install-libs:
	-cp -arf $(FIRMWARE_DIR)/app/lib/. $(LDPATH)
	-cp -arf $(FIRMWARE_DIR)/rootfs/lib/. $(LDPATH)
	-cp -arf $(FIRMWARE_DIR)/rootfs/thirdlib/. $(LDPATH)

