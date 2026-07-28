#!/usr/bin/env python3
"""
Decode a Commodore IEC transaction straight out of a Saleae .sal capture.

This is a ground-truth checker: it reads the .sal itself and applies the same
handshake framing as the C++ analyzer, so you can confirm what a capture really
contains without involving Logic 2 (useful when you are not sure which build of
the plugin Logic 2 has loaded).

    python3 sal_decode.py capture.sal
    python3 sal_decode.py capture.sal --atn 0 --clk 1 --data 2
    python3 sal_decode.py capture.sal --inverted     # probing VIA pins, not the bus

Note: the .sal internal layout is not documented by Saleae and may change
between Logic 2 releases. The reader below was reverse-engineered and verified
against CSV exports of the same captures; if a future Logic 2 breaks it, export
CSV instead and use test/test_decode_csv.cpp.
"""

import argparse
import bisect
import json
import struct
import sys
import zipfile

# --------------------------------------------------------------------------- #
# .sal reading
# --------------------------------------------------------------------------- #
#
# Each digital-N.bin holds:
#   0   char[8] "<SALEAE>"
#   8   uint32  version (3 observed)
#   12  uint32  type    (100 observed)
#   16  uint8   initial state flag
#   17  double  sample rate (Hz)
#   25  uint64  capture start, unix ms
#   33  double  fractional ms
#   43  uint64  chunk count
#   51  chunks
#
# and each chunk:
#   uint64 begin sample, uint64 end sample, uint16 level at begin,
#   uint64 payload length, payload
#
# The payload is a run-length list. Each run is a big-endian varint whose FIRST
# byte carries 6 data bits with bit 6 as its continuation flag, while any
# following bytes carry 7 data bits with bit 7 as the flag. The stored value is
# one less than the run length, and runs alternate the line level starting from
# the chunk's level.


def _read_runs(payload):
    runs = []
    i = 0
    n = len(payload)
    while i < n:
        b = payload[i]
        val = b & 0x3F
        cont = b & 0x40
        i += 1
        while cont:
            b = payload[i]
            val = (val << 7) | (b & 0x7F)
            cont = b & 0x80
            i += 1
        runs.append(val + 1)
    return runs


def parse_digital(blob):
    """Return (sample_rate, initial_level, [transition samples])."""
    if blob[:8] != b"<SALEAE>":
        raise ValueError("not a Saleae digital stream")
    sample_rate = struct.unpack_from("<d", blob, 17)[0]
    chunk_count = struct.unpack_from("<Q", blob, 43)[0]
    off = 51
    transitions = []
    initial = None
    for _ in range(chunk_count):
        begin, end = struct.unpack_from("<QQ", blob, off)
        level = struct.unpack_from("<H", blob, off + 16)[0]
        length = struct.unpack_from("<Q", blob, off + 18)[0]
        payload = blob[off + 26 : off + 26 + length]
        off += 26 + length
        if initial is None:
            initial = level
        t = begin
        for run in _read_runs(payload):
            t += run
            transitions.append(t)
    return sample_rate, (initial or 0), transitions


class Signal:
    def __init__(self, sample_rate, initial, transitions, inverted=False):
        self.sample_rate = sample_rate
        self.initial = initial ^ (1 if inverted else 0)
        self.tr = transitions

    def level(self, sample):
        i = bisect.bisect_right(self.tr, sample)
        return self.initial ^ (i & 1)

    def edges_in(self, lo, hi):
        """Transitions strictly inside (lo, hi)."""
        i = bisect.bisect_right(self.tr, lo)
        out = []
        while i < len(self.tr) and self.tr[i] < hi:
            out.append(self.tr[i])
            i += 1
        return out


def load_sal(path, atn_ch, clk_ch, data_ch, inverted):
    with zipfile.ZipFile(path) as z:
        names = set(z.namelist())
        meta = json.loads(z.read("meta.json")) if "meta.json" in names else {}

        def channel(idx):
            fn = "digital-%d.bin" % idx
            if fn not in names:
                raise SystemExit("%s has no %s" % (path, fn))
            return Signal(*parse_digital(z.read(fn)), inverted=inverted)

        return channel(atn_ch), channel(clk_ch), channel(data_ch), meta


