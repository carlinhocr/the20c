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
;record_lenght=$3c ;it is a memory position
serialDataVectorLow = $3d
serialDataVectorHigh = $3e
serialCharperLines = $3f
serialTotalLinesAscii =$40
serialDrawindEndChar=$41

soundLowByte=$50
soundHighByte=$51
soundDelay=$52

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
  jsr viaLcdInit
  jsr viaSoundInit
  jsr uartSerialInit
  jsr screenInit
  jsr lcdDemoMessage
  jsr mainProgram
  jmp listeningMode
; jsr portBTest
;  jsr serialTesting3_rxtx
;  jsr programLoop

lcdDemoMessage:

  ;Draw Screen 1 Final Demo
  lda #<screen1_demo
  sta charDataVectorLow
  lda #>screen1_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  ;Draw Screen 2 Final Demo
  lda #<screen2_demo
  sta charDataVectorLow
  lda #>screen2_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  rts 


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------ASCII----------------------------------------------
;-----------------------------------------------------------------------------------

set_position_lcd_line0:
  lda #pos_lcd_initial_line0
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line1:
  lda #pos_lcd_initial_line1
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line2:
  lda #pos_lcd_initial_line2
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line3:
  lda #pos_lcd_initial_line3
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
reset_screen_position:
  lda #pos_lcd_initial_line0
  jsr lcd_send_instruction 
  jmp print_ascii_screen_end

print_ascii_screen:  
  ;BEGIN print_ascii_screen
  jsr clear_display
  ldx #$ff ; start as ff so when i add 1 it goes to zero
  ldy #$ff ; jsut at the begginning so it would got all the 80 characters of the screen
print_ascii_screen_line:  
  inx
  cpx #$00
  beq set_position_lcd_line0
  cpx #$01
  beq set_position_lcd_line1
  cpx #$02
  beq set_position_lcd_line2
  cpx #$03
  beq set_position_lcd_line3
  cpx #$04
  beq reset_screen_position ; to reset the screen to initial position
print_ascii_screen_eeprom:
  iny ;so it would go out of a last byte equal 0 loop
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  beq print_ascii_screen_line ; jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr print_char 
  jmp print_ascii_screen_eeprom
print_ascii_screen_end:
  rts 
  ;END print_ascii_screen


;END---------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------ASCII----------------------------------------------
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
;--------------------------------VIASERIALINIT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaSerialInit:

  ;set all port A pins as output but bit 6
  ;bit 6 is the input from the serial protocol
  lda #%10111111  ;load all ones equivalent to $FF but bit 6
  sta RS_DDRA ;store the accumulator in the data direction register for Port A

  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta RS_DDRB ;store the accumulator in the data direction register for Port B

  lda #1
  sta RS_PORTA
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASERIALINIT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------UARTSERIALINIT-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

uartSerialInit:

  ;reset UART 6551 by writting to thestatus register
  lda #$00
  sta ACIA_STATUS

  ;configure the control register
  ;bit 7 = 0 -> 1 Stop Bit
  ;bit 6 =0 and bit 5=0 -> 8 bits word lenght
  ;bit 4 = 1 -> receiver clock source is baud rate
  ;bit 3 =1 bit 2=1 bit 1=1 bit 0=0 -> 9600 baudios as a baud rate
  ;bit 3 =1 bit 2=1 bit 1=1 bit 0=1 -> 19200 baudios as a baud rate
  ;lda #%00011110 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 9600 baudios
  lda #%00011111 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 19200 baudios
  sta ACIA_CTRL

  ;configure the command register
  ;bit 7 = 0 and bit 6 =0 -> odd parity but we will not be using parity
  ;bit 5=0 -> disable parity
  ;bit 4 = 0 -> disable ECHO
  ;bit 3 =1 bit 2=0 -> RTSB Active Low and Interrupts Disable
  ;bit 1 =1 -> Receiver interrupt request disable
  ;bit 0 =1 -> Data terminal Ready (DTRB Low)
  lda #%00001011 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 9600 baudios
  sta ACIA_CMD

  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------UARTSERIALINIT-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN PROGRAM---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
mainProgram:
  jsr printMessage01
  jsr delay_3_sec
  jsr printMessage02
  jsr delay_3_sec
  jsr printMessage03
  jsr delay_3_sec
  jsr printthe20cAscii
  jsr delay_3_sec
  jsr printMessage04
  jsr delay_3_sec  
  jsr printMessage05
  jsr delayClear 
  jsr printTrucoAscii
  jsr delayClear 
  jsr printMessage06
  jsr delayClear   
  jsr printCiberCirujas  
  jsr delayClear   
  jsr printArcadeAscii
  jsr delayClear   
  jsr printModoHistoriaAscii
  jsr delayClear   
  jsr printVentilastationAscii
  jsr delayClear  
  jsr printReplay
  jsr delayClear    
  jsr printMessage07
  jsr delayClear   
  jsr printCommodoreAscii
  jsr delayClear 
  jsr printMarioAscii
  jsr playMario
  ;jsr delayClear     
;   jsr print20cAscii
  rts

delayClear:
  jsr delay_3_sec  
  jsr printClearRS232Screen
  rts

printthe20cAscii:
  lda #< the20cAscii
  sta serialDataVectorLow
  lda #> the20cAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

printMarioAscii:
  lda #< marioReverseAscii
  sta serialDataVectorLow
  lda #> marioReverseAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

printCiberCirujas:
  lda #< cyberCirujasAscii
  sta serialDataVectorLow
  lda #> cyberCirujasAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

printReplay:
  lda #< replayAscii
  sta serialDataVectorLow
  lda #> replayAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printTrucoAscii:
  lda #< trucoAscii
  sta serialDataVectorLow
  lda #> trucoAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts    

printArcadeAscii:
  lda #< arcadeAscii
  sta serialDataVectorLow
  lda #> arcadeAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printModoHistoriaAscii:
  lda #< modoHistoriaAscii
  sta serialDataVectorLow
  lda #> modoHistoriaAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts    

