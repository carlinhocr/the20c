;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define KEYBOARD primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2
;scan keyboard on VIA2
;Show message on LCD on VIA1
;show light show with LEDs 

;PORTA rows input #$00
;PORTB columns output #$FF
;write a zero to each column in turn (1110, 1101, 1011, 0111)
;read the rows if one is in zero then it is because of a short circuit with the column
;now we know the intersection column + row and we can establish which key was pressed
;if no rows are zero then no key was pressed.


;VIA Ports and Constants
LCD_PORTB = $6000
LCD_PORTA = $6001
LCD_DDRB = $6002
LCD_DDRA = $6003
LCD_PCR = $600c
LCD_IFR = $600d
LCD_IER = $600e

;KB_PORTB = $7000
;KB_PORTA = $7001
;KB_DDRB = $7002
;KB_DDRA = $7003
;KB_PCR = $700c
;KB_IFR = $700d
;KB_IER = $700e

;CIA Ports and Constants
KB_PORTB = $7001
KB_PORTA = $7000
KB_DDRB = $7003
KB_DDRA = $7002

;zero page memory positions for Vectors and Data

PORTSTATUS=$b0
PATTERN=$b1
rowDetected = $b2
keyboardBufferPointer = $b3 ;points to the next free space on the keyboard buffer
keyboardBufferZPLow = $b4 
keyboardBufferZPHigh = $b5 ;256 positions from $3000 to $30FF
screenCursor=$b6
characterToPrint=$b7
rowNumberDetected = $b8
columnNumberDetected = $b9

keymapMemoryLowZeroPage=$ba
keymapMemoryHighZeroPage=$bb

keymapROMZeroPageLow=$bc
keymapROMZeroPageHigh=$bd

keyPressedAscii=$be
keyPressedPosition=$bf

columnScanned = $c0
portColumn =$c1
STATUS_PORTA=$c2
STATUS_PORTB=$c3
rowScanned=$C4
portRow=$c5

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



;constants
;BEGIN COMMODORE KEYBOARD CONSTANT
totalKeymapLenght=$40 ;64 key positions one more
;END COMMODORE KEYBOARD CONSTANT
cursorInitialPosition=$d4
cursorFinalPosition=$e7
fill=$43 ;letter C
totalScreenLenght4Lines=$50
totalScreenLenght=$3c ;make it only 3 lines long 3c = 60 decimal
totalLineLenght=$13 ;20 positions in hexadecimal is 13
end_char=$ff
cblank=$20

;Memory Mappings
;these are constants where we reflect the number of the memory position

screenBufferLow =$00 ;goes to $50 which is 80 decimal
screenBufferHigh =$30

lcdCharPositionsLow =$00 ;goes to $50 which is 80 decimal
lcdCharPositionsHigh =$31

keymapLow = $00
keymapHigh =$32

keyboardBufferLow = $00 
keyboardBufferHigh = $33 ;256 positions from $3000 to $30FF



;bin 2 ascii values
value =$0200 ;2 bytes, Low 16 bit half
mod10 =$0202 ;2 bytes, high 16 bit half and as it has the remainder of dividing by 10
             ;it is the mod 10 of the division (the remainder)
message = $0204 ; the result up to 6 bytes
counter = $020a ; 2 bytes
score = $020c ; 2 bytes
; scoreLow=$0c 
; scoreHigh=$02

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
  jsr viaKeyboardInit
  jsr screenInit
  jsr welcomeMessage
  jsr keyboardInit 
  jsr programLoop

programLoop:  
  ;jsr keyboardScanMini
  jsr keyboardScanRecursive
  ;jsr keyboardScan
  jsr printKeyboardBuffer
  jmp programLoop  


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

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIALCDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIAKEYCOARDINIT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaKeyboardInit:

  ;BEGIN enable interrupts KEYBOARD VIA
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  ;lda #%10000010
  ;sta KB_IER 
  ;enable negative edge transition ca1 KB_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  ;lda #%00000000
  ;sta KB_PCR 
  ;END enable interrupts

  ;BEGIN Configure Ports A & B
 
  ; WE ARE SCANNING THE KEYBOARD DIFFERENTLY C64 USES PORT A ROWS AS OUTPUT
  ; AND PORB COLUMNS AS INPUTS, it works the same
  ;set all port A pins as input for rows
  lda #%00000000  ;load all ones equivalent to $FF
  sta KB_DDRA ;store the accumulator in the data direction register for Port A

  ;set all port B pins as output for columns
  lda #%11111111  ;load all ones equivalent to $FF
  sta KB_DDRB ;store the accumulator in the data direction register for Port B


  ;END Configure Ports A & B

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIAKEYCOARDINIT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------WELCOME MESSAGE------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

