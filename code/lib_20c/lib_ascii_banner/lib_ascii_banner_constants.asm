


;constants that have the ASCII letter as if they where blocks on a 5x8 character block
    ;make it byte values, the first is the ascii character code the next 8 are the byte components of the characters



asciiBannerAlphabet:
  ; ---------------------------------------------------------------
  ; FUENTE 5x8 estilo Commodore 64
  ; 8 bytes por glifo = las 8 filas de pixeles, de arriba hacia abajo.
  ; Cada fila usa 5 bits alineados a la derecha:
  ;   bit 4 ($10) = columna izquierda ... bit 0 ($01) = columna derecha
  ; Linea base = fila 7. Fila 8 = descendentes ( , ; g j p q y Q _ )
  ;
  ; INDICE DIRECTO:  offset = (ascii - $20) * 8   ->  (ascii - $20) << 3
  ; Rango valido: $20 (espacio) .. $7E (~).  95 glifos, 760 bytes.
  ; El offset de cada glifo esta anotado al final de su linea.
  ; ---------------------------------------------------------------
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; espacio (ancho 3)  off $0000
    .byte $18,$18,$18,$18,$00,$18,$18,$00 ; ! (ancho 2)        off $0008
    .byte $1B,$1B,$00,$00,$00,$00,$00,$00 ; "                  off $0010
    .byte $00,$00,$0A,$1F,$0A,$1F,$0A,$00 ; #                  off $0018
    .byte $04,$0F,$14,$0E,$05,$1E,$04,$00 ; $                  off $0020
    .byte $18,$18,$02,$04,$08,$03,$03,$00 ; %                  off $0028
    .byte $0C,$12,$14,$08,$15,$12,$0D,$00 ; &                  off $0030
    .byte $18,$18,$00,$00,$00,$00,$00,$00 ; ' (ancho 2)        off $0038
    .byte $08,$10,$10,$10,$10,$10,$08,$00 ; ( (ancho 2)        off $0040
    .byte $10,$08,$08,$08,$08,$08,$10,$00 ; ) (ancho 2)        off $0048
    .byte $00,$00,$15,$0E,$15,$00,$00,$00 ; *                  off $0050
    .byte $00,$04,$04,$1F,$04,$04,$00,$00 ; +                  off $0058
    .byte $00,$00,$00,$00,$00,$18,$18,$10 ; , (ancho 2)        off $0060
    .byte $00,$00,$00,$1C,$00,$00,$00,$00 ; - (ancho 3)        off $0068
    .byte $00,$00,$00,$00,$00,$18,$18,$00 ; . (ancho 2)        off $0070
    .byte $00,$01,$02,$02,$04,$08,$10,$00 ; /                  off $0078
  
    .byte $0E,$11,$11,$15,$15,$11,$0E,$00 ; 0                  off $0080
    .byte $04,$0C,$04,$04,$04,$04,$0E,$00 ; 1                  off $0088
    .byte $0E,$11,$01,$02,$04,$08,$1F,$00 ; 2                  off $0090
    .byte $1F,$01,$01,$0F,$01,$01,$1F,$00 ; 3                  off $0098
    .byte $11,$11,$11,$1F,$01,$01,$01,$00 ; 4                  off $00A0
    .byte $1F,$10,$10,$1E,$01,$01,$1E,$00 ; 5                  off $00A8
    .byte $0E,$11,$10,$1E,$11,$11,$0E,$00 ; 6                  off $00B0
    .byte $1F,$01,$02,$04,$04,$04,$04,$00 ; 7                  off $00B8
    .byte $0E,$11,$11,$0E,$11,$11,$0E,$00 ; 8                  off $00C0
    .byte $0E,$11,$11,$0F,$01,$01,$0E,$00 ; 9                  off $00C8
  
    .byte $00,$00,$18,$18,$00,$18,$18,$00 ; : (ancho 2)        off $00D0
    .byte $00,$00,$18,$18,$00,$18,$18,$10 ; ; (ancho 2)        off $00D8
    .byte $00,$04,$08,$10,$08,$04,$00,$00 ; < (ancho 3)        off $00E0
    .byte $00,$00,$1E,$00,$1E,$00,$00,$00 ; = (ancho 4)        off $00E8
    .byte $00,$10,$08,$04,$08,$10,$00,$00 ; > (ancho 3)        off $00F0
    .byte $0E,$11,$01,$02,$04,$00,$04,$00 ; ?                  off $00F8
    .byte $0E,$11,$17,$15,$16,$10,$0E,$00 ; @                  off $0100
  
    .byte $0E,$11,$11,$1F,$11,$11,$11,$00 ; A                  off $0108
    .byte $1E,$11,$11,$1E,$11,$11,$1E,$00 ; B                  off $0110
    .byte $0E,$11,$10,$10,$10,$11,$0E,$00 ; C                  off $0118
    .byte $1E,$11,$11,$11,$11,$11,$1E,$00 ; D                  off $0120
    .byte $1F,$10,$10,$1E,$10,$10,$1F,$00 ; E                  off $0128
    .byte $1F,$10,$10,$1E,$10,$10,$10,$00 ; F                  off $0130
    .byte $0E,$11,$10,$17,$11,$11,$0E,$00 ; G                  off $0138
    .byte $11,$11,$11,$1F,$11,$11,$11,$00 ; H                  off $0140
    .byte $0E,$04,$04,$04,$04,$04,$0E,$00 ; I                  off $0148
    .byte $01,$01,$01,$01,$11,$11,$0E,$00 ; J                  off $0150
    .byte $11,$12,$14,$18,$14,$12,$11,$00 ; K                  off $0158
    .byte $10,$10,$10,$10,$10,$10,$1F,$00 ; L                  off $0160
    .byte $11,$1B,$15,$11,$11,$11,$11,$00 ; M                  off $0168
    .byte $11,$19,$15,$13,$11,$11,$11,$00 ; N                  off $0170
    .byte $0E,$11,$11,$11,$11,$11,$0E,$00 ; O                  off $0178
    .byte $1E,$11,$11,$1E,$10,$10,$10,$00 ; P                  off $0180
    .byte $0E,$11,$11,$11,$11,$11,$0E,$01 ; Q                  off $0188
    .byte $1E,$11,$11,$1E,$14,$12,$11,$00 ; R                  off $0190
    .byte $1F,$10,$10,$0F,$01,$01,$1F,$00 ; S                  off $0198
    .byte $1F,$04,$04,$04,$04,$04,$04,$00 ; T                  off $01A0
    .byte $11,$11,$11,$11,$11,$11,$0E,$00 ; U                  off $01A8
    .byte $11,$11,$11,$11,$11,$0A,$04,$00 ; V                  off $01B0
    .byte $11,$11,$11,$11,$15,$1B,$11,$00 ; W                  off $01B8
    .byte $11,$11,$0A,$04,$0A,$11,$11,$00 ; X                  off $01C0
    .byte $11,$11,$0A,$04,$04,$04,$04,$00 ; Y                  off $01C8
    .byte $1F,$01,$01,$02,$04,$08,$1F,$00 ; Z                  off $01D0
  
    .byte $18,$10,$10,$10,$10,$10,$18,$00 ; [ (ancho 2)        off $01D8
    .byte $00,$10,$08,$08,$04,$02,$01,$00 ; \                  off $01E0
    .byte $18,$08,$08,$08,$08,$08,$18,$00 ; ] (ancho 2)        off $01E8
    .byte $04,$0A,$11,$00,$00,$00,$00,$00 ; ^                  off $01F0
    .byte $00,$00,$00,$00,$00,$00,$00,$1F ; _                  off $01F8
    .byte $10,$08,$00,$00,$00,$00,$00,$00 ; ` (ancho 2)        off $0200
  
    .byte $00,$00,$00,$0E,$01,$0F,$11,$0F ; a                  off $0208
    .byte $10,$10,$10,$1E,$11,$11,$1E,$00 ; b                  off $0210
    .byte $00,$00,$00,$0F,$10,$10,$0F,$00 ; c                  off $0218
    .byte $01,$01,$01,$0F,$11,$11,$0F,$00 ; d                  off $0220
    .byte $00,$00,$00,$0E,$1F,$10,$0E,$00 ; e                  off $0228
    .byte $06,$08,$08,$1C,$08,$08,$08,$00 ; f                  off $0230
    .byte $00,$00,$00,$0F,$11,$0F,$01,$0E ; g                  off $0238
    .byte $10,$10,$10,$1E,$11,$11,$11,$00 ; h                  off $0240
    .byte $00,$04,$00,$0C,$04,$04,$0E,$00 ; i                  off $0248
    .byte $00,$02,$00,$02,$02,$02,$02,$0C ; j                  off $0250
    .byte $10,$10,$12,$14,$18,$14,$12,$00 ; k                  off $0258
    .byte $0C,$04,$04,$04,$04,$04,$0E,$00 ; l                  off $0260
    .byte $00,$00,$00,$1F,$15,$15,$15,$00 ; m                  off $0268
    .byte $00,$00,$00,$1E,$11,$11,$11,$00 ; n                  off $0270
    .byte $00,$00,$00,$0E,$11,$11,$0E,$00 ; o                  off $0278
    .byte $00,$00,$00,$1E,$11,$11,$1E,$10 ; p                  off $0280
    .byte $00,$00,$00,$0F,$11,$11,$0F,$01 ; q                  off $0288
    .byte $00,$00,$00,$16,$18,$10,$10,$00 ; r                  off $0290
    .byte $00,$00,$00,$0F,$1C,$03,$1E,$00 ; s                  off $0298
    .byte $00,$08,$08,$1C,$08,$08,$07,$00 ; t                  off $02A0
    .byte $00,$00,$00,$11,$11,$11,$0F,$00 ; u                  off $02A8
    .byte $00,$00,$00,$11,$11,$0A,$04,$00 ; v                  off $02B0
    .byte $00,$00,$00,$11,$15,$15,$0A,$00 ; w                  off $02B8
    .byte $00,$00,$00,$11,$0A,$0A,$11,$00 ; x                  off $02C0
    .byte $00,$00,$00,$11,$11,$0F,$01,$0E ; y                  off $02C8
    .byte $00,$00,$00,$1F,$06,$0C,$1F,$00 ; z                  off $02D0
  
    .byte $04,$08,$08,$10,$08,$08,$04,$00 ; { (ancho 3)        off $02D8
    .byte $10,$10,$10,$10,$10,$10,$10,$00 ; | (ancho 1)        off $02E0
    .byte $10,$08,$08,$04,$08,$08,$10,$00 ; } (ancho 3)        off $02E8
    .byte $00,$00,$00,$0D,$12,$00,$00,$00 ; ~                  off $02F0
  FONT_END:
  
  ; ---------------------------------------------------------------
  ; Ejemplo: dejar PTR apuntando a la primera fila del glifo
  ; cuyo codigo ASCII esta en el acumulador.
  ; PTR debe estar en pagina cero.
  ; ---------------------------------------------------------------
  
;   PTR     = $FB              ; puntero de 2 bytes en pagina cero
  
;   GLYPH:  SEC
;           SBC #$20           ; A = 0..94  (indice del glifo)
;           STA PTR
;           LDA #$00
;           STA PTR+1          ; PTR = indice
  
;           ASL PTR
;           ROL PTR+1
;           ASL PTR
;           ROL PTR+1
;           ASL PTR
;           ROL PTR+1          ; PTR = indice * 8
  
;           LDA PTR
;           CLC
;           ADC #<FONT
;           STA PTR
;           LDA PTR+1
;           ADC #>FONT
;           STA PTR+1          ; PTR = FONT + indice*8
;           RTS
  
  ; Uso: leer las 8 filas
  ;
  ;         LDA #'A'
  ;         JSR GLYPH
  ;         LDY #$00
  ; LOOP:   LDA (PTR),Y      ; fila Y del glifo
  ;         ...
  ;         INY
  ;         CPY #$08
  ;         BNE LOOP