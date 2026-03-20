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
LCD_VIA_BASE  = $6000
; IFR       = VIA_BASE + $0D   ; Interrupt Flag Register
; IER       = VIA_BASE + $0E   ; Interrupt Enable Register

; ── Timer 1 IFR bit mask ──────────────────────────────────

LCD_T1_FLAG   = %01000000         ; bit 6

LCD_PORTB = $6000
LCD_PORTA = $6001
LCD_DDRB = $6002 
LCD_DDRA = $6003
LCD_T1CL = LCD_VIA_BASE + $04   ; Timer 1 counter low   (R: clears T1 IFR bit)
LCD_T1CH = LCD_VIA_BASE + $05   ; Timer 1 counter high  (W: starts timer)
LCD_T1LL = LCD_VIA_BASE + $06   ; Timer 1 latch low
LCD_T1LH = LCD_VIA_BASE + $07   ; Timer 1 latch high
LCD_ACR  = LCD_VIA_BASE + $0B   ; Auxiliary Control Register
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
TIMER_ZP_SEC    = $42               ; loop counter for WAIT_ONE_SECOND  (1 byte)
TIMER_ZP_MIN    = $43               ; seconds counter for WAIT_ONE_MINUTE (1 byte)

soundLowByte=$50
soundHighByte=$51
soundDelay=$52

;Vectors RLE
rleVectorLow=$a0
rleVectorHigh=$a1

;LCD buttons
LCD_PORTSTATUS=$a2

;Zero Page Vectors Screen
screenCurrentASCII_Low=$b0
screenCurrentASCII_High=$b1

screenCurrentDescription_Low=$b2
screenCurrentDescription_High=$b3

;screenCurrentObjects_Low=$b4
;screenCurrentObjects_High=$b5

actionCheckVectorLow=$b6
actionCheckVectorHigh=$b7

;puzzleDataVectorLow=$b8
;puzzleDataVectorHigh=$b9

actionDataVectorLow=$ba
actionDataVectorHigh=$bb

sourceScreenVectorLow=$bc
sourceScreenVectorHigh=$bd

ramScreenVectorLow=$be
ramScreenVectorHigh=$bf

puzzlePivotLow=$c0
puzzlePivotHigh=$c1

pivotZpLow=$fe
pivotZpHigh=$ff

;Memory locations RLE
rleChar=$0200
rleTimes=$0201
rleScreenLines=$0202

screenCurrentID=$0210
screenMultiple=$0211
screenRecordSize=$0212
screenCurrentBaseAddressLow=$0213
screenCurrentBaseAddressHigh=$0214

objectCurrentID=$0215
objectMultiple=$0216
objectRecordSize=$0217
object1Offset=$0218
currentObjectOffset=$0219

puzzleCurrentID=$021a
puzzleMultiple=$021b
puzzleRecordSize=$021c
puzzle1Offset=$021d
puzzleObjectOffset=$021e

object_pointers_index=$021f
object_RAM_index=$0220
puzzle_pointers_index=$0221
puzzle_RAM_index=$0222
max_objects_per_screen=$0223
max_puzzles_per_screen=$0224
max_actions_per_screen=$0225

actionCurrentID=$0226
actionMultiple=$0227
actionRecordSize=$0228
action1Offset=$0229
actionObjectOffset=$022a

objectPosition=$022b
actionPosition=$022c

current_screen_offset=$022d
puzzlePrintOffset=$022e
objectPrintOffset=$022f
actionPrintOffset=$0230
screenPrintOffset=$0231

selectedAction=$0232
selectedObject=$0233
selectedObject1=$0234
selectedObject2=$0235
print_no_CRLF=$0236

currentPuzzleAction=$0237
currentPuzzleObject1=$0238
currentPuzzleObject2=$0239

userOptionSelection=$023a

heartRate=$023b
waterLevel=$023c
heartRateSensor=$023d
waterLevelSensor=$023e

flashlightStatus=$023f
actionCostTotal=$240
actionCostS1S1=$241
actionCostS1S2=$242
moveNextScreen=$0243
idleTimerStartMinute=$0244
sensorCurrentID=$0245
sensorCurrentStatus=$0246
timerExpired=$0247
gameEnded=$0248

fearLevel=$0249
watertLevel=$024a
actionHidden=$024b
highWaterLevel=$024c
currentActionHideWater=$024d
currentActionHideFear=$024e
currentActionHideFlashlightOff=$024f
highFearLevel=$0250

actionIDOptionsRAM=$0340 ;32 bytes but i only use 6
screenPointersRAM=$0500


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

;Timer Constants
; ── Timer load values for 1 MHz clock ────────────────────
;
;  Timer counts DOWN from the loaded value to 0, then sets
;  IFR bit 6.  At 1 MHz each tick = 1 µs.
;
;  Maximum single load = 65535 µs ≈ 65.535 ms
;  So to reach 1 second we need ~15.259 overflows of 65535,
;  but it's cleaner to use exactly 50 000 µs (50 ms) and
;  count 20 overflows  →  20 × 50 000 µs = 1 000 000 µs = 1 s
;
;  TICKS_50MS = 50 000 - 2 = 49 998
;    (subtract 2 because the VIA takes 2 extra cycles to
;     reload and set the flag — datasheet §4.2.1)
;  49 998 = $C34E
;  Low  byte: $4E
;  High byte: $C3

TIMER_TICKS_LO  = $4E               ; low  byte of 49 998
TIMER_TICKS_HI  = $C3               ; high byte of 49 998

TIMER_LOOPS_1S  = 20                ; 20 × 50 ms = 1 second
TIMER_LOOPS_5S  = 100               ;5 seconds
TIMER_LOOPS_10S  = 200               ;10 seconds

TIMER_LOOPS_1M  = 6                ; 6 × 10 seconds = 1 minute
TIMER_LOOPS_10M  = 60                ; 60 × 10 seconds = 10 minute

;Memory Mappings
;these are constants where we reflect the number of the memory position

screenBufferLow =$00 ;goes to $50 which is 80 decimal
screenBufferHigh =$30

lcdCharPositionsLow =$00 ;goes to $50 which is 80 decimal
lcdCharPositionsHigh =$31

;bin 2 ascii values
; value =$0200 ;2 bytes, Low 16 bit half
; mod10 =$0202 ;2 bytes, high 16 bit half and as it has the remainder of dividing by 10
;              ;it is the mod 10 of the division (the remainder)
; message = $0204 ; the result up to 6 bytes
; counter = $020a ; 2 bytes

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
  jsr viaRsInit
  ;jsr viaSoundInit
  jsr uartSerialInit
  jsr screenInit
  jsr lcdDemoMessage
  ;jmp listeningMode
  ;start MainProgran and I save stack space by not jumping to it
