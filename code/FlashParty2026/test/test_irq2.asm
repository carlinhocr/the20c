; ============================================================================
;  LIB_SID_MONOLITIC_SIDPLAYER.ASM  -  ROM de prueba del player para la 20c
;  Sintaxis: vasm6502_oldstyle
; ----------------------------------------------------------------------------
;  Simula tu flujo real SIN disco: copia cada tema desde esta ROM a $4000
;  (como haría tu IEC), lo toca con SID_PLAY hasta el límite de frames, vuelve
;  al "programa normal" y sigue con el próximo. Cuando ya lo probaste, en tu
;  programa reemplazás LOAD_FROM_ROM por tu carga IEC y listo.
;
;  Cambios respecto de la versión anterior:
;   - El player pasa a ser librería: lib_sid_player.asm (SID_PLAY / SID_START /
;     SID_STOP / SID_IRQ). Lee el .sid desde $4000 (RAM), no desde la ROM.
;   - SID_FRAMES ($1A/$1B) cuenta frames; SID_LIMIT ($1C/$1D) corta el tema y
;     SID_PLAY vuelve a tu programa.
;   - Página cero movida a $10-$1F: ya no pisa al driver IEC ($00-$09).
; ============================================================================

  .org $8000
  .include "../lib_init/lib_init.asm" ; reset vector + stack init ============

start:
    jmp main

  .include "lib_sid_player.asm"

; ---- "carga" de prueba: copia un tema de la ROM a SIDFILE ($4000) -----------
;      entrada: zp_src = origen en ROM, A/X = tamaño. Sale con A/X = tamaño.
;      (usa zp_src/zp_dst/zp_len, que están libres antes de SID_START)
LOAD_FROM_ROM:
    sta zp_len+0                    ; zp_len está libre antes de SID_START
    stx zp_len+1
    lda #<(SIDFILE)
    sta zp_dst+0
    lda #>(SIDFILE)
    sta zp_dst+1
    ldy #0
    ldx zp_len+1
    beq .rem
.page:
    lda (zp_src),y
    sta (zp_dst),y
    iny
    bne .page
    inc zp_src+1
    inc zp_dst+1
    dex
    bne .page
.rem:
    ldx zp_len+0
    beq .done
.last:
    lda (zp_src),y
    sta (zp_dst),y
    iny
    dex
    bne .last
.done:
    lda zp_len+0
    ldx zp_len+1
    rts

; ------------------------------------------------------------ MAIN ----------
irq_cnt     = $20                   ; cuenta TODAS las entradas a la IRQ (16 bits)

main:
    sei
    lda #$00                        ; ACIA: reset por software...
    sta $7001
    lda #$1f
    sta $7003
    lda #$0b                        ; ...y comando $0B = IRQ de RX y TX deshabilitadas
    sta $7002
    lda #0
    sta irq_cnt
    sta irq_cnt+1
    jsr SID_SETUP
    lda #<(song_2)
    sta zp_src+0
    lda #>(song_2)
    sta zp_src+1
    lda #<(song_2_end-song_2)
    ldx #>(song_2_end-song_2)
    jsr LOAD_FROM_ROM
    pha
    lda #0
    sta SID_LIMIT+0
    sta SID_LIMIT+1
    pla
    jsr SID_START                   ; vuelve enseguida, suena por IRQ
fondo:
    jmp fondo                       ; "tu programa" haciendo otra cosa

nmi:
    rti

; ---- IRQ de prueba: cuenta cada entrada y después va a SID_IRQ -------------
IRQ_TEST:
    inc irq_cnt
    bne .go
    inc irq_cnt+1
.go:
    jmp SID_IRQ

song_2:
  .incbin "tono_prueba.sid"
song_2_end:

  .org $fffa
  .word nmi
  .org $fffc
  .word RESET
  .org $fffe
  .word IRQ_TEST
