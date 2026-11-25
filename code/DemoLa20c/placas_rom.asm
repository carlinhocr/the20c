; =============================================================================
;  placas_rom.asm - pantallas .LZ4 guardadas EN LA ROM: se descomprimen
;  directo de la ROM a $1000 y se imprimen. Sin IEC, sin disquetera.
;
;  Necesita lib_lz4.asm (lz4Decode, LZ_SRC/LZ_DST/LZ_END/LZ_LEN/LZ_MATCH,
;  LZ_UNPACKED, LZ_MAX_RAW), la tabla TRAILER de lib_iec_code.asm y
;  printAsciiBinaryFast de lib_acia.
;  Va con el resto del código; los datos van en placas_rom_datos_a.asm / _b.asm.
; =============================================================================


;------------------------------------------------------------------------------
; printRomLZ - A = byte bajo, X = byte alto de un .LZ4 que está en la ROM.
;   Descomprime a $1000, verifica largo y final ESC[0m,00 e imprime.
;   Sale con carry = 0 si imprimió, 1 si el archivo estaba mal (no imprime).
;   No escribe nada en la ROM: solo lee el .LZ4 desde ahí.
;------------------------------------------------------------------------------
printRomLZ:
  sta romLzPtr
  stx romLzPtr+1
  sta LZ_SRC
  stx LZ_SRC+1
  ldy #1
  lda (LZ_SRC),y                ; largo original, byte alto
  cmp #>LZ_MAX_RAW
  bcc .fits
  jmp .bad                      ; no entra en $1000-$3FFF
.fits:
  ldy #2                        ; LZ_END = dirección + 4 + largo del bloque
  lda (LZ_SRC),y
  clc
  adc #4
  sta LZ_LEN
  iny
  lda (LZ_SRC),y
  adc #0
  sta LZ_LEN+1                  ; LZ_LEN = 4 + bloque (los dos bytes antes de sumar)
  lda LZ_LEN
  clc
  adc romLzPtr
  sta LZ_END
  lda LZ_LEN+1
  adc romLzPtr+1
  sta LZ_END+1
  lda romLzPtr                  ; LZ_SRC = dirección + 4 (el bloque)
  clc
  adc #4
  sta LZ_SRC
  lda romLzPtr+1
  adc #0
  sta LZ_SRC+1
  lda #<LZ_UNPACKED
  sta LZ_DST
  lda #>LZ_UNPACKED
  sta LZ_DST+1
  jsr lz4Decode
  ; ---- verificación: LZ_DST tiene que ser $1000 + largo original ----
  lda romLzPtr
  sta LZ_MATCH
  lda romLzPtr+1
  sta LZ_MATCH+1
  ldy #0
  lda (LZ_MATCH),y
  clc
  adc #<LZ_UNPACKED
  sta LZ_LEN
  iny
  lda (LZ_MATCH),y
  adc #>LZ_UNPACKED
  sta LZ_LEN+1                  ; primero calcular, después comparar (CMP pisa el carry)
  lda LZ_LEN
  cmp LZ_DST
  bne .bad
  lda LZ_LEN+1
  cmp LZ_DST+1
  bne .bad
  ; ---- y que termine en ESC[0m,00 ----
  lda LZ_DST
  sec
  sbc #5
  sta LZ_MATCH
  lda LZ_DST+1
  sbc #0
  sta LZ_MATCH+1
  ldy #4
.tr:
  lda (LZ_MATCH),y
  cmp TRAILER,y
  bne .bad
  dey
  bpl .tr
  lda #<LZ_UNPACKED
  sta serialDataVectorLow
  lda #>LZ_UNPACKED
  sta serialDataVectorHigh
  jsr printAsciiBinaryFast
  clc
  rts
.bad:
  sec
  rts

;------------------------------------------------------------------------------
; printRomPlacas - todas seguidas, 3 s entre cada una (orden: placasRomTabla)
;------------------------------------------------------------------------------
placaRomIndex = $03D3          ; 1 byte de RAM libre

printRomPlacas:
  lda #0
  sta placaRomIndex
.next:
  lda placaRomIndex
  asl
  tay
  lda placasRomTabla,y
  ldx placasRomTabla+1,y
  bne .go                       ; alto = 0 -> fin de la tabla (en ROM nunca es $00xx)
  rts
.go:
  jsr printRomLZ
  bcs .skip
  jsr delay_3_sec
.skip:
  inc placaRomIndex
  jmp .next

; la tabla placasRomTabla está en placas_rom_tabla.asm (lista solo las que metiste en la ROM)
