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



;variables
cursor_position=$a1

record_lenght=$CC ;it is a memory position

;constants
cursor_char=$fc
blank_char=$20

end_char=$ff
;cship=$00
;cinv1=$01
cship=$cE
cinv1=$f2
cinv2=$fc
cblank=$20
pos_line1_invaders=$8B
pos_line2_invaders=$CB
pos_line3_invaders=$9F
pos_line4_invaders=$DF
inv_line_lenght=$0A ; make the record lenght of 10 elements (one for position, 9 for graphics)
;center_cursor=$9d
center_cursor=$c9

diff_1_0=$40
diff_2_1=$2c
diff_3_2=$40







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

  jsr initilize_display

; Positions of LCD characters
; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 1	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 2	94	95	96	97	98	99	9a	9b	9c	9d	9e	9f	a0	a1	a2	a3	a4	a5	a6	a7
; 3	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7


; start:
;   jsr clear_display
;   jsr initiliaze_vectors
;   lda #$1
;   sta line_cursor
;   lda #center_cursor
;   sta cursor_position
;   lda #center_cursor
;   jsr lcd_send_instruction 
;   lda #cursor_char
;   jsr print_char


gameInitilize:
  jsr clear_display
  lda #$43
  jsr print_char  
  jsr DELAY_SEC
  ;jsr add_custom_chars_invaders
  ;jsr initilize_display
  ;jsr clear_display
  lda #cinv2
  jsr print_char  
  jsr DELAY_SEC
  lda #cinv1
  jsr print_char  
  jsr DELAY_SEC
  lda #cship
  jsr print_char  
  jsr DELAY_SEC
  ;jsr test_custom_chars
  lda #inv_line_lenght
  sta record_lenght
  jsr load_screen_memory
  jsr draw_screen
  
loop:
  jmp loop

test_custom_chars:
  ldx #$ff
  lda #$43
  jsr print_char
test_custom_chars_loop 
  inx
  txa
  jsr print_char
  cpx #$07
  bne test_custom_chars_loop
  rts

gameFlow:
  jsr draw_screen  

load_screen_memory:
  lda #$00
  sta screenMemoryLow
  lda #$04
  sta screenMemoryHigh
  ldy #$FF
load_screen_memory_copy:
;CHECK IF SCREEN MEMORy LOW DOES NOT NEED TO ADD 1 TO HIGH BYTE
  iny
  lda invaders_screen_0,y
  sta (screenMemoryLow),y ; always copy the character also when it is the end_char
  cmp #end_char
  bne load_screen_memory_copy
  rts

draw_screen
  lda #<invaders_screen_0
  sta charDataVectorLow
  lda #>invaders_screen_0
  sta charDataVectorHigh
  lda #$0A 
  sta record_lenght
  ;lda #screenMemoryLow
  ;sta charDataVectorLow
  ;lda #screenMemoryHigh
  ;sta charDataVectorLow
  jsr print_screen
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

pa4_button_action:
  jsr clear_display
  lda #<button_press_pa4
  sta charDataVectorLow
  lda #>button_press_pa4
  sta charDataVectorHigh
  jsr print_message
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
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta PORTB

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

left_cursor_endings:
  .byte  $80,$c0,$94,$d4

right_cursor_endings:
  .byte  $93,$d3,$a7,$e7

up_cursor_endings:
  .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8F,$8E,$90,$91,$92,$93

down_cursor_endings:
  .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7


invaders_screen_0:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cblank
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cblank
  .byte pos_line3_invaders,cblank,cblank,cblank,cblank,cblank,cblank,cblank,cblank,cblank
  .byte pos_line4_invaders,cblank,cblank,cblank,cship,cblank,cblank,cblank,cblank,cblank
  .byte end_char

invader_ship_1:
  .byte $00,$04,$04,$0e,$1f,$04,$0e,$00
invader_ship_2:
  .byte $00,$04,$0E,$15,$1B,$0E,$00,$00


;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