printCommodoreAscii:
  lda #< commodoreAscii
  sta serialDataVectorLow
  lda #> commodoreAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

printVentilastationAscii:
  lda #< ventilastationAscii
  sta serialDataVectorLow
  lda #> ventilastationAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

print20cAscii:
  lda #< la20cAscii
  sta serialDataVectorLow
  lda #> la20cAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

; printEspacioTecAscii:
;   lda #< espacioTecAscii
;   sta serialDataVectorLow
;   lda #> espacioTecAscii 
;   sta serialDataVectorHigh
;   jsr printAsciiDrawing
;   rts   

printClearRS232Screen:
  lda #< clearRS232Screen
  sta serialDataVectorLow
  lda #> clearRS232Screen 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

printMessage01:
  lda #< message01
  sta serialDataVectorLow
  lda #> message01 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printMessage02:
  lda #< message02
  sta serialDataVectorLow
  lda #> message02 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

printMessage03:
  lda #< message03
  sta serialDataVectorLow
  lda #> message03 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts     

printMessage04:
  lda #< message04
  sta serialDataVectorLow
  lda #> message04 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts    

printMessage05:
  lda #< message05
  sta serialDataVectorLow
  lda #> message05 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts      

printMessage06:
  lda #< message06
  sta serialDataVectorLow
  lda #> message06 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printMessage07:
  lda #< message07
  sta serialDataVectorLow
  lda #> message07 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts    

printAsciiDrawing:
  ;here print first line
  jsr send_rs232_line
  ldx #$0 ;the first line 0 we aleready printed
printAsciiDrawing_lenghts_loop:
  inx ;now going to line 1
  ;here increment on additional lines
  clc
  lda serialDataVectorLow ;load marioascii low
  adc serialCharperLines ; add the number of records of the last send_rs232_line
  sta serialDataVectorLow ; store the new value
  bcc printAsciiDrawing_lenghts_no_carry ;branch on carry clear or no carry
  ;if there is a carry it is in the carry flag
  ; clear the carry and add one to the high order byte
  clc
  lda serialDataVectorHigh
  adc #1; adds the carry if there is one
  sta serialDataVectorHigh
printAsciiDrawing_lenghts_no_carry  
  ;here printing the new mario line
  ldy #0
  lda (serialDataVectorLow),y 
  cmp #$65;"e"
  beq printAsciiDrawing_end
  jsr send_rs232_line
  jmp printAsciiDrawing_lenghts_loop
  ;cpx serialTotalLinesAscii ;check to see if 27 lines where printed from 1 to 26
  ;bne printAsciiDrawing_lenghts_loop
  ;return and increment according to the lenght of the mario screen
  ;end by jumping to listening mode
printAsciiDrawing_end:
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN PROGRAM-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SOUNDPROGRAM---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
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
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SOUNDPROGRAM---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALUART-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
serialUART:

  ldx #0
send_rs232_message:
  ;lets send a message
  lda rs232_message,x ;test for the NULL char that ends all ASCII strings
  beq send_rs232_message_end
  jsr send_rs232_char
  inx
  jmp send_rs232_message  

send_rs232_message_end:
  ;print cr
  lda #$0d
  jsr send_rs232_char
  lda #$0a
  jsr send_rs232_char 
  rts

rs232_message: .asciiz "RS-232 Terminal for 20c" ;\r carriage return \n line feed 

send_rs232_line:
  ldy #$0
send_rs232_line_loop:
  lda (serialDataVectorLow),y 
  ;test for the NULL char that ends all ASCII strings
  beq send_rs232_line_end
  jsr send_rs232_char
  iny
  jmp send_rs232_line_loop 
send_rs232_line_end:
  ;add the number of characters printed + 1 for the null char
  ;store in serialCharperLines
  clc
  tya
  adc #1
  sta serialCharperLines
  jsr send_rs232_CRLF
  rts  

send_rs232_CRLF:
  lda #$0d
  jsr send_rs232_char
  lda #$0a
  jsr send_rs232_char 
  rts   

listeningMode: 
  jmp loopReceiveData ;go to listening mode
  
  
  ;wait until the status register bit 3 receive data register is full =1, then 
  ;read the data register
loopReceiveData:
   
  lda ACIA_STATUS
  and #%00001000; and it to see if bit 3 is one, delete all the other bits
  beq loopReceiveData ; if zero we have not received anythinßg
  ;if we are here we have a byte to read
  lda ACIA_DATA ;read character
  jsr print_char ;print the char on the local lcd of the 20 c
  jsr send_rs232_char ;echo the character typed
  jmp loopReceiveData ;go to wait for next character
  rts

send_rs232_char:
  sta ACIA_DATA ;wrie whatever is on the accumulator to the transmit register
  ; preserve accumulator
  pha 
  ; preserve Y register
  tya  
  pha
  ; preserve X register
  txa  
  pha  

  ;check to see if the transmit data register is empty bit 4 of the status register
tx_wait:  
  lda ACIA_STATUS
  and #%00010000 ;leave vae only bit 4 on the accumulator
  beq tx_wait ;if zero the transmit buffer is full so we wait
  jsr tx_delay ; solve bit 4 hardware issue on the wdc issue
  ;recover X register
  pla
  tax
  ;recover y register
  pla
  tay
  ; recover accumulator
  pla 
  rts

tx_delay:
  ;at 19200 bauds it is 1 bit every 52 clock cycles
  ;so 8 bits + start and stop bit it is 10 bits or 520 cycles
  ldy #102
tx_delay_loop:  
  dey ;2 cycles
  bne tx_delay_loop ; 3 cycles
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALUART-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

portBTest:
; blibk pin 0 of PORT B
  lda #%11111111 
  sta RS_PORTB
  jsr delay_2_sec
  lda #%00000000 
  sta RS_PORTB
  jsr delay_2_sec
  jmp portBTest
  rts

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALTESTING------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


