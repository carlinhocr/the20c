;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2

;SOUND VIA

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
  jsr squareWaveTest;
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
  lda #$64
  sta soundLowByte
  lda #$00
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

  
playSquareWaveDelay: 
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
  lda #$0
  cmp soundDelay
  beq squareWaveSilentDelayDone
playSquareWaveDelayLoop:
  ldy #$FF
playSquareWaveDelayInnerLoop:
  nop
  nop  
  dey
  bne playSquareWaveDelayInnerLoop
  dec soundDelay
  bne playSquareWaveDelayLoop

  lda #%00000000
  sta SOUND_ACR
squareWaveSilentDelayDone:
  rts

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