mainProgram:
  ;initialize 
  ;jsr testPrinter
  jsr initilizationRoutines
  ;initialize screen as screen zero
  ;jsr timerWaitOneMinute
  jsr select_screen
  jsr draw_current_screen_table
mainProgramLoop:
  jsr action_selector
  jsr sensor_selector  
  lda gameEnded
  bne mainProgram ;if gameEnded is not zero then the game ended  
  jsr checkGameEnd  
  lda moveNextScreen
  beq mainProgramLoop;if zero do not move to next screen and ask for actions
  lda #$0
  sta moveNextScreen ;reset the move next screen flag
  jsr select_screen
  jsr draw_current_screen_table
  ;here the games continue so we jump to the loop and continue
  jmp mainProgramLoop   
  rts
;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LED_ASCII------------------------------------------
;-----------------------------------------------------------------------------------
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

lcdDemoMessage:
  ;Draw Screen 1 Final Demo
  lda #<screen1_demo
  sta charDataVectorLow
  lda #>screen1_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  rts 
;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LED_ASCII------------------------------------------
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
  ;sets interrupts for timer 1 and CA1 #%11000010
  lda #%11000010
  sta LCD_IER 
  ;enable negative edge transition ca1 LCD_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta LCD_PCR 
  ;bit 7,6 00 timer 1 one shot mode without pb7
  ;bit 5 in 0 timer 2 one shot mode
  ;bit 4,3,2 in 0 disable shift register
  ;bit 1 in zero portB latch disable
  ;bit 0 in 0 portA larch disable
  ;lda #%00000000      ; clear bits 7 and 6
  lda #%00000000      ; clear bits 7 and 6 (free running)
  sta LCD_ACR
  ;counter in zero bit 6 of IFR is set

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
;--------------------------------VIARSINIT------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaRsInit:

  ;BEGIN enable interrupts RS VIA
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  lda #%10000010
  sta RS_IER 
  ;enable negative edge transition ca1 RS_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta RS_PCR 
  ;END enable interrupts

  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta RS_DDRB ;store the accumulator in the data direction register for Port B
  
  ;set all port A pins as Inputs
  lda #%00000000  ;set as input PA7, PA6, PA5, PA4,PA3,PA2,PA1,PA0
  sta RS_DDRA ;store the accumulator in the data direction register for Port A
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
  lda #%00011110 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 9600 baudios
  ;lda #%00011111 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 19200 baudios
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
;--------------------------------PRINTER-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initializePrinter:
  jsr printerReset
  rts

testPrinter:  
  jsr printerReset
  jsr probandoPrinter
  jsr printerBoldOn
  jsr probandoPrinter
  jsr printerBoldOff
  jsr printerJustificationRight
  jsr probandoPrinter
  jsr printerJustificationCenter
  jsr probandoPrinter
  jsr printerJustificationLeft
  jsr probandoPrinter
;   jsr printerUnderlineOn
;   jsr probandoPrinter
;   jsr printerUnderlineOff
  jsr printerLetterSizeBig
  jsr probandoPrinter
  jsr printerLetterSizeMedium
  jsr probandoPrinter
  jsr printerLetterSizeNormal
  jsr probandoPrinter
  jsr printerFeedManyLines
  jsr printerCut
  rts

printerReset:
  ;Initialization sequence ESC @
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$40 ;@
  jsr send_rs232_char
  rts

printerCut:
  ;Initialization sequence ESC @
  lda #$1d 
  jsr send_rs232_char
  lda #$56
  jsr send_rs232_char
  lda #$00
  jsr send_rs232_char  
  rts

printerBoldOn:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$45 ;E
  jsr send_rs232_char
  lda #$1 ;bold on
  jsr send_rs232_char  
  rts

printerBoldOff:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$45 ;E
  jsr send_rs232_char
  lda #$0 ;bold off
  jsr send_rs232_char  
  rts  

probandoPrinter:
  lda #<msj_printer
  sta serialDataVectorLow  
  inx 
  lda #>msj_printer
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

printerJustificationLeft:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$61 ;a
  jsr send_rs232_char
  lda #$0 ;left
  jsr send_rs232_char  
  rts      

printerJustificationCenter:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$61 ;a
  jsr send_rs232_char
  lda #$1 ;Center
  jsr send_rs232_char  
  rts       

printerJustificationRight:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$61 ;a
  jsr send_rs232_char
  lda #$2 ;right
  jsr send_rs232_char  
  rts       

printerFeedOneLine:
  lda #$0a ;LF
  jsr send_rs232_char
  rts

printerFeedManyLines:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$64 ;a
  jsr send_rs232_char
  lda #$5 ;5 lines
  jsr send_rs232_char  
  rts    

printerUnderlineOn:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$2d ;n
  jsr send_rs232_char
  lda #$1
  jsr send_rs232_char  
  rts    

printerUnderlineOff:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$2d ;n
  jsr send_rs232_char
  lda #$0 
  jsr send_rs232_char  
  rts    
  
printerLetterSizeMedium:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$21 ;n
  jsr send_rs232_char
  ;bits 7 to 4 widht, bits 3 to 0 height 
  ;00 normal size
  lda #$11 ;medium size 
  jsr send_rs232_char  
  rts     

printerLetterSizeBig:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$21 ;n
  jsr send_rs232_char
  ;bits 7 to 4 widht, bits 3 to 0 height 
  ;00 normal size
  lda #$33 ;big size 
  jsr send_rs232_char  
  rts   

printerLetterSizeNormal:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$21 ;n
  jsr send_rs232_char
  ;bits 7 to 4 widht, bits 3 to 0 height 
  ;00 normal size
  lda #$00 ;medium size 
  jsr send_rs232_char  
  rts     
msj_printer:
  .ascii "Probando Printer"
  .ascii "e"   


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN PROGRAM---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


checkGameEnd:
  ;check end in screen s1s1
  lda timerExpired
  cmp #$3 ;checking 30 seconds three timers
  ;if less or equal continue
  bcc checkGameEnd2
  lda screenCurrentID
  cmp #$0 ;screen s1s1
  bne checkGameEnd2
  ;now we are on screen s1s1 and the timer expired lets end the game
  ;by changing the final screen
  lda #$4 ;endScreens1s1 id
  sta screenCurrentID
  lda #$1
  sta moveNextScreen
  lda #$1
  sta gameEnded
  lda #$0
  sta timerExpired ;stop the first screen timer expired
checkGameEnd2:  
checkGameEnd_end:
  rts

delayClear:
  jsr delay_3_sec  
  jsr printClearRS232Screen
  rts

