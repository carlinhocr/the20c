;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2

;SOUND VIA 6522

SOUND_PORTB = $4000
SOUND_PORTA = $4001
SOUND_DDRB = $4002 
SOUND_DDRA = $4003
SOUND_T1CL = $4004
SOUND_T1CH = $4005
SOUND_SR = $400a
SOUND_ACR = $400b
SOUND_PCR = $400c
SOUND_IFR = $400d
SOUND_IER = $400e
SOUND_PORTANH = $400f ;port A no handshake

;SOUND SID 6581

SID_V1FL = $4000
SID_V1FH = $4001
SID_V1PWL = $4002
SID_V1PWLH = $4003
SID_V1CTRL = $4004
SID_V1AD = $4005
SID_V1SR = $4006

SID_V2FL = $4007
SID_V2FH = $4008
SID_V2PWL = $4009
SID_V2PWLH = $400A
SID_V2CTRL = $400B
SID_V2AD = $400C
SID_V2SR = $400D

SID_V3FL = $400E
SID_V3FH = $400F
SID_V3PWL = $4010
SID_V3PWLH = $4011
SID_V3CTRL = $4012
SID_V3AD = $4013
SID_V3SR = $4014

SID_FILTER_FCL = $4015
SID_FILTER_FCH = $4016
SID_FILTER_RF = $4017
SID_FILTER_MV = $4018

SID_POTX = $4019
SID_POTY = $401A
SID_OSC3_RANDOM = $401B
SID_ENV3 = $401C



;ACIA/UART ports
ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003



;VIA Ports and Constant ds
LCD_PORTB = $6000
LCD_PORTA = $6001
LCD_DDRB = $6002 
LCD_DDRA = $6003
LCD_PCR = $600c
LCD_IFR = $600d
LCD_IER = $600e

RS_PORTB = $7000
RS_PORTA = $7001
RS_DDRB = $7002
RS_DDRA = $7003
RS_PCR = $700c
RS_IFR = $700d
RS_IER = $700e

;CIA Ports and Constants
; RS_PORTB = $7001
; RS_PORTA = $7000
; RS_DDRB = $7003
; RS_DDRA = $7002

;zero page memory positions for Vectors and Data


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
record_lenght=$3c ;it is a memory position
serialDataVectorLow = $3d
serialDataVectorHigh = $3e
serialCharperLines = $3f
serialTotalLinesAscii =$40
serialDrawindEndChar=$41

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
sidNotesLow=$5a
sidNotesHigh=$5b

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
  jsr viaLcdInit
  jsr squareTest
  jsr sidTest
loop:
  jmp loop

squareTest:
  jsr viaSoundInit ;j
  ;jsr squareWaveTest;
  ;jsr playMiddleCDelay
  jsr playScale
  jsr playScaleBytes
  jsr playHappyBirthdayBytes
  jsr playMarioBytes
  ;jsr playMario
  rts

sidTest:
  jsr sidNotesExamplePlay
  rts





;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIALCDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaLcdInit:

  ;BEGIN enable interrupts LCD VIA
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  lda #%10000010
  sta LCD_IER 
  ;enable negative edge transition ca1 LCD_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta LCD_PCR 
  ;END enable interrupts

  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta LCD_DDRB ;store the accumulator in the data direction register for Port B

  lda #%11100000  ;set the last 3 pins as output PA7, PA6, PA5 and as input PA4,PA3,PA2,PA1,PA0
  sta LCD_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIALCDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASOUNDINIT---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaSoundInit:

  ;Enable timer 1 to square wave output on pin PB7
  ;lda #%11000000 ;$c0
  ;sta SOUND_ACR 
  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta SOUND_DDRB ;store the accumulator in the data direction register for Port B

  lda #%11111111  ;set the last 3 pins as output PA7, PA6, PA5 and as input PA4,PA3,PA2,PA1,PA0
  sta SOUND_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B

  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASOUNDINIT---------------------------------------
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

