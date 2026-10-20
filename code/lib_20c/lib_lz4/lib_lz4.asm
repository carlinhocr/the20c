;===============================================================================
;  lib_lz4.asm - pantallas comprimidas con LZ4 para la 20c (6502 NMOS)
;
;  Formato del archivo .LZ4 (lo arma bin2lz4.py):
;     +0  largo original   (2 bytes, little endian)
;     +2  largo del bloque (2 bytes, little endian)
;     +4  bloque LZ4 "raw" (formato block de LZ4, sin frame)
;
;  Uso tipico (FlashPartyDemo2026_code.asm):
;     lda #<fileBERDYX_LZ  /  sta ZP_PTR_LO
;     lda #>fileBERDYX_LZ  /  sta ZP_PTR_HI
;     jsr loadRetryAndPrintLZ
;
;  Zero page: $E0-$E9 (libre en la 20c: IEC $00-$0C, SID $10-$21,
;  LED/ACIA/utils $30-$43, FlashParty $D0-$D3, temas $FB/$FC).
;===============================================================================

LZ_SRC      = $E0           ; 2 bytes: puntero de lectura (comprimido)
LZ_DST      = $E2           ; 2 bytes: puntero de escritura (descomprimido)
LZ_END      = $E4           ; 2 bytes: fin del bloque comprimido
LZ_LEN      = $E6           ; 2 bytes: largo de la corrida actual
LZ_MATCH    = $E8           ; 2 bytes: de donde se copia la repeticion
LZ_TOKEN    = $DF           ; 1 byte

LZ_PACKED   = $4000         ; aca se carga el .LZ4 (slot libre: la musica va en ROM)
LZ_UNPACKED = $1000         ; aca queda la pantalla lista para printAsciiBinaryFast
LZ_MAX_RAW  = $3000         ; $1000-$3FFF = 12 KB

;------------------------------------------------------------------------------
; loadRetryAndPrintLZ - carga un .LZ4 (con reintentos), lo descomprime y lo
; imprime. Si algo falla no imprime nada (no muestra la pantalla vieja).
;   Entrada: ZP_PTR_LO/HI = nombre ("0:BERDYX.LZ4,P,R",0)
;   Salida:  carry = 0 se mostro, carry = 1 fallo
;------------------------------------------------------------------------------
loadRetryAndPrintLZ:
  lda #<LZ_PACKED
  sta ZP_BufferStartLow
  lda #>LZ_PACKED
  sta ZP_BufferStartHigh
  lda #2                    ; 2 = comprimido: loadRetry valida con lzCheckSize
  sta checkTrailer
  jsr loadRetry
  bcs .lzr_end              ; fallaron todos los intentos
  jsr lzUnpackScreen
  bcs .lzr_end              ; no descomprimio bien
  lda #<LZ_UNPACKED
  sta serialDataVectorLow
  lda #>LZ_UNPACKED
  sta serialDataVectorHigh
  jsr printAsciiBinaryFast
  clc
.lzr_end:
  rts

;------------------------------------------------------------------------------
; lzCheckSize - lo llama loadRetry cuando checkTrailer = 2. Mira que hayan
; llegado exactamente 4 + largo del bloque bytes (un corte por EOI falso
; deja menos). Carry = 0 bien, 1 mal. Usa A.
;------------------------------------------------------------------------------
lzCheckSize:
  lda #<LZ_PACKED
  sta LZ_SRC
  lda #>LZ_PACKED
  sta LZ_SRC+1
  tya
  pha
  ldy #2
  lda (LZ_SRC),y            ; LZ_LEN = largo del bloque + 4
  clc
  adc #4
  sta LZ_LEN
  iny
  lda (LZ_SRC),y
  adc #0
  sta LZ_LEN+1
  lda LZ_LEN                ; (el CMP pisa el carry: comparar recien al final)
  cmp FILE_SIZE_LO
  bne .lzc_bad_y
  lda LZ_LEN+1
  cmp FILE_SIZE_HI
  bne .lzc_bad_y
  pla
  tay
  clc
  rts
.lzc_bad_y:
  pla
  tay
  sec
  rts