welcomeMessage:
  jsr clear_display
  lda #$80 ;position cursor at the start of sthe first line
  jsr lcd_send_instruction
  lda #<startMessage1
  sta charDataVectorLow
  lda #>startMessage1
  sta charDataVectorHigh
  jsr print_message
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------WELCOME MESSAGE------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------KEYBOARD INIT--------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

keyboardInit:
  lda #$0
  sta keyboardBufferPointer
  sta screenCursor
  lda #keyboardBufferLow
  sta keyboardBufferZPLow
  lda #keyboardBufferHigh
  sta keyboardBufferZPHigh
  jsr loadKeymap
  lda #$94 ;position cursor at the start of third line
  jsr lcd_send_instruction
  rts

loadKeymap:
  ;load vectors
  lda #keymapLow
  sta keymapMemoryLowZeroPage ; to use indirect addressing with y
  lda #keymapHigh
  sta keymapMemoryHighZeroPage
  lda #<keyboardMap
  sta keymapROMZeroPageLow
  lda #>keyboardMap
  sta keymapROMZeroPageHigh
  ldy #$ff
loadKeymapLoop:
  iny
  cpy #totalKeymapLenght ;64 decimal it counts from 0 to 63 and then at 64 quits
  beq loadKeymapEnd
  ; copy from ROM to RAM the LCD positions
  lda (keymapROMZeroPageLow),Y
  sta (keymapMemoryLowZeroPage),Y
  jmp loadKeymapLoop
loadKeymapEnd:
  rts    

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------KEYBOARD INIT--------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------KEYBOARD SCAN--------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

keyboardScanRecursive:
  ldy #$ff
  lda #%11111110
  sta portColumn
  clc 
keyboardScanRecLoop:
  iny
  sty columnScanned
  sty columnNumberDetected
  lda portColumn ; first attempt is #%1111110
  sta KB_PORTB ;writes to portB   
  lda KB_PORTA ; load PA status it is #%11111111 if no key was pressed because of pullups
  sta STATUS_PORTA
  cmp #%11111111
  bne keyboardScanRowRecursive ; it means a key was pressed see which one
  ;jsr keyboardScanRows
  ;lda #$1 ;see if a row was detected
  ;cmp rowDetected
  ;beq writeKeyboardBufferJump2
keyboardScanRecLoopReturn:  
  ;lda #$0
  ;sta rowDetected ; deactivate any detected rows
  sec
  rol portColumn
  ldy columnScanned
  cpy #$7
  bne keyboardScanRecLoop
  rts ; return to main programLoop

keyboardScanRowRecursive:
  ldx #$ff
  lda #%11111110
  sta portRow
  clc
keyboardScanRowRecLoop:
  inx
  stx rowScanned
  lda STATUS_PORTA
  cmp portRow
  beq keyFound
  sec
  rol portRow
  ldx rowScanned
  cpx #$7
  bne keyboardScanRowRecLoop
  jmp keyboardScanRecLoopReturn ; all rows scanned nothing found go back to columns scanning

keyFound:
  lda rowScanned
  sta rowNumberDetected
  lda columnScanned
  sta columnNumberDetected
  ldx #$ff
  lda #$0
  sta keyPressedPosition
keyPositionLoop:
  inx
  cpx rowNumberDetected
  beq keyPositionAddColumn ;stop looping when key found
  lda keyPressedPosition
  clc
  adc #$08 ; keep going to the next row on the key map and add to the position of the pressed key
  sta keyPressedPosition
  cpx #$07
  bne keyPositionLoop
  rts ; return to main program loop as we have iterated more than 8 rows (from 0 to 7)

keyPositionAddColumn:
  lda keyPressedPosition
  clc
  adc columnNumberDetected
  sta keyPressedPosition
  jsr DELAY_two_tenth_SEC  ;for debouncing
  jsr DELAY_two_tenth_SEC  ;for debouncing
  jsr DELAY_two_tenth_SEC  ;for debouncing
  jsr addKeyToKeyboardBufferMapKey ; just to separate both procedures
  rts ;this rts also returns to main programLoop  


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------KEYBOARD SCAN--------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------    

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------PRINT KEYBOARD BUFFER------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

