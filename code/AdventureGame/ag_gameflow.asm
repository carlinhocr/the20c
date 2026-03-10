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

screenCurrentObjects_Low=$b4
screenCurrentObjects_High=$b5

objectDataVectorLow=$b6
objectDataVectorHigh=$b7

puzzleDataVectorLow=$b8
puzzleDataVectorHigh=$b9

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


objectsRAM=$0300 ;32 bytes but i only use 6
objectIDOptionsRAM=$0320;32 bytes but i only use 6
actionIDOptionsRAM=$0340 ;32 bytes but i only use 6
puzzlesRAM=$0400
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
TIMER_LOOPS_1M  = 60                ; 60 × 1 second = 1 minute

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
  jsr timerWaitOneSecond
  ;jsr mainProgram
  ;jmp listeningMode

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
  lda #%00000000      ; clear bits 7 and 6
  sta LCD_ACR

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
mainProgram:
  ;initialize 
  ;jsr testPrinter
  jsr initilizationRoutines
  ;initialize screen as screen zero
  jsr initialize_screen
  jsr draw_current_screen_table
mainProgramLoop:
  jsr action_selector
  lda moveNextScreen
  beq mainProgramLoop;if zero do not move to next screen and ask for actions
  lda #$0
  sta moveNextScreen ;reset the move next screen flag
  jsr select_screen
  jsr draw_current_screen_table
  jmp mainProgramLoop   
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
  ;save accumulator x and y registers
  pla
  tay
  pla
  tax
  pla
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
  sei ;disable interrupts only to be enabled prior to user input
  ;jsr loadObjectsRAM
  ;jsr loadPuzzlesRAM
  jsr loadConstants
  ;jsr initiatilizeObjectsIDs
  jsr initiatilizeActionsIDs
  rts

loadPuzzlesRAM:
  lda puzzle_record_length ;16 bytes
  sta puzzleRecordSize
  ldx puzzle_solved_offset ;here starts the solved property of puzzles
  stx puzzle_pointers_index
  ldx #$0
  stx puzzle_RAM_index
  ldy #$0 
loadPuzzlesRAM_loop:
  ldx puzzle_pointers_index
  lda puzzles_pointers,x ;load low byte address for solved #$a
  sta pivotZpLow
  inx  
  lda puzzles_pointers,x ;load high byte address for solved #$b
  sta pivotZpHigh
  ;update next puzzle_pointers_index
  lda puzzle_pointers_index
  clc
  adc puzzleRecordSize
  sta puzzle_pointers_index
  ;load ram index and store visibility attribute 
  ldx puzzle_RAM_index
  lda (pivotZpLow),y
  sta puzzlesRAM,x
  ;update puzzle_RAM_index for next spot available
  inx 
  stx puzzle_RAM_index
  ;check if the last puzzle was reached if it is break
  cpx puzzle_count
  bne loadPuzzlesRAM_loop
  ;end loop and return 
  rts

loadConstants:
  lda #$6
  sta max_objects_per_screen
  lda #$2
  sta max_puzzles_per_screen 
  lda #$6
  sta max_actions_per_screen
  lda #$0
  sta print_no_CRLF  
  lda #$0 ;flashlight off
  sta flashlightStatus ;flashlight off
  lda #$0
  sta actionCostTotal
  lda #$0
  sta moveNextScreen
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

timerWaitOneSecond:
  cli ;enable interrupts
  ;clear bits 7 and 6 timer 1 in one shot mode
  lda LCD_ACR
  and #%00111111      
  sta LCD_ACR
  lda #TIMER_LOOPS_1S ;constant with the number 20 the number 50ms loops to reach a second
  sta TIMER_ZP_SEC ; memory position to degrade the loop
  jsr timerLoadTick
  rts

timerLoadTick:  
  lda #TIMER_TICKS_LO
  sta LCD_T1LL ;set latch low
  lda #TIMER_TICKS_HI
  sta LCD_T1LH ;set latch high and start timer and clears IFR T1
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

initialize_screen:
  lda #$0
  sta screenCurrentID
  jsr load_screen_ram
  rts

select_screen:
  lda screenCurrentID
  jsr load_screen_ram
  rts

select_screen_noascii:
  ;lda #$0
  ;sta screenCurrentID
  ;jsr load_screen_ram
  jsr draw_current_screen_table_noascii
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
  ;jsr draw_screen_by_hand
  jsr draw_screen_description_flashlight
  ;jsr draw_screen_by_ram_ascii  
;  jsr draw_screen_description
;  jsr selectPuzzle
;  jsr selectObject
  ;jsr selectAction
  rts

draw_current_screen_table_noascii:
  jsr send_rs232_CRLF ;add a blank line
  jsr draw_screen_description
  jsr selectPuzzle
  ;jsr selectObject
  ;jsr selectAction
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
  tya
  pha
  sty actionPosition
  lda actionPosition
  tax 
  lda actionCurrentID
  sta actionIDOptionsRAM,x
  jsr processAction
  pla
  tay
  iny
  cpy max_actions_per_screen ;max objects per screen 0-6 for now 
  bne loadScreenActionOptions_loop
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
  cli ;enable interrupts to accept user action
receiveUserOptionSelection_loop:  
  lda userOptionSelection
  cmp #$ff   
  beq receiveUserOptionSelection_loop
  ;we have a valid user input 
  sei ;disable user action until we know if valid action if not ask again
  rts  

action_selector:;
  jsr initiatilizeActionsIDs
  jsr loadScreenActionOptions
