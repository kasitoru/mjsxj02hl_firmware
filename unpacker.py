#!/usr/bin/env python
# coding=utf-8

import os
import click

@click.command()
@click.argument('inputfile', default="demo_hlc6.bin", type=click.Path(exists=True))
@click.argument('outputdir', default="unpack")

def cli(inputfile, outputdir):
    dic = [
        ("kernel", 0x1f0000),
        ("rootfs", 0x3d0000),
        ("app", 0x3d0000),
        ("kback", 0x1f0000)
    ]
    
    inputfile = click.format_filename(inputfile)
    outputdir = click.format_filename(outputdir)
    
    if not os.path.isdir(outputdir):
        os.makedirs(outputdir)

    fullflash = open(inputfile, 'rb')
    fullflash.seek(64)
    for name, size in dic:
        filename = os.path.join(outputdir, name + ".bin")
        buffer = fullflash.read(size)
        f = open(filename, "wb")
        f.write(buffer)
        f.close()
    fullflash.close()

if __name__ == '__main__':
    cli()
    pass

