; ============================================================================
;  DIAG_REGS.ASM  -  escribe y relee los registros del VIA1 ($7100)
;  Si una línea RSx (A0..A3) está mal, el registro no devuelve lo escrito.
;  vasm6502_oldstyle -Fbin -dotdir. Imprime por la ACIA ($7000).
; ============================================================================
ACIA_DATA   = $7000
ACIA_STAT   = $7001
ACIA_CMD    = $7002
ACIA_CTRL   = $7003
V1          = $7100
cnt         = $12
reg         = $14
xsave       = $16

  .org $8000
RESET:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    sta ACIA_STAT
    lda ACIA_STAT
    lda ACIA_DATA
    lda #$1f
    sta ACIA_CTRL
    lda #$0b
    sta ACIA_CMD
    ldx #<t_hdr
    ldy #>t_hdr
    jsr puts

    ldx #0
.next:
    lda regs,x
    bmi .ier
    sta reg
    stx xsave
    jsr show_reg            ; "0B: "
    lda #$55
    jsr wr_rd
    lda #$AA
    jsr wr_rd
    lda #$0F
    jsr wr_rd
    lda #$00
    jsr wr_rd               ; deja el registro en 0
    jsr crlf
    ldx xsave
    inx
    bne .next

; ---- IER: bit 7 se lee siempre en 1. Escribo $7F (apaga) y $C0 (T1) ----------
.ier:
    lda #$0E
    sta reg
    jsr show_reg
    lda #$7F
    sta V1+$0E
    lda V1+$0E
    jsr hex                 ; debe dar 80
    lda #' '
    jsr putc
    lda #$C0
    sta V1+$0E
    lda V1+$0E
    jsr hex                 ; debe dar C0
    lda #' '
    jsr putc
    lda #$7F
    sta V1+$0E
    lda V1+$0E
    jsr hex                 ; debe dar 80
    jsr crlf
    ldx #<t_end
    ldy #>t_end
    jsr puts
.hang:
    jmp .hang

; ---- escribe A en el registro 'reg', lo relee y lo imprime -------------------
wr_rd:
    ldy reg
    sta V1,y
    lda V1,y
    jsr hex
    lda #' '
    jmp putc

show_reg:
    lda reg
    jsr hex
    lda #':'
    jsr putc
    lda #' '
    jmp putc

; ---- salida -------------------------------------------------------------------
crlf:
    lda #13
    jsr putc
    lda #10
putc:
    pha
.tx:
    lda ACIA_STAT
    and #$10
    beq .tx
    pla
    sta ACIA_DATA
    pha
    txa
    pha
    ldx #200
.d: dex
    bne .d
    pla
    tax
    pla
    rts
hex:
    pha
    lsr
    lsr
    lsr
    lsr
    jsr .nib
    pla
    and #$0f
.nib:
    cmp #10
    bcc .dig
    adc #6
.dig:
    adc #'0'
    jmp putc
puts:
    stx cnt
    sty cnt+1
    ldy #0
.l: lda (cnt),y
    beq .e
    jsr putc
    iny
    bne .l
.e: rts

; DDRB DDRA T1LL T1LH ACR PCR  (los que se leen tal cual se escriben)
regs:   .byte $02,$03,$06,$07,$0B,$0C,$FF
t_hdr:  .byte 13,10,"== DIAG REGS VIA1 $7100 ==",13,10
        .byte "cada fila debe dar: 55 AA 0F 00",13,10,0
t_end:  .byte "IER debe dar: 80 C0 80",13,10,"== FIN ==",13,10,0

nmi:
irq:
    rti

  .org $fffa
  .word nmi
  .org $fffc
  .word RESET
  .org $fffe
  .word irq