sidNotesExamplePlay:
  ;load note address
  lda #< sidNotesExample
  sta sidNotesLow
  lda #> sidNotesExample
  sta sidNotesHigh
  jsr soundSid
  rts

soundSid:
  jsr sidInit
  ;set attacj/decay for Voice 1
  lda #9
  sta SID_V1AD
  ;set sustain/release for Voice 1
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
  lda (sidNotesLow),y 
  cmp #$FF
  beq playSidNotesEnd 
  ;store high frequency for Voice 1
  sta SID_V1FH
  ;load and store low frequency for Voice 1
  iny
  lda (sidNotesLow),y 
  sta SID_V1FL
  ;load and wait duration for Voice 1
  iny
  lda (sidNotesLow),y 
  sta soundDelay
  ;set wave form sawtooth
  lda #33
  sta SID_V1CTRL
  ;wait soundDelay time
  jsr sidSoundDelay
  ;release of wave form sawtooth
  lda #32
  sta SID_V1CTRL
  ;wait 50 for the duration of the release before next note
  lda #50
  sta soundDelay
  jsr sidSoundDelay
  ;play next note
  jmp playSidNotesLoop

playSidNotesEnd:  
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

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SOUND SID -----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SOUND SQUARE PROGRAM-------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

squareWaveTest:
  lda #$70
  sta soundLowByte
  lda #$04
  sta soundHighByte
  jsr playSquareWave
  rts

playMiddleC:
  ;Note A or middle C is 440hz
  ;to play it when running at 1 Mhz
  ;1000000 / 440 = 2272
  ;we divide by 2 to take into account the low and hihg rise of the period
  ;1000000 / 440 / 2 = 1136
  ;decimal to hexa 1136 = $0470
  lda #$70
  sta soundLowByte
  lda #$04
  sta soundHighByte
  jsr playSquareWave
  rts

  
playSquareWave: 
  lda soundLowByte
  ora soundHighByte ;if the OR is zero both bytes are zeroes a wave of aero lenght is empty
  beq squareWaveSilent
  lda soundLowByte
  sta SOUND_T1CL
  lda soundHighByte
  sta SOUND_T1CH
  ;Enable timer 1 to square wave output on pin PB7
  lda #%11000000 ;$c0
  sta SOUND_ACR 

squareWaveSilent:
  lda #%00000000
  sta SOUND_ACR
  rts



squareWaveDelayTest:
  lda #$64
  sta soundLowByte
  lda #$00
  sta soundHighByte
  lda #55
  sta soundDelay
  jsr playSquareWaveDelay
  rts

playMiddleCDelay:
  ;Note A or middle C is 440hz
  ;to play it when running at 1 Mhz
  ;1000000 / 440 = 2272
  ;we divide by 2 to take into account the low and hihg rise of the period
  ;1000000 / 440 / 2 = 1136
  ;decimal to hexa 1136 = $0470
  lda #$70
  sta soundLowByte
  lda #$04
  sta soundHighByte
  lda #55
  sta soundDelay
  jsr playSquareWaveDelay
  rts


playScaleBytes:
  lda #< scaleNotes
  sta musicalNotesLow
  lda #> scaleNotes
  sta musicalNotesHigh
  lda #44 ;zero t 75
  sta totalMusicalBytes
  jsr playNotes
  rts

scaleNotes:
  ;format musical note hight byte, musical note low byte, duration
  .byte $03,$bc,60 ;a5 956
  .byte $03,$54,60 ;d5 852
  .byte $02,$f7,60 ;e5
  .byte $02,$cc,60 ;f5
  .byte $02,$7e,60 ;g5
  .byte $02,$38,60 ;a5
  .byte $01,$fa,60 ;b5
  .byte $01,$de,60 ;c6
  .byte $01,$fa,60 ;b5
  .byte $02,$38,60 ;a5
  .byte $02,$7e,60 ;g5
  .byte $02,$cc,60 ;f5
  .byte $02,$f7,60 ;e5
  .byte $03,$54,60 ;d5
  .byte $03,$bc,60 ;a5
  ;notes hexa 03bc,0354,02f7,02cc,027e,0238,01fa,01de,01fa,0238,027e,02cc,02f7,0354,03bc
  ;notes decimal 956, 852, 759,716,638,568,506,478,506,568,638,716,759,852,956  