# --------------------------------------------------------------------------- #
# IEC framing - mirrors src/IECDecodeCore.h
# --------------------------------------------------------------------------- #
def decode(atn, clk, data):
    """Yield (value, is_command, is_eoi, sample) per byte."""
    rises = [t for t in clk.tr if clk.level(t) == 1]
    out = []
    armed = False
    nbits = 0
    byte = 0
    eoi_pending = False
    is_cmd = False
    start = 0

    for r in rises:
        j = bisect.bisect_right(clk.tr, r)
        if j >= len(clk.tr):
            break
        fall = clk.tr[j]
        edges = data.edges_in(r, fall)

        if edges:
            # Ready (handshake) window: re-arm, dropping any partial byte.
            armed, nbits, byte = True, 0, 0
            eoi_pending = len(edges) >= 2
            continue
        if not armed:
            continue

        if data.level(r):
            byte |= 1 << nbits          # LSB first, wire HIGH = 1
        if nbits == 0:
            is_cmd = atn.level(r) == 0  # ATN LOW = command phase
            start = r
        nbits += 1
        if nbits == 8:
            out.append((byte, is_cmd, eoi_pending and not is_cmd, start))
            armed, nbits, byte = False, 0, 0
    return out


def describe(value, is_cmd):
    if not is_cmd:
        return "'%s'" % chr(value) if 32 <= value < 127 else ""
    if 0x20 <= value <= 0x3E:
        return "LISTEN device %d" % (value - 0x20)
    if value == 0x3F:
        return "UNLISTEN"
    if 0x40 <= value <= 0x5E:
        return "TALK device %d" % (value - 0x40)
    if value == 0x5F:
        return "UNTALK"
    if 0x60 <= value <= 0x6F:
        return "DATA channel %d" % (value - 0x60)
    if 0xE0 <= value <= 0xEF:
        return "CLOSE channel %d" % (value - 0xE0)
    if 0xF0 <= value <= 0xFF:
        return "OPEN channel %d" % (value - 0xF0)
    return ""


def main():
    ap = argparse.ArgumentParser(description="Decode Commodore IEC traffic from a .sal capture")
    ap.add_argument("capture")
    ap.add_argument("--atn", type=int, default=0, help="ATN channel index (default 0)")
    ap.add_argument("--clk", type=int, default=1, help="CLK channel index (default 1)")
    ap.add_argument("--data", type=int, default=2, help="DATA channel index (default 2)")
    ap.add_argument("--inverted", action="store_true", help="probing inverted/VIA pins, not the bus wire")
    ap.add_argument("--quiet", action="store_true", help="only print the extracted payload text")
    args = ap.parse_args()

    atn, clk, data, meta = load_sal(args.capture, args.atn, args.clk, args.data, args.inverted)
    rows = decode(atn, clk, data)

    if not args.quiet:
        names = {}
        for row in meta.get("data", {}).get("rowsSettings", []):
            ch = row.get("channel", {})
            if ch.get("type") == "Digital":
                names[ch.get("deviceChannel")] = row.get("name")
        if names:
            print("channels: ATN=%s(%d) CLK=%s(%d) DATA=%s(%d)"
                  % (names.get(args.atn, "?"), args.atn,
                     names.get(args.clk, "?"), args.clk,
                     names.get(args.data, "?"), args.data))
        print("sample rate: %.0f Hz    bytes decoded: %d\n" % (clk.sample_rate, len(rows)))
        print("    time(s)   phase  byte  meaning")
        for value, is_cmd, eoi, sample in rows:
            print("  %10.6f  %-5s  $%02X%s  %s"
                  % (sample / clk.sample_rate, "CMD" if is_cmd else "data", value,
                     " EOI" if eoi else "    ", describe(value, is_cmd)))
        print()

    text = "".join(chr(v) if (32 <= v < 127) else "." for v, c, e, s in rows if not c)
    print("payload text: %s" % text)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:  # e.g. piped into `head`
        try:
            sys.stdout.close()
        except Exception:
            pass
