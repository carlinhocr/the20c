#!/usr/bin/env python3
"""bin2lz4.py - comprime pantallas .BIN de la 20c al formato .LZ4 de lib_lz4.asm

Uso:  python3 bin2lz4.py BERDYX.BIN OSO.BIN ...      (deja BERDYX.LZ4, OSO.LZ4, ...)
Necesita:  pip install lz4

Formato:  [largo original lo,hi] [largo del bloque lo,hi] [bloque LZ4 raw]
Verifica que cada archivo descomprima igual al original y que entre en
$1000-$3FFF (12 KB) y el comprimido en $4000-$6FFF.
"""
import os, sys
import lz4.block

MAX_RAW = 0x3000
MAX_PACKED = 0x3000

def pack(raw: bytes) -> bytes:
    blk = lz4.block.compress(raw, mode='high_compression', compression=12, store_size=False)
    return len(raw).to_bytes(2, 'little') + len(blk).to_bytes(2, 'little') + blk

def main(paths):
    for p in paths:
        raw = open(p, 'rb').read()
        if not raw.endswith(b'\x1b[0m\x00'):
            print(f'{p}: no termina en ESC[0m,00 (la 20c lo rechazaria)'); continue
        if len(raw) >= MAX_RAW:
            print(f'{p}: {len(raw)} bytes, no entra en $1000-$3FFF'); continue
        out = pack(raw)
        assert lz4.block.decompress(out[4:], uncompressed_size=len(raw)) == raw
        if len(out) > MAX_PACKED:
            print(f'{p}: comprimido {len(out)} bytes, no entra en $4000-$6FFF'); continue
        dst = os.path.splitext(p)[0] + '.LZ4'
        open(dst, 'wb').write(out)
        print(f'{os.path.basename(p):14s} {len(raw):6d} -> {len(out):5d} bytes ({len(out)/len(raw):.0%})  {os.path.basename(dst)}')

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(1)
    main(sys.argv[1:])
