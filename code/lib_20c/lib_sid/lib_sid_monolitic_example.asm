;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2


;SOUND SID 6581

SID_BASE = $7300

SID_V1FL = SID_BASE + 0
SID_V1FH = SID_BASE + 1
SID_V1PWL = SID_BASE + 2
SID_V1PWLH = SID_BASE + 3
SID_V1CTRL = SID_BASE + 4
SID_V1AD = SID_BASE + 5
SID_V1SR = SID_BASE + 6

SID_V2FL = SID_BASE + 7
SID_V2FH = SID_BASE + 8
SID_V2PWL = SID_BASE + 9
SID_V2PWLH = SID_BASE + $A
SID_V2CTRL = SID_BASE + $B
SID_V2AD = SID_BASE + $C
SID_V2SR = SID_BASE + $D

SID_V3FL = SID_BASE + $E
SID_V3FH = SID_BASE + $F
SID_V3PWL = SID_BASE + $10
SID_V3PWLH = SID_BASE + $11
SID_V3CTRL = SID_BASE + $12
SID_V3AD = SID_BASE + $13
SID_V3SR = SID_BASE + $14

SID_FILTER_FCL = SID_BASE + $15
SID_FILTER_FCH = SID_BASE + $16
SID_FILTER_RF = SID_BASE + $17
SID_FILTER_MV = SID_BASE + $18

SID_POTX = SID_BASE + $19
SID_POTY = SID_BASE + $1A
SID_OSC3_RANDOM = SID_BASE + $1B
SID_ENV3 = SID_BASE + $1C




charDataVectorLow = $30
charDataVectorHigh = $31
delay_COUNT_A = $32        
delay_COUNT_B = $33
screenMemoryLow=$34 ;80 bytes
screenMemoryHigh=$35 
lcdCharPositionsLowZeroPage =$36 
lcdCharPositionsHighZeroPage =$37
lcdROMPositionsLowZeroPage =$38 
lcdROMPositionsHighZeroPage =$39
initialScreenZeroPageLow=$3a
initialScreenZeroPageHigh=$3b
;record_lenght=$3c ;it is a memory position
serialDataVectorLow = $3d
serialDataVectorHigh = $3e
serialCharperLines = $3f
serialTotalLinesAscii =$40
serialDrawindEndChar=$41

octaveOffset=$46
noteFreqLow=$47
noteFreqHigh=$48
musicNote=$49
musicOctave=$4a
notesParseLow=$4b
notesParseHigh=$4c
waveFormV1=$4d
waveFormV2=$4e
waveFormV3=$4f
soundLowByte=$50
soundHighByte=$51
soundDelay=$52
musicalNotesLow=$53
musicalNotesHigh=$54
musicalDurationLow=$55
musicalDurationHigh=$56
totalMusicalBytes=$57
sidLocationLow=$58
sidLocationHigh=$59
sidNotesLowV1=$5a
sidNotesHighV1=$5b
sidNotesLowV2=$5c
sidNotesHighV2=$5d
sidNotesLowV3=$5e
sidNotesHighV3=$5f

;constants
fill=$43 ;letter C
totalScreenLenght4Lines=$50
totalScreenLenght=$3c ;make it only 3 lines long 3c = 60 decimal
totalLineLenght=$13 ;20 positions in hexadecimal is 13
end_char=$ff
cblank=$20

pos_line1=$8B
pos_line2=$CB
pos_line3=$9F
pos_line4=$DF

record_lenght=$09

lenght_screen_lines=$04; 0 to 3
lenght_ascii_line_characters=$20
lenght_screen_characters=$50 ;80 in decimal
pos_lcd_initial_line0=$80
pos_lcd_initial_line1=$C0
pos_lcd_initial_line2=$94
pos_lcd_initial_line3=$D4


;Memory Mappings
;these are constants where we reflect the number of the memory position

screenBufferLow =$00 ;goes to $50 which is 80 decimal
screenBufferHigh =$30

lcdCharPositionsLow =$00 ;goes to $50 which is 80 decimal
lcdCharPositionsHigh =$31

