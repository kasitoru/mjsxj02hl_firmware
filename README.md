# mjsxj02hl_firmware

[![Donate](https://img.shields.io/badge/donate-YooMoney-blueviolet.svg)](https://yoomoney.ru/to/4100110221014297)

Build tools for mjsxj02hl firmware

**Attention! This firmware is no longer supported by the author. We recommend using [OpenIPC](https://github.com/OpenIPC/device-mjsxj02hl).**


## Dependencies

```bash
sudo apt install u-boot-tools dbus
pip install click
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