printClearRS232Screen:
  lda #< clearRS232Screen
  sta serialDataVectorLow
  lda #> clearRS232Screen 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

printAsciiDrawing:
  sei ;disable interrupts to run
  ;save accumulator x and y registers
  pha
  txa
  pha
  tya
  pha
  ;here print first line
  ;initialize in cero serialCharperLines
  lda #$0
  sta serialCharperLines
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
  inc serialDataVectorHigh
printAsciiDrawing_lenghts_no_carry  
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
  ;save accumulator x and y registers
  pla
  tay
  pla
  tax
  pla
  ;cli let them be on when it is ok for them to be on
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN PROGRAM-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------INITIALIZATION-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initilizationRoutines:
  ;sei ;disable interrupts only to be enabled prior to user input or timer
  ;the only time interrupts will work is while waiting for user input
  jsr loadConstants
  jsr initiatilizeActionsIDs
  rts

loadConstants:
  ;add it to the SCREEN FILE the max number of actions calculated from the amount of actions in the screen
  lda #$4 
  sta max_actions_per_screen
  lda #$3 ; user zero to check and hide options
  sta highWaterLevel
  lda #$1
  sta highFearLevel

;VARIABLE  
  lda #$0
  sta print_no_CRLF  
  lda #$0
  sta actionCostTotal
  lda #$0
  sta moveNextScreen
  ;add it to the SCREEN FILE to choose in the dashboard in which screen to start
  lda #$3; start with screen id 3 the start screen
  sta screenCurrentID  
  lda #$ff
  sta idleTimerStartMinute
  lda #$ff
  sta userOptionSelection  
  lda #$00
  sta timerExpired
  lda #$00
  sta gameEnded
  ;new added
  lda #$0
  sta fearLevel
  lda #$0
  sta waterLevel
  lda #$0 ;flashlight off
  sta flashlightStatus ;flashlight off
  
  rts 

initiatilizeActionsIDs:  
  lda #$ff
  ldx #$0
initiatilizeActionsIDs_loop:
  sta actionIDOptionsRAM,x
  inx
  cpx max_actions_per_screen
  bne initiatilizeActionsIDs_loop
  rts  

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------INITIALIZATION-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------TIMER------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

timerWaitTenMinutes:
  ;cli ;enable interrupts 
  lda #TIMER_LOOPS_10M ;60 rounds of 20 seconds each
  sta TIMER_ZP_MIN  
  jsr timerWaitTenSeconds
  rts

timerWaitFiveSeconds:
  ;cli ;enable interrupts   
  lda #TIMER_LOOPS_5S ;constant with the number 20 the number 50ms loops to reach a second
  sta TIMER_ZP_SEC ; memory position to degrade the loop
  jsr timerLoadTick
  rts

timerWaitOneSecond:
  ;cli ;enable interrupts   
  lda #TIMER_LOOPS_1S ;constant with the number 20 the number 50ms loops to reach a second
  sta TIMER_ZP_SEC ; memory position to degrade the loop
  jsr timerLoadTick
  rts

timerLoadTick:  
  lda #TIMER_TICKS_LO
  sta LCD_T1LL ;set latch low
  lda #TIMER_TICKS_HI
  sta LCD_T1CH ;set latch high and start timer and clears IFR T1
  rts  

timerCheckSecondElapsed:
  lda LCD_T1CL             ; reading T1CL clears IFR bit 6
  dec TIMER_ZP_SEC
  lda TIMER_ZP_SEC
  beq timerCheckSecondElapsedTrue
  jsr timerLoadTick  
  rts
timerCheckSecondElapsedTrue:
  lda #< msj_secondElapsed
  sta serialDataVectorLow
  lda #> msj_secondElapsed
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr timerWaitOneSecond ;set the timer again
  rts  

timerWaitOneMinute:
  cli ;enable interrupts 
  lda #TIMER_LOOPS_1M
  sta TIMER_ZP_MIN  
  lda #TIMER_LOOPS_10S ;constant with the number 200 the number 50ms loops to reach a second
  sta TIMER_ZP_SEC ; memory position to degrade the loop
  lda #TIMER_TICKS_LO
  sta LCD_T1LL ;set latch low
  lda #TIMER_TICKS_HI
  sta LCD_T1CH ;set latch high and start timer and clears IFR T1  
  rts

timerWaitTenSeconds:
  ;cli ;enable interrupts   
  lda #TIMER_LOOPS_10S ;constant with the number 200 the number 50ms loops to reach a second
  sta TIMER_ZP_SEC ; memory position to degrade the loop
  lda #TIMER_TICKS_LO
  sta LCD_T1LL ;set latch low
  lda #TIMER_TICKS_HI
  sta LCD_T1CH ;set latch high and start timer and clears IFR T1
  rts  

timerCheck10SecondElapsed:
  lda LCD_T1CL             ; reading T1CL clears IFR bit 6
  dec TIMER_ZP_SEC
  lda TIMER_ZP_SEC
  beq timerCheck10SecondElapsedTrue    
  ;keep counting until we reach from 200 to aero on timer_zp_sec
  lda #TIMER_TICKS_LO
  sta LCD_T1LL ;set latch low
  lda #TIMER_TICKS_HI
  sta LCD_T1CH ;set latch high and start timer and clears IFR T1  
  rts
timerCheck10SecondElapsedTrue:
  inc timerExpired
  dec TIMER_ZP_MIN
  jsr timerWaitTenSeconds ;set the timer again
  rts     

timerCheckMinuteElapsed:
  lda TIMER_ZP_MIN
  beq timerCheckMinuteElapsedTrue
  jsr timerWaitTenSeconds  
  rts
timerCheckMinuteElapsedTrue:  
  jsr timerWaitOneMinute  
  rts



;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------TIMER------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

select_screen:
  lda screenCurrentID
  jsr load_screen_ram
  rts

load_screen_ram:
  lda screenCurrentID
  ;multiply by 2 the id
  asl ;if not screen zero multiple by 2
  sta current_screen_offset
  ldx current_screen_offset ;byte 6 if it is screen 3
  ;store in sourceScreenVector the address of screen_x_id
  ;use screen zero
  lda screens_index,x
  sta sourceScreenVectorLow
  inx
  lda screens_index,x
  sta sourceScreenVectorHigh
  ;store in ramScreenVectorLow the address of the RAM portin for the screen
  lda #$00
  sta ramScreenVectorLow
  lda #$05
  sta ramScreenVectorHigh
  ldy #$ff
load_screen_ram_loop:
  iny
  cpy screen_record_length
  beq load_screen_ram_end
  lda (sourceScreenVectorLow),Y
  sta (ramScreenVectorLow),Y
  jmp load_screen_ram_loop