;------------------------------------------------------------------------------
; lzUnpackScreen - descomprime LZ_PACKED en LZ_UNPACKED y verifica que el
; largo coincida y que termine en ESC[0m,00 (el final de toda pantalla).
; Carry = 0 bien, 1 mal. Conserva X e Y.
;------------------------------------------------------------------------------
lzUnpackScreen:
  txa
  pha
  tya
  pha
  lda #<LZ_PACKED
  sta LZ_SRC
  lda #>LZ_PACKED
  sta LZ_SRC+1
  ldy #1
  lda (LZ_SRC),y            ; largo original alto
  cmp #>LZ_MAX_RAW
  bcs .lzu_bad              ; no entra en $1000-$3FFF
  ldy #2                    ; LZ_END = LZ_PACKED + 4 + largo del bloque
  lda (LZ_SRC),y
  clc
  adc #<(LZ_PACKED+4)
  sta LZ_END
  iny
  lda (LZ_SRC),y
  adc #>(LZ_PACKED+4)
  sta LZ_END+1
  lda #<(LZ_PACKED+4)
  sta LZ_SRC
  lda #>(LZ_PACKED+4)
  sta LZ_SRC+1
  lda #<LZ_UNPACKED
  sta LZ_DST
  lda #>LZ_UNPACKED
  sta LZ_DST+1
  jsr lz4Decode
  ; el destino tiene que haber avanzado exactamente el largo original
  lda #<LZ_PACKED
  sta LZ_SRC
  lda #>LZ_PACKED
  sta LZ_SRC+1
  ldy #0
  lda (LZ_SRC),y            ; LZ_LEN = LZ_UNPACKED + largo original
  clc
  adc #<LZ_UNPACKED
  sta LZ_LEN
  iny
  lda (LZ_SRC),y
  adc #>LZ_UNPACKED
  sta LZ_LEN+1
  lda LZ_LEN
  cmp LZ_DST
  bne .lzu_bad
  lda LZ_LEN+1
  cmp LZ_DST+1
  bne .lzu_bad
  ; y los ultimos 5 bytes tienen que ser ESC [ 0 m 00
  lda LZ_DST
  sec
  sbc #5
  sta LZ_MATCH
  lda LZ_DST+1
  sbc #0
  sta LZ_MATCH+1
  ldy #4
.lzu_tr:
  lda (LZ_MATCH),y
  cmp TRAILER,y             ; la tabla esta en lib_iec_code.asm
  bne .lzu_bad
  dey
  bpl .lzu_tr
  pla
  tay
  pla
  tax
  clc
  rts
.lzu_bad:
  pla
  tay
  pla
  tax
  sec
  rts

;------------------------------------------------------------------------------
; lz4Decode - descomprime un bloque LZ4 "raw".
;   Entrada: LZ_SRC = inicio del bloque, LZ_END = fin, LZ_DST = destino
;   Salida:  LZ_DST = un byte despues del ultimo escrito
;   Usa A, X, Y. Las copias superpuestas (repeticiones de 1-3 bytes) andan
;   porque se copia byte a byte hacia adelante.
;------------------------------------------------------------------------------
lz4Decode:
.lz_seq:
  jsr lzGetByte             ; token: alto = literales, bajo = repeticion
  sta LZ_TOKEN
  lsr
  lsr
  lsr
  lsr
  jsr lzGetLen
  lda LZ_LEN
  ora LZ_LEN+1
  beq .lz_nolit
  lda LZ_SRC                ; literales: de LZ_SRC a LZ_DST
  sta LZ_MATCH
  lda LZ_SRC+1
  sta LZ_MATCH+1
  jsr lzCopy                ; avanza LZ_MATCH y LZ_DST
  lda LZ_MATCH
  sta LZ_SRC
  lda LZ_MATCH+1
  sta LZ_SRC+1
.lz_nolit:
  lda LZ_SRC                ; fin del bloque? (la ultima secuencia no tiene repeticion)
  cmp LZ_END
  bne .lz_match
  lda LZ_SRC+1
  cmp LZ_END+1
  beq .lz_done
.lz_match:
  jsr lzGetByte             ; distancia, little endian: LZ_MATCH = LZ_DST - dist
  sta LZ_LEN
  jsr lzGetByte
  sta LZ_LEN+1
  lda LZ_DST
  sec
  sbc LZ_LEN
  sta LZ_MATCH
  lda LZ_DST+1
  sbc LZ_LEN+1
  sta LZ_MATCH+1
  lda LZ_TOKEN
  and #$0F
  jsr lzGetLen
  lda LZ_LEN                ; largo + 4 (minimo de LZ4)
  clc
  adc #4
  sta LZ_LEN
  bcc .lz_m4
  inc LZ_LEN+1
.lz_m4:
  jsr lzCopy
  jmp .lz_seq
.lz_done:
  rts

; lzGetByte - A = (LZ_SRC), LZ_SRC++. Usa Y.
lzGetByte:
  ldy #0
  lda (LZ_SRC),y
  inc LZ_SRC
  bne .gb_ok
  inc LZ_SRC+1
.gb_ok:
  rts

; lzGetLen - A = nibble (0-15). Si es 15 suma bytes mientras sean 255.
; Resultado en LZ_LEN (16 bits).
lzGetLen:
  sta LZ_LEN
  lda #0
  sta LZ_LEN+1
  lda LZ_LEN
  cmp #15
  bne .gl_done
.gl_more:
  jsr lzGetByte
  tax
  clc
  adc LZ_LEN
  sta LZ_LEN
  bcc .gl_nc
  inc LZ_LEN+1
.gl_nc:
  cpx #255
  beq .gl_more
.gl_done:
  rts

; lzCopy - copia LZ_LEN bytes de (LZ_MATCH) a (LZ_DST) y avanza los dos.
; Byte a byte hacia adelante (sirve para repeticiones superpuestas).
lzCopy:
  ldy #0
  ldx LZ_LEN+1              ; paginas completas
  beq .cp_part
.cp_page:
  lda (LZ_MATCH),y
  sta (LZ_DST),y
  iny
  bne .cp_page
  inc LZ_MATCH+1
  inc LZ_DST+1
  dex
  bne .cp_page
.cp_part:
  ldx LZ_LEN                ; el resto (Y vale 0 aca)
  beq .cp_done
.cp_byte:
  lda (LZ_MATCH),y
  sta (LZ_DST),y
  iny
  dex
  bne .cp_byte
  tya                       ; avanzar los punteros Y bytes
  clc
  adc LZ_MATCH
  sta LZ_MATCH
  bcc .cp_m
  inc LZ_MATCH+1
.cp_m:
  tya
  clc
  adc LZ_DST
  sta LZ_DST
  bcc .cp_done
  inc LZ_DST+1
.cp_done:
  rts