action_selection_ask_again:  
  jsr receiveUserOptionSelection  
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
  

receiveUserInputAction:
  lda #$2 ; 2 usar
  sta selectedAction
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


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------PUZZLE------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


check_puzzle:
  ;load the puzzle combination of verbs and objects
  ;check against selectedAction,selectedObject1,selectedObject2
  lda selectedAction
  cmp #$2 ;action usar only check this action for now
  beq check_puzzle_cont
  rts
check_puzzle_cont:
  ldx screen_puzzle_offset
  lda screenPointersRAM,x 
  sta puzzleDataVectorLow  
  inx 
  lda screenPointersRAM,x 
  sta puzzleDataVectorHigh
  ldy #$0
check_puzzle_cont_loop:
  lda (puzzleDataVectorLow),y
  sta puzzleCurrentID
  tya
  pha
  jsr verify_one_puzzle
  pla
  tay
  iny
  cpy max_puzzles_per_screen ;max objects per screen 0-6 for now 
  bne check_puzzle_cont_loop
  rts

verify_one_puzzle: 
  lda puzzleCurrentID
  cmp #$ff ;invalid object so that slot is empty do not process
  beq end_verify_one_puzzle
  asl ;multiply by two 
  tax
  lda puzzles_index,x
  sta pivotZpLow
  inx
  lda puzzles_index,x
  sta pivotZpHigh
  ;here i have  puzzle_pointer_1 un the pivotZPLow+High
  ;from there i have to go 4 bytes for action
  lda puzzle_action_offset
  tay
  lda (pivotZpLow),Y
  sta puzzlePivotLow  
  iny 
  lda (pivotZpLow),Y
  sta puzzlePivotHigh
  ;here i have the address of puzzle_1_action in puzzleActionLow+High
  ldy #$0 
  lda (puzzlePivotLow),y ;now i have the value of the action
  sta currentPuzzleAction  
  ldy #$1
  lda (puzzlePivotLow),y ;now i have object1
  sta currentPuzzleObject1
  ldy #$2
  lda (puzzlePivotLow),y ;now i have object2
  sta currentPuzzleObject2
  ;now i have to compare the puzzles to the selected action and objects
  lda selectedAction
  cmp currentPuzzleAction
  bne end_verify_one_puzzle
  jsr print_msj_accok
  lda selectedObject1
  cmp currentPuzzleObject1
  beq foundOneObject
  lda selectedObject2
  cmp currentPuzzleObject1
  beq foundOneObject
  jmp end_verify_one_puzzle
foundOneObject: 
  lda selectedObject1
  cmp currentPuzzleObject2
  beq foundBothObjects
  lda selectedObject2
  cmp currentPuzzleObject2
  beq foundBothObjects
  jmp end_verify_one_puzzle
foundBothObjects:  
  lda puzzleCurrentID
  cmp #$0
  jsr solve_puzzle_0
end_verify_one_puzzle:
  rts

solve_puzzle_0:
  ldx puzzleCurrentID
  lda #$1
  sta puzzlesRAM,X
  lda #$1
  ldx #$3 ;object 3 is the key lets make it visible
  sta objectsRAM,X
  rts
  
selectPuzzle:
  ldx screen_puzzle_offset
  lda screenPointersRAM,x 
  sta puzzleDataVectorLow  
  inx 
  lda screenPointersRAM,x 
  sta puzzleDataVectorHigh
  ldy #$0
selectPuzzle_loop:
  lda (puzzleDataVectorLow),y
  sta puzzleCurrentID
  tya
  pha
  jsr processPuzzle
  pla
  tay
  iny
  cpy max_puzzles_per_screen ;max objects per screen 0-6 for now 
  bne selectPuzzle_loop
  rts

processPuzzle:
  lda puzzleCurrentID
  cmp #$ff ;invalid object so that slot is empty do not process
  beq end_processPuzzle
  ;jsr puzzle_multiple_calculate
  ;check visibility do not print invisible objects
  ldx puzzleCurrentID
  lda puzzlesRAM,x
  cmp #$1
  bne puzzledNotSolved
  lda puzzle_description_solved_offset
  sta puzzlePrintOffset
  ;jsr print_puzzle_solved
  jsr print_puzzle  
  rts  
puzzledNotSolved:  
  ;jsr print_puzzle_notsolved
  lda puzzle_description_notsolved_offset
  sta puzzlePrintOffset
  jsr print_puzzle 
  rts
end_processPuzzle:  
  rts   

print_puzzle:
  lda puzzleCurrentID
  asl ;multiply by two 
  tax
  lda puzzles_index,x
  sta pivotZpLow
  inx
  lda puzzles_index,x
  sta pivotZpHigh
  lda puzzlePrintOffset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

print_msj_accok:  
  lda #< msj_accok
  sta serialDataVectorLow  
  lda #> msj_accok
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------PUZZLE------------------------------------------
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
  .ascii "Paso un segundo"
  .ascii "e"    

actions_unknown:
  .ascii "Mmmm no puedes hacer eso"
  .ascii "e"     

option_unknown:
  .ascii "Mmmm esa opción no es válida"
  .ascii "e"    

; ============================================================
;  ACS Screens — auto-generated by acs_screens_to_asm.py
; ============================================================


screens_index:
  .word screen_pointers_0  ; s1s1
  .word screen_pointers_1  ; s1s2
screens_index_record_length:
  .byte 2  ; each screens_index entry is 1 .word (2 bytes)

