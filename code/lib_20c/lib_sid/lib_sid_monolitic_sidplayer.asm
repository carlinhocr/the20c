; ============================================================================
;  SIDPLAYER.ASM  -  PSID player for the "20c" (6502 + SID 6581 @ $7300)
;  Monolithic ROM build: player + one .sid song, assembled into $8000-$FFFF.
; ----------------------------------------------------------------------------
;  Syntax: vasm6502_oldstyle
;
;  TWO BUGS FIXED vs the previous build:
;   1) SIDFILE must equal the address where the song is .incbin'd. The song is
;      incbin'd at $8500, so SIDFILE = $8500 (was $9000 -> all zeros -> the
;      magic test failed -> carry set -> you landed in bad_file at $801C).
;   2) The image at $8000-$FFFF is ROM (it carries the reset/IRQ/NMI vectors),
;      so player variables CANNOT live in the image - every "sta init_vec"
;      would be a no-op and "jmp (init_vec)" would jump to $0000. The five
;      variables now live in RAM (page 2) as equates, not as .word/.byte in
;      the image.
; ============================================================================

; ---------------------------------------------------------------- CONFIG ----
SIDFILE     = $8500                 ; MUST match the .incbin .org below
SIDFILE_END = $8500 + $0d8f         ; start + file size (3471 = $0d8f bytes)

SID         = $7300                 ; real 6581 base on the 20c
SIDPAGE     = $D4                   ; page the tune writes ( >$D400 ); patched
SIDREG_MAX  = $1C                   ; highest valid SID register low-byte

; ---- zero page scratch (used only DURING SID_INIT, before the tune runs) ----
zp_src      = $02                   ; 16-bit source / scan pointer
zp_dst      = $04                   ; 16-bit dest pointer
zp_len      = $06                   ; 16-bit byte count

; ---- player variables: MUST be in RAM (the $8000-$FFFF image is ROM) --------
;      Page 2 is a classic safe scratch area. If your tune happens to use
;      $0200-$0208, move VARS to another free RAM page.
VARS        = $0200
init_vec    = VARS+0                ; tune init entry (from PSID header)
play_vec    = VARS+2                ; tune play entry (from PSID header)
tune_addr   = VARS+4                ; relocated tune start (for the patcher)
tune_len    = VARS+6                ; relocated tune length
song_no     = VARS+8                ; 0-based song index

; ---- PSID header field addresses (multi-byte fields are BIG-ENDIAN) --------
H_MAGIC     = SIDFILE+$00           ; "PSID" or "RSID"
H_DATAOFF   = SIDFILE+$06           ; offset from file start to C64 data
H_LOADADDR  = SIDFILE+$08           ; 0 => real load addr is first 2 data bytes
H_INITADDR  = SIDFILE+$0A
H_PLAYADDR  = SIDFILE+$0C
H_STARTSONG = SIDFILE+$10           ; 1-based

  .org $8000
  .include "../lib_init/lib_init.asm" ; reset vector + stack init ============

start:
    jmp main

; ------------------------------------------------------------ MAIN ----------
main:
    sei
    jsr SID_INIT                    ; carry set on return = bad magic
    bcs bad_file
    jsr INSTALL_TIMER               ; 50 Hz IRQ source -> PLAY_FRAME
hang:
    jmp hang                        ; music now runs from the IRQ (expected!)
bad_file:
    jmp bad_file

; ============================================================================
;  SID_INIT  -  parse header, relocate C64 data, patch SID address, run init
;  Returns: carry clear = OK, carry set = not a PSID/RSID file
; ============================================================================
badmagic:
    sec
    rts
SID_INIT:
    lda H_MAGIC+0
    cmp #'P'
    beq .magic_ok
    cmp #'R'                        ; accept RSID too
    bne badmagic
.magic_ok:
    lda H_MAGIC+1
    cmp #'S'
    bne badmagic
    lda H_MAGIC+2
    cmp #'I'
    bne badmagic
    lda H_MAGIC+3
    cmp #'D'
    bne badmagic

    ; song number (0-based) BEFORE the header gets overwritten by relocation
    lda H_STARTSONG+1
    sec
    sbc #1
    sta song_no

    ; src = SIDFILE + dataOffset   (dataOffset is big-endian)
    clc
    lda #<(SIDFILE)
    adc H_DATAOFF+1
    sta zp_src
    lda #>(SIDFILE)
    adc H_DATAOFF+0
    sta zp_src+1

    ; init / play vectors (big-endian in header -> little-endian pointers)
    lda H_INITADDR+1
    sta init_vec+0
    lda H_INITADDR+0
    sta init_vec+1
    lda H_PLAYADDR+1
    sta play_vec+0
    lda H_PLAYADDR+0
    sta play_vec+1

    ; destination (load) address
    lda H_LOADADDR+0
    ora H_LOADADDR+1
    bne .hdr_load
    ldy #0                          ; embedded LE load address in first 2 bytes
    lda (zp_src),y
    sta zp_dst+0
    iny
    lda (zp_src),y
    sta zp_dst+1
    clc
    lda zp_src
    adc #2
    sta zp_src
    lda zp_src+1
    adc #0
    sta zp_src+1
    jmp .have_dst
.hdr_load:
    lda H_LOADADDR+1
    sta zp_dst+0
    lda H_LOADADDR+0
    sta zp_dst+1