serialTesting3_rxtx:
;use BIT instruction because it test bit 7 and 6 on the negative and overflow flag
;we will be using the overflow flag to check on bit 6 of PORTA
;BVC branch if overflow is zero CLEAR
;BVS branch if overflow is one SET

  ;set high the transmit bit , transmitting from the 20c
  ;pin 0 of port A must be output
  ;the mas 232 will translate +5v to +7v so it is a zero in the rs-232 protocol
  lda #1
  sta RS_PORTA
  jsr bit_delay
  jsr bit_delay
  jsr bit_delay

  lda #"*"
  sta $0200

 ;set a 0 in port A pin 0
 ;send the start bit as the first bit ZERO
  lda #%11111110          ;2
  and RS_PORTA      ;4
  sta RS_PORTA      ;4
  ;loop through all 8 bits of the character
  ldx #8            ;2
  ;wait start bit for 104 microseconds add 28 more cycles = 14 nops
  ;this equals 30 cycles

write_bit:  
  ;delay for 104 microseconds
  jsr bit_delay_write ; 6
  ;get the each bit in turn on the carry flag
  ror $0200         ;6
  bcs send_1        ;2 +1if the branch is taken
  ;send 0
  lda #%11111110    ;2
  and RS_PORTA      ;4
  sta RS_PORTA      ;4
  jmp tx_done       ;3
  ;write bit 0 = 6+2+4+4+3
send_1:
  ;set a 1 in port A pin 0
  lda #%00000001    ;2
  ora RS_PORTA      ;4
  sta RS_PORTA      ;4
  ;write bit 1 = 6+2+4+4
tx_done:   
  dex               ;2
  bne write_bit     ;2
  ;total bit 0 = 6+6+2+2+4+4+3+2+2 = 29
  ;total bit 1 = 6+6+2+2+1+4+4+2+2 = 28
  ;wait 104 microsecons for the last bit  
  ldx #20 ;2
  nop ;2
  ;2+2+20*5
wait_104:  
  dex ;2
  bne wait_104 ;3
  ;set a 1 in port A pin 0
  ;set the transmit pin high for the stop bit
  lda #%00000001
  ora RS_PORTA
  sta RS_PORTA 
  jsr bit_delay
 
rx_wait:
  ;loop waiting on the start BIT
  bit RS_PORTA ; put PORTA.bit6 into overflow V flag
  bvs rx_wait ; check for overflow flag and keep looping if it is high
  jsr half_bit_delay ; wait after the start bit to sample midbit the rs232 signals
  ;loop to load 8 bits
  ldx #8 ;set to read 8 bits
read_bit:
  jsr bit_delay ;have a delay so we can time the charcters for 104 microsecons of 9600 bps 
  bit RS_PORTA ;put PORTA.6 bit on the overflow flag
  ;put the overflow flag on the carry bit
  bvs recv_1
  clc ;if here we received a zero
  jmp rx_done
recv_1:
  sec ;set carry flag because we read a one
  nop ;compensate for branch duration
  nop
rx_done:
  ror ;get the carry bit into bit 7 of the accumulator
  dex ;decrement the number of bits read
  bne read_bit
  ;All bits now in accumulator
  jsr print_char ; pint the character
  jsr bit_delay ;wait out the stop bit
  jmp rx_wait ; return after 8 bits were read

bit_delay:
  nop ;compensate because i am not using phx +4
  nop
  ldy #13 ;decimal 13 to wait 104 microseconds because the former code takes 39 or 40 microseconds
bit_delay_loop:
  dey       
  bne bit_delay_loop  
  nop ;compensate because i am not using plx
  nop 
  rts

bit_delay_write:
;decimal 13 to wait 104 microseconds because the former code takes 29 or 28 microseconds
  ;29+2(ldy)+6(rts)+X=104
  ;37+x=104
  ;x=67
  ;loop =4 cycles
  ;wait = 67/5 =13,4

  ;36+y=104
  ;y=66
  ;loop 5 cycles
  ;wait =66/5= 13,2
  ldy #13   ;2
bit_delay_loop_write:
  dey       ;2
  bne bit_delay_loop_write  ;5
  rts       ;6

half_bit_delay:
  ldy #6 ;decimal 6 to wait 52 microseconds to read in the middle of the bits
half_bit_delay_loop:
  dey
  bne half_bit_delay_loop  
  rts  

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SCREEN MANAGEMENT----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

; Positions of LCD characters
; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 1	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 2	94	95	96	97	98	99	9a	9b	9c	9d	9e	9f	a0	a1	a2	a3	a4	a5	a6	a7
; 3	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7


; Posible ordinal positions

; 01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  A,  B,  C,  D,  E,  F,  10, 11, 12, 13
; 14, 15, 16, 17, 18, 19, 1A, 1B, 1C, 1D, 1E, 1F, 20, 21, 22, 23, 24, 25, 26, 27
; 28, 29, 2A, 2B, 2C, 2D, 2E, 2F, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 3A, 3B
; 3C, 3D, 3E, 3F, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 4A, 4B, 4C, 4D, 4E, 4F

screenInit:
  jsr initilize_display
  jsr clear_display
  jsr loadCursorPositions
  jsr loadScreen
  jsr drawScreen
  jsr DELAY_SEC   
  jsr clearScreenBuffer
  jsr drawScreen 
  rts

; create a matrix of cursor positions in memory 4x20
loadCursorPositions:
  ;load vectors
  lda #lcdCharPositionsLow
  sta lcdCharPositionsLowZeroPage ; to use indirect addressing with y
  lda #lcdCharPositionsHigh
  sta lcdCharPositionsHighZeroPage
  lda #<lcd_positions
  sta lcdROMPositionsLowZeroPage
  lda #>lcd_positions
  sta lcdROMPositionsHighZeroPage
  ldy #$ff
loadCursorPositionsLoop:
  iny
  cpy #totalScreenLenght4Lines 
  ;cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq loadCursorPositionsEnd
  ; copy from ROM to RAM the LCD positions
  lda (lcdROMPositionsLowZeroPage),Y
  sta (lcdCharPositionsLowZeroPage),Y
  jmp loadCursorPositionsLoop
loadCursorPositionsEnd:
  rts