screens_pointers:
screen_pointers_0:
  .word screen_0_id                ; s1s1 id                [0,1]
  .word screen_0_name              ; s1s1 name              [2,3]
  .word screen_0_north             ; s1s1 north             [4,5]
  .word screen_0_south             ; s1s1 south             [6,7]
  .word screen_0_east              ; s1s1 east              [8,9]
  .word screen_0_west              ; s1s1 west              [10,11]
  .word screen_0_puzzle1           ; s1s1 puzzle1           [12,13]
  .word screen_0_puzzle2           ; s1s1 puzzle2           [14,15]
  .word screen_0_action1           ; s1s1 action1           [16,17]
  .word screen_0_action2           ; s1s1 action2           [18,19]
  .word screen_0_action3           ; s1s1 action3           [20,21]
  .word screen_0_action4           ; s1s1 action4           [22,23]
  .word screen_0_action5           ; s1s1 action5           [24,25]
  .word screen_0_action6           ; s1s1 action6           [26,27]
  .word screen_0_description       ; s1s1 description       [28,29]
  .word screen_0_ascii             ; s1s1 ascii             [30,31]
  .word screen_0_flashlight_on     ; s1s1 flashlight_on     [32,33]
  .word screen_0_flashlight_off    ; s1s1 flashlight_off    [34,35]
screen_pointers_1:  
  .word screen_1_id                ; s1s2 id                [36,37]
  .word screen_1_name              ; s1s2 name              [38,39]
  .word screen_1_north             ; s1s2 north             [40,41]
  .word screen_1_south             ; s1s2 south             [42,43]
  .word screen_1_east              ; s1s2 east              [44,45]
  .word screen_1_west              ; s1s2 west              [46,47]
  .word screen_1_puzzle1           ; s1s2 puzzle1           [48,49]
  .word screen_1_puzzle2           ; s1s2 puzzle2           [50,51]
  .word screen_1_action1           ; s1s2 action1           [52,53]
  .word screen_1_action2           ; s1s2 action2           [54,55]
  .word screen_1_action3           ; s1s2 action3           [56,57]
  .word screen_1_action4           ; s1s2 action4           [58,59]
  .word screen_1_action5           ; s1s2 action5           [60,61]
  .word screen_1_action6           ; s1s2 action6           [62,63]
  .word screen_1_description       ; s1s2 description       [64,65]
  .word screen_1_ascii             ; s1s2 ascii             [66,67]
  .word screen_1_flashlight_on     ; s1s2 flashlight_on     [68,69]
  .word screen_1_flashlight_off    ; s1s2 flashlight_off    [70,71]
screen_pointers_2:
  .word screen_2_id                ; s1s3 id                [72,73]
  .word screen_2_name              ; s1s3 name              [74,75]
  .word screen_2_north             ; s1s3 north             [76,77]
  .word screen_2_south             ; s1s3 south             [78,79]
  .word screen_2_east              ; s1s3 east              [80,81]
  .word screen_2_west              ; s1s3 west              [82,83]
  .word screen_2_puzzle1           ; s1s3 puzzle1           [84,85]
  .word screen_2_puzzle2           ; s1s3 puzzle2           [86,87]
  .word screen_2_action1           ; s1s3 action1           [88,89]
  .word screen_2_action2           ; s1s3 action2           [90,91]
  .word screen_2_action3           ; s1s3 action3           [92,93]
  .word screen_2_action4           ; s1s3 action4           [94,95]
  .word screen_2_action5           ; s1s3 action5           [96,97]
  .word screen_2_action6           ; s1s3 action6           [98,99]
  .word screen_2_description       ; s1s3 description       [100,101]
  .word screen_2_ascii             ; s1s3 ascii             [102,103]
  .word screen_2_flashlight_on     ; s1s3 flashlight_on     [104,105]
  .word screen_2_flashlight_off    ; s1s3 flashlight_off    [106,107]

screen_puzzle_offset:
  .byte 12  ; (byte of screen_0_puzzle1 in screens_pointers)
screen_action_offset:
  .byte 16  ; (byte of screen_0_action1 in screens_pointers)
screen_description_offset:
  .byte 28  ; (byte of screen_0_description in screens_pointers)
screen_ascii_offset:
  .byte 30  ; (byte of screen_0_ascii in screens_pointers)
screen_flashlight_on_offset:
  .byte 32  ; (byte of screen_0_flashlight_on in screens_pointers)
screen_flashlight_off_offset:
  .byte 34  ; (byte of screen_0_flashlight_off in screens_pointers)
screen_record_length:
  .byte 36  ; (total .word bytes per screen record)

; ── Screen 0: s1s1 ──────────────────────────
screen_0_id:
  .byte 0

screen_0_name:
  .ascii "s1s1"
  .ascii "e"

screen_0_north:
  .byte 255  ; none

screen_0_south:
  .byte 255  ; none

screen_0_east:
  .byte 1  ; s1s2

screen_0_west:
  .byte 255  ; none

screen_0_puzzle1:
  .byte 0  ; s1s1Levantarse

screen_0_puzzle2:
  .byte 255  ; none

screen_0_action1:
  .byte 0  ; LEVANTARSE

screen_0_action2:
  .byte 1  ; MIRAR ALREDEDOR

screen_0_action3:
  .byte 2  ; GRITAR POR AYUDA

screen_0_action4:
  .byte 255  ; none

screen_0_action5:
  .byte 255  ; none

screen_0_action6:
  .byte 255  ; none

screen_0_description:
  .ascii ""
  .ascii "e"

