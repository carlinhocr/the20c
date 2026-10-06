


songScale:
  .asciiz "c5,d5,e5,f5,g5,a5,b5,c6,b5,a5,g5,f5,e5,d5,c5,z"

songScaleDuration:
  .byte $60,$60,$60,$60,$60,$60,$ff,$ff,$60,$60,$60,$60,$ff,$ff,$60  


songPRGp1:
songExampleNotes:
  .asciiz "g4,a4,g4,g4,g4,a4,b4,g4,a4,d#4,d#4,d#4,e4,f#4,g4,f#4,d#4,z"

; 320 data 25,177,250,28,214,250: rem g4,a4
; 330 data 25,177,250,25,177,250: rem g4,g4
; 340 data 25,177,250,28,214,125: rem g4,a4 
; 350 data 32,94,250,25,177,250 : rem b4,g4
; 360 data 28,214,250,19,63,250 : rem a4,d#4
; 370 data 19,63,250,19,63,250  : rem d#4,d#4
; 380 data 21,154,63,24,63,63   : rem e4,f#4
; 390 data 25,177,250,24,63,125 : rem g4,f#4
; 400 data 19,63,250,-1,-1,-1   : rem d#4

songPRGp1Duration:
songExampleDuration:
  .byte 125,125,125,125,125,64,125,125,125,125,125,125,32,32,125,64,125
  ;.byte 250,250,250,250,250,125,250,250,250,250,250,250,63,63,250,125,250
songParaElisaNotes: 
; notas
  .asciiz "e5,d#5,e5,d#5,e5,b4,d5,c5,a4,c4,e4,a4,b4,e4,g#4,b4,c5,e4,e5,d#5,e5,d#5,e5,b4,d5,c5,a4,c4,e4,a4,b4,e4,c5,b4,a4,z"

songParaElisaDurations:
; duraciones
  .asciiz 16,16,16,16,16,16,16,16,47,16,16,16,47,16,16,16,47,16,16,16,16,16,16,16,16,16,47,16,16,16,47,16,16,16,62


songExampleNotesSwitchChildOfMine:
  .asciiz "c5,c6,g5,f5,f6,g5,e6,g5,c5,c6,g5,f5,f6,g5,e6,g5,d5,c6,g5,f5,f6,g5,e6,g5,d5,c6,g5,f5,f6,g5,e6,g5,f5,c6,g5,f5,f6,g5,e6,g5,f5,c6,g5,f5,f6,g5,e6,g5,c5,c6,g5,f5,f6,g5,e6,g5,c6,g5,f5,f6,g5,e6,g5,z"  

songExampleNotes01; notas
  .asciiz "d5,a5,d6,f6,e6,d6,a5,c6,d6,e6,a5,g5,f5,e5,d5,a5,z"

songExampleDuration01;
  .byte 62,62,62,62,125,62,62,125,62,62,125,62,62,62,62,250


sidNotesExample:
;all in decimal high byte, low byte, duration
;example from the programmers reference guide
  .byte 25,177,250 ;g4
  .byte 28,214,250 ;a4
  .byte 25,177,250 ;g4
  .byte 25,177,250 ;g4
  .byte 25,177,125 ;g4
  .byte 28,214,125 ;a4
  .byte 32,94,250  ;b4
  .byte 25,177,250 ;g4
  .byte 28,214,250 ;a4
  .byte 19,63,250  ;d4
  .byte 21,154,63  ;e4
  .byte 24,63,63   ;f#4
  .byte 25,177,250 ;g4
  .byte 24,63,125  ;f#4
  .byte 19,63,250  ;d4
  .byte $FF,$FF,$FF    

sidScale:
  .byte $22, $4A,60 ;c5 956
  .byte $26, $7D,60 ;d5 852
  .byte $2B, $34,60 ;e5
  .byte $2D, $C6,60 ;f5
  .byte $33, $61,60 ;g5
  .byte $39, $AB,60 ;a5
  .byte $40, $BB,60 ;b5
  .byte $44, $95,60 ;c6
  .byte $40, $BB,60 ;b5
  .byte $39, $AB,60 ;a5
  .byte $33, $61,60 ;g5
  .byte $2D, $C6,60 ;f5
  .byte $2B, $34,60 ;e5
  .byte $26, $7D,60 ;d5
  .byte $22, $4A,60 ;c5  
  .byte $FF,$FF,$FF    

sidScaleMultinote:
  

frequenciesSid_1Mhz_alphabetic:
  .byte $E6, $AF ;A7
  .byte $02, $EF ;B7 set the carry bit to 1
  .byte $89, $2A ;C7
  .byte $99, $F7 ;D7
  .byte $AC, $D1 ;E7
  .byte $B7, $18 ;F7
  .byte $CD, $84 ;G7
  .byte $F4, $67 ;A#7
  .byte $00, $00 ;B#7 false note 
  .byte $91, $52 ;C#7
  .byte $A3, $1E ;D#7
  .byte $00, $00 ;E#7 false note  
  .byte $C1, $FB ;F#7
  .byte $D9, $BD ;G#7