loadScreen:
  ;load vectors
  lda #screenBufferLow
  sta screenMemoryLow ; to use indirect addressing with y
  lda #screenBufferHigh
  sta screenMemoryHigh
  lda #<initialScreen
  sta initialScreenZeroPageLow
  lda #>initialScreen
  sta initialScreenZeroPageHigh
  ldy #$ff
loadScreenLoop:
  iny
  cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq loadCursorPositionsEnd
  ; copy from ROM to RAM the LCD positions
  lda (initialScreenZeroPageLow),Y
  sta (screenMemoryLow),Y
  jmp loadScreenLoop
loadScreenEnd:
  rts

drawScreen:
  ldy #$ff
drawScreenLoop:
  iny
  cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq drawScreenEnd
  ;position cursor
  lda (lcdCharPositionsLowZeroPage),Y ;load cursor position
  jsr lcd_send_instruction ; position cursor
  ;write screen character
  lda (screenMemoryLow),Y ;load character
  jsr print_char 
  jmp drawScreenLoop
drawScreenEnd:
  rts


print_screen:  
  ;BEGIN Write all the letters 
  ldy #$00 ;first byte is the position of the line
print_screen_load_position:
  lda (charDataVectorLow),y
  cmp #end_char;compare to ending character
  beq print_screen_end ;jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr lcd_send_instruction 
  ldx #$00
print_screen_eeprom:  
  iny
  inx
  cpx record_lenght ; record lenght is a memory position now
  beq print_screen_load_position
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  jsr print_char 
  jmp print_screen_eeprom
print_screen_end:
  rts   

print_message:  
  ;BEGIN Write all the letters
  ldy #$00 ;start on FF so when i add one it will be 0

print_message_eeprom:  
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  beq print_message_end ; jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr print_char 
  iny
  jmp print_message_eeprom
print_message_end:
  rts 
  ;END Write all the letters  

clearScreenBuffer: 
  ldy #$FF 
clearScreenBufferLoop:
  iny      
  cpy #$50
  beq clearScreenBufferEnd
  lda #cblank ;load ship form
  sta (screenMemoryLow),y ;at the alien position en Y draw the alien ship on the accumulator
  jmp clearScreenBufferLoop 
clearScreenBufferEnd: 
  rts    


;END--------------------------------------------------------------------------------  
;-----------------------------------------------------------------------------------
;--------------------------------SCREEN MANAGEMENT----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------Binary to Ascii------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



bin_2_ascii:
divide:
  ;initialize the remainder to be 0
  lda #0
  sta mod10
  sta mod10 + 1
  clc ; we will clear the carry bit
  ;END Initialization of the 4 bytes

  ldx #16
divloop:
  ;rotate the quotient and the remainder
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ;substract 1010, we will do it 8 bits at a time
   sec ; set the carry bit
  lda mod10
  sbc #10 ;substract with carry from 10
  tay ; save the low part of the 16 bits of the remainder to register y
  lda mod10 + 1
  sbc #0 ;substract with carry zero as the 8 high bits are all zeroes from 10 division
  ; the answer is on the combination of the a register and the y register
  ; a,y = dividend - divisor
  ; if the carry is clear for a then the dividend was less that the divisor and we will
  ; discard the result and do a shift left
  bcc ignore_result ; we will branch if the carry bit is clear (the carry of the last operation)
  ; if we do not ignore the result we want to store the intermediate result a,y
  ; in mod10+1 for a register and mod10 for the y register
  sty mod10
  sta mod10 + 1

  ; and then we will keep with the division if we did less than 16 left shifts

ignore_result:
  dex ; decrement the X time that we shifted left
    ; dex affects the Z flag if the content of the x register is zero
  bne divloop ;if what is on the X register
  ;we will rotate the carry bit inside value to have the result of the division
  rol value
  rol value + 1

  ;now we have to store the remainder
  lda mod10
  clc
  adc #"0" ;by adding zero to the a register we will have the ascii number of its value
  jsr push_char ;and now we store our character in the string
  ; we will be done dividen whne the result of the division is a zero
  ; we will check value and value + 1 and if any bit is one we are not done
  lda value
  ora value + 1 ; combine all ones from the 16 bits of value
  bne divide ; if a is not zero keep dividing
  rts

print_message_ascii:  
  ;BEGIN Write all the letters
  ldx #0 ;start on FF so when i add one it will be 0

print_message_eeprom_ascii:  
  lda message,x ;load letter from eeprom position message + the value of register X
  beq print_message_ascii_end ; jump to end if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr print_char 
  inx
  jmp print_message_eeprom_ascii
  ;END Write all the letters  
print_message_ascii_end:
  rts   

number: .word 1729 ;the number we will convert

;add the content of the a register to a null terminated string message
push_char:
  pha ;push new character into the stack first 
  ldy #0

char_loop:
  lda message,y ;get char on string and put into x
  tax
  pla
  sta message,y ; we replaced the old first character with the new one
  iny ; lets go to the next character
  txa
  pha ; we have the character that used to be on the beginning of the message on the stack
  ;if a is zero we are at the end of the string
  bne char_loop
  pla
  sta message,y ; store the null terminator again
  rts
;END-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------Binary to Ascii------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LCD COMMANDS---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

clear_display:
; BEGIN clear display instruction  on port B
  lda #%00000001 ;the instruction itself is 00000001
  jsr lcd_send_instruction
  ; END clear display instruction on port B 


initilize_display:
; BEGIN clear display instruction  on port B
  lda #%00000001 ;the instruction itself is 00000001
  jsr lcd_send_instruction
  ; END clear display instruction on port B  

  ; BEGIN send the instruction function set on port B
  lda #%00111000 ;the instruction itself is 001, data lenght 8bits(1), Number Display lines 2 (1)
            ;and Character Font 5x8 (0), last two bits are unused
  jsr lcd_send_instruction 
  ; END send the instruction function set on port B

  ;BEGIN Turn on Display instruction
  lda #%00001100 ;the instruction itself is 0001, Display On(1), Cursor Off (0)
            ;and Cursor Blinking Off (0)
  jsr lcd_send_instruction 
  ; END Turn on Display instruction

   ;BEGIN Entry Mode Set instruction
  lda #%00000110 ;the instruction itself is 00001, Put next character to the right (1)
            ;and Scroll Display Off (0)
  jsr lcd_send_instruction
  ; END Entry Mode Set instruction
  rts