screen_0_ascii:
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░#########░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░#         ##░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░#             #░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░#                ##░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░░░░######                   #####░░░░░░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░░░#     #                   #    #░░░░░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░##     #                     #  # ###░░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░░#     #                      # #     #░░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░░░#    #########                #####    #░░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░░#######         #       ########      #   #░░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░░░#                 #######     ##        #   #░░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░░##                  ##           ##        #   #░░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░░░#                     ###           #       ######░░░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░░##                      ##             ##     ###   ##░░░░░░░░░░░░"
  .ascii "░░░░░░░░░░░░░#####                    #                #   ##       ##░░░░░░░░░░"
  .ascii "░░░░░░░░░░░#      #    ####         ###                ###            #░░░░░░░░░"
  .ascii "░░░░░░░░░░#        ## #    #       #########        ###  #            #░░░░░░░░░"
  .ascii "░░░░░░░░░#          ##      #   ###         ##     #   ########       #░░░░░░░░░"
  .ascii "░░░░░░░░░#         #         ###              ##  #####        ##      #░░░░░░░░"
  .ascii "░░░░░░░░░#        #            #                ##              ##    #░░░░░░░░░"
  .ascii "░░░░░░░░░#       #              #               #                ##   #░░░░░░░░░"
  .ascii "░░░░░░░░░░#     #                #             #                  #  #░░░░░░░░░░"
  .ascii "░░░░░░░░░##    #                 #            #                    # #░░░░░░░░░░"
  .ascii "░░░░░░░░##    ##                 ##            #                  #   #░░░░░░░░░"
  .ascii "" 
  .ascii "e" 

screen_0_flashlight_on:
  .ascii "Despiertas sobre piedra húmeda."
  .ascii "La caverna se cerro detrás de ti." 
  .ascii "Un derrumbe de rocas antiguas, pesadas, acomodadas como si el colapso"
  .ascii "hubiera sido final, no accidental." 
  .ascii "El frío no duele todavía." 
  .ascii "Sientes un constante goteo de agua, cada vez mas cerca de ti."
  .ascii "e"

screen_0_flashlight_off:
  .ascii "Despiertas sobre piedra húmeda."
  .ascii "La caverna se cerro detrás de ti." 
  .ascii "Un derrumbe de rocas antiguas, pesadas, acomodadas como si el colapso"
  .ascii "hubiera sido final, no accidental." 
  .ascii "El frío no duele todavía." 
  .ascii "Sientes un constante goteo de agua, cada vez mas cerca de ti."
  .ascii "e"

; ── Screen 1: s1s2 ──────────────────────────
screen_1_id:
  .byte 1

screen_1_name:
  .ascii "s1s2"
  .ascii "e"

screen_1_north:
  .byte 255  ; none

screen_1_south:
  .byte 255  ; none

screen_1_east:
  .byte 255  ; none

screen_1_west:
  .byte 255  ; none

screen_1_puzzle1:
  .byte 255  ; none

screen_1_puzzle2:
  .byte 255  ; none

screen_1_action1:
  .byte 7  ; VEO QUE CAE AGUA

screen_1_action2:
  .byte 255  ; none

screen_1_action3:
  .byte 255  ; none

screen_1_action4:
  .byte 255  ; none

screen_1_action5:
  .byte 255  ; none

screen_1_action6:
  .byte 255  ; none

screen_1_description:
  .ascii ""
  .ascii "e"

screen_1_ascii:
  .ascii "#################################################################################"
  .ascii "###########################^^^^^#^^^##^^^^^^^####################################"
  .ascii "######################^^^^^########################^^^^^^########################"
  .ascii "##################^^^^^^###############################^^^^^#####################"
  .ascii "###############^^^^^#########################################^^^^^###############"
  .ascii "###########^^^^^##########################%%%%#####################^^^^^#########"
  .ascii "########^^^^^######################%%%%%%%@@@@@@%%%%%%%################^^^#######"
  .ascii "#####^^^^^###################%%%%%%%@@@@@@@@@@@@@@@@%%%%%%%################^^^^##"
  .ascii "###^^^^^##################%%%%%%%@@@@@@@@@@@######@@@@@@@@@@@%%%%%%%########^^^^#"
  .ascii "##^^^^^#################%%%%%%%@@@@@@@@######################@@@@@@@@%%%%%%%^^^^#"
  .ascii "##^^^^^###############%%%%%%%@@@@@@@@############################@@@@@@@@%%%%%%%#"
  .ascii "###^^^^^###############%%%%%%%@@@@@@################################@@@@@@%%%%%%#"
  .ascii "#####^^^^^###############%%%%%%%@@@@####################################%%%%%%%##"
  .ascii "########^^^^^##########################^^^^^^^^^^^^^^^^################^^^#######"
  .ascii "############^^^^^##########################################^^^^^#################"
  .ascii "################^^^^^######################################^^^^^#################"
  .ascii "######################^^^^^############################^^^^^#####################"
  .ascii "###############################^^^^^#^^^##^^^^^^^################################"
  .ascii "#################################################################################"
  .ascii "#################################################################################"
  .ascii ""
  .ascii "e"
  

screen_1_flashlight_on:
  .ascii "Al levantarte, miras a tu alrededor. Ves que el agua gotea lenta, pero constantemente, inundando la caverna. Como si midiera el tiempo."
  .ascii "e"

screen_1_flashlight_off:
  .ascii "Al levantarte, miras a tu alrededor. Ves que el agua gotea lenta, pero constantemente, inundando la caverna. Como si midiera el tiempo."
  .ascii "e"

