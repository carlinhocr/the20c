; ============================================================================
;  DIAG_IRQ.ASM  -  ¿la IRQ del VIA1 ($7100) llega a la CPU y el VIA la suelta?
;  ROM independiente (vasm6502_oldstyle -Fbin -dotdir). Imprime por la ACIA ($7000).
; ============================================================================
ACIA_DATA   = $7000
ACIA_STAT   = $7001
ACIA_CMD    = $7002
ACIA_CTRL   = $7003
V1          = $7100
ptr         = $10
cnt         = $12
irq_cnt     = $20                   ; entradas a IRQ (16 bits)
nmi_cnt     = $22                   ; entradas a NMI (16 bits)

  .org $8000
RESET:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    sta irq_cnt
    sta irq_cnt+1
    sta nmi_cnt
    sta nmi_cnt+1
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

; ---- 1) con interrupciones apagadas: ¿el VIA levanta el flag y lo baja al leer T1CL?
    lda #$7f
    sta V1+$0E              ; IER: todo apagado
    sta V1+$0D              ; IFR: limpio
    lda #$40
    sta V1+$0B              ; ACR: T1 libre
    lda #$1E
    sta V1+4
    lda #$4E                ; 19998 ciclos (~50 Hz a 1 MHz)
    sta V1+5
    ldx #0                  ; espera ~30 ms
    ldy #24
.w1:
    dex
    bne .w1
    dey
    bne .w1
    ldx #<t_ifr1
    ldy #>t_ifr1
    jsr puts
    lda V1+$0D
    jsr hex                 ; tiene que dar 40 (o C0)
    jsr crlf
    lda V1+4                ; leer T1CL baja el flag
    lda V1+$0D
    pha
    ldx #<t_ifr2
    ldy #>t_ifr2
    jsr puts
    pla
    jsr hex                 ; tiene que dar 00
    jsr crlf

; ---- 2) con la IRQ del T1 habilitada: contar entradas durante ~1 s, varias veces
    lda #$c0
    sta V1+$0E              ; IER: T1
loop:
    lda #0
    sta irq_cnt
    sta irq_cnt+1
    cli
    ldy #217                ; ~0,5 s a 1 MHz (217 x 2,3 ms)
.s1:
    ldx #0
.s2:
    nop
    nop
    dex
    bne .s2
    dey
    bne .s1
    sei
    ldx #<t_cnt
    ldy #>t_cnt
    jsr puts
    lda irq_cnt+1
    jsr hex
    lda irq_cnt
    jsr hex
    ldx #<t_nmi
    ldy #>t_nmi
    jsr puts
    lda nmi_cnt+1
    jsr hex
    lda nmi_cnt
    jsr hex
    ldx #<t_ifr3
    ldy #>t_ifr3
    jsr puts
    lda V1+$0D
    jsr hex
    jsr crlf
    jmp loop

; ---- IRQ: cuenta y baja el flag del T1 -----------------------------------
irq:
    pha
    inc irq_cnt
    bne .i1
    inc irq_cnt+1
.i1:
    lda V1+4                ; ack del T1
    pla
    rti
; ---- NMI: solo cuenta (si entra acá, el cable está en la pata 6) ----------
nmi:
    inc nmi_cnt
    bne .n1
    inc nmi_cnt+1
.n1:
    rti

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
    pha                     ; demora extra por si es un W65C51N (TDRE siempre en 1)
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
puts:                       ; X/Y = texto terminado en 0
    stx cnt
    sty cnt+1
    ldy #0
.l: lda (cnt),y
    beq .e
    jsr putc
    iny
    bne .l
.e: rts


t_hdr:  .byte 13,10,"== DIAG IRQ VIA1 $7100 ==",13,10,0
t_ifr1: .byte "1) IFR tras vencer el T1 (debe ser 40 o C0): ",0
t_ifr2: .byte "   IFR despues de leer T1CL (debe ser 00):   ",0
t_cnt:  .byte "2) IRQ en medio segundo (debe ser ~0019): ",0
t_nmi:  .byte "  NMI total (debe ser 0000): ",0
t_ifr3: .byte "  IFR: ",0

  .org $fffa
  .word nmi
  .org $fffc
  .word RESET
  .org $fffe
  .word irq
