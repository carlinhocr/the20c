;CIA Ports and Constants
;PORTB = $6001
;PORTA = $6000
;DDRB = $6003
;DDRA = $6002

;VIA Ports and Constants
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600c
IFR = $600d
IER = $600e
PORTSTATUS=$A0

startRAMData =$2000


;Vectors

charLoadLow=$28
charLoadHigh=$29
charDataVectorLow = $30
charDataVectorHigh = $31
delay_COUNT_A = $32        
delay_COUNT_B = $33
screenMemoryLow=$34 ;80 bytes
screenMemoryHigh=$35 
screenMemoryLow2=$36 ;80 bytes
screenMemoryHigh2=$37 

lcdCharPositionsLowZeroPage =$38 
lcdCharPositionsHighZeroPage =$39
lcdROMPositionsLowZeroPage =$3a 
lcdROMPositionsHighZeroPage =$3b
initialScreenZeroPageLow=$3c
initialScreenZeroPageHigh=$3d
aliensArrayZPL=$3E
aliensArrayZPH=$3F

temporaryY=$40
posScreenAlienInitial=$41 ;variable
alienTotal=$42
calien=$43
xVariable=$44
xDirection=$45 ; 0 right 1 left

firePosition=$46
fireInPlay=$47 ;0 no fire 1 fire


cursor_position=$a1
cursor_position_relative=$a2
aliensRemaining=$a3
scoreHexa=$a4
gameStatus=$a5 ;0 not started, 1 playing, 2 over

record_lenght=$CC ;it is a memory position
record_lenght_plus1=$CD

rightCursorVectorLow=$d0
rightCursorVectorHigh=$d1
leftCursorVectorLow=$d2
leftCursorVectorHigh=$d3
upCursorVectorLow=$d4
upCursorVectorHigh=$d5
downCursorVectorLow=$d6
downCursorVectorHigh=$d7
fireCursorVectorLow=$d8
fireCursorVectorHigh=$d9
line_cursor=$da
scoreMessageVectorLow=$db 
scoreMessageVectorHigh=$dc


;Memory Mappings

screenBufferLow =$00 ;goes to $50 which is 80 decimal
screenBufferHigh =$30

lcdCharPositionsLow =$00 ;goes to $50 which is 80 decimal
lcdCharPositionsHigh =$31

aliensArrayMemoryPositionCinv2L=$00
aliensArrayMemoryPositionCinv2H=$32

aliensArrayMemoryPositionCinv1L=$50
aliensArrayMemoryPositionCinv1H=$32

;variables



;constants
cursor_char=$00 ;this selects a ship
blank_char=$20
fill=$43 ;letter C
totalScreenLenght4Lines=$50
totalScreenLenght=$3c ;make it only 3 lines long 3c = 60 decimal
end_char=$ff
cship=$00
cinv1=$01
cinv2=$fc
cfire=$7c
cexplosion=$f3

xLimit=$04 ; how much the shift moves left and right

cblank=$20
posScreenAlienInitialCinv1=$09
alienTotalCinv1=$05
posScreenAlienInitialCinv2=$1C
alienTotalCinv2=$07

pos_line1_invaders=$8B
pos_line2_invaders=$CB
pos_line3_invaders=$9F
pos_line4_invaders=$DF
inv_line_lenght=$0A ; make the record lenght of 10 elements (one for position, 9 for graphics)
;center_cursor=$9d
center_cursor=$e1

diff_1_0=$40
diff_2_1=$2c
diff_3_2=$40







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
;--------------------------------STACK, CIA, INTERRUPTs-----------------------------
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


  ;BEGIN enable interrupts
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  lda #%10000010
  sta IER 
  ;enable negative edge transition ca1 pcr register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta PCR 
  ;END enable interrupts

  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta DDRB ;store the accumulator in the data direction register for Port B

  lda #%11100000  ;set the last 3 pins as output PA7, PA6, PA5 and as input PA4,PA3,PA2,PA1,PA0
  sta DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------STACK, CIA, INTERRUPTs-----------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------GAME-----------------------------------------------
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



; PLAN
; create a matrix of cursor positions in memory 4x20
;
; create a videoRAM MAP 4x20 from ROM
;
; create a function that reads the video ram and position by position puts it in the
; correct lcd position drawing the screen
;
; an array of aliens with the realtive position of each
;
; a function that reads that array and writes to the screen 
;
;

