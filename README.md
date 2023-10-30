# mjsxj02hl_firmware

[![Donate](https://img.shields.io/badge/donate-YooMoney-blueviolet.svg)](https://yoomoney.ru/to/4100110221014297)

Build tools for mjsxj02hl firmware

**Attention! This firmware is no longer supported by the author. We recommend using [OpenIPC](https://github.com/OpenIPC/device-mjsxj02hl).**

## Preparation

1. Install dependencies:

```bash
sudo apt install git cmake lib32z1 lib32stdc++6 u-boot-tools dbus python3-pip dos2unix
pip3 install click
```

2. Install Hi3518Ev300 toolchain:

```bash
sudo mkdir /opt/hisi-linux
sudo chmod 777 /opt/hisi-linux
tar -zxf arm-himix100-linux.tgz
source ./arm-himix100-linux.install
mkdir -p /opt/hisi-linux/x86-arm/arm-himix100-linux/target/usr/app/lib
gnome-session-quit
```

## Usage

Clone the repository:

```bash
git clone https://github.com/kasitoru/mjsxj02hl_firmware
cd mjsxj02hl_firmware
```

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