;bin 2 ascii values
value =$0200 ;2 bytes, Low 16 bit half
mod10 =$0202 ;2 bytes, high 16 bit half and as it has the remainder of dividing by 10
             ;it is the mod 10 of the division (the remainder)
message = $0204 ; the result up to 6 bytes
counter = $020a ; 2 bytes

;define LCD signals
E = %10000000 ;Enable Signal
RW = %01000000 ; Read/Write Signal
RS = %00100000 ; Register Select

  .org $8000


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------STACK, INTERRUPTs----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

RESET:
  ;initialize stack
  ldx #$ff
  txs ;transfer x index register to stack register
  ;clear interrupt disable bit
  cli ;sets at zero the interrupt disable bit 
      ;N Z C I D V
      ;- - - 0 - -


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------STACK, INTERRUPTs----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


programStart:
  ;initialize variables, vectors, memory mappings and constans
  ;configure stack and enable interrupts
  ;jsr viaLcdInit
  ;jsr screenInit
  ;jsr sidPlayerMessage  
  ;jsr squareTest
  ;jsr sidTest
  jsr sidNotesExamplePlay
loop:
  jmp loop

; sidPlayerMessage:
;   ;Draw Screen 1 Final Demo
;   lda #<screen1_sidPlayer
;   sta charDataVectorLow
;   lda #>screen1_sidPlayer
;   sta charDataVectorHigh
;   jsr print_ascii_screen  
;   rts

; screen1_sidPlayer:
;   .asciiz "                    "
;   .asciiz "       SID          "
;   .asciiz "      PLAYER        "
;   .asciiz "                    "    







;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SIDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;clear sid register
sidInit:
  ;SID_V1FL is where all sid registers start
  lda #< SID_V1FL
  sta sidLocationLow
  lda #> SID_V1FL
  sta sidLocationHigh
  ldy #$FF
  lda #$0
sidInitLoop:
  iny 
  sta (sidLocationLow),y 
  cpy #$28
  bne sidInitLoop
  rts


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SIDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SOUND SID -----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

sidTest:
  jsr sidInit
  ;set attacj/decay for Voice 1
  ;bits 7-4 attack bits 3-0 decay
  ;9 is 0001 0001
  ;8ms of attack and 24ms of decay
  ;measured on a 1Mhz clock
  ;for other frecuency multiple 1Mhz/other freq
  lda #9;0001 0001
  sta SID_V1AD
  ;set sustain/release for Voice 1
  ;bits 7-4 sustain bits 3-0 release
  ;6 is 0000 0110
  ;sustain at zero amplitud
  ;decay identical to release scale
  ;6 is 204ms
  lda #6
  sta SID_V1SR
  ;set Volume to maximum
  lda #15
  sta SID_FILTER_MV
  lda #$1C ;a4 high byte
  sta SID_V1FH
  lda #$D5; a4 low byte
  sta SID_V1FL
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  ;lda #33 ;
  ;sta SID_V1CTRL
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  lda #$03
  sta SID_BASE + 2
  lda #$FF
  sta SID_BASE + 3
  lda #%01000001 ;
  sta SID_V1CTRL
  jmp sidTest

testSidLoop:
  jmp testSidLoop

sidTestMultiNotes:
  jsr sidInit
  ;store contro byte wave form for each voice
  lda #%00010001 ; triangle 17 set the code bit and start
  sta waveFormV1
  lda #%01000001 ; square 65 set the code bit and start
  sta waveFormV2
  lda #%00100001 ; sawtooth 17 set the code bit and start
  sta waveFormV3
  ldy #$FF
sidTestMultiNotesDecodeNotes:
  iny 
  rts


sidNotesExamplePlay:
  ;load note address
  lda #<sidNotesExample
  sta sidNotesLowV1
  lda #>sidNotesExample
  sta sidNotesHighV1
  jsr soundSid
  lda #<sidScale
  sta sidNotesLowV1
  lda #>sidScale
  sta sidNotesHighV1
  jsr soundSid
  lda #<sidScale
  sta sidNotesLowV1
  lda #>sidScale
  sta sidNotesHighV1
  lda #<sidScale
  sta sidNotesLowV2
  lda #>sidScale
  sta sidNotesHighV2
  lda #<sidScale
  sta sidNotesLowV3
  lda #>sidScale
  sta sidNotesHighV3
  jsr soundSid3VoicesExample
  rts