; ── Screen 2: s1s3 ──────────────────────────
screen_2_id:
  .byte 2

screen_2_name:
  .ascii "s1s3"
  .ascii "e"

screen_2_north:
  .byte 255  ; none

screen_2_south:
  .byte 255  ; none

screen_2_east:
  .byte 255  ; none

screen_2_west:
  .byte 255  ; none

screen_2_puzzle1:
  .byte 255  ; none

screen_2_puzzle2:
  .byte 255  ; none

screen_2_action1:
  .byte 255  ; none

screen_2_action2:
  .byte 255  ; none

screen_2_action3:
  .byte 255  ; none

screen_2_action4:
  .byte 255  ; none

screen_2_action5:
  .byte 255  ; none

screen_2_action6:
  .byte 255  ; none

screen_2_description:
  .ascii ""
  .ascii "e"

screen_2_ascii:
  .ascii "░░░░░░░░░##    #                 #            #                    # #░░░░░░░░░░"
  .ascii "░░░░░░░░##    ##                 ##            #                  #   #░░░░░░░░░"
  .ascii "" 
  .ascii "e" 

screen_2_flashlight_on:
  .ascii "La caverna se abre en una cámara amplia pero baja. El techo parece aplastarte con su peso estalactitas afiladas cuelgan peligrosamente del mismo. Las paredes son rugosas, húmedas al tacto, y reflejan una luz apagada que no tiene fuente clara. El aire es frío y estancado. Huele a roca mojada y a algo más viejo, casi orgánico. El suelo tiene marcas irregulares, como pasos interrumpidos en un camino que se pierde en la oscuridad."
  .ascii "e"

screen_2_flashlight_off:
  .ascii "La caverna se abre en una cámara amplia pero baja. El techo parece aplastarte con su peso estalactitas afiladas cuelgan peligrosamente del mismo. Las paredes son rugosas, húmedas al tacto, y reflejan una luz apagada que no tiene fuente clara. El aire es frío y estancado. Huele a roca mojada y a algo más viejo, casi orgánico. El suelo tiene marcas irregulares, como pasos interrumpidos en un camino que se pierde en la oscuridad."
  .ascii "e"

; ── Total screen count ──────────────────────────────────────
screen_count:
  .byte 3

; ============================================================
;  ACS Actions — auto-generated by acs_actions_to_asm.py
; ============================================================

actions_index:
  .word action_pointer_0  ; LEVANTARSE
  .word action_pointer_1  ; MIRAR ALREDEDOR
  .word action_pointer_2  ; GRITAR POR AYUDA
  .word action_pointer_3  ; MIRAR ENTRADA
  .word action_pointer_4  ; GRITAR
  .word action_pointer_5  ; LINTERNA
  .word action_pointer_6  ; EXPLORAR CAMINO
  .word action_pointer_7  ; VEO QUE CAE AGUA
actions_index_record_length:
  .byte 2  ; each actions_index entry is 1 .word (2 bytes)

actions_pointers:
action_pointer_0:
  .word action_0_id            ; LEVANTARSE id            [0,1]
  .word action_0_name          ; LEVANTARSE name          [2,3]
  .word action_0_sensor_id     ; LEVANTARSE sensor_id     [4,5]
  .word action_0_sensor_active ; LEVANTARSE sensor_active [6,7]
  .word action_0_screen        ; LEVANTARSE screen        [8,9]
  .word action_0_cost          ; LEVANTARSE cost          [10,11]
  .word action_0_description   ; LEVANTARSE description   [12,13]
action_pointer_1:
  .word action_1_id            ; MIRAR ALREDEDOR id            [14,15]
  .word action_1_name          ; MIRAR ALREDEDOR name          [16,17]
  .word action_1_sensor_id     ; MIRAR ALREDEDOR sensor_id     [18,19]
  .word action_1_sensor_active ; MIRAR ALREDEDOR sensor_active [20,21]
  .word action_1_screen        ; MIRAR ALREDEDOR screen        [22,23]
  .word action_1_cost          ; MIRAR ALREDEDOR cost          [24,25]
  .word action_1_description   ; MIRAR ALREDEDOR description   [26,27]
action_pointer_2:
  .word action_2_id            ; GRITAR POR AYUDA id            [28,29]
  .word action_2_name          ; GRITAR POR AYUDA name          [30,31]
  .word action_2_sensor_id     ; GRITAR POR AYUDA sensor_id     [32,33]
  .word action_2_sensor_active ; GRITAR POR AYUDA sensor_active [34,35]
  .word action_2_screen        ; GRITAR POR AYUDA screen        [36,37]
  .word action_2_cost          ; GRITAR POR AYUDA cost          [38,39]
  .word action_2_description   ; GRITAR POR AYUDA description   [40,41]
action_pointer_3:
  .word action_3_id            ; MIRAR ENTRADA id            [42,43]
  .word action_3_name          ; MIRAR ENTRADA name          [44,45]
  .word action_3_sensor_id     ; MIRAR ENTRADA sensor_id     [46,47]
  .word action_3_sensor_active ; MIRAR ENTRADA sensor_active [48,49]
  .word action_3_screen        ; MIRAR ENTRADA screen        [50,51]
  .word action_3_cost          ; MIRAR ENTRADA cost          [52,53]
  .word action_3_description   ; MIRAR ENTRADA description   [54,55]