load_screen_ram_end:
  rts

draw_current_screen_table:
  jsr draw_screen_ascii
  jsr draw_screen_description
  jsr draw_screen_description_flashlight
  rts

draw_screen_ascii:
  lda screen_ascii_offset
  sta screenPrintOffset
  jsr draw_screen
  rts  

draw_screen_description:
  lda screen_description_offset
  sta screenPrintOffset
  jsr draw_screen
  rts  

draw_screen_description_flashlight:
  lda flashlightStatus
  cmp #$1
  beq draw_screen_description_flashlight_on
  ;flashlight off
  lda screen_flashlight_off_offset
  sta screenPrintOffset  
  jsr draw_screen
  rts   
draw_screen_description_flashlight_on:  
  lda screen_flashlight_on_offset
  sta screenPrintOffset
  jsr draw_screen
  rts    

draw_screen:  
  ldx screenPrintOffset  ;description offset
  lda screenPointersRAM,x 
  sta serialDataVectorLow  
  inx 
  lda screenPointersRAM,x
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

draw_screen_by_ram_ascii:  
  ldx screen_ascii_offset  ; offset ascii
  lda screenPointersRAM,x
  ;lda $051e ;the 30 offset starting ascii low byte
  sta serialDataVectorLow  
  inx 
  lda screenPointersRAM,x
  ;lda $051f ;the 31 offset starting ascii high byte
  sta serialDataVectorHigh
  jsr printAsciiDrawing

draw_screen_by_hand:  
  ldx screenPrintOffset  ;description offset
  lda #<screen_0_ascii
  sta serialDataVectorLow  
  inx 
  lda #>screen_0_ascii
  sta serialDataVectorHigh
  jsr printAsciiDrawing

;   lda #<screen_0_flashlight_on
;   sta serialDataVectorLow  
;   inx 
;   lda #>screen_0_flashlight_on
;   sta serialDataVectorHigh
;   jsr printAsciiDrawing  
  rts    


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------ACTION------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


loadScreenActionOptions:
  jsr printActionsHeader
  ldx screen_action_offset  ;fist object byte offset
  lda screenPointersRAM,x 
  sta actionDataVectorLow  
  inx 
  lda screenPointersRAM,x 
  sta actionDataVectorHigh
  ldy #$0
loadScreenActionOptions_loop:
  lda (actionDataVectorLow),y
  sta actionCurrentID
  ;check to see if action is hidden
  ;according to 
  ;fearLevel
  ;waterLevel
  ;Flashlight Off
  lda #$0
  sta actionHidden ;the action is not hidden on 0 and hidden on 1
  tya ;save Y because i am going to another process
  pha ;save Y because i am going to another process
  jsr checkActionVisibility
  pla ;retrieve Y after processAction
  tay ;retrieve Y after processAction
  lda actionHidden
  bne nextAction;action  hidden is not zero hide the action
  ;if we are here the action is visible
  tya ;save Y because i am going to another process
  pha ;save Y because i am going to another process
  sty actionPosition
  ldx actionPosition
  lda actionCurrentID
  sta actionIDOptionsRAM,x ;save the action on the position to show for options
  jsr processAction
  pla ;retrieve Y after processAction
  tay ;retrieve Y after processAction
nextAction:  
  iny ;go to next action of the screen
  cpy max_actions_per_screen ;max objects per screen 0-5 for now 
  ;check if the actions menu goes 6 time
  bne loadScreenActionOptions_loop
  rts

checkActionVisibility:
  lda actionCurrentID
  asl ;multiply by two 
  tax
  lda actions_index,x
  sta pivotZpLow
  inx
  lda actions_index,x
  sta pivotZpHigh
  lda action_hide_water_offset
  tay
  lda (pivotZpLow),Y
  sta actionCheckVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionCheckVectorHigh  
  lda (actionCheckVectorLow),Y
  sta currentActionHideWater
  ; lda action_hide_fear_offset
  ; tay
  ; lda (pivotZpLow),Y
  ; sta currentActionHideFear
  ; lda action_hide_flashlight_offset
  ; tay
  ; lda (pivotZpLow),Y
  ; sta currentActionHideFlashlightOff
  lda currentActionHideWater
  clc 
  adc #$30
  jsr send_rs232_char
  lda currentActionHideWater  
  beq checkActionVisibility_notHide ;not hide on water level
  ;here we check the water level
  lda waterLevel ;current water level
  lda #$3 ;force hight water level
  cmp highWaterLevel
  bne checkActionVisibility_notHide
  jmp checkActionVisibility_hide
  ;For now only checking on water Level
checkActionVisibility_notHide:  
  lda #$0
  sta actionHidden
  rts  
checkActionVisibility_hide:
  lda #$1
  sta actionHidden
  rts  

printLettersAction:
  ldx actionPosition
  lda letterActions,X
  jsr send_rs232_char
  lda #$29
  jsr send_rs232_char
  lda #$20
  jsr send_rs232_char
  rts  

printActionsHeader:
  lda #< actions_header
  sta serialDataVectorLow  
  lda #> actions_header
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

processAction:
  lda actionCurrentID
  cmp #$ff ;invalid object so that slot is empty do not process
  beq end_processAction
  ;jsr action_multiple_calculate
  jsr printLettersAction
  jsr print_current_action_name
end_processAction:  
  rts  

print_current_action_name:
  lda actionCurrentID
  asl ;multiply by two 
  tax
  lda actions_index,x
  sta pivotZpLow
  inx
  lda actions_index,x
  sta pivotZpHigh
  lda action_name_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

receiveUserOptionSelection:
  ;ask for user input and wait
  ;wait infinity loop only interrupted by user input
  lda #$ff
  sta userOptionSelection
  cli ;enable interrupts to accept user action also the timer can interrupt here
receiveUserOptionSelection_loop:  
  lda userOptionSelection
  cmp #$ff   
  beq receiveUserOptionSelection_loop
  ;we have a valid user input 
  ;sei ;disable user action until we know if valid action if not ask again
  rts  

action_selector:;
  sei ;do not inrerrupt while running actions
  jsr initiatilizeActionsIDs
  jsr loadScreenActionOptions
  cli
action_selection_ask_again:  
  jsr receiveUserOptionSelection  
  sei
  ldx userOptionSelection
  lda actionIDOptionsRAM,x ;here we have the action ID
  sta selectedAction
  lda selectedAction
  cmp #$ff
  bne action_selection_option_ok
  jsr print_option_unknown
  jmp action_selection_ask_again
action_selection_option_ok:  
  jsr runAction
  cli
  rts