soundSid3VoicesExample:
  jsr sidInit
  ;set attacj/decay for Voice 1,2,3
  ;bits 7-4 attack bits 3-0 decay
  ;9 is 0001 0001
  ;8ms of attack and 24ms of decay
  ;measured on a 1Mhz clock
  ;for other frecuency multiple 1Mhz/other freq  
  ;
  lda #9;0001 0001
  sta SID_V1AD
  ;organ for voice 2
  lda #0;0000 0000 
  sta SID_V2AD
  ;violin for voice 3
  lda #$A8;1010 1000 
  sta SID_V3AD
  ;set sustain/release for Voice 1,2,3
  ;bits 7-4 sustain bits 3-0 release
  ;6 is 0000 0110
  ;sustain at zero amplitud
  ;decay identical to release scale
  ;6 is 204ms
  lda #6
  sta SID_V1SR
    ;organ for voice 2
  lda #15;0000 1111 
  sta SID_V2SR
  ;violin for voice 3
  lda #$A9;1010 1001 
  sta SID_V3SR

  ;set Volume to maximum
  lda #15
  sta SID_FILTER_MV
playSidNotes3Voices:  
  ;play notes
  ldy #$FF
playSidNotesLoop3Voices:
  iny 
  lda (sidNotesLowV1),y 
  cmp #$FF
  beq playSidNotesEnd3Voices 
  ;store high frequency for Voice 1,2,3
  sta SID_V1FH
  lda (sidNotesLowV2),y 
  sta SID_V2FH
  lda (sidNotesLowV3),y 
  sta SID_V3FH
  ;load and store low frequency for Voice 1,2,3
  iny
  lda (sidNotesLowV1),y 
  sta SID_V1FL
  lda (sidNotesLowV2),y 
  sta SID_V2FL
  lda (sidNotesLowV3),y 
  sta SID_V3FL
  ;load and wait duration for Voice 1 for the 3 voices
  iny
  lda (sidNotesLowV1),y 
  sta soundDelay
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  lda #33 ; sawtooth ;0010000
  sta SID_V1CTRL
  lda #%01000001 ;square
  sta SID_V2CTRL
  lda #%00010001 ;triangle
  sta SID_V3CTRL
  ;wait soundDelay time
  jsr sidSoundDelay
  ;00100001 
  ;bit 5 selects sawtooth
  ;the last bit turns off starts the Release Phase
  lda #32 ;0010000
  sta SID_V1CTRL
  lda #%01000000 ;square
  sta SID_V2CTRL
  lda #%00010000 ;triangle
  sta SID_V3CTRL
  ;wait 50 for the duration of the release before next note
  lda #50
  sta soundDelay
  jsr sidSoundDelay
  ;play next note
  jmp playSidNotesLoop3Voices

playSidNotesEnd3Voices:  
  ;jmp playSidNotes ;keep playing in loop
  ;it reaches here when the hight byte for
  ;the ound note is $FF
  rts

soundSid:
  jsr sidInit
  ;set attacj/decay for Voice 1
  ;bits 7-4 attack bits 3-0 decay
  ;9 is 0001 0001
  ;8ms of attack and 24ms of decay
  ;measured on a 1Mhz clock
  ;for other frecuency multiple 1Mhz/other freq  
  lda #9;0001 0001
  sta SID_V1AD
  ;set sustain/release for Voice 1
  ;bits 7-4 sustain bits 3-0 release
  ;6 is 0000 0110
  ;sustain at zero amplitud
  ;decay identical to release scale
  ;6 is 204ms
  lda #6
  sta SID_V1SR
  ;set Volume to maximum
  lda #15
  sta SID_FILTER_MV
playSidNotes:  
  ;play notes
  ldy #$FF