game:
  jsr gameInitilize
  jsr gameFlow

gameInitilize:
  jsr screenInit
  jsr shipInit
  jsr aliensInit
  jsr scoreInit
  jsr drawScreen
  jsr DELAY_SEC
  jsr initFire
  lda #$0;load screen
  sta gameStatus
  rts

gameFlow:    
  lda #$1
  sta gameStatus
  jsr clearScreenBuffer  
  jsr moveAliens
  jsr moveFire
  jsr checkCollisions
  jsr writeScore
  jsr drawScreen
  jsr DELAY_SEC
  jmp gameFlow

gameEnd:
  lda #$2
  sta gameStatus
  jsr clear_display
  lda #$C0 ;position cursor at the start of second line
  jsr lcd_send_instruction
  lda #<endGameMessage
  sta charDataVectorLow
  lda #>endGameMessage
  sta charDataVectorHigh
  jsr print_message
gameEndLoop:
  jmp gameEndLoop    
  

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------GAME-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------ALIENS---------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

aliensInit:
  jsr loadAliens
  jsr writeAliens
  lda #$ff
  sta xVariable
  lda #$00 
  sta xDirection
  rts

moveAliens:   
  lda xDirection
  beq moveAliensRight
moveAliensLeft:
  inc xVariable
  jsr moveLeft
  lda xVariable 
  cmp #xLimit ; do... until
  bne moveAliensEnd 
  lda #$ff
  sta xVariable  
  lda #$0
  sta xDirection ; go right
  jmp moveAliensEnd
moveAliensRight:
  inc xVariable
  jsr moveRight
  lda xVariable 
  cmp #xLimit; do... until
  bne moveAliensEnd 
  lda #$ff
  sta xVariable  
  lda #$1
  sta xDirection ; go left
  jmp moveAliensEnd
moveAliensEnd:
  rts
  

loadAliens:
  jsr prepAliensCinv1
  jsr loadAliensPrep
  jsr prepAliensCinv2
  jsr loadAliensPrep
  rts

moveRight:
  jsr prepAliensCinv1
  jsr moveRightPrep
  jsr prepAliensCinv2
  jsr moveRightPrep
  jsr writeAliens
  rts

moveLeft:
  jsr prepAliensCinv1
  jsr moveLeftPrep
  jsr prepAliensCinv2
  jsr moveLeftPrep
  jsr writeAliens
  rts

writeAliens:
  jsr prepAliensCinv1
  jsr writeAliensPrep
  jsr prepAliensCinv2
  jsr writeAliensPrep
  rts

prepAliensCinv1:
  lda #aliensArrayMemoryPositionCinv1L
  sta aliensArrayZPL
  lda #aliensArrayMemoryPositionCinv1H
  sta aliensArrayZPH
  lda #posScreenAlienInitialCinv1
  sta posScreenAlienInitial
  lda #alienTotalCinv1
  sta alienTotal
  lda #cinv1
  sta calien
  rts  

prepAliensCinv2:
  lda #aliensArrayMemoryPositionCinv2L
  sta aliensArrayZPL
  lda #aliensArrayMemoryPositionCinv2H
  sta aliensArrayZPH
  lda #posScreenAlienInitialCinv2
  sta posScreenAlienInitial
  lda #alienTotalCinv2
  sta alienTotal
  lda #cinv2
  sta calien
  rts  

loadAliensPrep:  
  ldy #$FF  
loadAliensLoop:  
  iny
  cpy alienTotal
  beq loadAliensEnd
  tya ;transfer y to the accumulator
  clc ; clear carry before adding
  adc posScreenAlienInitial ; add the initial position to the Y in the accumulator
  sta (aliensArrayZPL),y ;save the alien in the position   
  jmp loadAliensLoop 
loadAliensEnd:
  rts

writeAliensPrep:  
  ldy #$FF    
writeAliensLoop:
  iny      
  cpy alienTotal
  beq writeAliensEnd
  lda (aliensArrayZPL),y ;alien position loaded
  sty temporaryY; save current y position 
  tay ;transfer position in screen of alien to register Y
  lda calien ;load ship form
  sta (screenMemoryLow),y ;at the alien position en Y draw the alien ship on the accumulator
  ldy temporaryY
  jmp writeAliensLoop 
