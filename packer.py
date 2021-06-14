#!/usr/bin/env python
# coding=utf-8

import os
import subprocess
import click
import tempfile

@click.command()
@click.argument('kernel', default="kernel.bin", type=click.Path(exists=True))
@click.argument('rootfs', default="rootfs.bin", type=click.Path(exists=True))
@click.argument('app', default="app.bin", type=click.Path(exists=True))
@click.argument('kback', default="kback.bin", type=click.Path(exists=True))
@click.argument('outfile', default="demo_hlc6.bin")

def cli(kernel, rootfs, app, kback, outfile):
    dic = [
        ("kernel", 0x1f0000, click.format_filename(kernel)),
        ("rootfs", 0x3d0000, click.format_filename(rootfs)),
        ("app", 0x3d0000, click.format_filename(app)),
        ("kback", 0x1f0000, click.format_filename(kback)),
    ]
    
    outfile = click.format_filename(outfile)

    fullflash = tempfile.NamedTemporaryFile(delete=False)
    for name, size, filename in dic:
        buffersize = os.path.getsize(filename)
        if size < buffersize:
            click.echo('Size mismatch. The provided {} has a '
                       'size of {}, but it need to have the '
                       'size {}. Please try to free some '
                       'space!'.format(name,
                                       buffersize,
                                       size))
            return
        part = open(filename, "rb")
        buffer = part.read(size)
        fullflash.write(buffer)
        if buffersize < size:
            padsize = size - buffersize
            for x in range(0, padsize):
                fullflash.write(bytearray.fromhex('00'))
    fullflash.close()

    cmd = "mkimage -A ARM -O linux -T firmware -C none -a 0 -e 0 -n hlc6 -d " + fullflash.name + " " + outfile
    subprocess.check_output(cmd, shell=True)
    os.remove(fullflash.name)
    click.echo('Firmware {} was successfully created!'.format(outfile))

if __name__ == '__main__':
    cli()
    pass