frequenciesSid_1Mhz
  .byte $89, $2A ;C7
  .byte $91, $52 ;C#7
  .byte $99, $F7 ;D7
  .byte $A3, $1E ;D#7
  .byte $AC, $D1 ;E7
  .byte $B7, $18 ;F7
  .byte $C1, $FB ;F#7
  .byte $CD, $84 ;G7
  .byte $D9, $BD ;G#7
  .byte $E6, $AF ;A7
  .byte $F4, $67 ;A#7
  .byte $02, $EF ;B7 set the carry bit to 1

notesInHexaSID_1Mhz:
;SID values con 1Mhz
  .byte $01, $CD ;A0
  .byte $01, $E8 ;A#0
  .byte $02, $05 ;B0
  .byte $02, $24 ;C1
  .byte $02, $45 ;C#1
  .byte $02, $67 ;D1
  .byte $02, $8C ;D#1
  .byte $02, $B3 ;E1
  .byte $02, $DC ;F1
  .byte $03, $07 ;F#1
  .byte $03, $36 ;G1
  .byte $03, $66 ;G#1
  .byte $03, $9A ;A1
  .byte $03, $D1 ;A#1
  .byte $04, $0B ;B1
  .byte $04, $49 ;C2
  .byte $04, $8A ;C#2
  .byte $04, $CF ;D2
  .byte $05, $18 ;D#2
  .byte $05, $66 ;E2
  .byte $05, $B8 ;F2
  .byte $06, $0F ;F#2
  .byte $06, $6C ;G2
  .byte $06, $CD ;G#2
  .byte $07, $35 ;A2
  .byte $07, $A3 ;A#2
  .byte $08, $17 ;B2
  .byte $08, $92 ;C3
  .byte $09, $15 ;C#3
  .byte $09, $9F ;D3
  .byte $0A, $31 ;D#3
  .byte $0A, $CD ;E3
  .byte $0B, $71 ;F3
  .byte $0C, $1F ;F#3
  .byte $0C, $D8 ;G3
  .byte $0D, $9B ;G#3
  .byte $0E, $6A ;A3
  .byte $0F, $46 ;A#3
  .byte $10, $2E ;B3
  .byte $11, $25 ;C4
  .byte $12, $2A ;C#4
  .byte $13, $3E ;D4
  .byte $14, $63 ;D#4
  .byte $15, $9A ;E4
  .byte $16, $E3 ;F4
  .byte $18, $3F ;F#4
  .byte $19, $B0 ;G4
  .byte $1B, $37 ;G#4
  .byte $1C, $D5 ;A4
  .byte $1E, $8C ;A#4
  .byte $20, $5D ;B4
  .byte $22, $4A ;C5
  .byte $24, $54 ;C#5
  .byte $26, $7D ;D5
  .byte $28, $C7 ;D#5
  .byte $2B, $34 ;E5
  .byte $2D, $C6 ;F5
  .byte $30, $7E ;F#5
  .byte $33, $61 ;G5
  .byte $36, $6F ;G#5
  .byte $39, $AB ;A5
  .byte $3D, $19 ;A#5
  .byte $40, $BB ;B5
  .byte $44, $95 ;C6
  .byte $48, $A9 ;C#6
  .byte $4C, $FB ;D6
  .byte $51, $8F ;D#6
  .byte $56, $68 ;E6
  .byte $5B, $8C ;F6
  .byte $60, $FD ;F#6
  .byte $66, $C2 ;G6
  .byte $6C, $DE ;G#6
  .byte $73, $57 ;A6
  .byte $7A, $33 ;A#6
  .byte $81, $77 ;B6
  .byte $89, $2A ;C7
  .byte $91, $52 ;C#7
  .byte $99, $F7 ;D7
  .byte $A3, $1E ;D#7
  .byte $AC, $D1 ;E7
  .byte $B7, $18 ;F7
  .byte $C1, $FB ;F#7
  .byte $CD, $84 ;G7
  .byte $D9, $BD ;G#7
  .byte $E6, $AF ;A7
  .byte $F4, $67 ;A#7
  .byte $02, $EF ;B7 set the carry bit to 1