writeAliensEnd: 
  rts

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
moveRightPrep:
  ldy #$FF
moveRightLoop:
  iny
  cpy alienTotal
  beq moveRightEnd
  lda #$01
  clc
  adc (aliensArrayZPL),y
  sta (aliensArrayZPL),y
  jmp moveRightLoop
moveRightEnd:
  rts

moveLeftPrep:
  ldy #$FF  
moveLeftLoop:
  iny
  cpy alienTotal
  beq moveLeftEnd
  sec
  lda (aliensArrayZPL),y
  sbc #$01
  sta (aliensArrayZPL),y
  jmp moveLeftLoop
moveLeftEnd:
  rts

destroyAlien:
  ldy firePosition
  lda #cexplosion
  sta (screenMemoryLow),y 
  rts ;ends 

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------ALIENS---------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SCREEN MANAGEMENT----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

screenInit:
  jsr add_custom_chars_invaders
  jsr initilize_display
  jsr clear_display
  lda #cinv2
  jsr print_char  
  jsr DELAY_SEC
  lda #cinv1
  jsr print_char  
  jsr DELAY_SEC
  lda #cship
  jsr print_char  
  jsr DELAY_SEC
  jsr testScore
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

;END--------------------------------------------------------------------------------  
;-----------------------------------------------------------------------------------
;--------------------------------SCREEN MANAGEMENT----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------




;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------------FIRE-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

initFire:
  ;initialize first fire position
  lda #$51 ;out of the screen so it does not appear initilially
  sta firePosition
  ;inititialize fire that it is not in play
  lda #$0
  sta fireInPlay
  rts

writeFire:
  ldy firePosition
  lda #cfire
  sta (screenMemoryLow),y
  rts 

moveFire:
  jsr updateFire
  jsr writeFire
  rts  

updateFire:
  lda fireInPlay  
  beq updateFireEnd ;no fire in play do nothing (fireInPlay = 0)
  ;there is a fire in play update position
  cmp #$01
  beq updateFire1Row ; go to first row
  cmp #$02
  beq updateFire2or3Row
  cmp #$03
  beq updateFire2or3Row
  ;if not 0,1,2,3 we have to destroy the fire
  jsr destroyFire
  jmp updateFireEnd
updateFire1Row:
  ;no position update let it be written in first row but increase to second row for next iteration
  inc fireInPlay
  rts
updateFire2or3Row:
  ;update fire position increase to third row for next iteration
  sec
  lda firePosition
  sbc #$14 ;#jump
  sta firePosition
  inc fireInPlay
  rts  
updateFireEnd:  
  rts  

destroyFire:
  lda #$00
  sta fireInPlay
  lda #$51
  sta firePosition
  rts ;ends updateFireSubroutine

fireButtonPressed:
  lda fireInPlay  
  bne fireButtonPressedEnd ; there is already a fire in play it is not the first fire do nothing
  jsr mapPositionShip
  ;subtract 20 decimal $14 hexa from the ship position to draw the fire
  lda cursor_position_relative
  sec
  sbc #$14 ;#jump
  sta firePosition
  lda #$01
  sta fireInPlay
fireButtonPressedEnd:
  rts ;ends updateFireSubroutine
  
;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------------FIRE-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
  


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------------COLLISIONS-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
    

checkCollisions:
  ;check with aliens 1 positions
checkAliens:
  lda fireInPlay
  beq checkAliensEnd  
  ldy #$FF
  jsr prepAliensCinv1
  jsr checkAliensLoop 
  ldy #$FF
  jsr prepAliensCinv2
  jsr checkAliensLoop
checkAliensEnd:
  rts

checkAliensLoop:
  iny
  cpy alienTotal
  beq checkAliensLoopEnd
  lda (aliensArrayZPL),y
  cmp firePosition   ;loadFirePosition and compare with alien position
  bne checkAliensLoop   
  ;if match erase alien, destroy fire, add to scores
  ;if here we found the fire and the alien in the same screen position
  ;update alien position to out of the screen
  lda #$52
  sta (aliensArrayZPL),y
  jsr destroyAlien
  jsr destroyFire
  jsr updateScore  
