
;===============================================================================
; IEC BUS BIT MASKS
;===============================================================================
; These masks correspond to the VIA Port B pin assignments described above.

; --- Output pins (directly control bus lines) ---
DATA_OUT    = %00000001         ; PB0 - DATA output (1 = pull low, 0 = release)
CLK_OUT     = %00000010         ; PB1 - CLK  output (1 = pull low, 0 = release)
ATN_OUT     = %00000100         ; PB2 - ATN  output (1 = pull low, 0 = release)

; --- Input pins (read the actual bus state) ---
DATA_IN     = %00001000         ; PB3 - DATA input (1 = line is low/asserted)
CLK_IN      = %00010000         ; PB4 - CLK  input (1 = line is low/asserted)

; --- Combined masks ---
ALL_OUTPUTS = DATA_OUT | CLK_OUT | ATN_OUT  ; = %00000111
ALL_RELEASE = %00000000         ; All outputs released (lines go high via pull-ups)



;===============================================================================
; IEC DEVICE AND COMMAND CONSTANTS
;===============================================================================
; These are the standard IEC bus command bytes. Device 8 is the default
; for the first Commodore 1541 disk drive.

DEVICE_NUM  = 8                 ; Default 1541 device number
DEV_LISTEN  = $20 + DEVICE_NUM ; $28 - LISTEN command for device 8
DEV_TALK    = $40 + DEVICE_NUM ; $48 - TALK command for device 8
CMD_UNLISTEN= $3F               ; Universal UNLISTEN (all devices stop listening)
CMD_UNTALK  = $5F               ; Universal UNTALK  (talker stops talking)