lcd_wait:
  pha ; push to preserve the contents of the acummulator register
  ;set LCD_PORTB to all inputs so we can read the busy flag
  lda #$00000000 ;port b ins input
  sta LCD_DDRB 
lcd_busy:
  ;set register select to 0 and RW to 1 to read the busy flag
  lda #RW ;set RW RW = %01000000 ; Read/Write Signal
  sta LCD_PORTA
  lda #(RW | E) ;do the enable and do not era the RW bit
  sta LCD_PORTA
  ;this will give us the info from the busy flags and the counter 01 BF AC AC AC AC AC AC AC
  ;on port B so we read it
  lda LCD_PORTB
  and #%10000000 ;and the accumulator to loose all bits but the 7 bit (from 7 to 0)
                ; on the acummulator I will now have only the Busy Flag result
  bne lcd_busy ; branch if the zero flag is not set
  ;turn off the enable bit
  lda #RW ;set RW RW = %01000000 ; Read/Write Signal
  sta LCD_PORTA
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF to make it output
  sta LCD_DDRB ;store the accumulator in the data direction register for Port B
  pla ; pull to restablish the contents of the acummulator register
  rts


lcd_send_instruction:
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta LCD_PORTB
            
  lda #%0  ;Clear RS,RW and E bit on Port A  
  sta LCD_PORTA ;     

  ;togle the enable bit in order to send the instruction
  ;RS is zero so we are sending instructions
  ;RW is zero so we are writing
  lda #E ;enable bit is 1 , so we turn on the chip and execute the instruction.
  sta LCD_PORTA ; 

  lda #%0  ;Clear RS,RW and E bit on Port A  
  sta LCD_PORTA ;  
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts ; return from the subroutine

print_char:
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta LCD_PORTB

  ;RS is one so we are sending data
  ;RW is zero so we are writing
  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta LCD_PORTA ;     

  ;togle the enable bit in order to send the instruction
  lda #(RS | E );RS and enable bit are 1 , we OR them and send the data
  sta LCD_PORTA ; 

  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta LCD_PORTA ; 
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts

lcd_send_data:
  ;print_char is equal to send data
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta LCD_PORTB

  ;RS is one so we are sending data
  ;RW is zero so we are writing
  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta LCD_PORTA ;     

  ;togle the enable bit in order to send the instruction
  lda #(RS | E );RS and enable bit are 1 , we OR them and send the data
  sta LCD_PORTA ; 

  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta LCD_PORTA ; 
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LCD COMMANDS---------------------------------------
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

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



startMessage1:
  .ascii "    RS-232 TERMINAL    "   

the20cAscii:
  .ascii "  _  _     _                            "
  .ascii " | || |___| |__ _                       "
  .ascii " | __ / _ \ / _` |                      "
  .ascii " |_||_\___/_\__,_|_        ___ __       "
  .ascii " / __| ___ _  _  | |__ _  |_  )  \ __   "
  .ascii " \__ \/ _ \ || | | / _` |  / / () / _|_ "
  .ascii " |___/\___/\_, | |_\__,_| /___\__/\__( )"
  .ascii "  __| |___ |__/_ _  _ _____ _____    |/ "
  .ascii " / _` / -_) | ' \ || / -_) V / _ \      "
  .ascii " \__,_\___| |_||_\_,_\___|\_/\___/      "
  .ascii "e"                                       

marioReverseAscii:
  .ascii "     y puedo hacer un mario"
  .ascii "██████████████████████████████████"
  .ascii "███████████████        ██      ███"
  .ascii "███████████    ░░░░░░    ▓▓▓▓▓▓ ██"
  .ascii "█████████  ░░░░░░░░░░░░  ▓▓▓▓▓▓ ██"
  .ascii "███████  ░░░░░░            ▓▓▓▓ ██"
  .ascii "█████  ░░░░░░                ▓▓ ██"
  .ascii "█████  ░░    ▓▓▓▓▓▓▓▓▓▓▓▓       ██"
  .ascii "███        ▓▓▓▓▓▓  ▓▓  ▓▓  ░░░░ ██"
  .ascii "███  ▓▓    ▓▓▓▓▓▓  ▓▓  ▓▓  ░░░░ ██"
  .ascii "█  ▓▓▓▓      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ░░ ██"
  .ascii "█  ▓▓▓▓▓▓  ▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓  ░░ ██"
  .ascii "█  ▓▓▓▓▓▓  ▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓  ░░ ██"
  .ascii "███  ▓▓▓▓▓▓▓▓        ▓▓▓▓       ██"
  .ascii "█████    ▓▓▓▓▓▓▓▓          ░░  ███"
  .ascii "███████      ▓▓▓▓▓▓▓▓▓▓  ░░░░  ███"
  .ascii "███▓▓  ░░░░              ░░  █████"
  .ascii "███  ░░░░░░░░    ▓▓▓▓▓▓    ███████"
  .ascii "█    ░░░░░░░░  ▓▓▓▓▓▓▓▓▓▓  ███████"
  .ascii "█    ░░░░░░░░  ▓▓▓▓▓▓▓▓▓▓  ███████"
  .ascii "█      ░░░░░░░░  ▓▓▓▓▓▓        ███"
  .ascii "███      ░░░░░░                ███"
  .ascii "█████                      ░░░░  █"
  .ascii "███  ░░░░                 ░░░░░░ █"
  .ascii "█    ░░                   ░░░░░░ █"
  .ascii "█  ░░░░                   ░░░░░░ █"
  .ascii "█  ░░░░           ██████  ░░░░   █"
  .ascii "█  ░░░░   ███████████████       ██"
  .ascii "███    ███████████████████████████"
  .ascii "██████████████████████████████████"
  .ascii "        y esa musiquita????     "
  .ascii "e"

