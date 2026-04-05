;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2


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
LCD_T2CL = LCD_VIA_BASE + $08   ; Timer 1 counter low   (R: clears T1 IFR bit)
LCD_T2CH = LCD_VIA_BASE + $09   ; Timer 1 counter high  (W: starts timer)
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
ramScreenVectorLow=$b0
ramScreenVectorHigh=$b1
dashboardScreenVectorLow=$b2
dashboardScreenVectorHigh=$b3
actionCheckVectorLow=$b4
actionCheckVectorHigh=$b5
actionDataVectorLow=$b6
actionDataVectorHigh=$b7
sourceScreenVectorLow=$b8
sourceScreenVectorHigh=$b9
sourceDashboardVectorLow=$ba
sourceDashboardVectorHigh=$bb
sensorDataVectorLow=$bc
sensorDataVectorHigh=$bd

pivotZpLow=$fe
pivotZpHigh=$ff

;Memory locations RLE
rleChar=$0200
rleTimes=$0201
rleScreenLines=$0202

value=                  $0203
value_1=                $0204
mod10=                    $0205
mod10_1=                  $0206
message = $0207 ; the result up to 6 bytes to $020b
;used by message= $0207
;$0208
;$0209
;$020a
;$020b
multiFactor1=                     $020c
multiFactor2=                     $020d
multiResultLow=                   $020e
multiResultHigh=                  $020f
screenCurrentID=                  $0210
max_actions_per_screen=           $0211
actionCurrentID=                  $0212
actionPosition=                   $0213
current_screen_offset=            $0214
screenPrintOffset=                $0215
selectedAction=                   $0216
print_no_CRLF=                    $0217
flashlightOff=                    $0218
userOptionSelection=              $0219
heartRateLevel=                   $021a
waterLevel=                       $021b
heartRateSensor=                  $021c
waterLevelSensor=                 $021d
flashlightStatus=                 $021e
actionCostTotal=                  $021f
currentActionCost=                $0220
currentActionHideWater=           $0221
currentActionHideFear=            $0222
currentActionHideFlashlightOff=   $0223
simulationTimePassedLowDigits=    $0224
simulationTimePassedHighDigits=   $0225
dashboardCurrentID=               $0226
current_dashboard_offset=         $0227
extraSecondsFlashlightOffLowByte= $0228
extraSecondsFlashlightOffHighByte=$0229
extraSecondsHeartRateLowByte=     $022a
extraSecondsHeartRateHighByte=    $022b
extraSecondsWaterLevelLowByte=    $022c
extraSecondsWaterLevelHighByte=   $022d
maxSimulationTimeLowByte=         $022e
maxSimulationTimeHighByte=        $022f
simulationTimeExpired=            $0230
endScreenSimulationTimeisUp=      $0231
timeRemainingLowByte=             $0232
timeRemainingHighByte=            $0233
;FREE               $0234  
flashlightToggleFlag=             $0235
flashlightSecondsUsedLowByte=     $0236
flashlightSecondsUsedHighByte=    $0237
maxFlashlightTimeLowByte=         $0238
maxFlashlightTimeHighByte=        $0239
timeRemainingFlashLightLowByte=   $023a
timeRemainingFlashLightHighByte=  $023b
randomNumber=                     $023c
enemyProbActionReset=             $023d
enemyProbActionCost=              $023e
enemyProbActionCostCummulative=   $023f
enemyProbActionCummPlusFlashlight=$0240
enemyProbFlashlight=              $0241
enemyProbCurrentScreen=           $0242
enemyProbabilityTotal=            $0243
idleTimerStartMinute=             $0244
sensorCurrentID=                  $0245
sensorCurrentStatus=              $0246
timerExpired=                     $0247
gameEnded=                        $0248
fearLevel=                        $0249
watertLevel=                      $024a
actionHidden=                     $024b
highWaterLevel=                   $024c
highFearLevel=                    $024d
moveNextScreen=                   $024e
actionFailedProb=                 $024f
actionFailedProbWaterPerLevel=    $0250
actionFailedProbFlashlight=       $0251
actionFailedProbHeartRate=        $0252
actionFailedWaterFlashLightHeartRate=    $0253
actionFailedProbabilityTotal=     $0254
endScreenByEnemy=                 $0255
endScreenByActionFailed=          $0256
divisorBarSegment=                $0257
printableNumberOfBars=            $0258
levelsToIncreaseWater=            $0259
timerOn=                          $025a
maximumWaterLevel=                $025b
simulationSegments=               $025c
flashlightSegments=               $025d
dashboardStartScreen=             $025e
dashboardEndScreenDefault=        $025f
barMaximumTimerLow=               $0260
barMaximumTimerHigh=              $0261
segmentBarSizeHigh=               $0262
segmentBarSizeLow=                $0263
currentTimeBarHigh=               $0264
currentTimeBarLow=                $0265
currentSegmentBarSizeHigh=        $0266
currentSegmentBarSizeLow=         $0267
barSegmentNumbers=                $0268
emptyBars=                        $0269
currentNumberOfBars=              $026a
endByTimeUp=                      $026b
endByEnemy=                       $026c
endByActionFailed=                $026d
endByDirectAction=                $026e
additionalWaterLevel=             $026f
dashboardEndScreenEnemy=          $0270
dashboardEndScreenTimeUp=         $0271
dashboardEndScreenActionFailed=   $0272
dashboardHighFearLevel=           $0273
dashboardHighWaterLevel=          $0274