checkAliensLoopEnd:
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------------COLLISIONS-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------------SCORE----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

scoreInit:
  clc
  sei ;disable interrupts so as to update properly the counter
  lda #alienTotalCinv1
  adc #alienTotalCinv2
  sta aliensRemaining
  lda #$0
  sta score
  lda #$0
  sta score + 1
  lda #<scoreMessage
  sta scoreMessageVectorLow
  lda #>scoreMessage
  sta scoreMessageVectorHigh
  cli ; reenable interrupts after updating
  rts

updateScore:
  sei ;disable interrupts so as to update properly the counter
  clc
  lda score
  adc #$1
  sta score
  bne updateScoreContinue
  ;addOneMore to the next byte
  clc
  lda score +1
  adc #$1
  sta score +1
updateScoreContinue:
  sec
  lda aliensRemaining
  sbc #$1
  cli ; reenable interrupts after updating
  beq endScore
  rts 

endScore:
  jsr gameEnd
  rts

testScore:
  jsr scoreInit
  jsr bin_2_ascii_score
  jsr print_message_ascii
  jsr delay_2_sec
  rts  

writeScore:  
  ldy #$FF    
writeScoreLoop:
  iny ;write the letter score in position 0     
  lda (scoreMessageVectorLow),y ;letter loaded
  beq writeScore2Line ;if #$0 end of string finish writing score message
  sta (screenMemoryLow),y ;
  jmp writeScoreLoop 
writeScore2Line: 
  jsr bin_2_ascii_score
  ldx #$ff ; to iterate message
  ldy #$16 ; so it will start at the beginning of line two in position 16
writeScore2Loop:
  iny
  inx
  lda message,x
  beq writeScore2LineEnd
  sta (screenMemoryLow),y
  jmp writeScore2Loop
writeScore2LineEnd:
  rts  

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------------SCORE----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SPACE SHIP-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

mapPositionShip:
  ldy #$FF
mapPositionLoop:
  iny
  cpy #totalScreenLenght4Lines ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq mapPositionLoopEnd
;position cursor
  lda (lcdCharPositionsLowZeroPage),Y ;load cursor position
  cmp cursor_position
  bne mapPositionLoop
  ;the Y position is the relative position of the ship
  sty cursor_position_relative
mapPositionLoopEnd:
  rts

shipInit:
  jsr initiliaze_vectors
  lda #$4
  sta line_cursor
  lda #center_cursor
  sta cursor_position
  lda #center_cursor
  jsr lcd_send_instruction 
  lda #cursor_char
  jsr print_char

initiliaze_vectors:
  lda #<left_cursor_endings
  sta leftCursorVectorLow
  lda #>left_cursor_endings
  sta leftCursorVectorHigh
  lda #<right_cursor_endings
  sta rightCursorVectorLow
  lda #>right_cursor_endings
  sta rightCursorVectorHigh
  rts

draw_cursor:
  lda cursor_position
  jsr lcd_send_instruction 
  lda #cursor_char
  jsr print_char
  rts

erase_cursor:
  lda cursor_position
  jsr lcd_send_instruction 
  lda #blank_char
  jsr print_char
  rts

move_cursor_right:
  ldy #$FF
  lda cursor_position
check_right_limit:  
  iny 
  lda (rightCursorVectorLow),y ;first fo to address in right_cursor_endingss, then increase it
  cmp cursor_position 
  beq not_move_right
  cpy #$03
  bne check_right_limit
  jsr erase_cursor
  inc cursor_position
  jsr draw_cursor
not_move_right:
  rts
  

move_cursor_left:
  ldy #$FF
  lda cursor_position
check_left_limit:  
  iny 
  lda (leftCursorVectorLow),y ;first fo to address in left_cursor_endings, then increase it
  cmp cursor_position  
  beq not_move_left
  cpy #$03
  bne check_left_limit
  jsr erase_cursor
  dec cursor_position
  jsr draw_cursor
not_move_left:
  rts

move_cursor_up:
  lda line_cursor
  cmp #$0
  beq not_move_up
  cmp #$1
  beq move_up_from_row_1
  cmp #$2
  beq move_up_from_row_2
  cmp #$3
  beq move_up_from_row_3
  ;if not row 0,1,  2 or 3 then return wrong case
  rts