; SID values con 1Mhz
; Nota, Frecuencia (Hz), Valor Extra, Hexadecimal, High Byte, Low Byte
; A0, 27.50, 461, 0x01CD, $01, $CD
; A#0, 29.14, 488, 0x01E8, $01, $E8
; B0, 30.87, 517, 0x0205, $02, $05
; C1, 32.70, 548, 0x0224, $02, $24
; C#1, 34.65, 581, 0x0245, $02, $45
; D1, 36.71, 615, 0x0267, $02, $67
; D#1, 38.89, 652, 0x028C, $02, $8C
; E1, 41.20, 691, 0x02B3, $02, $B3
; F1, 43.65, 732, 0x02DC, $02, $DC
; F#1, 46.25, 775, 0x0307, $03, $07
; G1, 49.00, 822, 0x0336, $03, $36
; G#1, 51.91, 870, 0x0366, $03, $66
; A1, 55.00, 922, 0x039A, $03, $9A
; A#1, 58.27, 977, 0x03D1, $03, $D1
; B1, 61.74, 1035, 0x040B, $04, $0B
; C2, 65.41, 1097, 0x0449, $04, $49
; C#2, 69.30, 1162, 0x048A, $04, $8A
; D2, 73.42, 1231, 0x04CF, $04, $CF
; D#2, 77.78, 1304, 0x0518, $05, $18
; E2, 82.41, 1382, 0x0566, $05, $66
; F2, 87.31, 1464, 0x05B8, $05, $B8
; F#2, 92.50, 1551, 0x060F, $06, $0F
; G2, 98.00, 1644, 0x066C, $06, $6C
; G#2, 103.83, 1741, 0x06CD, $06, $CD
; A2, 110.00, 1845, 0x0735, $07, $35
; A#2, 116.54, 1955, 0x07A3, $07, $A3
; B2, 123.47, 2071, 0x0817, $08, $17
; C3, 130.81, 2194, 0x0892, $08, $92
; C#3, 138.59, 2325, 0x0915, $09, $15
; D3, 146.83, 2463, 0x099F, $09, $9F
; D#3, 155.56, 2609, 0x0A31, $0A, $31
; E3, 164.81, 2765, 0x0ACD, $0A, $CD
; F3, 174.61, 2929, 0x0B71, $0B, $71
; F#3, 185.00, 3103, 0x0C1F, $0C, $1F
; G3, 196.00, 3288, 0x0CD8, $0C, $D8
; G#3, 207.65, 3483, 0x0D9B, $0D, $9B
; A3, 220.00, 3690, 0x0E6A, $0E, $6A
; A#3, 233.08, 3910, 0x0F46, $0F, $46
; B3, 246.94, 4142, 0x102E, $10, $2E
; C4, 261.63, 4389, 0x1125, $11, $25
; C#4, 277.18, 4650, 0x122A, $12, $2A
; D4, 293.66, 4926, 0x133E, $13, $3E
; D#4, 311.13, 5219, 0x1463, $14, $63
; E4, 329.63, 5530, 0x159A, $15, $9A
; F4, 349.23, 5859, 0x16E3, $16, $E3
; F#4, 369.99, 6207, 0x183F, $18, $3F
; G4, 392.00, 6576, 0x19B0, $19, $B0
; G#4, 415.30, 6967, 0x1B37, $1B, $37
; A4, 440.00, 7381, 0x1CD5, $1C, $D5
; A#4, 466.16, 7820, 0x1E8C, $1E, $8C
; B4, 493.88, 8285, 0x205D, $20, $5D
; C5, 523.25, 8778, 0x224A, $22, $4A
; C#5, 554.37, 9300, 0x2454, $24, $54
; D5, 587.33, 9853, 0x267D, $26, $7D
; D#5, 622.25, 10439, 0x28C7, $28, $C7
; E5, 659.26, 11060, 0x2B34, $2B, $34
; F5, 698.46, 11718, 0x2DC6, $2D, $C6
; F#5, 739.99, 12414, 0x307E, $30, $7E
; G5, 783.99, 13153, 0x3361, $33, $61
; G#5, 830.61, 13935, 0x366F, $36, $6F
; A5, 880.00, 14763, 0x39AB, $39, $AB
; A#5, 932.33, 15641, 0x3D19, $3D, $19
; B5, 987.77, 16571, 0x40BB, $40, $BB
; C6, 1046.50, 17557, 0x4495, $44, $95
; C#6, 1108.73, 18601, 0x48A9, $48, $A9
; D6, 1174.66, 19707, 0x4CFB, $4C, $FB
; D#6, 1244.51, 20879, 0x518F, $51, $8F
; E6, 1318.51, 22120, 0x5668, $56, $68
; F6, 1396.91, 23436, 0x5B8C, $5B, $8C
; F#6, 1479.98, 24829, 0x60FD, $60, $FD
; G6, 1567.98, 26306, 0x66C2, $66, $C2
; G#6, 1661.22, 27870, 0x6CDE, $6C, $DE
; A6, 1760.00, 29527, 0x7357, $73, $57
; A#6, 1864.66, 31283, 0x7A33, $7A, $33
; B6, 1975.53, 33143, 0x8177, $81, $77
; C7, 2093.00, 35114, 0x892A, $89, $2A
; C#7, 2217.46, 37202, 0x9152, $91, $52
; D7, 2349.32, 39415, 0x99F7, $99, $F7
; D#7, 2489.02, 41758, 0xA31E, $A3, $1E
; E7, 2637.02, 44241, 0xACD1, $AC, $D1
; F7, 2793.83, 46872, 0xB718, $B7, $18
; F#7, 2959.96, 49659, 0xC1FB, $C1, $FB
; G7, 3135.96, 52612, 0xCD84, $CD, $84
; G#7, 3322.44, 55741, 0xD9BD, $D9, $BD
; A7, 3520.00, 59055, 0xE6AF, $E6, $AF
; A#7, 3729.31, 62567, 0xF467, $F4, $67
; B7   $01 $02, $EF set the carry bit to 1