cyberCirujasAscii:
  .ascii ""
  .ascii ""
  .ascii "                         █████ █   █ ████  █████ ████            n"
  .ascii "                         █   █ █   █ █  █  █     █  █            i"
  .ascii "              n          █     █████ █████ ███   █████"
  .ascii "              i          █         █ █   █ █     █   █           o"
  .ascii "                         █████ █████ █████ █████ █   █           c"
  .ascii "              h                                                  i"
  .ascii "              a                  ▓▓▓ ▓▓▓ ▓▓▓                     s"
  .ascii "              r                 ▓   ▓   ▓   ▓▓▓▓                 x"
  .ascii "              d                 ▓   ▓   ▓   ▓   ▓                s"
  .ascii "              w       ▒▒▒▒▒▒▒▒▒▒▓▓▓▓ ▓▓▓▓   ▓   ▓▒▒▒▒▒▒▒▒"
  .ascii "              a       ▒▒  ▒▒  ▒▓         ▓▓▓    ▓▒  ▒  ▒▒        c"
  .ascii "              r       ▒▒▒▒▒▒▒▒▒▓       ▓▓▒▒▒▒▓▓▓▒▒▒▒▒▒▒▒▒        o"
  .ascii "              e       ░░░░░░░░░▓   ▓▓▓▓░░░░░░░░░░░░░░░░░░        n"
  .ascii "                                ▓               ▓"
  .ascii "              o                  ▓             ▓                 h"
  .ascii "              c                   ▓▓▓▓▓▓▓▓▓▓▓▓▓                  a"
  .ascii "              i                                                  r"
  .ascii "              o      █████ ███ ████  █   █     █ █████ █████     d"
  .ascii "              s      █   █  █  █  █  █   █     █ █   █ █         w"
  .ascii "              o      █      █  █████ █   █     █ █████ █████     a"
  .ascii "                     █      █  █   █ █   █ █   █ █   █     █     r"
  .ascii "                     █████ ███ █   █ █████ █████ █   █ █████     e"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

replayAscii:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                                                  q6g"
  .ascii "                                                 ewrf"
  .ascii "         eweewefd                               fyu9     q66qo      q6q    q6."
  .ascii "      ewesadd  bttf     .(oog.   gg  g66g      345    gfhvvsas0   wqe.   ssf."
  .ascii "    6esadsd4   ndsg    6rjh43g  455v9. 4ng    s5    gsaw   sag   345   qsrv9"
  .ascii "  6we  xcvs   65ng   689(  .9)  wte   asbg   re    gsd    df9   fsv  .vcvxz"
  .ascii "  6g  qefuvmv52g   6hn1  .zg   45w   sfv6   aw    sfw   sfsd  sagv vs.vrg9"
  .ascii "     6bsd$w#6     6wefgfhg)  dfhn   sfxg  sde   nnmbb v1sav as dssdv dds."
  .ascii "    6pf   szp   63$32      6ssxc   asad sg saxvg vsxc97 sadxv  ogo  dwr"
  .ascii "   6fv    qwg dfg  fvbaxve5wsfgdggggi9)v   oggo   ogo   ogo        ddf"
  .ascii "   sd      dqs+     6vb9)  afs                                66.fdf9"
  .ascii "   o                      sas                                  669."
  .ascii "                          oo"
  .ascii ""
  .ascii "                              . . . . . . . . ."
  .ascii "                              | | | | | | | | |"
  .ascii "                             @@@@@@@@@@@@@@@@@@@"
  .ascii "                             (                 )"
  .ascii "                             )    F E L I Z    ("
  .ascii "                             (                 )"
  .ascii "                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  .ascii "                        (                           )"
  .ascii "                        )   A N I V E R S A R I O   ("
  .ascii "                        (                           )"
  .ascii "                        @@@@@@@@@@@@berdyx@@@@@@@@@@@"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

trucoAscii:

  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "         ┌─────┐┌────────────────┐"
  .ascii "      ┌──┘     └┘              ┌─┘"
  .ascii "      └──┐     │ ┌───────────┬─┘        ┌───┬───┬───┐"
  .ascii "         └┬────┘ │         ■┌┘          │7  │1  │1  │"
  .ascii "         ┌┘      │     ■    └──────┐    │ ¥ │ ! │ ¥ │"
  .ascii "         │      ┌┴┐└         ┌───┐ │    │   │   │   │"
  .ascii "         │      │ └┐         └──┐└─┘    └┬─┬┴───┴─┬─┘       ┐"
  .ascii "         └─┐ ┌──┘  └──┐   └─    │        │        │"
  .ascii "           └─┘     ┌──┴──┐   ┌┐ ├┐       └┬─────┬─┘            ┐"
  .ascii "              ┌────┘     └── └└┐┘└───┐    │     │"
  .ascii "           ┌──┘               └└┐    └────┘   ┌─┘                 ┐"
  .ascii "           │      ┌           ┌┴┴────┐        │"
  .ascii "           │      └────┐  ┌───┴─┐    │ ───────┘     ┌  ─  ─  ─  ─  ─  ─  ┐"
  .ascii "           │           └─┬┘    ─┴─┐  │"
  .ascii "           └─┐berdyx     │    ─┬──┘  │              │  T R U C O         │"
  .ascii "             └───────────┴┐  ─┬┴┐   ┌┘"
  .ascii "                          └───┘ └───┘               │    A R B I S E R   │"
  .ascii ""
  .ascii "                                                    └  ─  ─  (c) 1982-86 ┘"
  .ascii "                     DONDE TODO COMENZO..."
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