runAction:
  ;an action does three things
  ;prints a description
  ;moves you to a screen
  ;turn off or off a sensor
  ;select the offset of the Action
  lda selectedAction
  cmp #$ff ;invalid object so that slot is empty do not process
  beq runActionEnd
  asl ;multiply by two 
  tax
  lda actions_index,x
  sta pivotZpLow
  inx
  lda actions_index,x
  sta pivotZpHigh
  ;prints the description of the action
  lda action_description_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  ;turns on/off a sensor
  lda action_sensor_id_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  ;always store the sensor ID for the Action specially if it is $FF
  sta sensorCurrentID 
  ;load if the sensor is or not active
  lda action_sensor_active_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  sta sensorCurrentStatus ;on off  
  ;moves you to next screen
  lda action_screen_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  cmp #$ff ;invalid object so that slot is empty do not process
  beq runActionEnd
  sta screenCurrentID
  lda #$1
  sta moveNextScreen
runActionEnd:
  rts

printActionUnknown:  
  lda #< actions_unknown
  sta serialDataVectorLow  
  lda #> actions_unknown
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

print_option_unknown
  lda #< option_unknown
  sta serialDataVectorLow  
  lda #> option_unknown
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

print_with_or_without_CRLF  
  lda print_no_CRLF
  bne printing_NOCRLF
  jsr printAsciiDrawing
  rts
printing_NOCRLF:
  jsr send_rs232_line_noCRLF   
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------ACTION------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SENSORS------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

sensor_selector:
;   lda #$73
;   jsr send_rs232_char 
;   lda sensorCurrentID
;   clc
;   adc #$30
;   jsr send_rs232_char  
  lda sensorCurrentID
  cmp #$ff
  beq sensor_selector_end
  cmp #$0
  beq sensor_selector_0
;   cmp #$1
;   beq sensor_selector_1
;   cmp #$2
;   beq sensor_selector_2
  cmp #$3
  beq sensor_selector_3
sensor_selector_0:
  jsr sensor_0_run
  rts  
sensor_selector_3:
  jsr sensor_3_run
  rts
sensor_selector_end:
  rts

sensor_0_run:
  lda sensorCurrentStatus
  beq sensor_0_run_off
  lda sensorCurrentID
  asl
  tax
  lda sensors_index,X
  sta pivotZpLow
  inx
  lda sensors_index,X
  sta pivotZpHigh
  lda sensor_dialog_on_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts
sensor_0_run_off:  
  rts

sensor_3_run:
  lda sensorCurrentStatus
  beq sensor_3_run_off
  lda sensorCurrentID
  asl
  tax
  lda sensors_index,X
  sta pivotZpLow
  inx
  lda sensors_index,X
  sta pivotZpHigh
  lda sensor_dialog_on_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  ;jsr timerAllGame
  jsr timerWaitOneMinute
  rts
sensor_3_run_off:  
  rts  

timerAllGame:
  lda #<msj_timerAllGame
  sta serialDataVectorLow  
  inx 
  lda #>msj_timerAllGame
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  ;jsr timerWaitOneMinute 
  rts  

startTimerIdle:
  lda TIMER_ZP_MIN
  sta idleTimerStartMinute
  rts

timerCheckTimeIdleElapsed: ;called from interruptions
  lda idleTimerStartMinute
  sec
  sbc TIMER_ZP_MIN
  cmp #12;60 - 12 = 48 so it is 12  
  ;branch on carry clear is less than 2 minutes 
  bcc timerCheckTimeIdleElapsedEnd
  ;if we are here we ended the game
  rts
timerCheckTimeIdleElapsedEnd
  rts

check_sensor:
  jsr turnOnHearRate
  jsr delay_3_sec
  jsr turnOffHearRate
  jsr delay_3_sec
  jsr increaseWaterLevel
  jmp check_sensor


heartbeatOnSensor:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000001 ;bit 0 on 1 turn on heartrate 
  sta heartRateSensor
  jsr heartbeatSet
  rts

heartbeatOffSensor:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000000 ;bit 0 on 0 turn off heartrate
  sta heartRateSensor
  jsr heartbeatSet
  rts

increaseWaterLevelSensor:
  jsr waterOnSensor
  jsr waterSet
  jsr delay_3_sec
  jsr waterOffSensor
  jsr waterSet
  rts

waterSet:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  ;we will modify port b bits PB1 
  lda RS_PORTB ;load what is already on port B
  and #%10111101 ;keep bits 7,5,4,3,2,0 and reset bits 6, 1 of port b
  sta RS_PORTB
  ora waterLevelSensor ;set bit 6 for sync and bit 0.
  sta RS_PORTB ;set the new value
  rts  
  
waterOnSensor:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000010 ;bit 0 on 1 turn on heartrate 
  sta waterLevelSensor
  rts

waterOffSensor:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000000 ;bit 0 on 0 turn off heartrate
  sta waterLevelSensor
  rts

heartbeatSet:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  ;we will modify port b bits PB1 and PB0
  lda RS_PORTB ;load what is already on port B
  and #%10111110 ;keep bits 7,5,4,3,2,1 and reset bits 6, 1 and 0 of port b
  sta RS_PORTB
  ora heartRateSensor ;set bit 6 for sync and bit 0.
  sta RS_PORTB ;set the new value
  rts  
;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SENSORS------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------HEARTRATE------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initializeHearRate:
  ;five heart rate levels 0 to 4
  lda #$0  
  sta heartRate
  rts

increaseHeartRate:
  inc heartRate
  rts

decreaseHeartRate:
  dec heartRate
  rts  

checkHearRateLevel:
  lda #$2
  cmp heartRate
  bcs checkHearRateLevel_greater ;is_greater_or_equal Branch if Carry Set (variable >= 6502)
  jsr turnOffHearRate 
checkHearRateLevel_greater: 
  jsr turnOnHearRate
  rts

turnOnHearRate:
  lda #< msj_heartOn
  sta serialDataVectorLow  
  lda #> msj_heartOn
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr heartbeatOnSensor
  ;add jump to a routine to show hate rate on the sensor
  rts   

turnOffHearRate:
  lda #< msj_heartOff
  sta serialDataVectorLow  
  lda #> msj_heartOff
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr heartbeatOffSensor
  rts     

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------HEARTRATE------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------WATERLEVEL------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initializeWaterLevel:
  ;five heart rate levels 0 to 4
  lda #$0  
  sta waterLevel
  rts  

increaseWaterLevel:
  inc waterLevel
  lda #< msj_waterOn
  sta serialDataVectorLow  
  lda #> msj_waterOn
  sta serialDataVectorHigh
  jsr printAsciiDrawing  
  jsr increaseWaterLevelSensor
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------WATERLEVEL------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



  byte 00,00,00,00,00,00,00,00,00,00

