# mjsxj02hl_firmware
Build tools for mjsxj02hl firmware

## Dependencies

```bash
sudo apt install u-boot-tools dbus
pip install click
```

## Usage

### Unpack image:
```bash
make INPUT_FILE=image.bin OUTPUT_DIR=unpkg unpack
```

or (defaults input file `demo_hlc6.bin` and output directory `unpacked`):

```bash
make unpack
```

### Pack image:
```bash
make INPUT_DIR=unpkg OUTPUT_FILE=image.bin all
```

or (defaults input directory `unpacked` and output file `demo_hlc6.bin`):

```bash
make all
```