action_pointer_4:
  .word action_4_id            ; GRITAR id            [56,57]
  .word action_4_name          ; GRITAR name          [58,59]
  .word action_4_sensor_id     ; GRITAR sensor_id     [60,61]
  .word action_4_sensor_active ; GRITAR sensor_active [62,63]
  .word action_4_screen        ; GRITAR screen        [64,65]
  .word action_4_cost          ; GRITAR cost          [66,67]
  .word action_4_description   ; GRITAR description   [68,69]
action_pointer_5:
  .word action_5_id            ; LINTERNA id            [70,71]
  .word action_5_name          ; LINTERNA name          [72,73]
  .word action_5_sensor_id     ; LINTERNA sensor_id     [74,75]
  .word action_5_sensor_active ; LINTERNA sensor_active [76,77]
  .word action_5_screen        ; LINTERNA screen        [78,79]
  .word action_5_cost          ; LINTERNA cost          [80,81]
  .word action_5_description   ; LINTERNA description   [82,83]
action_pointer_6:
  .word action_6_id            ; EXPLORAR CAMINO id            [84,85]
  .word action_6_name          ; EXPLORAR CAMINO name          [86,87]
  .word action_6_sensor_id     ; EXPLORAR CAMINO sensor_id     [88,89]
  .word action_6_sensor_active ; EXPLORAR CAMINO sensor_active [90,91]
  .word action_6_screen        ; EXPLORAR CAMINO screen        [92,93]
  .word action_6_cost          ; EXPLORAR CAMINO cost          [94,95]
  .word action_6_description   ; EXPLORAR CAMINO description   [96,97]
action_pointer_7:
  .word action_7_id            ; VEO QUE CAE AGUA id            [98,99]
  .word action_7_name          ; VEO QUE CAE AGUA name          [100,101]
  .word action_7_sensor_id     ; VEO QUE CAE AGUA sensor_id     [102,103]
  .word action_7_sensor_active ; VEO QUE CAE AGUA sensor_active [104,105]
  .word action_7_screen        ; VEO QUE CAE AGUA screen        [106,107]
  .word action_7_cost          ; VEO QUE CAE AGUA cost          [108,109]
  .word action_7_description   ; VEO QUE CAE AGUA description   [110,111]
action_name_offset:
  .byte 2  ; (byte of action_0_name in actions_pointers)
action_sensor_id_offset:
  .byte 4  ; (byte of action_0_sensor_id in actions_pointers)
action_screen_offset:
  .byte 8  ; (byte of action_0_screen in actions_pointers)
action_description_offset:
  .byte 12  ; (byte of action_0_description in actions_pointers)
action_record_length:
  .byte 14  ; (total .word bytes per action record)

; ── Action 0: LEVANTARSE ──────────────────────────
action_0_id:
  .byte 0

action_0_name:
  .ascii "LEVANTARSE"
  .ascii "e"

action_0_sensor_id:
  .byte 0  ; none

action_0_sensor_active:
  .byte 1  ; on

action_0_screen:
  .byte 1  ; screen id

action_0_cost:
  .byte 15

action_0_description:
  .ascii "Con esfuerzo, te incorporas sin saber como. Semejante derrumbe deberia haber sido mortal. El frio no duele, todavia."
  .ascii "e"

; ── Action 1: MIRAR ALREDEDOR ──────────────────────────
action_1_id:
  .byte 1

action_1_name:
  .ascii "MIRAR ALREDEDOR"
  .ascii "e"

action_1_sensor_id:
  .byte 255  ; none

action_1_sensor_active:
  .byte 0  ; off

action_1_screen:
  .byte 255  ; screen id

action_1_cost:
  .byte 15

action_1_description:
  .ascii "Desde el suelo solo se ve oscuridad"
  .ascii "e"

; ── Action 2: GRITAR POR AYUDA ──────────────────────────
action_2_id:
  .byte 2

action_2_name:
  .ascii "GRITAR POR AYUDA"
  .ascii "e"

action_2_sensor_id:
  .byte 255  ; none

action_2_sensor_active:
  .byte 0  ; off

action_2_screen:
  .byte 255  ; screen id

action_2_cost:
  .byte 15

action_2_description:
  .ascii "Intentas gritar, pero tu boca esta llena de agua"
  .ascii "e"

; ── Action 3: MIRAR ENTRADA ──────────────────────────
action_3_id:
  .byte 3

action_3_name:
  .ascii "MIRAR ENTRADA"
  .ascii "e"

action_3_sensor_id:
  .byte 255  ; none

action_3_sensor_active:
  .byte 0  ; off

action_3_screen:
  .byte 255  ; screen id

action_3_cost:
  .byte 15

action_3_description:
  .ascii "Entre las rocas hay rendijas por donde entra aire viciado, pero ninguna lo bastante grande para pasar. Hay marcas irregulares, como si alguien hubiera intentado moverlas y se hubiera detenido a mitad de camino. Tal vez no sea una opcion volver por ahí, pero la idea de explorar una caverna a oscuras no parece tentadora."
  .ascii "e"

; ── Action 4: GRITAR ──────────────────────────
action_4_id:
  .byte 4

action_4_name:
  .ascii "GRITAR"
  .ascii "e"

action_4_sensor_id:
  .byte 255  ; none

action_4_sensor_active:
  .byte 0  ; off

action_4_screen:
  .byte 255  ; screen id

action_4_cost:
  .byte 10

action_4_description:
  .ascii "El eco tarda demasiado en volver. Sientes que algo se mueve encima de ti. Debe ser tu imaginacion, te repites."
  .ascii "e"

; ── Action 5: LINTERNA ──────────────────────────
action_5_id:
  .byte 5