playSidNotesLoop:
  iny 
  lda (sidNotesLowV1),y 
  cmp #$FF
  beq playSidNotesEnd 
  ;store high frequency for Voice 1
  sta SID_V1FH
  ;load and store low frequency for Voice 1
  iny
  lda (sidNotesLowV1),y 
  sta SID_V1FL
  ;load and wait duration for Voice 1
  iny
  lda (sidNotesLowV1),y 
  sta soundDelay
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  lda #33 ;
  sta SID_V1CTRL
  ;wait soundDelay time
  jsr sidSoundDelay
  ;00100001 
  ;bit 5 selects sawtooth
  ;the last bit turns off starts the Release Phase
  lda #32 ;0010000
  sta SID_V1CTRL
  ;wait 50 for the duration of the release before next note
  lda #50
  sta soundDelay
  jsr sidSoundDelay
  ;play next note
  jmp playSidNotesLoop

playSidNotesEnd:  
  ;jmp playSidNotes ;keep playing in loop
  ;it reaches here when the hight byte for
  ;the ound note is $FF
  rts
  
sidSoundDelay:
  ;save state to the stack
  pha ;store accumulator
  txa ;store x
  pha ;store x
  tya ;store y
  pha ;store y
  lda soundDelay
  tax
  cpx #$0
  beq sidSoundDelayDone
sidSoundDelayLoop:
  ldy #$FF
sidSoundDelayInnerLoop:
  nop
  nop  
  dey
  bne sidSoundDelayInnerLoop
  dex
  bne sidSoundDelayLoop
sidSoundDelayDone:  
  pla ;recover y
  tay ;recover y
  pla ;recover x
  tax ;recover x
  pla ;recover accummulator
  rts

parseNotes:
  rts


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

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SOUND SID -----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------PARSER NOTES --------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

songExampleNotes:
  .asciiz "c5,d5,e5,f5,g5,a5,b5,a5,g5,f5,e5,d5,c5,z"

parserNotes:
  ldx #$FF
parserNotesLoop:
  inx
  lda songExampleNotes,x ;here I load note
  cmp #$7a;"z"
  beq parserNotesEnd
  sec
  sbc #$61
  sta musicNote ;0=a,1=b,etc ...8=b#7 9=b#7
  inx  ;the X is for the octave or #
  lda songExampleNotes,x ;here i load octave or #
  cmp #$23;"#"
  bne parseOctave ;jumping with the octave on the accumulator and x index
  lda #$7
  clc
  adc musicNote

  ;if musicNote was a then its value was 0
  ;if I find de # the value is 0+7
  ;finding its place in frequenciesSid_1Mhz_alphabetic
  inx ; get X index to the octave after #
parseOctave:
  lda songExampleNotes,x
  sec ;lets substract 30 to obtain the number instead of ascii code
  sbc #$30
  sta musicOctave
  inx
  lda songExampleNotes,x
  cmp #$2C ;" ,  "
  beq parserNotesLoop
  
parserNotesEnd:
  rts

; noteToFrequency:
;   lda musicNote
;   cmp #0 ;it is the note a
;   beq calculateNote ;calculating the case it was a
;   ;multiply by 2 musicNote to position the byte offset
;   ;for all othe notes
;   clc
;   rol musicNote
; calculateNote:  
;   ;load high byte and save it
;   ldx musicNote
;   lda frequenciesSid_1Mhz_alphabetic,x
;   sta noteFreqHigh
;   ;load low byte and save it
;   inx
;   lda frequenciesSid_1Mhz_alphabetic,x
;   sta noteFreqLow
;   ;calculate octave offset
;   lda #7 ;highest octave
;   sec
;   sbc musicOctave
;   sta octaveOffset
;   ;rol according to octave
;   clc ;clear carry to roll for all notes but B
;   lda musicNote ;already multiplied if 2 it is note B
;   bne calculateOctave
;   sec ;set carry for note B
;   ldy octaveOffset
; calculateOctave:
;   cpy #$0
;   beq noteToFrequencyDone