playHappyBirthdayBytes:
  lda #< happyBirthdayNotes
  sta musicalNotesLow
  lda #> happyBirthdayNotes
  sta musicalNotesHigh
  lda #74 ;zero t 75
  sta totalMusicalBytes
  jsr playNotes
  rts

happyBirthdayNotes:
;black 0.5 and white 1.0 seconds
;   C4(0.5)  C4(0.5)  D4(0.5)  
;  C4(0.5)  F4(0.5)  E4(1.0)
; C4(0.5)  C4(0.5)  D4(0.5)  
;  C4(0.5)  G4(0.5)  F4(1.0)
; C4(0.5)  C4(0.5)  C5(0.5)  
; A4(0.5)  F4(0.5)  E4(0.5)  
; D4(1.0) 
; A#4(0.5) A#4(0.5) A4(0.5)  
; F4(0.5)  G4(0.5)  F4(1.0)

  .byte $07, $77,60 ;C4
  .byte $07, $77,60 ;C4
  .byte $06, $A6,60 ;D4  
  .byte $07, $77,60 ;C4
  .byte $05, $97,60 ;F4
  .byte $05, $EC,100 ;E4

  .byte $07, $77,60 ;C4
  .byte $07, $77,60 ;C4
  .byte $06, $A6,60 ;D4   
  .byte $07, $77,60 ;C4 
  .byte $04, $FB,60 ;G4
  .byte $05, $97,100 ;F4

  .byte $07, $77,60 ;C4
  .byte $07, $77,60 ;C4
  .byte $03, $BB,60;C5
  .byte $04, $70,60 ;A4
  .byte $05, $97,60 ;F4
  .byte $05, $EC,60 ;E4

  .byte $06, $A6,100 ;D4 

  .byte $04, $30,60 ;A#4
  .byte $04, $30,60 ;A#4
  .byte $04, $70,60 ;A4
  .byte $05, $97,60 ;F4
  .byte $04, $FB,60 ;G4    
  .byte $05, $97,100 ;F4

playMarioBytes:
  lda #< marioNotes
  sta musicalNotesLow
  lda #> marioNotes
  sta musicalNotesHigh
  lda #44 ;zero t 75
  sta totalMusicalBytes
  jsr playNotes
  rts

marioNotes:
  .byte $00,$be,75
  .byte $00,$be,75
  .byte $00,$00,75
  .byte $00,$00,75
  .byte $00,$ef,75
  .byte $00,$be,75  
  .byte $00,$00,75
  .byte $00,$9f,75  
  .byte $00,$00,75
  .byte $00,$00,75
  .byte $00,$00,75   
  .byte $01,$3f,75  
  .byte $00,$00,75
  .byte $00,$00,75
  .byte $00,$00,75   
  .byte $00,$ef,75  

playNotes:  
  ldy #$ff
  ;end at number 29 decimal
playNotesLoop:
  iny
  lda (musicalNotesLow),y ;read high byte
  sta soundHighByte
  iny
  lda (musicalNotesLow),y ; read low byte
  sta soundLowByte
  iny
  lda (musicalNotesLow),y
  sta soundDelay
  jsr playSquareWaveDelay
  cpy totalMusicalBytes
  bne playNotesLoop
  rts

  

playScale:
   ;sound delay 60 always
  lda #60
  sta soundDelay
  ;here are the different notes
  ;956 
  ;852
  ;759
  ;716
  ;638
  ;568
  ;506
  ;478
  ;506
  ;568
  ;638
  ;716
  ;759
  ;852
  ;956
  lda #$bc
  sta soundLowByte
  lda #$03
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$54
  sta soundLowByte
  lda #$03
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$f7
  sta soundLowByte
  lda #$02
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$cc
  sta soundLowByte
  lda #$02
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$7e
  sta soundLowByte
  lda #$02
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$38
  sta soundLowByte
  lda #$02
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$fa
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$de
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$fa
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$38
  sta soundLowByte
  lda #$02
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$7e
  sta soundLowByte
  lda #$02
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$cc
  sta soundLowByte
  lda #$02
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$f7
  sta soundLowByte
  lda #$02
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$54
  sta soundLowByte
  lda #$03
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$bc
  sta soundLowByte
  lda #$03
  sta soundHighByte
  jsr playSquareWaveDelay
  rts