action_5_name:
  .ascii "LINTERNA"
  .ascii "e"

action_5_sensor_id:
  .byte 255  ; none

action_5_sensor_active:
  .byte 0  ; off

action_5_screen:
  .byte 255  ; screen id

action_5_cost:
  .byte 5

action_5_description:
  .ascii "La linterna se "
  .ascii "e"

; ── Action 6: EXPLORAR CAMINO ──────────────────────────
action_6_id:
  .byte 6

action_6_name:
  .ascii "EXPLORAR CAMINO"
  .ascii "e"

action_6_sensor_id:
  .byte 255  ; none

action_6_sensor_active:
  .byte 0  ; off

action_6_screen:
  .byte 255  ; screen id

action_6_cost:
  .byte 20

action_6_description:
  .ascii "Te dispones a explorar el camino que se abre en la oscuridad."
  .ascii "e"

; ── Action 7: VEO QUE CAE AGUA ──────────────────────────
action_7_id:
  .byte 7

action_7_name:
  .ascii "VEO QUE CAE AGUA"
  .ascii "e"

action_7_sensor_id:
  .byte 0  ; none

action_7_sensor_active:
  .byte 1  ; on

action_7_screen:
  .byte 2  ; screen id

action_7_cost:
  .byte 0

action_7_description:
  .ascii "Si es verdad, ves como se empieza a llenar la caverna"
  .ascii "e"

; ── Total action count ──────────────────────────────────────
action_count:
  .byte 8

puzzles_index:
  .word puzzle_pointer_0  ; prender_vela
  .word puzzle_pointer_1  ; abrir_puerta_llave
puzzles_index_record_length:
  .byte 2  ; each puzzles_index entry is 1 .word (2 bytes)

puzzles_pointers:
puzzle_pointer_0:
  .word puzzle_0_id                   ; prender_vela id                   [0,1]
  .word puzzle_0_name                 ; prender_vela name                 [2,3]
  .word puzzle_0_action               ; prender_vela action               [4,5]
  .word puzzle_0_object1              ; prender_vela object1              [6,7]
  .word puzzle_0_object2              ; prender_vela object2              [8,9]
  .word puzzle_0_solved               ; prender_vela solved               [10,11]
  .word puzzle_0_description_solved   ; prender_vela description_solved   [12,13]
  .word puzzle_0_description_notsolved; prender_vela description_notsolved[14,15]
puzzle_pointer_1:
  .word puzzle_1_id                   ; abrir_puerta_llave id                   [16,17]
  .word puzzle_1_name                 ; abrir_puerta_llave name                 [18,19]
  .word puzzle_1_action               ; abrir_puerta_llave action               [20,21]
  .word puzzle_1_object1              ; abrir_puerta_llave object1              [22,23]
  .word puzzle_1_object2              ; abrir_puerta_llave object2              [24,25]
  .word puzzle_1_solved               ; abrir_puerta_llave solved               [26,27]
  .word puzzle_1_description_solved   ; abrir_puerta_llave description_solved   [28,29]
  .word puzzle_1_description_notsolved; abrir_puerta_llave description_notsolved[30,31]
puzzle_action_offset:
  .byte 4  ; (byte of puzzle_0_action in puzzles_pointers)
puzzle_solved_offset:
  .byte 10  ; (byte of puzzle_0_solved in puzzles_pointers)
puzzle_description_solved_offset:
  .byte 12  ; (byte of puzzle_0_description_solved in puzzles_pointers)
puzzle_description_notsolved_offset:
  .byte 14  ; (byte of puzzle_0_description_notsolved in puzzles_pointers)
puzzle_record_length:
  .byte 16  ; (total .word bytes per puzzle record)

; ── Puzzle 0: prender_vela ──────────────────────────
puzzle_0_id:
  .byte 0

puzzle_0_name:
  .ascii "prender_vela"
  .ascii "e"

puzzle_0_action:
  .byte 2  ; usar

puzzle_0_object1:
  .byte 1  ; encendedor

puzzle_0_object2:
  .byte 0  ; vela

puzzle_0_solved:
  .byte 0

puzzle_0_description_solved:
  .ascii "Ahora si puedes ver claramente, en el piso notas una llave"
  .ascii "e"

puzzle_0_description_notsolved:
  .ascii "La cueva esta muy oscura, no puedes ver casi nada"
  .ascii "e"

; ── Puzzle 1: abrir_puerta_llave ──────────────────────────
puzzle_1_id:
  .byte 1

puzzle_1_name:
  .ascii "abrir_puerta_llave"
  .ascii "e"

puzzle_1_action:
  .byte 2  ; usar

puzzle_1_object1:
  .byte 3  ; llave

puzzle_1_object2:
  .byte 4  ; puerta

puzzle_1_solved:
  .byte 0

puzzle_1_description_solved:
  .ascii "Abres la puerta y puedes pasar a otra sección de la cueva"
  .ascii "e"

puzzle_1_description_notsolved:
  .ascii "Puedes ver una puerta cerrada al final de la cueva."
  .ascii "e"

; ── Total puzzle count ──────────────────────────────────────
puzzle_count:
  .byte 2


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
  lda #$34 ;number 4 in ascii
  jsr send_rs232_char
  rts

pa3_button_action:
  ;up button on LCD PCB
  lda #$1 ;option 1 es B option
  sta userOptionSelection  
  lda #$31 ;number 1 in ascii
  jsr send_rs232_char
  rts

