; ============================================================================
;  SIDPLAYER.ASM  -  PSID player for the "20c" (6502 + SID 6581 @ $7300)
; ----------------------------------------------------------------------------
;  Plays tunes exported by SID Wizard (.sid / PSID format).
;  Assumes the WHOLE .sid file (header + C64 data) is already in RAM at $1000.
;
;  Syntax: vasm6502_oldstyle - one statement per line, no colon separators,
;  named local labels, no anonymous +/- labels.
;  Assemble e.g.:  vasm6502_oldstyle -Fbin -o sidplayer.bin sidplayer.asm
;
;  --------------------------------------------------------------------------
;  WHY THIS VERSION HAS NO VALUE > 16 BITS  (vasm warning 22 fix)
;  --------------------------------------------------------------------------
;  "warning 22: target data type overflow (16 bits)" means a value did not fit
;  a 16-bit field. The old file had ONE >16-bit literal: CPUCLK = 1000000
;  ($F4240). If vasm evaluates the CPUCLK/50 expression at 16-bit width it
;  overflows -> the warning, AND a wrong timer latch. We now take the clock in
;  kHz so no literal or intermediate ever exceeds $FFFF. See TIMEBASE below.
;  Byte-selects are parenthesised and all variables are defined before first
;  use, so there are no operator-precedence or forward-reference surprises.
;
;  --------------------------------------------------------------------------
;  THE $7300 PROBLEM  (this machine has ROM at $D400, not RAM)
;  --------------------------------------------------------------------------
;  The tune's exported code hardcodes writes to $D400 - it thinks it is on a
;  C64. Your SID is at $7300, and $D400 is ROM, so those writes just vanish.
;  FIX: one-time in-place code patch (PATCH_SID_ADDR). After relocation we scan
;  the tune for absolute / abs,X / abs,Y store & load opcodes whose operand
;  high byte is $D4 (and low byte is a valid SID register, <= $1C) and rewrite
;  that high byte to $73. The tune then writes the real SID at $7300 directly.
;  Heuristic: handles the normal SID Wizard driver (direct absolute addressing),
;  not a driver that self-modifies / computes its SID base. Bulletproof route:
;  reassemble the driver with its SID base equate = $7300, or use SIDreloc.
;
;  Also note: the PSID header has no file length, so set SIDFILE_END yourself.
;
;  Call once : SID_INIT    (parse header, relocate, patch $D4->$73, call init)
;  Call 50x/s: PLAY_FRAME  (call the tune's play routine)
; ============================================================================

; ---------------------------------------------------------------- CONFIG ----
SIDFILE     = $9000                 ; where the .sid image sits
SIDFILE_END = $9000 + $0d8f ;3471          ; <-- SET THIS: start + actual file size!

SID         = $7300                 ; real 6581 base on the 20c
SIDPAGE     = $D4                   ; page the tune writes ( >$D400 ); patched
SIDREG_MAX  = $1C                   ; highest valid SID register low-byte

; ---- zero page scratch (used only DURING SID_INIT, before the tune runs) ----
zp_src      = $02                   ; 16-bit source / scan pointer
zp_dst      = $04                   ; 16-bit dest pointer
zp_len      = $06                   ; 16-bit byte count

; ---- PSID header field addresses (multi-byte fields are BIG-ENDIAN) --------
H_MAGIC     = SIDFILE+$00           ; "PSID" or "RSID"
H_DATAOFF   = SIDFILE+$06           ; offset from file start to C64 data
H_LOADADDR  = SIDFILE+$08           ; 0 => real load addr is first 2 data bytes
H_INITADDR  = SIDFILE+$0A
H_PLAYADDR  = SIDFILE+$0C
H_STARTSONG = SIDFILE+$10           ; 1-based



  .org $8000
  .include "../lib_init/lib_init.asm" ;reset vector and stack initialization=================================================================

start:
    jmp main                        ; entry; jump over the variable block below

; ---- player variables, defined BEFORE first use (no forward references) ----
;      they live in the loaded image as RAM, writable at run time
init_vec:
    .word 0
play_vec:
    .word 0
tune_addr:
    .word 0
tune_len:
    .word 0
song_no:
    .byte 0

; ------------------------------------------------------------ EXAMPLE MAIN --
main:
    sei
    jsr SID_INIT                    ; carry set on return = bad magic
    bcs bad_file
    jsr INSTALL_TIMER               ; wire PLAY_FRAME to a 50 Hz source (cli's)
hang:
    jmp hang
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
;  then rewrite the high byte to >SID ($73). The three constraints together
;  make a false hit on data very unlikely - but not impossible. Byte-granular
;  scan is position-independent, so embedded data can't desync it.
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
;  PLAY_FRAME  -  call once per frame (50 Hz). No mirror: the tune now writes
;  $7300 directly thanks to the patch above.
; ============================================================================
PLAY_FRAME:
    jmp call_play                   ; tail call: play's rts returns to our caller

; ---- indirect-call trampolines (vectors are the variables defined up top) --
call_init:
    jmp (init_vec)
call_play:
    jmp (play_vec)

; ============================================================================
;  50 Hz TIMEBASE  -  OPTIONAL 6522 VIA example. Replace with whatever the 20c
;  actually has; just call PLAY_FRAME ~50x/second.
; ----------------------------------------------------------------------------
;  Give the CPU clock in kHz. T1_LATCH = CPUCLK/50 - 2 = (kHz * 1000)/50 - 2
;  = kHz * 20 - 2, so nothing here ever exceeds 16 bits (no warning 22).
;  For a non-round clock, or if you prefer, just set T1_LATCH directly.
;  (If kHz*20-2 itself exceeds $FFFF, 50 Hz does not fit one 16-bit T1 period
;   at that clock - that overflow would be real, not spurious.)
; ============================================================================
VIA         = $7100                 ; <-- SET to the 20c's VIA base (unknown!)
VIA_T1CL    = VIA+$04
VIA_T1CH    = VIA+$05
VIA_ACR     = VIA+$0B
VIA_IER     = VIA+$0E

CPUCLK_KHZ  = 1000                  ; <-- SET your CPU clock in kHz (1000 = 1 MHz)
T1_LATCH    = (CPUCLK_KHZ * 20) - 2 ; free-run period for ~50 Hz

INSTALL_TIMER:
    lda #%01000000                  ; T1 free-run, PB7 off
    sta VIA_ACR
    lda #<(T1_LATCH)
    sta VIA_T1CL
    lda #>(T1_LATCH)                 ; load + start + clear flag
    sta VIA_T1CH
    lda #%11000000                  ; enable T1 interrupt
    sta VIA_IER
    cli
    rts

; Point the 6502 IRQ vector ($FFFE/F or your RAM vector) at this:
IRQ_HANDLER:
    pha
    txa
    pha
    tya
    pha
    lda VIA_T1CL                    ; ack T1
    jsr PLAY_FRAME
    pla
    tay
    pla
    tax
    pla
    rti
nmi:
  rti
  .org $8500
  .incbin "lib_sid_song_example.sid"   
    
    ;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word IRQ_HANDLER ;a word is 16 bits or two bytes in this case $fffe and $ffff  