move_up_from_row_1:
  jsr erase_cursor
  lda cursor_position
  sbc #diff_1_0
  sta cursor_position
  jsr draw_cursor
  dec line_cursor
  rts
move_up_from_row_2:
  jsr erase_cursor
  clc
  lda cursor_position
  adc #diff_2_1
  sta cursor_position
  jsr draw_cursor
  dec line_cursor
  rts
move_up_from_row_3:
  jsr erase_cursor
  lda cursor_position
  sbc #diff_3_2
  sta cursor_position
  jsr draw_cursor
  dec line_cursor
  rts
not_move_up:
  rts  

move_cursor_down:
  lda line_cursor
  cmp #$0
  beq move_down_from_row_0
  cmp #$1
  beq move_down_from_row_1
  cmp #$2
  beq move_down_from_row_2
  cmp #$3
  beq not_move_down
  ;if not row 0,1,  2 or 3 then return wrong case
  rts
move_down_from_row_0:
  inc line_cursor
  jsr erase_cursor
  clc
  lda cursor_position
  adc #diff_1_0
  sta cursor_position
  jsr draw_cursor
  rts
move_down_from_row_1:
  inc line_cursor
  jsr erase_cursor
  lda cursor_position
  sbc #diff_2_1
  sta cursor_position
  jsr draw_cursor
  rts
move_down_from_row_2:
  inc line_cursor
  jsr erase_cursor
  clc
  lda cursor_position
  adc #diff_3_2
  sta cursor_position
  jsr draw_cursor
  rts
not_move_down:
  rts 


test_buttons:
  lda PORTA
  sta PORTSTATUS
  ;move PA4 to PA7 and PA3 to PA6
  rol PORTSTATUS
  rol PORTSTATUS
  rol PORTSTATUS
  rol PORTSTATUS ; now we have PA4 on the carry and PA3 on the negative flag 
  lda PORTSTATUS
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
  rol PORTSTATUS
  rol PORTSTATUS ; now we have PA2 on the carry and PA1 on the negative flag 
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
  rol PORTSTATUS
  rol PORTSTATUS ; now we have PA0 on the carry 
  bcc pressed_buttons_pa0
  ;no button was pressed but we had an interrupt
  rts
pressed_buttons_pa0:
  jsr pa0_button_action
  rts

; pa4_button_action:
;   jsr clear_display
;   lda #<button_press_pa4
;   sta charDataVectorLow
;   lda #>button_press_pa4
;   sta charDataVectorHigh
;   jsr print_message
;   rts

pa4_button_action:
  jsr fireButtonPressed
  rts

pa3_button_action:
  jsr move_cursor_up
  rts

pa2_button_action:
  jsr move_cursor_left
  rts

pa1_button_action:
  jsr move_cursor_down
  rts

pa0_button_action:
  jsr move_cursor_right
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SPACE SHIP-----------------------------------------
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
  ;set PORTB to all inputs so we can read the busy flag
  lda #$00000000 ;port b ins input
  sta DDRB 
lcd_busy:
  ;set register select to 0 and RW to 1 to read the busy flag
  lda #RW ;set RW RW = %01000000 ; Read/Write Signal
  sta PORTA
  lda #(RW | E) ;do the enable and do not era the RW bit
  sta PORTA
  ;this will give us the info from the busy flags and the counter 01 BF AC AC AC AC AC AC AC
  ;on port B so we read it
  lda PORTB
  and #%10000000 ;and the accumulator to loose all bits but the 7 bit (from 7 to 0)
                ; on the acummulator I will now have only the Busy Flag result
  bne lcd_busy ; branch if the zero flag is not set
  ;turn off the enable bit
  lda #RW ;set RW RW = %01000000 ; Read/Write Signal
  sta PORTA
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF to make it output
  sta DDRB ;store the accumulator in the data direction register for Port B
  pla ; pull to restablish the contents of the acummulator register
  rts


lcd_send_instruction:
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta PORTB
            
  lda #%0  ;Clear RS,RW and E bit on Port A  
  sta PORTA ;     

  ;togle the enable bit in order to send the instruction
  ;RS is zero so we are sending instructions
  ;RW is zero so we are writing
  lda #E ;enable bit is 1 , so we turn on the chip and execute the instruction.
  sta PORTA ; 

  lda #%0  ;Clear RS,RW and E bit on Port A  
  sta PORTA ;  
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts ; return from the subroutine