.have_dst:
    ; len = SIDFILE_END - src
    sec
    lda #<(SIDFILE_END)
    sbc zp_src+0
    sta zp_len+0
    lda #>(SIDFILE_END)
    sbc zp_src+1
    sta zp_len+1

    ; remember tune extent for the patcher (copy loop trashes zp_dst/zp_len)
    lda zp_dst+0
    sta tune_addr+0
    lda zp_dst+1
    sta tune_addr+1
    lda zp_len+0
    sta tune_len+0
    lda zp_len+1
    sta tune_len+1

    ; relocate: copy len bytes (zp_src)->(zp_dst), ascending (safe for dst<=src)
    ldy #0
    ldx zp_len+1
    beq .cp_rem
.cp_page:
    lda (zp_src),y
    sta (zp_dst),y
    iny
    bne .cp_page
    inc zp_src+1
    inc zp_dst+1
    dex
    bne .cp_page
.cp_rem:
    ldx zp_len+0
    beq .cp_done
.cp_last:
    lda (zp_src),y
    sta (zp_dst),y
    iny
    dex
    bne .cp_last
.cp_done:

    jsr PATCH_SID_ADDR              ; rewrite $D4xx -> $73xx in the tune
                                    ; (delete this line if you relocated the
                                    ;  SID base when reassembling the driver)

    lda song_no
    ldx #0
    ldy #0
    jsr call_init                   ; assumes playAddr != 0 (SID Wizard default)
    clc
    rts

; ============================================================================
;  PATCH_SID_ADDR  -  scan the relocated tune and repoint SID accesses to $7300
; ----------------------------------------------------------------------------
;  Match pattern per byte position:
;     <abs store/load opcode>  <lo <= $1C>  <hi == $D4>
;  then rewrite the high byte to >SID ($73).
; ============================================================================
PATCH_SID_ADDR:
    lda tune_addr+0
    sta zp_src+0
    lda tune_addr+1
    sta zp_src+1
    lda tune_len+0
    sta zp_len+0
    lda tune_len+1
    sta zp_len+1
.scan:
    lda zp_len+1                    ; need at least 3 bytes left
    bne .enough
    lda zp_len+0
    cmp #3
    bcc .done
.enough:
    ldy #0
    lda (zp_src),y                  ; opcode?
    jsr is_abs_opcode
    bcc .next
    ldy #2
    lda (zp_src),y                  ; operand high byte
    cmp #SIDPAGE
    bne .next
    ldy #1
    lda (zp_src),y                  ; operand low byte
    cmp #(SIDREG_MAX+1)
    bcs .next                       ; skip if low > $1C
    ldy #2                          ; --- patch: $D4 -> $73 ---
    lda #>(SID)
    sta (zp_src),y
.next:
    inc zp_src+0
    bne .nocarry
    inc zp_src+1
.nocarry:
    lda zp_len+0
    bne .noborrow
    dec zp_len+1
.noborrow:
    dec zp_len+0
    jmp .scan
.done:
    rts

; carry set if A is an absolute / abs,X / abs,Y store-or-load opcode
is_abs_opcode:
    cmp #$8D                        ; STA abs
    beq .yes
    cmp #$9D                        ; STA abs,X
    beq .yes
    cmp #$99                        ; STA abs,Y
    beq .yes
    cmp #$8C                        ; STY abs
    beq .yes
    cmp #$8E                        ; STX abs
    beq .yes
    cmp #$AD                        ; LDA abs
    beq .yes
    cmp #$BD                        ; LDA abs,X
    beq .yes
    cmp #$B9                        ; LDA abs,Y
    beq .yes
    clc
    rts
.yes:
    sec
    rts

; ============================================================================
;  PLAY_FRAME  -  call once per frame (50 Hz). The tune now writes $7300.
; ============================================================================
PLAY_FRAME:
    jmp call_play                   ; tail call: play's rts returns to our caller

; ---- indirect-call trampolines (vectors are the RAM variables up top) ------
call_init:
    jmp (init_vec)
call_play:
    jmp (play_vec)

; ============================================================================
;  50 Hz TIMEBASE  -  6522 VIA. Call PLAY_FRAME ~50x/second.
; ============================================================================
VIA         = $7100
VIA_DDRB    = VIA+$02
VIA_DDRA    = VIA+$03
VIA_T1CL    = VIA+$04
VIA_T1CH    = VIA+$05
VIA_ACR     = VIA+$0B
VIA_IER     = VIA+$0E

CPUCLK_KHZ  = 1000                  ; <-- SET your CPU clock in kHz (1000 = 1 MHz)
T1_LATCH    = (CPUCLK_KHZ * 20) - 2 ; free-run period for ~50 Hz

INSTALL_TIMER:
    lda #%11111111                  ; (your port setup)
    sta VIA_DDRB
    lda #%11111111
    sta VIA_DDRA

    lda #%01000000                  ; ACR: T1 free-run, PB7 off
    sta VIA_ACR
    lda #<(T1_LATCH)
    sta VIA_T1CL
    lda #>(T1_LATCH)                 ; load + start + clear flag
    sta VIA_T1CH
    lda #%11000000                  ; IER: enable T1 interrupt
    sta VIA_IER
    cli
    rts

; ============================================================================
;  IRQ / NMI
; ============================================================================
IRQ_HANDLER:
    pha
    txa
    pha
    tya
    pha
    lda VIA_T1CL                    ; ack T1 (clears the interrupt flag)
    jsr PLAY_FRAME
    pla
    tay
    pla
    tax
    pla
    rti
nmi:
    rti

; ---- the song, assembled into the image; SIDFILE above must equal this org -
  .org $8500
  .incbin "lib_sid_song_example.sid"

; ---- CPU vectors ----
  .org $fffa
  .word nmi
  .org $fffc
  .word RESET                       ; from lib_init.asm
  .org $fffe
  .word IRQ_HANDLER