;=============================================================
;Phrases
;=============================================================
objects_header:
  .ascii "Puedes ver los siguientes objetos:"
  .ascii "e"

actions_header:
  .ascii "Puedes realizar las siguientes acciones:"
  .ascii "e"  

letterActions:
  .ascii "ABCDE"  

numbersObjects:
  .ascii "123456"  

pasamos:
  .ascii "Por aca pasamos"
  .ascii "e"

msj_mirar:
  .ascii "Mirar "
  .ascii "e"
  
msj_usar:
  .ascii "Usar "
  .ascii "e"

msj_con:  
  .ascii " con "
  .ascii "e"

msj_accok:
  .ascii "Epa... esa es la acción"
  .ascii "e"  

msj_objok:
  .ascii "Epa... ese es un objeto"
  .ascii "e"   

msj_objok2:
  .ascii "Epa... y ese es el otro!"
  .ascii "e"    

msj_heartOn:
  .ascii "Tu corazón se acelera y no puedes pensar"
  .ascii "e"    

msj_heartOff:
  .ascii "Tu corazón esta tranquilo"
  .ascii "e"

msj_waterOn:
  .ascii "El Agua Sube"
  .ascii "e"    

msj_secondElapsed:
  .ascii "Paso el tiempo"
  .ascii "e"    

msj_minuteElapsed:
  .ascii "Paso un minuto y te quedan "
  .ascii "e"    

msj_timerAllGame:
  .ascii "Comienza la Aventura tiene 10 minutos"
  .ascii "e"    

msj_timerExpired:
  .ascii "El tiempo pasa..."
  .ascii "e"    

msj_iddleTimer1:
  .ascii "El constante goteo era hipnotico. Gota, pausa, gota. "
  .ascii "El agua comenzo a entumecer tus extremidades hasta que dejaste de sentirlas. "
  .ascii "Un eterno sueño te dio la bienvenida. "    
  .ascii "e"     
actions_unknown:
  .ascii "Mmmm no puedes hacer eso"
  .ascii "e"     

option_unknown:
  .ascii "Mmmm esa opción no es válida"
  .ascii "e"    

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------TEST BUTTONS-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

test_buttons:
  ;sei ;disable interrupts to process user buton selection
  lda LCD_PORTA
  sta LCD_PORTSTATUS
  ;move PA4 to PA7 and PA3 to PA6
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS ; now we have PA4 on the carry and PA3 on the negative flag 
  lda LCD_PORTSTATUS
  bcc pressed_buttons_pa4 ;no carry  means that Pa4 was zero then it was pressed
  bmi test_buttons_keep_testing; if one the pa3 was not pressed
pressed_buttons_pa3:
  ;here button pa3 was pressed
  jsr pa3_button_action 
  rts
pressed_buttons_pa4:  
  jsr pa4_button_action
  rts
test_buttons_keep_testing:
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS ; now we have PA2 on the carry and PA1 on the negative flag 
  bcc pressed_buttons_pa2 ;no carry  means that Pa2 was zero then it was pressed
  bmi test_buttons_keep_testing_again; if one the pa1 was not pressed
pressed_buttons_pa1:
  ;here button pa1 was pressed
  jsr pa1_button_action 
  rts
pressed_buttons_pa2:  
  jsr pa2_button_action
  rts
test_buttons_keep_testing_again:
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS ; now we have PA0 on the carry 
  bcc pressed_buttons_pa0
  ;no button was pressed but we had an interrupt
  rts
pressed_buttons_pa0:
  jsr pa0_button_action
  rts

pa4_button_action:
  ;fire button on LCD PCB
  lda #$4 ;option 4 es e option
  sta userOptionSelection
;   lda #$34 ;number 4 in ascii
;   jsr send_rs232_char
  rts

pa3_button_action:
  ;up button on LCD PCB
  lda #$1 ;option 1 es B option
  sta userOptionSelection  
;   lda #$31 ;number 1 in ascii
;   jsr send_rs232_char
  rts

pa2_button_action:
  ;right button on LCD PCB
  lda #$2 ;option 2 es C option
  sta userOptionSelection  
;   lda #$32 ;number 2 in ascii
;   jsr send_rs232_char
  rts

pa1_button_action:
  ;down button on LCD PCB
  lda #$3 ;option 1 es D option
  sta userOptionSelection
;   lda #$33 ;number 1 in ascii
;   jsr send_rs232_char
  rts

pa0_button_action:
  ;left button on LCD PCB
  lda #$0 ;option 0 es A option
  sta userOptionSelection
;   lda #$30 ;number 0 in ascii
;   jsr send_rs232_char
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------TEST BUTTONS-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------RLE------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;one line for RLE
rle_data:
  .byte 97,3,98,98,32,31,32,9,99,101,99,97,102,102,98,98,32,104,111,108,97
  .byte 32,99,111,109,111,32,101,115,116,97,115,255 ;255 is the end character
  .ascii "aaabb                                        cecaffbb hola como estas"

;algoritm
;read first char and read second char
;if first char is 255 end
;if second char <32 print first char second char times
;if second char = 255 print first char one time and end
;else all conditions print first char one time
rle_init:
  lda #< rle_data
  sta rleVectorLow
  lda #> rle_data 
  sta rleVectorHigh
  rts

rle_screen:
  lda #< screen_20c_compressed
  sta rleVectorLow
  lda #> screen_20c_compressed
  sta rleVectorHigh
  ;first byte is size
  ldy #$00
  lda (rleVectorLow),y 
  sta rleScreenLines 
rle_screen_cont:  
  ldx #$ff
rle_screen_process_line:
  inx
  cpx rleScreenLines
  beq rle_screen_end
  jsr rle_expand
  jmp rle_screen_process_line
rle_screen_end:
  rts



rle_expand:
  txa 
  pha
  ldy #$00 ;to bypass the first byte of number of lines
rle_expand_loop:
  iny
rle_expand_loop_cont1:  
  lda (rleVectorLow),y  
  cmp #$ff
  beq rle_expand_end
  sta rleChar
  iny
rle_expand_loop_cont2:   
  lda (rleVectorLow),y 
  cmp #$ff
  beq rle_expand_print_one_and_end
  lda (rleVectorLow),y   
  cmp #32
  ;when accumulator is minor that data (do not use bmi)
  bcc rle_expand_several_times
  ;if we are here is just print one time and continue
  lda #$1
  sta rleTimes
  ;print the char
  jsr rle_print_char
  dey ;decrement y as it was a new character there and not times Byte
  jmp rle_expand_loop