print_char:
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta PORTB

  ;RS is one so we are sending data
  ;RW is zero so we are writing
  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta PORTA ;     

  ;togle the enable bit in order to send the instruction
  lda #(RS | E );RS and enable bit are 1 , we OR them and send the data
  sta PORTA ; 

  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta PORTA ; 
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts

lcd_send_data:
  ;print_char is equal to send data
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta PORTB

  ;RS is one so we are sending data
  ;RW is zero so we are writing
  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta PORTA ;     

  ;togle the enable bit in order to send the instruction
  lda #(RS | E );RS and enable bit are 1 , we OR them and send the data
  sta PORTA ; 

  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta PORTA ; 
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


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------CUSTOM CHARS---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

test_custom_chars:
    ldx #$ff
    lda #$43
    jsr print_char
test_custom_chars_loop: 
    inx
    txa
    jsr print_char
    cpx #$07
    bne test_custom_chars_loop
    rts    

add_custom_chars_invaders:
    ;BEGIN Add custom char instruction
    ;8026 lda
  
char_0_invaders: 
    lda #($40+$00);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
    ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
    ;8028 jumps to send intrsuction
    jsr lcd_send_instruction
    lda #<invader_ship_1
    sta charLoadLow
    lda #>invader_ship_1
    sta charLoadHigh
    jsr char_load
  
char_1_invaders: 
    lda #($40+$08);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
    ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
    ;8028 jumps to send intrsuction
    jsr lcd_send_instruction
    lda #<invader_ship_2
    sta charLoadLow
    lda #>invader_ship_2
    sta charLoadHigh
    jsr char_load
  
add_custom_chars_end_invaders:  
    rts
  
char_load:  
    ldy #$FF
char_load_loop:
    iny  
    lda (charLoadLow),y
    jsr lcd_send_data
    cpy #07
    bne char_load_loop
    rts
    ;END send data for custom character 5x8 char

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------CUSTOM CHARS---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------INTERRUPT MANAGEMENT-------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

nmi:
  ;preserve Accumulator, X and Y so we can use them here
  pha ; store accumulator in the stack
  txa ; transfer X to Accumulator
  pha ; store the X register in the stack
  tya ; transfer Y to Accumulator
  pha ; store the Y register in the stack
  ;bit command read the memory and compares just used to read the register
  bit PORTA ; clear the interrupt flag
  jsr clear_display
  lda #<button_press_nmi
  sta charDataVectorLow
  lda #>button_press_nmi
  sta charDataVectorHigh
  jsr print_message
  jsr delay_1_sec
exit_nmi:  
  ;reserve order of stacking to restore values
  pla ; retrieve the Y register from the stack
  tay ; transfer accumulator to Y register
  pla ; retrieve the X register from the stack
  tax ; transfer accumulator to X register
  pla ; restore the accumulator value
  rti 

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

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------INTERRUPT MANAGEMENT-------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


initial_message:
  .ascii "Main Screen"

button_press_pa4:
  .ascii "Fire Button"

button_press_pa3:
  .ascii "Up Button"

button_press_pa2:
  .ascii "Left Button"

button_press_pa1:
  .ascii "Down Button"

button_press_pa0:
  .ascii "Right Button"

button_press_nmi:
  .ascii "NMI Interrupt"

button_press_irq:
  .ascii "IRQ Interrupt"

endGameMessage:
  .ascii "Game Over you WIN!!"  

scoreMessage:
  .ascii "SCORE"   

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


invaders_screen_0:
  .byte pos_line1_invaders,cinv1,cinv1,cblank,cinv1,cinv1,cinv1,cinv1,cinv1,cblank
  .byte pos_line2_invaders,cinv2,cblank,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cblank
  .byte pos_line3_invaders,cblank,cblank,cblank,cblank,cblank,cblank,cblank,cblank,cblank
  .byte pos_line4_invaders,cblank,cblank,cblank,cship,cblank,cblank,cblank,cblank,cblank
  .byte end_char

invader_ship_1:
  .byte $00,$04,$04,$0e,$1f,$04,$0e,$00
invader_ship_2:
  .byte $00,$04,$0E,$15,$1B,$0E,$00,$00

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



