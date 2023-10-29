# mjsxj02hl_firmware

[![Donate](https://img.shields.io/badge/donate-YooMoney-blueviolet.svg)](https://yoomoney.ru/to/4100110221014297)

Build tools for mjsxj02hl firmware

**Attention! This firmware is no longer supported by the author. We recommend using [OpenIPC](https://github.com/OpenIPC/device-mjsxj02hl).**

## Preparation of tools

1. Install dependencies:

```bash
sudo apt install git cmake u-boot-tools dbus python3-pip
pip install click
```

2. Install Hi3518Ev300 toolchain:

```bash
tar -zxf arm-himix100-linux.tgz
sudo ./arm-himix100-linux.install
gnome-session-quit
```

3. Creating a directory for shared libraries and setting permissions:

```bash
sudo mkdir -p /opt/hisi-linux/x86-arm/arm-himix100-linux/target/usr/app/lib
sudo chmod 777 /opt/hisi-linux/x86-arm/arm-himix100-linux/target/usr/app/lib
```

4. Clone the repository:

```bash
git clone https://github.com/kasitoru/mjsxj02hl_firmware
cd mjsxj02hl_firmware
```

## Usage

### Build firmware:
```bash
make FIRMWARE_VER=x.y.z
```

### Unpack image:
```bash
make FIRMWARE_FILE=image.bin FIRMWARE_DIR=unpkg unpack
```

or (defaults input file `demo_hlc6.bin` and output directory `temp/firmware`):

```bash
make unpack
```

### Pack image:
```bash
make FIRMWARE_DIR=unpkg FIRMWARE_FILE=image.bin pack
```

or (defaults input directory `temp/firmware` and output file `demo_hlc6.bin`):

```bash
make pack
```