; Secondary address flags (OR'd with channel number 0-15):
SA_OPEN     = $F0               ; Secondary address for OPEN  (+ channel)
SA_CLOSE    = $E0               ; Secondary address for CLOSE (+ channel)
SA_DATA     = $60               ; Secondary address for DATA  (+ channel)

; Channel numbers:
CHAN_LOAD    = 0                 ; Channel 0 = LOAD (read file)
CHAN_SAVE    = 1                 ; Channel 1 = SAVE (write file)
CHAN_CMD     = 15                ; Channel 15 = command/status channel

; Demo switches:
; DEMO 0 in MAIN formats a disk, which ERASES it. Off by default for safety.
; Set to 1 and re-assemble to run the format demo.
ENABLE_FORMAT_DEMO = 0


;===============================================================================
; PROTOCOL TIMEOUTS
;===============================================================================
; Stated in real time, not in loop iterations. See the note in the version
; history for why. Change RFD_TIMEOUT_MS and nothing else.

RFD_CHUNK      = 50000          ; T2 count for one chunk = 50 ms at 1 MHz
RFD_CHUNK_MS   = 50             ; ...the same figure in milliseconds
RFD_TIMEOUT_MS = 3000           ; ~2.4x the 1.2353 s measured on a 1571
RFD_OUTER      = RFD_TIMEOUT_MS / RFD_CHUNK_MS   ; = 60 chunks
                                ; If your assembler dislikes '/' in an equate,
                                ; just write RFD_OUTER = 60. RFD_OUTER is held
                                ; in one byte, so the ceiling is 255 x 50 ms
                                ; = 12.75 s.

; --- Receive-side budgets (v26) ---
RTS_TIMEOUT_MS = 3000           ; talker "ready to send": CLK released. A drive
                                ; may have to read a sector between bytes, and
                                ; a measured SD2IEC directory lookup took
                                ; 636 ms, so this needs the same headroom as
                                ; RFD_TIMEOUT_MS.
RTS_OUTER      = RTS_TIMEOUT_MS / RFD_CHUNK_MS

CLKLOW_TIMEOUT_MS = 500         ; after our EOI acknowledge, how long the
                                ; talker gets to pull CLK low and start bits
CLKLOW_OUTER   = CLKLOW_TIMEOUT_MS / RFD_CHUNK_MS

DEVICE_TIMEOUT_MS = 250         ; device-not-present: a REAL timeout, absence
                                ; can only be detected by time passing
DEVICE_OUTER   = DEVICE_TIMEOUT_MS / RFD_CHUNK_MS

ACK_TIMEOUT_MS = 250            ; watchdog on the listener's byte acknowledge
ACK_OUTER      = ACK_TIMEOUT_MS / RFD_CHUNK_MS

TURN_TIMEOUT_MS = 3000          ; watchdog on the device taking CLK after the
                                ; turnaround; it may have to read a sector
                                ; before it can offer the first byte
TURN_OUTER     = TURN_TIMEOUT_MS / RFD_CHUNK_MS

EOI_WINDOW     = 256            ; T2 count = ~256 us at 1 MHz. THE protocol
                                ; constant for EOI: if the talker has not
                                ; pulled CLK low within this window after our
                                ; RFD, the byte coming is the last one.

; NOTE ON MAKING THIS LONGER: a genuinely absent device is detected earlier,
; by the .atn_wait_device check that watches for DATA going LOW at all. So
; lengthening the RFD window costs nothing in error detection - the two
; failures are distinguishable. This is why the stock KERNAL waits essentially
; forever at this point. If you write to a nearly-full disk, the BAM search
; takes longer than the 1.2353 s measured here; raise RFD_TIMEOUT_MS rather
; than trying to shave it.


;===============================================================================
; FILENAME STRINGS
;===============================================================================
; These are null-terminated filename strings used by the demo.
;
; Format: "drivenumber:filename,type,mode"
;   Drive number: 0 (only option on single-drive 1541)
;   Type: P = Program (PRG), S = Sequential (SEQ), U = User (USR)
;   Mode: R = Read, W = Write
;
; The "@" prefix means "save with replace" (overwrite existing file).

FNAME_READ:
            .byte "0:READFILE,P,R", $00  ; Open TESTFILE as PRG for reading

FNAME_WRITE:
            .byte "@0:OUTFILE,P,W", $00  ; Write OUTFILE as PRG (overwrite if exists)

FNAME_WRITE_RAM:
            .byte "@0:WRITEFILE,P,W", $00  ; Write WRITEFILE as PRG (overwrite if exists)

FNAME_WRITE_ROM_ASCII:
            .byte "@0:WRITEROM,P,W", $00  ; Write WRITEFILE as PRG (overwrite if exists)            

;-------------------------------------------------------------------------------
; DOS COMMAND STRINGS (sent to the command channel, #15)
;-------------------------------------------------------------------------------
; Format ("NEW") command. Syntax: N<drive>:<disk name>,<2-char id>
;   - With an ID  -> full format (writes all sector headers; slow, ~80s).
;   - Without ID  -> quick directory clear (only on an already-formatted disk).
; This one does a full format, naming the disk "NEWDISK" with ID "01".

FMT_COMMAND:
            .byte "N0:NEWDISK,01", $00   ; full format, disk name NEWDISK, id 01

; A few other ready-to-use DOS command strings (not used by the demo, shown
; as examples - point ZP_PTR at one and call IEC_SEND_COMMAND):
FMT_QUICK:
            .byte "N0:NEWDISK", $00      ; quick "new" (no id) - clears directory
CMD_SCRATCH:
            .byte "S0:OLDFILE", $00      ; delete the file OLDFILE
CMD_VALIDATE:
            .byte "V0", $00              ; validate (rebuild block-availability map)
CMD_INIT:
            .byte "I0", $00              ; initialize (re-read BAM after disk swap)



messageIECStart:
  .asciiz "Inicializando Rutinas IEC"  

messageRunningMainDemo:
  .asciiz "Empezando Demo"  

messageEndMainDemo:
  .asciiz "Terminando Demo" 

messageRunningAsciiDemo:
  .asciiz "Empezando ASCII Demo"  



la20cAscii:
  .ascii "                                    LA 20c               " ; 58 bytes (57+null char)
  .ascii "" ;1 byte  
  .ascii "                                 OSOLABS.TECH            " ;58
  .ascii "" ;1 byte  
  .ascii "                    ┌─┴─┴─┴─┴─┴─┬─┴─┴─┴─┴─┴─┬─┴─┴─┴─┴─┴─┐" ;58
  .ascii "                    │  4F53 4F  │    RAM    │    RAM    ├" ;58
  .ascii "                    │  ■■■■ ■■  │           │           ├" ;58
  .ascii "                    │  Address  │    ▐░▌    │    ▐▒▌    ├" ;58
  .ascii "                    │   Data    │           │           ├" ;58
  .ascii "                    │  Display  │    ROM    │    ROM    ├" ;58 ;466 bytes
  .ascii "                    ├───────────├───────────├───────────┤───────┐"
  .ascii "                    │    BUS    ▌    BUS    ▌    BUS    │ D P A │"
  .ascii "                    │           ▌           ▌           │ U R N │"
  .ascii "                    │  Address  ▌  Address  ▌  Address  │ I O L │"
  .ascii "                    │   Data    ▌   Data    ▌   Data    │ N T Y │"
  .ascii "                    │ Expansion ▌ Expansion ▌ Expansion │ O . Z │"
  .ascii "                    ├───────────┬───────────┬───────────┤───────┘"
  .ascii "                    │ VIA 6522  │   GLUE    │  CPU 6502 ├"
  .ascii "                    │           │   LOGIC   │   .....   ├"
  .ascii "                    │   ....    │....  .... │   ▓▓▓▓▓   ├"
  .ascii "                    │   ░░░░    │))))  (((( │   ·····   ├"
  .ascii "                    │   ····    │····  ···· │           ├"
  .ascii "                    ├───────────┬───────────┬───────────┤"
  .ascii "                    │  I/0 LCD  │   POWER   │   CLOCK   ├"
  .ascii "                    │           │   module  │    OSO    ├"
  .ascii "                    │ ▄▄▄▄▄▄▄▄  │  5v  ♥    │           ├"
  .ascii "                    │ █berdyx█  │  9v  ♦    │           ├"
  .ascii "                    │ ▀▀▀▀▀▀▀▀  │ 12v  ♣    │        ☻  ├"
  .ascii "                    └───────────┴───────────┴───────────┘"
  .ascii ""
  .ascii "e" 