rle_expand_several_times:
  sta rleTimes
  ;print the char
  jsr rle_print_char
  jmp rle_expand_loop 
rle_expand_print_one_and_end:
  lda #1
  sta rleTimes
  ;print the char
  jsr rle_print_char
rle_expand_end:
  ;print line feed and carriege return
  jsr send_rs232_CRLF
  tya
  clc
  adc rleVectorLow
  sta rleVectorLow
  bcc rle_expand_end_end
  inc rleVectorHigh
rle_expand_end_end:  
  ;retreive x value for each line
  pla
  tax 
  rts  

rle_print_char:
  pha
  tya
  pha 
  txa
  pha 
  ldx #$0
rle_print_char_loop:
  cpx rleTimes
  beq rle_print_char_end
  txa
  pha 
  lda rleChar
  jsr send_rs232_char   
  pla
  tax
  inx
  jmp rle_print_char_loop
rle_print_char_end:
  pla
  tax
  pla
  tay
  pla
  rts


; rle_expand:
;   txa 
;   pha
;   ldy #$00 ;to bypass the first byte of number of lines
; rle_expand_loop:
;   iny
;   cpy #$0
;   bne rle_expand_loop_cont1
;   inc rleVectorHigh
; rle_expand_loop_cont1:  
;   lda (rleVectorLow),y  
;   cmp #$ff
;   beq rle_expand_end
;   sta rleChar
;   iny
;   cpy #$0
;   bne rle_expand_loop_cont2
;   inc rleVectorHigh
; rle_expand_loop_cont2:   
;   lda (rleVectorLow),y 
;   cmp #$ff
;   beq rle_expand_print_one_and_end
;   lda (rleVectorLow),y   
;   cmp #32
;   ;when accumulator is minor that data (do not use bmi)
;   bcc rle_expand_several_times
;   ;if we are here is just print one time and continue
;   lda #$1
;   sta rleTimes
;   ;print the char
;   jsr rle_print_char
;   dey ;decrement y as it was a new character there and not times Byte
;   jmp rle_expand_loop

; rle_expand_several_times:
;   sta rleTimes
;   ;print the char
;   jsr rle_print_char
;   jmp rle_expand_loop 
; rle_expand_print_one_and_end:
;   lda #1
;   sta rleTimes
;   ;print the char
;   jsr rle_print_char
; rle_expand_end:
;   ;print line feed and carriege return
;   jsr send_rs232_CRLF
;   tya
;   clc
;   adc rleVectorLow
;   sta rleVectorLow
;   bcc rle_expand_end_end
;   inc rleVectorHigh
; rle_expand_end_end:  
;   ;retreive x value for each line
;   pla
;   tax 
;   rts  

; rle_print_char:
;   pha
;   tya
;   pha 
;   txa
;   pha 
;   ldx #$0
; rle_print_char_loop:
;   cpx rleTimes
;   beq rle_print_char_end
;   txa
;   pha 
;   lda rleChar
;   jsr send_rs232_char   
;   pla
;   tax
;   inx
;   jmp rle_print_char_loop
; rle_print_char_end:
;   pla
;   tax
;   pla
;   tay
;   pla
;   rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------RLE------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALUART-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
serialUART:

send_rs232_line:
  ldy #$0
send_rs232_line_loop:
  tya 
  clc
  adc serialDataVectorLow
  ;bcc send_rs232_line_loop_same_page
  ;inc serialDataVectorHigh
;send_rs232_line_loop_same_page:  
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

send_rs232_line_noCRLF:
  ldy #$0
send_rs232_line_noCRLF_loop:
  lda (serialDataVectorLow),y 
  ;test for the NULL char that ends all ASCII strings
  beq send_rs232_line_noCRLF_end
  jsr send_rs232_char
  iny
  jmp send_rs232_line_noCRLF_loop 
send_rs232_line_noCRLF_end:
  ;add the number of characters printed + 1 for the null char
  ;store in serialCharperLines
  clc
  tya
  adc #1
  sta serialCharperLines
  ;jsr send_rs232_CRLF
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

; delay_1_sec:
;   jsr DELAY_SEC
;   rts

; delay_2_sec:
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   rts

delay_3_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

; delay_4_sec:
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; rts 

; delay_5_sec:
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   rts

; DELAY_onetenth_SEC:
;   lda #$10
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN

; DELAY_two_tenth_SEC:
;   lda #$10
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN   

DELAY_SEC:
  lda #$FF
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

; DELAY_HALF_SEC:
;   lda #$50
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN

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

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------                                      

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
  .asciiz "     Adventure      "
  .asciiz "       Game         "  
  .asciiz "        RLE         "
  .asciiz "                    "


  


