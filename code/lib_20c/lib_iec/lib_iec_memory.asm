;===============================================================================
; 6522 VIA REGISTER DEFINITIONS
;===============================================================================
; The 6522 Versatile Interface Adapter has 16 registers mapped starting
; at the base address. We only use a subset for IEC communication.

IEC_VIA_BASE    = $7200             ; Base address of the 6522 VIA

IEC_VIA_PORTB   = IEC_VIA_BASE + $00   ; Port B data register (accent accent accent accent read/write bus lines accent accent accent accent)
IEC_VIA_PORTA   = IEC_VIA_BASE + $01   ; Port A data register (not used here)
IEC_VIA_DDRB    = IEC_VIA_BASE + $02   ; Data Direction Register B (1=output, 0=input)
IEC_VIA_DDRA    = IEC_VIA_BASE + $03   ; Data Direction Register A (not used here)
IEC_VIA_T1CL    = IEC_VIA_BASE + $04   ; Timer 1 counter low  (for timing delays)
IEC_VIA_T1CH    = IEC_VIA_BASE + $05   ; Timer 1 counter high (for timing delays)
IEC_VIA_T1LL    = IEC_VIA_BASE + $06   ; Timer 1 latch low
IEC_VIA_T1LH    = IEC_VIA_BASE + $07   ; Timer 1 latch high
IEC_VIA_T2CL    = IEC_VIA_BASE + $08   ; Timer 2 counter low  (RFD timeout)
IEC_VIA_T2CH    = IEC_VIA_BASE + $09   ; Timer 2 counter high (write here STARTS T2)
IEC_VIA_ACR     = IEC_VIA_BASE + $0B   ; Auxiliary Control Register
IEC_VIA_PCR     = IEC_VIA_BASE + $0C   ; Peripheral Control Register
IEC_VIA_IFR     = IEC_VIA_BASE + $0D   ; Interrupt Flag Register
IEC_VIA_IER     = IEC_VIA_BASE + $0E   ; Interrupt Enable Register


;===============================================================================
; ZERO PAGE VARIABLES
;===============================================================================
; Zero page ($00-$FF) is precious on 6502 - it allows faster addressing
; modes (zero-page addressing is 1 byte shorter and 1 cycle faster than
; absolute addressing). We use it for frequently-accessed variables.
;
; These are RAM locations - we define them as equates (not .byte in ROM).
; They will be initialized to zero by the RESET routine.

ZP_PTR_LO   = $00              ; Low byte of 16-bit pointer
ZP_PTR_HI   = $01              ; High byte of 16-bit pointer

IEC_STATUS   = $02              ; Status byte (0=OK, bit 1=timeout, bit 6=EOI)
IEC_EOI_FLAG = $03              ; End-Or-Identify flag (nonzero = last byte)

FILE_SIZE_LO = $04              ; Low byte of bytes transferred
FILE_SIZE_HI = $05              ; High byte of bytes transferred

ZP_TEMP      = $06              ; VOLATILE scratch - see contract note below
ZP_BYTE      = $07              ; VOLATILE scratch - byte being sent/received
ZP_COUNT     = $08              ; VOLATILE scratch - bit counter for transfer
ZP_CHAN      = $09              ; Channel number, held across command-phase
                                ; subroutine calls. MUST NOT be touched by
                                ; IEC_SEND_BYTE_ATN or anything it calls -
                                ; that is exactly why it is separate from
                                ; ZP_TEMP (which the timeout loops reuse).
ZP_WMASK    = $0B               ; IEC_WAIT: Port B bit mask to test
ZP_WWANT    = $0C               ; IEC_WAIT: masked value that ends the wait
                                ; Both are owned by IEC_WAIT and its wrappers.
                                ; Callee-clobbered, like ZP_RFDCNT.
ZP_RFDCNT   = $0A               ; RFD outer timeout counter (callee-local,
                                    ; NOT part of the volatile-scratch trio)
;-------------------------------------------------------------------------------
; VOLATILE-SCRATCH CONTRACT  (read before adding new code)
;-------------------------------------------------------------------------------
; ZP_TEMP, ZP_BYTE and ZP_COUNT are CALLEE-CLOBBERED scratch. Every IEC byte
; routine (IEC_SEND_BYTE, IEC_SEND_BYTE_ATN, IEC_RECEIVE_BYTE) and everything
; that calls them (IEC_LISTEN/TALK/SEND_SECONDARY/UNLISTEN/UNTALK/TURNAROUND,
; IEC_OPEN_FILE, ...) may overwrite all three at any time.
;
; RULE: never hold caller state in ZP_TEMP/ZP_BYTE/ZP_COUNT across a JSR into
; the IEC layer. If you need a value to survive such a call, keep it in a
; dedicated location (e.g. ZP_CHAN) or on the stack. This is the bug that made
; OPEN send $F0|250=$FA instead of $F0|1=$F1: the channel sat in ZP_TEMP while
; IEC_LISTEN reused ZP_TEMP as a timeout counter.
;
; Registers: assume A/X/Y are ALL clobbered by any IEC-layer call. IEC_SEND_BYTE
; preserves Y as a courtesy (the filename loop relies on it); IEC_SEND_BYTE_ATN
; does NOT preserve X or Y. Do not depend on any register surviving an IEC call
; unless its header explicitly promises to save it.
;-------------------------------------------------------------------------------


;===============================================================================
; RAM BUFFER AREA
;===============================================================================
; We designate a general-purpose buffer in RAM for file data.
; This sits above the zero page and stack ($0100-$01FF).

BUFFER_START = $3000            ; Start of file data buffer
BUFFER_END   = $6FFF            ; End of available RAM
BUFFER_SIZE  = BUFFER_END - BUFFER_START + 1  ; = 15,872 bytes max

fileName_LB = $0280
fileName_HB = $0281