arcadeAscii:
  .ascii "                                                                           "
  .ascii "                             jugar NO es opcional                          "
  .ascii "                                                                           "
  .ascii "                                ╔═══════════╗                              "
  .ascii "                                ║  N A V E  ║                              "
  .ascii "                                ╠═══════════╣                              "
  .ascii "                                ║           ║                              "
  .ascii "                                ║   never   ║                              "
  .ascii "                                ║  give up  ║                              "
  .ascii "                                ║           ║                              "
  .ascii "                               ╔╩═══════════╩╗                             "
  .ascii "                               ║     ! o     ║                             "
  .ascii "                               ╚╦═══════════╦╝                             "
  .ascii "                                ║     ▄     ║                              "
  .ascii "                                ║    ▄█▄    ║                              "
  .ascii "                                ║   █▀ ▀█   ║                              "
  .ascii "                                ║  ███████  ║                              "
  .ascii "                                ║   ▀   ▀   ║                              "
  .ascii "                                ║           ║                              "
  .ascii "                                ║   berdyx  ║                              "
  .ascii "                                ╚═══════════╝                              "
  .ascii " ┌─────┐ ┌─┐    ┌─┐ ┌─┐ ┌────┐                                             "
  .ascii " │ ┌───┘ │ │    │ │ │ │ │ ┌┐ │                                             "
  .ascii " │ │     │ │    │ │ │ │ │    └┐                █████      ████       ████  "
  .ascii " │ └───┐ │ └──┐ │ └─┘ │ │ └┘  │               ██   ██    ██  ██     ██  ██ "
  .ascii " └─────┘ └────┘ └─────┘ └─────┘              ██         ██    ██   ██    ██"
  .ascii "                                             ██         ████████   ████████"
  .ascii "    ┌─┐ ┌─┐  ┌─────┐ ┌─┐ ┌─┐                  ██   ██   ██    ██   ██    ██"
  .ascii "    │ │ │ │  │ ┌─  │ │ │ │ │                   █████    ██    ██   ██    ██"
  .ascii "    │ └─┘ └┐ │ │ │ │ │ └─┘ └┐                                              "
  .ascii "    └───┐ ┌┘ │  ─┘ │ └───┐ ┌┘                                              "
  .ascii "        └─┘  └─────┘     └─┘                                               "
  .ascii "e" 

modoHistoriaAscii:

  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                 █                              "
  .ascii "                                               ███                              "
  .ascii "                                                ██                              "
  .ascii "                   █ ███  ██       ████       ████      ████                    "
  .ascii "                 █████ ███  ██   ██    ██   ██  ██    ██    ██                  "
  .ascii "                  ██   ██   ██   ██    ██  ██   ██    ██    ██                  "
  .ascii "                  ██   ██   ██   ██    ██  ██   ██ █  ██    ██                  "
  .ascii "                  ██   ██   ███   ██   █    ██  ███    ██   █                   "
  .ascii "                  █    █    █      ████      ███  █     ████                    "
  .ascii "                                                                                "
  .ascii "           ██       █               █                       █                   "
  .ascii "          ███                     ███                                           "
  .ascii "           ██  █     █      ███    ████    ████     ██ ██    █     ████         "
  .ascii "           ██████  ███    ███  █   ██    ██    ██  ██████  ███    █   ██        "
  .ascii "           ██  ██   ██   ███       ██    ██    ██  ██   █   ██   ██   ██        "
  .ascii "           ██  ██   ██     ████    ██    ██    ██  ██       ██   ██   ██        "
  .ascii "           ██  ██   ███  █    ██   ██ █   ██   █   ██       ███   ██ ██         "
  .ascii "           █   █    ██    ████      ██     ████    █        ██     ███ ██       "
  .ascii "              █                                                                 "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                             videojuegos en contexto                            "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                          (N. del A.: hablen del X-COM)                         "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "e"

narcoPoliceAscii:
  .ascii "e"


commodoreAscii: 
  .ascii ""
  .ascii ""
  .ascii "              DREAN COMMODORE 64, desde San Luis a Villa Martelli"
  .ascii ""
  .ascii "   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░"
  .ascii "   ▓▓▓▓▓▓Drean Commodore ≡ 64▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓Enc ☻▓▓▓▓▓▓▓▓▓▓▓▓░b"
  .ascii "   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░e"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░r"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░d"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒┌──┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬────┬────┐▒▒▒▒▒▒▒▒▒▒┌───┐▒▒▒▒▒▒▒▒▒░y"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒│<-│1│2│3│4│5│6│7│8│9│0│+│-│£│CLR │INST│▒▒▒▒▒▒▒▒▒▒│f 1│▒▒▒▒▒▒▒▒▒░x"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒├──┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┤HOME│ DEL│▒▒▒▒▒▒▒▒▒▒└───┘▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒├────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──┴────┤▒▒▒▒▒▒▒▒▒▒┌───┐▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒│CTRL│Q│W│E│R│T│Y│U│I│O│P│@│*│↑│RESTORE│▒▒▒▒▒▒▒▒▒▒│f 3│▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒┌─┴──┬─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴───────┤▒▒▒▒▒▒▒▒▒▒└───┘▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒│RUN │SHIFT├─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──────┬┘▒▒▒▒▒▒▒▒▒▒┌───┐▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒│STOP│ LOCK│A│S│D│F│G│H│J│K│L│:│;│RETURN│▒▒▒▒▒▒▒▒▒▒▒│f 5│▒▒▒▒▒▒▒▒▒░░" 
  .ascii "   ▒▒▒▒▒▒▒▒├────┴─────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴┬──┬──┤▒▒▒▒▒▒▒▒▒▒▒└───┘▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒├─┬─────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─────┤CR│CR│▒▒▒▒▒▒▒▒▒▒▒┌───┐▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒│Ç│SHIFT│Z│X│C│V│B│N│M│,│.│/│SHIFT│SR│SR│▒▒▒▒▒▒▒▒▒▒▒│f 7│▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒└─┴─────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─────┴──┴──┘▒▒▒▒▒▒▒▒▒▒▒└───┘▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┌─────────────────┐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒└─────────────────┘▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e" 