playMario:
  ;sound delay 75 always
  lda #75
  sta soundDelay
  lda #$be
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$be
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$ef
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$be
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$9f
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$3f
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$ef
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$3f
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$7b
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$1c
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$fd
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$0c
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$1c
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$3f
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$be
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$9f
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$8e
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$b3
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$9f
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$be
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$ef
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$d5
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$fd
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$ef
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$3f
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$7b
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$1c
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$fd
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$0d
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$1c
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$3f
  sta soundLowByte
  lda #$01
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$be
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$9f
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$8e
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$b3
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$9f
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$be
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$ef
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$d5
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$fd
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  lda #$00
  sta soundLowByte
  lda #$00
  sta soundHighByte
  jsr playSquareWaveDelay
  rts
  
playSquareWaveDelay: 
;save register accumulator, x and y
  pha ;store accumulator
  txa ;store x
  pha ;store x
  tya ;store y
  pha ;store y
  lda soundLowByte
  ora soundHighByte ;if the OR is zero both bytes are zeroes a wave of aero lenght is empty
  beq squareWaveSilentDelay
  lda soundLowByte
  sta SOUND_T1CL
  lda soundHighByte
  sta SOUND_T1CH
  ;Enable timer 1 to square wave output on pin PB7
  lda #%11000000 ;$c0
  sta SOUND_ACR 

squareWaveSilentDelay:
  lda soundDelay
  tax
  cpx #$0
  beq squareWaveSilentDelayDone
playSquareWaveDelayLoop:
  ldy #$FF
playSquareWaveDelayInnerLoop:
  nop
  nop  
  dey
  bne playSquareWaveDelayInnerLoop
  dex
  bne playSquareWaveDelayLoop

  lda #%00000000
  sta SOUND_ACR
squareWaveSilentDelayDone:
  pla ;recover y
  tay ;recover y
  pla ;recover x
  tax ;recover x
  pla ;recover accummulator
  rts

