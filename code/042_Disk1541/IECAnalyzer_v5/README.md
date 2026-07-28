# Commodore IEC Analyzer for Saleae Logic 2

A custom **Low Level Analyzer** (C++) that decodes the **Commodore IEC serial bus**
— the three-wire bus (ATN / CLK / DATA) used between a C64 / VIC-20 and a 1541
disk drive (and compatible peripherals).

It turns raw logic captures into readable bytes and labels them as bus commands
(LISTEN, TALK, OPEN, CLOSE, …) or data, detects the **EOI** "last byte" signal,
and exports everything to CSV.

---

## What it decodes

- **Byte framing** from the CLK/DATA handshake: 8 bits, **LSB first**, each bit
  sampled on a **CLK rising edge**.
- **Command vs. data phase** from ATN: a byte sent while ATN is asserted is a
  command; otherwise it is data.
- **The command-byte map:**

  | Byte range | Meaning |
  |------------|---------|
  | `$20`–`$3E` | LISTEN device *(dev = byte − $20)* |
  | `$3F` | UNLISTEN |
  | `$40`–`$5E` | TALK device *(dev = byte − $40)* |
  | `$5F` | UNTALK |
  | `$60`–`$6F` | secondary **DATA** channel *(ch = byte − $60)* |
  | `$E0`–`$EF` | secondary **CLOSE** channel *(ch = byte − $E0)* |
  | `$F0`–`$FF` | secondary **OPEN** channel *(ch = byte − $F0)* |

  *(Channel 15 is the drive's DOS command/status channel.)*
- **EOI** ("End Or Identify", the last-byte marker): flagged when an over-long
  idle gap precedes a byte.
- **Data bytes** are shown in your chosen base plus the printable ASCII/PETSCII
  character when applicable.

Results appear as bubbles on the DATA row, as rows in the Logic 2 data table
(with `value`, `phase`, `eoi`, `device`/`channel` fields, searchable), and via
**Export → CSV** (`Time, Phase, Type, Value, ASCII, EOI`). Each sampled bit gets
an up-arrow marker on CLK; an EOI byte gets a start marker on DATA.

---

## The wire convention (important)

All three IEC lines are **active-low, open-collector, pulled up**:

- *Released* = nobody pulls = **HIGH** (idle / false).
- *Asserted* = someone pulls = **LOW** (true / attention).

On the **bus wire itself** the data bit maps **directly**: a `1` bit is DATA
**released HIGH**, a `0` bit is DATA **pulled LOW**. ATN **LOW** = command phase,
**HIGH** = data phase. This analyzer expects you to probe the **bus wire**, so by
default it reads levels exactly as above — no inversion.

> The 6522 VIA *register* side (PB0/PB3, etc.) is the **complement** of the wire,
> because the open-collector hardware inverts between wire and port pin. If you
> tap the VIA/CIA port pins or sit behind an inverting buffer instead of the bus
> wire, enable **"Signals inverted"** in the settings and every line is flipped
> back for you.

Connect one probe to each of ATN, CLK and DATA (plus ground).

---

## Settings

| Setting | Default | Notes |
|---------|---------|-------|
| **ATN / CLK / DATA** | — | One channel each (must be distinct). |
| **Signals inverted** | off | Enable only if probing an inverted/register side rather than the bus wire. |

There are no timing thresholds to set — framing follows the bus **handshake**,
not the clock rate (see below).

### How framing works (handshake, not timing)

Framing follows the bus **handshake**, not the clock rate. A tight 6502 driver
clocks bytes back-to-back, so the gap between bytes is no bigger than the gap
between bits - there is no pause to key on, and any timing-threshold approach is
fundamentally impossible for this bus.

Per byte, on the bus wire (active-low: released = HIGH, asserted = LOW):

- **RTS** - talker releases CLK, so CLK rises while DATA is still held LOW.
- **RFD** - listener releases DATA, so **DATA rises while CLK is HIGH**.
- **8 bits** - talker sets DATA while CLK is LOW, then releases CLK; each CLK
  rising edge is a sample point (LSB first, wire HIGH = bit 1).
- **ACK** - listener pulls DATA LOW.

The decoder classifies every **CLK-high window** (each CLK rising edge through
the following falling edge):

| DATA during the window | meaning |
|---|---|
| transitions | **handshake window** (the RTS/RFD ready phase) |
| steady | **bit window**, value = the DATA level |

A byte is then just *a handshake window followed by 8 consecutive bit windows*.
Every new handshake window re-arms and discards any partial bit group, so the
decoder is self-synchronising: it cannot drift, and it makes no assumption about
how many CLK edges a byte occupies.

That re-arming matters more than it looks. When a transaction ends, the
controller releases CLK **before** it releases DATA, so the final CLK-high
window stays open for the entire idle period - seconds - and inevitably contains
DATA activity. It therefore looks exactly like a ready phase. The next window is
the real RTS of the following transaction, which re-arms and discards the stale
one. Without that, a decoder latches onto the idle window and reads the RTS edge
as bit 0, turning the first byte of a transaction from `$28` (LISTEN device 8)
into `$50` (TALK device 16) while every subsequent byte still decodes correctly.

**EOI** ("last byte") is structural, not a duration: the talker stalls and the
listener answers by pulsing DATA LOW inside the ready phase, so the arming
window carries extra DATA edges instead of the single RFD rise. Only data-phase
bytes (ATN released) can be EOI; command bytes never are.

## Build

Requires CMake ≥ 3.13 and a C++11 compiler. The build fetches the Saleae
AnalyzerSDK automatically (needs network on first configure).

```sh
cmake -B build
cmake --build build
```

The plugin is written to **`build/Analyzers/`**:

- Linux: `libIECAnalyzer.so`
- macOS: `libIECAnalyzer.dylib`
- Windows: `IECAnalyzer.dll` *(use the "x64 Native Tools" prompt / a 64-bit toolchain)*

Build it on the **same OS** you run Logic 2 on — a compiled analyzer is
platform-specific.

### Verifying the decoder (optional)

The decode logic lives in one header, `src/IECDecodeCore.h`, so it can be run
outside Logic 2. There are two test programs, both driving the exact same core through a mock
channel. `test/test_framing.cpp` is self-contained and covers the handshake
cases (including the idle-window regression above); `test/test_decode_csv.cpp`
replays a real logic-analyzer CSV export:

```sh
cd test
SDK=../build/_deps/analyzersdk-src/include
g++ -std=c++11 -I$SDK test_framing.cpp -o tf && ./tf
g++ -std=c++11 -I$SDK test_decode_csv.cpp -o t && ./t your_capture.csv
```

`test_decode_csv.cpp` expects CSV columns `Time,ATN,CLK,DATA[,...]`.

### Checking a capture without Logic 2

`tools/sal_decode.py` reads a `.sal` capture directly and applies the same
handshake framing, so you can see what a capture really contains regardless of
which build Logic 2 happens to have loaded:

```sh
python3 tools/sal_decode.py capture.sal            # full byte listing
python3 tools/sal_decode.py capture.sal --quiet     # just the payload text
python3 tools/sal_decode.py capture.sal --inverted  # probing VIA pins
```

It needs no dependencies beyond Python 3. The `.sal` internal layout is not
documented by Saleae, so if a future Logic 2 release changes it, export CSV and
use `test_decode_csv.cpp` instead.

Point `-I` at any copy of the Saleae AnalyzerSDK `include/` (the build fetches one
under `build/_deps/analyzersdk-src/include`). The CSV must have the bus-wire
ATN/CLK/DATA in columns 2–4 (1 = HIGH/released, 0 = LOW/asserted).

## Install in Logic 2

1. Logic 2 → **Edit → Preferences** (or the gear) → find the **Custom Low Level
   Analyzers** directory setting.
2. Point it at your `build/Analyzers/` folder (or copy the built library into the
   folder it already lists).
3. **Fully quit and relaunch Logic 2.** It loads analyzer libraries once at
   startup and keeps them in memory - removing and re-adding the analyzer
   instance does *not* pick up a rebuilt library.
4. Add an analyzer and choose **"Commodore IEC v5"**, then assign ATN, CLK and
   DATA. The version suffix in the name is deliberate: it tells you at a glance
   which build Logic 2 actually loaded.

## Reading the payload as text

Each byte gets its own bubble on the timeline, so a filename or file contents
appears as a run of single-character bubbles rather than a phrase. To read it as
text, open the **data table** (bottom panel) and click **Terminal** at its
top-right: the analyzer streams data-phase bytes there as a continuous stream,
so a transfer shows up as e.g.

```
0:READFILE,P,RHola que archivito Eh!@0:WRITEFILE,P,WHola que archivito Eh!
```

Command bytes (LISTEN/TALK/OPEN/UNLISTEN and secondary addresses) are
deliberately kept out of the terminal stream so they don't break up the text;
they remain visible on the timeline and in the data table.

## Try it without hardware

The plugin ships a simulation generator. With no device attached, add the
**Commodore IEC** analyzer and start a capture using **simulated data**: it
produces a repeating, simplified *read-file* exchange — `LISTEN 8`, `OPEN 0`, a
short filename, `UNLISTEN`, `TALK 8`, a `DATA` secondary, the bytes `A B C` with
EOI on `C`, `UNTALK`, then `CLOSE`/`UNLISTEN` — so you can confirm decoding,
bubbles, the data table and EOI before touching a real bus.

---

## Notes & limitations

- **Mid-stream capture start.** The decoder re-arms on every handshake window,
  so it re-syncs automatically; only a byte already in progress when the capture
  begins is skipped.
- **EOI is structural.** It is detected from the listener's DATA-low blip in the
  ready window (before CLK first falls) on a data-phase byte, not from any
  absolute pause length — so it is robust to variable bit timing.
- **Probe the bus wire.** Assign ATN/CLK/DATA to the actual bus lines (idle
  HIGH, asserted LOW). If you instead probe the VIA/CIA register pins (which the
  open-collector hardware inverts), enable **"Signals inverted."**
- **The simulation is simplified.** It reproduces the byte handshake, the
  command/data phases and the EOI pause, but does **not** model the electrical
  bus *turnaround* (which end physically drives CLK during a read) — that detail
  does not change how the bytes decode.
- This analyzer reads the bus; it does not drive or ACK anything.

Protocol behaviour follows the accompanying IEC / 1541 protocol guide
(active-low wire rules, the LSB-first rising-edge handshake, the command map,
and the EOI pause).