;   cmp #$63 ;"c" and "c#"
;   beq noteC
;   cmp #$64 ;"d" and "d#"
;   beq noteD
;   cmp #$65 ;"e"
;   beq noteE
;   cmp #$66 ;"f" and "f#"
;   beq noteF
;   cmp #$67 ;"g" and "g#"
;   beq noteG
;   cmp #$61 ;"a" and "a#"
;   beq noteA
;   cmp #$62 ;"b"
;   beq noteB

; noteC:
;   inx  ;the X is for the octave or #
;   lda songExampleNotes,x ;here i load octave or #
;   cmp #$23;"#"
;   beq noteCNumeral
;   lda #$0 ;0 note for C ;if not # save the note
;   sta musicNote
;   beq parseOctave
; noteCNumeral:
;   lda #$1 ;1 note for c#
;   sta musicNote
;   inx
;   beq parseOctave

; noteD:
;   inx ;the X is for the octave or # 
;   lda songExampleNotes,x 
;   cmp #$23;"#"
;   beq noteDNumeral
;   lda #$2 ;2 note for D
;   sta musicNote
;   beq parseOctave
; noteDNumeral:
;   lda #$3 ;3 note for D#
;   sta musicNote
;   inx
;   beq parseOctave

; noteE:
;   inx ;the X is for the octave or # 
;   lda songExampleNotes,x 
;   lda #$4 ;2 note for D
;   sta musicNote
;   beq parseOctave

; noteF:
;   inx  ;the X is for the octave or #
;   lda songExampleNotes,x ;here i load octave or #
;   cmp #$23;"#"
;   beq noteFNumeral
;   lda #$5 ;0 note for f ;if not # save the note
;   sta musicNote
;   beq parseOctave
; noteFNumeral:
;   lda #$6 ;1 note for f#
;   sta musicNote
;   inx
;   beq parseOctave  

; noteG:
;   inx  ;the X is for the octave or #
;   lda songExampleNotes,x ;here i load octave or #
;   cmp #$23;"#"
;   beq noteGNumeral
;   lda #$7 ;0 note for g ;if not # save the note
;   sta musicNote
;   beq parseOctave
; noteGNumeral:
;   lda #$8 ;1 note for g#
;   sta musicNote
;   inx
;   beq parseOctave  

; noteA:
;   inx  ;the X is for the octave or #
;   lda songExampleNotes,x ;here i load octave or #
;   cmp #$23;"#"
;   beq noteANumeral
;   lda #$9 ;0 note for g ;if not # save the note
;   sta musicNote
;   beq parseOctave
; noteANumeral:
;   lda #$a ;1 note for g#
;   sta musicNote
;   inx
;   beq parseOctave 

; noteB:
;   inx ;the X is for the octave or # 
;   lda songExampleNotes,x 
;   lda #$b ;2 note for D
;   sta musicNote
;   beq parseOctave  

; parseOctave:
;   lda songExampleNotes,x
;   sec ;lets substract 30 to obtain the number instead of ascii code
;   sbc #$30
;   sta musicOctave
;   inx
;   lda songExampleNotes,x
;   cmp #$2C ;" ,  "
;   beq parserNotesLoop
  
; parserNotesEnd:
;   rts
 

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------PARSER NOTES --------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

delay_1_sec:
  jsr DELAY_SEC
  rts

delay_2_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

delay_3_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

delay_4_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts 

delay_5_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

DELAY_onetenth_SEC:
  lda #$10
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

DELAY_two_tenth_SEC:
  lda #$10
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN   

DELAY_SEC:
  lda #$FF
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

DELAY_HALF_SEC:
  lda #$50
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

DELAY_MAIN:
    LDX delay_COUNT_A     ; Load outer loop count
OUTER_LOOP:
    LDY delay_COUNT_B     ; Load inner loop count
INNER_LOOP:
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    DEY               ; Decrement inner loop counter
    BNE INNER_LOOP    ; Branch if not zero
    DEX               ; Decrement outer loop counter
    BNE OUTER_LOOP    ; Branch if not zero
    RTS               ; Return from subroutine

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



nmi:
irq:
    rti

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