pa2_button_action:
  ;right button on LCD PCB
  lda #$2 ;option 2 es C option
  sta userOptionSelection  
  lda #$32 ;number 2 in ascii
  jsr send_rs232_char
  rts

pa1_button_action:
  ;down button on LCD PCB
  lda #$3 ;option 1 es D option
  sta userOptionSelection
  lda #$33 ;number 1 in ascii
  jsr send_rs232_char
  rts

pa0_button_action:
  ;left button on LCD PCB
  lda #$0 ;option 0 es A option
  sta userOptionSelection
  lda #$30 ;number 0 in ascii
  jsr send_rs232_char
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

the20cAscii:
  .ascii "  _  _     _ "
  .ascii " | || |___| |__ _"
  .ascii " | __ / _ \ / _` |"
  .ascii " |_||_\___/_\__,_|_        ___ __"
  .ascii " / __| ___ _  _  | |__ _  |_  )  \ __"
  .ascii " \__ \/ _ \ || | | / _` |  / / () / _|_"
  .ascii " |___/\___/\_, | |_\__,_| /___\__/\__( )"
  .ascii "  __| |___ |__/_ _  _ _____ _____    |/"
  .ascii " / _` / -_) | ' \ || / -_) V / _ \"
  .ascii " \__,_\___| |_||_\_,_\___|\_/\___/"
  .ascii ""
  .ascii ""
  .ascii ""    
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

arcadeAscii:
  .ascii ""
  .ascii "                             jugar NO es opcional"
  .ascii ""
  .ascii "                                ╔═══════════╗"
  .ascii "                                ║  N A V E  ║"
  .ascii "                                ╠═══════════╣"
  .ascii "                                ║           ║"
  .ascii "                                ║   never   ║"
  .ascii "                                ║  give up  ║"
  .ascii "                                ║           ║"
  .ascii "                               ╔╩═══════════╩╗"
  .ascii "                               ║     ! o     ║"
  .ascii "                               ╚╦═══════════╦╝"
  .ascii "                                ║     ▄     ║"
  .ascii "                                ║    ▄█▄    ║"
  .ascii "                                ║   █▀ ▀█   ║"
  .ascii "                                ║  ███████  ║"
  .ascii "                                ║   ▀   ▀   ║"
  .ascii "                                ║           ║"
  .ascii "                                ║   berdyx  ║"
  .ascii "                                ╚═══════════╝"
  .ascii " ┌─────┐ ┌─┐    ┌─┐ ┌─┐ ┌────┐"
  .ascii " │ ┌───┘ │ │    │ │ │ │ │ ┌┐ │"
  .ascii " │ │     │ │    │ │ │ │ │    └┐                █████      ████       ████  "
  .ascii " │ └───┐ │ └──┐ │ └─┘ │ │ └┘  │               ██   ██    ██  ██     ██  ██ "
  .ascii " └─────┘ └────┘ └─────┘ └─────┘              ██         ██    ██   ██    ██"
  .ascii "                                             ██         ████████   ████████"
  .ascii "    ┌─┐ ┌─┐  ┌─────┐ ┌─┐ ┌─┐                  ██   ██   ██    ██   ██    ██"
  .ascii "    │ │ │ │  │ ┌─  │ │ │ │ │                   █████    ██    ██   ██    ██"
  .ascii "    │ └─┘ └┐ │ │ │ │ │ └─┘ └┐"
  .ascii "    └───┐ ┌┘ │  ─┘ │ └───┐ ┌┘"
  .ascii "        └─┘  └─────┘     └─┘"
  .ascii "e" 

modoHistoriaAscii:

  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                                                 █"
  .ascii "                                               ███"
  .ascii "                                                ██"
  .ascii "                   █ ███  ██       ████       ████      ████"
  .ascii "                 █████ ███  ██   ██    ██   ██  ██    ██    ██"
  .ascii "                  ██   ██   ██   ██    ██  ██   ██    ██    ██"
  .ascii "                  ██   ██   ██   ██    ██  ██   ██ █  ██    ██"
  .ascii "                  ██   ██   ███   ██   █    ██  ███    ██   █"
  .ascii "                  █    █    █      ████      ███  █     ████"
  .ascii ""
  .ascii "           ██       █               █                       █"
  .ascii "          ███                     ███"
  .ascii "           ██  █     █      ███    ████    ████     ██ ██    █     ████"
  .ascii "           ██████  ███    ███  █   ██    ██    ██  ██████  ███    █   ██"
  .ascii "           ██  ██   ██   ███       ██    ██    ██  ██   █   ██   ██   ██"
  .ascii "           ██  ██   ██     ████    ██    ██    ██  ██       ██   ██   ██"
  .ascii "           ██  ██   ███  █    ██   ██ █   ██   █   ██       ███   ██ ██"
  .ascii "           █   █    ██    ████      ██     ████    █        ██     ███ ██"
  .ascii "              █"
  .ascii ""
  .ascii ""
  .ascii "                             videojuegos en contexto"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                          (N. del A.: hablen del X-COM)"
  .ascii ""
  .ascii "                          (N. del OSO: y del Defender of the Crown)"
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
  
la20cAscii:
  .ascii "                                    LA 20c"
  .ascii ""  
  .ascii "                                 OSOLABS.TECH"
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
  lda #$62 ;b 
  jsr send_rs232_char  
  lda LCD_IFR
  and #%01000000;#LCD_T1_FLAG
  beq irqNextInterruptSource
  lda #$61 ;a 
  jsr send_rs232_char
  jsr timerCheckSecondElapsed
irqNextInterruptSource:
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