notesInHexaSquareWave:
;High byte, Low Byte and note name
  .byte $47, $05 ;A0
  .byte $43, $09 ;A#0
  .byte $3F, $46 ;B0
  .byte $3B, $B9 ;C1
  .byte $38, $5E ;C#1
  .byte $35, $34 ;D1
  .byte $32, $38 ;D#1
  .byte $2F, $66 ;E1
  .byte $2C, $BD ;F1
  .byte $2A, $3A ;F#1
  .byte $27, $DC ;G1
  .byte $25, $9F ;G#1
  .byte $23, $82 ;A1
  .byte $21, $84 ;A#1
  .byte $1F, $A3 ;B1
  .byte $1D, $DC ;C2
  .byte $1C, $2F ;C#2
  .byte $1A, $9A ;D2
  .byte $19, $1C ;D#2
  .byte $17, $B3 ;E2
  .byte $16, $5E ;F2
  .byte $15, $1D ;F#2
  .byte $13, $EE ;G2
  .byte $12, $CF ;G#2
  .byte $11, $C1 ;A2
  .byte $10, $C2 ;A#2
  .byte $0F, $D1 ;B2
  .byte $0E, $EE ;C3
  .byte $0E, $17 ;C#3
  .byte $0D, $4D ;D3
  .byte $0C, $8E ;D#3
  .byte $0B, $D9 ;E3
  .byte $0B, $2F ;F3
  .byte $0A, $8E ;F#3
  .byte $09, $F7 ;G3
  .byte $09, $67 ;G#3
  .byte $08, $E0 ;A3
  .byte $08, $61 ;A#3
  .byte $07, $E8 ;B3
  .byte $07, $77 ;C4
  .byte $07, $0B ;C#4
  .byte $06, $A6 ;D4
  .byte $06, $47 ;D#4
  .byte $05, $EC ;E4
  .byte $05, $97 ;F4
  .byte $05, $47 ;F#4
  .byte $04, $FB ;G4
  .byte $04, $B3 ;G#4
  .byte $04, $70 ;A4
  .byte $04, $30 ;A#4
  .byte $03, $F4 ;B4
  .byte $03, $BB ;C5
  .byte $03, $85 ;C#5
  .byte $03, $53 ;D5
  .byte $03, $23 ;D#5
  .byte $02, $F6 ;E5
  .byte $02, $CB ;F5
  .byte $02, $A3 ;F#5
  .byte $02, $7D ;G5
  .byte $02, $59 ;G#5
  .byte $02, $38 ;A5
  .byte $02, $18 ;A#5
  .byte $01, $FA ;B5
  .byte $01, $DD ;C6
  .byte $01, $C2 ;C#6
  .byte $01, $A9 ;D6
  .byte $01, $91 ;D#6
  .byte $01, $7B ;E6
  .byte $01, $65 ;F6
  .byte $01, $51 ;F#6
  .byte $01, $3E ;G6
  .byte $01, $2C ;G#6
  .byte $01, $1C ;A6
  .byte $01, $0C ;A#6
  .byte $00, $FD ;B6
  .byte $00, $EE ;C7
  .byte $00, $E1 ;C#7
  .byte $00, $D4 ;D7
  .byte $00, $C8 ;D#7
  .byte $00, $BD ;E7
  .byte $00, $B2 ;F7
  .byte $00, $A8 ;F#7
  .byte $00, $9F ;G7
  .byte $00, $96 ;G#7
  .byte $00, $8E ;A7
  .byte $00, $86 ;A#7
  .byte $00, $7E ;B7
  .byte $00, $77 ;C8