; writeKeyboardBufferMapKey:  
;   lda #$d4 ;position cursor at the start of sthe fourth line
;   jsr lcd_send_instruction
;   ldy keyPressedPosition
;   lda (keymapMemoryLowZeroPage),Y
;   jsr print_char 
;   jsr delay_1_sec
;   jsr welcomeMessage
;   rts

addKeyToKeyboardBufferMapKey:  
  ldy keyPressedPosition
  lda (keymapMemoryLowZeroPage),Y ;store character in accumulator
  ldy keyboardBufferPointer
  sta (keyboardBufferZPLow),Y ;save character to pointer
  inc keyboardBufferPointer
  ;jsr DELAY_onetenth_SEC ;for debouncing
  rts

printKeyboardBuffer:
  ldy #$FF
printKeyboardBufferLoop:
  iny
  cpy keyboardBufferPointer 
  beq printKeyboardBufferEnd
  lda (keyboardBufferZPLow),Y 
  sta characterToPrint
  lda #cursorInitialPosition ;position cursor at the start of sthe fourth line
  clc   
  adc screenCursor
  jsr lcd_send_instruction
  lda #totalLineLenght
  cmp screenCursor 
  beq printKeyboardBufferCharacter ;keep cursor so not to overrun the line
  inc screenCursor ;always points to the first free
printKeyboardBufferCharacter:  
  lda characterToPrint
  jsr print_char 
  jmp printKeyboardBufferLoop
printKeyboardBufferEnd:
  lda #$0
  sta keyboardBufferPointer
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------PRINT KEYBOARD BUFFER------------------------------
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

buttonPressed:
  lda #$94 ;position cursor at the start of sthe third line
  jsr lcd_send_instruction
  lda #<buttonPressedMessage
  sta charDataVectorLow
  lda #>buttonPressedMessage
  sta charDataVectorHigh
  jsr print_message
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

bin_2_ascii_score:
  lda #0 ;this signals the empty string
  sta message ;initialize the string we will use for the results
  ;BEGIN Initialization of the 4 bytes
  ; initializae value to be the counter to ccount interrupts 
  sei ;disable interrupts so as to update properly the counter
  lda score
  sta value 
  lda score + 1
  sta value + 1
  cli ; reenable interrupts after updating
  jsr bin_2_ascii
  rts

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
  .ascii "    C64 KEYBOARD"    

buttonPressedMessage:
  .ascii "   BUTTON PRESSED"
 

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

  

keyboardMaptest: ;position of number
  ;all that i do not have a current core are #
  .byte $30,$31,$32,$33,$34,$35,$36,$37 ; PA0
  .byte $41,$42,$43,$44,$45,$46,$47,$48 ; PA1
  .byte $30,$31,$32,$33,$34,$35,$36,$37 ; PA2
  .byte $41,$42,$43,$44,$45,$46,$47,$48 ; PA3 
  .byte $30,$31,$32,$33,$34,$35,$36,$37 ; PA4
  .byte $41,$42,$43,$44,$45,$46,$47,$48 ; PA5
  .byte $30,$31,$32,$33,$34,$35,$36,$37 ; PA6
  .byte $41,$42,$43,$44,$45,$46,$47,$48 ; PA7  


keyboardMap:
;all that i do not have a current core are #
;       PB0,Pb1,PB2,PB3,PB4,PB5,PB6,Pb7
  .byte $23,$23,$2d,$30,$38,$36,$34,$32 ; PA0
  .byte $23,$23,$40,$4f,$55,$54,$45,$51 ; PA1
  .byte $23,$3d,$3a,$4b,$48,$46,$53,$23 ; PA2
  .byte $23,$23,$2e,$4d,$42,$43,$5a,$20 ; PA3
  .byte $23,$2f,$2c,$4e,$56,$58,$23,$23 ; PA4
  .byte $23,$3b,$4c,$4a,$47,$44,$41,$23 ; PA5
  .byte $23,$2a,$50,$49,$59,$52,$57,$23 ; PA6
  .byte $23,$ed,$2b,$39,$37,$35,$33,$31 ; PA7

;       PB0,Pb1,PB2,PB3,PB4,PB5,PB6,Pb7
;       "#","#","-","0","8","6","4","2" PA0
;       "#","#","@","O","U","T","E","Q" PA1
;       "#","=",":","K","H","F","S","#" PA2
;       "#","#",".","M","B","C","Z"," " PA3
;       "#","/",",","N","V","X","#","#" PA4
;       "#",";","L","J","G","D","A","#" PA5 
;       "#","*","P","I","Y","R","W","#" PA6
;       "#","£","+","9","7","5","3","1" PA7


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



