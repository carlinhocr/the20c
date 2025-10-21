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
  jsr viaSoundInit
  ;jsr squareWaveTest;
  ;jsr playMiddleCDelay
  jsr playScale
  jsr playScaleBytes
  jsr playHappyBirthdayBytes
  jsr playMarioBytes
  ;jsr playMario
loop:
  jmp loop




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
;--------------------------------SOUNDPROGRAM---------------------------------------
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
  cpy #44
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

notesInHexa:
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
;--------------------------------SOUNDPROGRAM---------------------------------------
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