; Nota, Frecuencia (Hz), Valor Extra, Hexadecimal, High Byte, Low Byte
; A0, 27.50, 18181, 0x4705, $47, $05
; A#0, 29.14, 17161, 0x4309, $43, $09
; B0, 30.87, 16198, 0x3F46, $3F, $46
; C1, 32.70, 15289, 0x3BB9, $3B, $B9
; C#1, 34.65, 14430, 0x385E, $38, $5E
; D1, 36.71, 13620, 0x3534, $35, $34
; D#1, 38.89, 12856, 0x3238, $32, $38
; E1, 41.20, 12134, 0x2F66, $2F, $66
; F1, 43.65, 11453, 0x2CBD, $2C, $BD
; F#1, 46.25, 10810, 0x2A3A, $2A, $3A
; G1, 49.00, 10204, 0x27DC, $27, $DC
; G#1, 51.91, 9631, 0x259F, $25, $9F
; A1, 55.00, 9090, 0x2382, $23, $82
; A#1, 58.27, 8580, 0x2184, $21, $84
; B1, 61.74, 8099, 0x1FA3, $1F, $A3
; C2, 65.41, 7644, 0x1DDC, $1D, $DC
; C#2, 69.30, 7215, 0x1C2F, $1C, $2F
; D2, 73.42, 6810, 0x1A9A, $1A, $9A
; D#2, 77.78, 6428, 0x191C, $19, $1C
; E2, 82.41, 6067, 0x17B3, $17, $B3
; F2, 87.31, 5726, 0x165E, $16, $5E
; F#2, 92.50, 5405, 0x151D, $15, $1D
; G2, 98.00, 5102, 0x13EE, $13, $EE
; G#2, 103.83, 4815, 0x12CF, $12, $CF
; A2, 110.00, 4545, 0x11C1, $11, $C1
; A#2, 116.54, 4290, 0x10C2, $10, $C2
; B2, 123.47, 4049, 0x0FD1, $0F, $D1
; C3, 130.81, 3822, 0x0EEE, $0E, $EE
; C#3, 138.59, 3607, 0x0E17, $0E, $17
; D3, 146.83, 3405, 0x0D4D, $0D, $4D
; D#3, 155.56, 3214, 0x0C8E, $0C, $8E
; E3, 164.81, 3033, 0x0BD9, $0B, $D9
; F3, 174.61, 2863, 0x0B2F, $0B, $2F
; F#3, 185.00, 2702, 0x0A8E, $0A, $8E
; G3, 196.00, 2551, 0x09F7, $09, $F7
; G#3, 207.65, 2407, 0x0967, $09, $67
; A3, 220.00, 2272, 0x08E0, $08, $E0
; A#3, 233.08, 2145, 0x0861, $08, $61
; B3, 246.94, 2024, 0x07E8, $07, $E8
; C4, 261.63, 1911, 0x0777, $07, $77
; C#4, 277.18, 1803, 0x070B, $07, $0B
; D4, 293.66, 1702, 0x06A6, $06, $A6
; D#4, 311.13, 1607, 0x0647, $06, $47
; E4, 329.63, 1516, 0x05EC, $05, $EC
; F4, 349.23, 1431, 0x0597, $05, $97
; F#4, 369.99, 1351, 0x0547, $05, $47
; G4, 392.00, 1275, 0x04FB, $04, $FB
; G#4, 415.30, 1203, 0x04B3, $04, $B3
; A4, 440.00, 1136, 0x0470, $04, $70
; A#4, 466.16, 1072, 0x0430, $04, $30
; B4, 493.88, 1012, 0x03F4, $03, $F4
; C5, 523.25, 955, 0x03BB, $03, $BB
; C#5, 554.37, 901, 0x0385, $03, $85
; D5, 587.33, 851, 0x0353, $03, $53
; D#5, 622.25, 803, 0x0323, $03, $23
; E5, 659.26, 758, 0x02F6, $02, $F6
; F5, 698.46, 715, 0x02CB, $02, $CB
; F#5, 739.99, 675, 0x02A3, $02, $A3
; G5, 783.99, 637, 0x027D, $02, $7D
; G#5, 830.61, 601, 0x0259, $02, $59
; A5, 880.00, 568, 0x0238, $02, $38
; A#5, 932.33, 536, 0x0218, $02, $18
; B5, 987.77, 506, 0x01FA, $01, $FA
; C6, 1046.50, 477, 0x01DD, $01, $DD
; C#6, 1108.73, 450, 0x01C2, $01, $C2
; D6, 1174.66, 425, 0x01A9, $01, $A9
; D#6, 1244.51, 401, 0x0191, $01, $91
; E6, 1318.51, 379, 0x017B, $01, $7B
; F6, 1396.91, 357, 0x0165, $01, $65
; F#6, 1479.98, 337, 0x0151, $01, $51
; G6, 1567.98, 318, 0x013E, $01, $3E
; G#6, 1661.22, 300, 0x012C, $01, $2C
; A6, 1760.00, 284, 0x011C, $01, $1C
; A#6, 1864.66, 268, 0x010C, $01, $0C
; B6, 1975.53, 253, 0x00FD, $00, $FD
; C7, 2093.00, 238, 0x00EE, $00, $EE
; C#7, 2217.46, 225, 0x00E1, $00, $E1
; D7, 2349.32, 212, 0x00D4, $00, $D4
; D#7, 2489.02, 200, 0x00C8, $00, $C8
; E7, 2637.02, 189, 0x00BD, $00, $BD
; F7, 2793.83, 178, 0x00B2, $00, $B2
; F#7, 2959.96, 168, 0x00A8, $00, $A8
; G7, 3135.96, 159, 0x009F, $00, $9F
; G#7, 3322.44, 150, 0x0096, $00, $96
; A7, 3520.00, 142, 0x008E, $00, $8E
; A#7, 3729.31, 134, 0x0086, $00, $86
; B7, 3951.07, 126, 0x007E, $00, $7E
; C8, 4186.01, 119, 0x0077, $00, $77

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------SOUND SQUARE PROGRAM---------------------------------
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