actionIDOptionsRAM=$0440 ;32 bytes but i only use 6
screenPointersRAM=$0500
dashboardPointersRAM=$0600

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
  ;initialize variables, vectors, memory mappings and constans DONE
  ;configure stack and enable interrupts DONE
  ;Initialize HARDWARE
  jsr viaLcdInit
  jsr viaRsInit
  ;jsr viaSoundInit
  jsr uartSerialInit
  jsr screenInit
  .org $9000
loopMessage:  
  jsr lcdDemoMessage
  lda #< screen_0_ascii
  sta serialDataVectorLow
  lda #> screen_0_ascii
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  ldx #$1
  lda #$1 ;select bank 1
  sta RS_PORTA
loopMessageWait:
  txa
  beq loopMessage
  inx  
  jmp loopMessageWait

  ;jmp listeningMode
  ;start MainProgran and I save stack space by not jumping to it

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------PRINTASCIIDRAWING-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

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
;-----------------------------PRINTASCIIDRAWING-------------------------------------
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
  .asciiz "        DUAL        "
  .asciiz "      EEPROM 0      "  
  .asciiz "                    "
  .asciiz "                    "


  

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
  ;sets interrupts for CA1 #%10000010

  lda #%10000010
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
  lda #%01000000      ; set bit 6 to make it freen running load and continue
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
  ;lda #%00000000  ;set as input PA7, PA6, PA5, PA4,PA3,PA2,PA1,PA0
  ;set all port A pins as output
  lda #%11111111  ;load all ones equivalent to $FF  
  sta RS_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B
  ;Use PA0 connecting PA0 to EEPROM0 and the inverted PA0 to EEPROM1
  lda #$00
  sta RS_PORTA
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------VIARSINIT---------------------------------------
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
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

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

  .org $a000
screen_0_ascii:
  .ascii "Hola soy el "
  .ascii "EEPROM que está en"
  .ascii "la Memoria 00"
  .ascii "e"
;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------INTERRUPT MANAGEMENT-------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
  .org $fe00
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
;   lda LCD_IFR
;   and #%01000000;#LCD_T1_FLAG
;   beq irqNextInterruptSource
  ;jsr timerCheckSecondElapsed
;   lda #$61
;   jsr send_rs232_char
  ;jsr timerCheck10SecondElapsed
  ;jsr timerCheckMinuteElapsed
  ;jsr timerCheckTimeIdleElapsed
irqNextInterruptSource:
;   lda #$62
;   jsr send_rs232_char
  ;jsr test_buttons ;test_buttons loads the message
exit_irq:  
  ;reserve order of stacking to restore values
  pla ; retrieve the Y register from the stack
  tay ; transfer accumulator to Y register
  pla ; retrieve the X register from the stack
  tax ; transfer accumulator to X register
  pla ; restore the accumulator value
  cli ;re enable interrupts
  rti 

  .org $ff00
switch_bank:
  sta RS_PORTA
  jmp loopMessageWait
;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