ventilastationAscii:
    .ascii "                                                                                "
  .ascii "                           V E N T I L A S T A T I O N                          "
  .ascii "                                                                                "
  .ascii "              La primer consola del mundo corriendo en un ventilador            "
  .ascii "                                                                                "
  .ascii "                       Y, obviamente, creada en Argentina                       "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                 ░░░░░░░▓▓▓▓▓▓▓                                 "
  .ascii "                             ░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓                             "
  .ascii "                          ░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                         "
  .ascii "                        ░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                       "
  .ascii "                      ▓░░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░                     "
  .ascii "                     ▓▓▓▓░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░                    "
  .ascii "                    ▓▓▓▓▓▓▓░░░░░░░░░░░░░███▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░                   "
  .ascii "                   ▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░██████▓▓▓▓▓▓▓░░░░░░░░░                  "
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░☻░░░████████▓▓▓░░░░░░░░░░░░                 "
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░☻▒▒▒▒███████░░░░░░░░░░░░░░                 "
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓███░░░░▒████▒███████░░░░░░░░░░░░░░                "
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓▓▒█  █▒███████░░░░░░░░░░░░░░                "
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓▓▒█  █▒░██████░░░░░░░░░░░░░░                "
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓░▒████▒░██████░░░░░░░░░░░░░░                "
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓▓████░░░▒▒▒▒░░█████░░░░░░░░░░░░░░                 "
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓░░█████░░░░░░█████▓▓▓░░░░░░░░░░░░                 "
  .ascii "                   ▓▓▓▓▓▓▓▓▓░░░░░░████████████▓▓▓▓▓▓▓░░░░░░░░░                  "
  .ascii "                    ▓▓▓▓▓▓░░░░░░░░░░░██████▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░                   "
  .ascii "                     ▓▓▓░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░                    "
  .ascii "                      ▓░░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░                     "
  .ascii "                        ░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                       "
  .ascii "                          ░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                         "
  .ascii "                             ░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓                             "
  .ascii "                                 ░░░░berdyx▓▓▓▓                                 "
  .ascii "                                       ║║                                       "
  .ascii "e" 

la20cAscii:
  .ascii ""
  .ascii "                    ┌─┴─┴─┴─┴─┴─┬─┴─┴─┴─┴─┴─┬─┴─┴─┴─┴─┴─┐"
  .ascii "                    │  4F53 4F  │    RAM    │    RAM    ├"
  .ascii "                    │  ■■■■ ■■  │           │           ├"
  .ascii "                    │  Address  │    ▐░▌    │    ▐▒▌    ├"
  .ascii "                    │   Data    │           │           ├"
  .ascii "                    │  Display  │    ROM    │    ROM    ├"
  .ascii "                    ├───────────├───────────├───────────┤───────┐"
  .ascii "                    │    BUS    ▌    BUS    ▌    BUS    │ D P A │"
  .ascii "                    │           ▌           ▌           │ U R N │"
  .ascii "                    │  Address  ▌  Address  ▌  Address  │ I O L │"
  .ascii "                    │   Data    ▌   Data    ▌   Data    │ N T Y │"
  .ascii "                    │ Expansion ▌ Expansion ▌ Expansion │ O . Z │"
  .ascii "                    ├───────────┬───────────┬───────────┤───────┘"
  .ascii "                    │ VIA 6522  │   GLUE    │  CPU 6502 ├"
  .ascii "                    │           │   LOGIC   │   .....   ├"
  .ascii "                    │   ....    │....  .... │   ▓▓▓▓▓   ├"
  .ascii "                    │   ░░░░    │))))  (((( │   ·····   ├"
  .ascii "                    │   ····    │····  ···· │           ├"
  .ascii "                    ├───────────┬───────────┬───────────┤"
  .ascii "                    │  I/0 LCD  │   POWER   │   CLOCK   ├"
  .ascii "                    │           │   module  │    OSO    ├"
  .ascii "                    │ ▄▄▄▄▄▄▄▄  │  5v  ♥    │           ├"
  .ascii "                    │ █berdyx█  │  9v  ♦    │           ├"
  .ascii "                    │ ▀▀▀▀▀▀▀▀  │ 12v  ♣    │        ☻  ├"
  .ascii "                    └───────────┴───────────┴───────────┘"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e" 


clearRS232Screen:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e" 

screen1_demo:
  .asciiz "   Hola de nuevo,   "
  .asciiz "                    "  
  .asciiz "   Soy, la  20c.    "
  .asciiz "                    "


screen2_demo:
  .asciiz "                    "
  .asciiz "    Ahora tengo     "
  .asciiz "      RS-232        "
  .asciiz "                    "  


message01:
  .ascii "Ahora si! tengo RS-232"
  .ascii "e" 

message02:
  .ascii ""

  .ascii "pero bueno muestro texto"
  .ascii "e" 

message03:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "a ver....hagamos fuerza"
  .ascii ""
  .ascii "mmmmmmffff"
  .ascii "mmmpppppfffffff"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"   

message04:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "vaaaaamoooos"
  .ascii "puedo hacer ascii ART"
  .ascii ""
  .ascii ""
  .ascii "e"    

message05:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "Pero mejor traigo a un artista"
  .ascii "      El Principe de las 286"
  .ascii ""  
  .ascii "           Berdyx"
  .ascii ""
  .ascii "e" 

message06:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "            Tenemos muchos Amigos"
  .ascii ""  
  .ascii "   A los que les queremos Agradecer y Nombrar"
  .ascii ""  
  .ascii "            todos de la scene Retro "
  .ascii ""
  .ascii "e"   


message07:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "            aaaaa mira quien volvio ....."
  .ascii ""  
  .ascii ""
  .ascii "e"    

lcd_positions:
lcd_positions_line0:
  .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F,$90,$91,$92,$93
lcd_positions_line1:
  .byte $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF,$D0,$D1,$D2,$D3
lcd_positions_line2:
  .byte $94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F,$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
lcd_positions_line3:
  .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7


; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 1	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 2	94	95	96	97	98	99	9a	9b	9c	9d	9e	9f	a0	a1	a2	a3	a4	a5	a6	a7
; 3	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7
initialScreen:
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill

left_cursor_endings:
 ; .byte  $80,$c0,$94,$d4
  .byte  $88,$c8,$9c,$dc  

right_cursor_endings:
  .byte  $93,$d3,$a7,$e7

; up_cursor_endings:
;   .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8F,$8E,$90,$91,$92,$93
up_cursor_endings: ;so it is all in one line
  .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
  
down_cursor_endings:
  .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
  

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