screen_20c_compressed:
  .byte 31
  .byte 32,32,34,32,31,32,5,76,65,32
  .byte 50,48,99,34,255
  .byte 32,32,34,34,32,32,255
  .byte 32,32,34,32,31,32,32,79,83,79
  .byte 76,65,66,83,46,84,69,67,72,34
  .byte 255
  .byte 32,32,34,34,32,32,255
  .byte 32,32,34,32,20,226,148,140,226,148
  .byte 128,226,148,180,226,148,128,226,148,180
  .byte 226,148,128,226,148,180,226,148,128,226
  .byte 148,180,226,148,128,226,148,180,226,148
  .byte 128,226,148,172,226,148,128,226,148,180
  .byte 226,148,128,226,148,180,226,148,128,226
  .byte 148,180,226,148,128,226,148,180,226,148
  .byte 128,226,148,180,226,148,128,226,148,172
  .byte 226,148,128,226,148,180,226,148,128,226
  .byte 148,180,226,148,128,226,148,180,226,148
  .byte 128,226,148,180,226,148,128,226,148,180
  .byte 226,148,128,226,148,144,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 52,70,53,51,32,52,70,32,32,226
  .byte 148,130,32,4,82,65,77,32,4,226
  .byte 148,130,32,4,82,65,77,32,4,226
  .byte 148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 226,150,160,226,150,160,226,150,160,226
  .byte 150,160,32,226,150,160,226,150,160,32
  .byte 32,226,148,130,32,11,226,148,130,32
  .byte 11,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 65,100,100,114,101,115,115,32,32,226
  .byte 148,130,32,4,226,150,144,226,150,145
  .byte 226,150,140,32,4,226,148,130,32,4
  .byte 226,150,144,226,150,146,226,150,140,32
  .byte 4,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 68,97,116,97,32,4,226,148,130,32
  .byte 11,226,148,130,32,11,226,148,156,34
  .byte 255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 68,105,115,112,108,97,121,32,32,226
  .byte 148,130,32,4,82,79,77,32,4,226
  .byte 148,130,32,4,82,79,77,32,4,226
  .byte 148,156,34,255
  .byte 32,32,34,32,20,226,148,156,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,156,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,156
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,164,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,144
  .byte 34,255
  .byte 32,32,34,32,20,226,148,130,32,4
  .byte 66,85,83,32,4,226,150,140,32,4
  .byte 66,85,83,32,4,226,150,140,32,4
  .byte 66,85,83,32,4,226,148,130,32,68
  .byte 32,80,32,65,32,226,148,130,34,255
  .byte 32,32,34,32,20,226,148,130,32,11
  .byte 226,150,140,32,11,226,150,140,32,11
  .byte 226,148,130,32,85,32,82,32,78,32
  .byte 226,148,130,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 65,100,100,114,101,115,115,32,32,226
  .byte 150,140,32,32,65,100,100,114,101,115
  .byte 115,32,32,226,150,140,32,32,65,100
  .byte 100,114,101,115,115,32,32,226,148,130
  .byte 32,73,32,79,32,76,32,226,148,130
  .byte 34,255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 68,97,116,97,32,4,226,150,140,32
  .byte 3,68,97,116,97,32,4,226,150,140
  .byte 32,3,68,97,116,97,32,4,226,148
  .byte 130,32,78,32,84,32,89,32,226,148
  .byte 130,34,255
  .byte 32,32,34,32,20,226,148,130,32,69
  .byte 120,112,97,110,115,105,111,110,32,226
  .byte 150,140,32,69,120,112,97,110,115,105
  .byte 111,110,32,226,150,140,32,69,120,112
  .byte 97,110,115,105,111,110,32,226,148,130
  .byte 32,79,32,46,32,90,32,226,148,130
  .byte 34,255
  .byte 32,32,34,32,20,226,148,156,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,172,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,172
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,164,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,152
  .byte 34,255
  .byte 32,32,34,32,20,226,148,130,32,86
  .byte 73,65,32,54,53,50,50,32,32,226
  .byte 148,130,32,3,71,76,85,69,32,4
  .byte 226,148,130,32,32,67,80,85,32,54
  .byte 53,48,50,32,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,11
  .byte 226,148,130,32,3,76,79,71,73,67
  .byte 32,3,226,148,130,32,3,46,5,32
  .byte 3,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 46,4,32,4,226,148,130,46,4,32
  .byte 32,46,4,32,226,148,130,32,3,226
  .byte 150,147,226,150,147,226,150,147,226,150
  .byte 147,226,150,147,32,3,226,148,156,34
  .byte 255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 226,150,145,226,150,145,226,150,145,226
  .byte 150,145,32,4,226,148,130,41,4,32
  .byte 32,40,4,32,226,148,130,32,3,194
  .byte 183,194,183,194,183,194,183,194,183,32
  .byte 3,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 194,183,194,183,194,183,194,183,32,4
  .byte 226,148,130,194,183,194,183,194,183,194
  .byte 183,32,32,194,183,194,183,194,183,194
  .byte 183,32,226,148,130,32,11,226,148,156
  .byte 34,255
  .byte 32,32,34,32,20,226,148,156,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,172,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,172
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,164,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 73,47,48,32,76,67,68,32,32,226
  .byte 148,130,32,3,80,79,87,69,82,32
  .byte 3,226,148,130,32,3,67,76,79,67
  .byte 75,32,3,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,11
  .byte 226,148,130,32,3,109,111,100,117,108
  .byte 101,32,32,226,148,130,32,4,79,83
  .byte 79,32,4,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,226
  .byte 150,132,226,150,132,226,150,132,226,150
  .byte 132,226,150,132,226,150,132,226,150,132
  .byte 226,150,132,32,32,226,148,130,32,32
  .byte 53,118,32,32,226,153,165,32,4,226
  .byte 148,130,32,11,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,226
  .byte 150,136,98,101,114,100,121,120,226,150
  .byte 136,32,32,226,148,130,32,32,57,118
  .byte 32,32,226,153,166,32,4,226,148,130
  .byte 32,11,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,226
  .byte 150,128,226,150,128,226,150,128,226,150
  .byte 128,226,150,128,226,150,128,226,150,128
  .byte 226,150,128,32,32,226,148,130,32,49
  .byte 50,118,32,32,226,153,163,32,4,226
  .byte 148,130,32,8,226,152,187,32,32,226
  .byte 148,156,34,255
  .byte 32,32,34,32,20,226,148,148,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,180,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,180
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,152,34,255
  .byte 32,32,34,34,255
  .byte 32,32,34,101,34,32,255


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

; left_cursor_endings:
;  ; .byte  $80,$c0,$94,$d4
;   .byte  $88,$c8,$9c,$dc  

; right_cursor_endings:
;   .byte  $93,$d3,$a7,$e7

; ; up_cursor_endings:
; ;   .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8F,$8E,$90,$91,$92,$93
; up_cursor_endings: ;so it is all in one line
;   .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
  
; down_cursor_endings:
;   .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
  
  .org $c000
  .include "acs_screens.asm"  
  .org $e000  
  .include "acs_actions.asm"
  .org $f000
  .include "acs_sensors.asm"
  .org $f800
  .include "acs_dashboard.asm"


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------INTERRUPT MANAGEMENT-------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

nmi:

irq:
  sei ; disable interrupts
  ;preserve Accumulator, X and Y so we can use them here
  pha ; store accumulator in the stack
  txa ; transfer X to Accumulator
  pha ; store the X register in the stack
  tya ; transfer Y to Accumulator
  pha ; store the Y register in the stack
  ;bit command read the memory and compares just used to read the register
  ;bit PORTA ; clear the interrupt flag I am doing it with an LDA on test_buttons
  
  ;check that the input is enabled first (so the program is waiting for user input)
  ;or we can disable interruptions and only enable them before accepting input from the user;
  lda LCD_IFR
  and #%01000000;#LCD_T1_FLAG
  beq irqNextInterruptSource
  ;jsr timerCheckSecondElapsed
;   lda #$61
;   jsr send_rs232_char
  jsr timerCheck10SecondElapsed
  ;jsr timerCheckMinuteElapsed
  ;jsr timerCheckTimeIdleElapsed
irqNextInterruptSource:
;   lda #$62
;   jsr send_rs232_char
  jsr test_buttons ;test_buttons loads the message
exit_irq:  
  ;reserve order of stacking to restore values
  pla ; retrieve the Y register from the stack
  tay ; transfer accumulator to Y register
  pla ; retrieve the X register from the stack
  tax ; transfer accumulator to X register
  pla ; restore the accumulator value
  cli ;re enable interrupts
  rti 



;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



