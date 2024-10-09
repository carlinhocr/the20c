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

cursor_position=$a1
center_cursor=$c9
right_cursor_limit=$d3
left_cursor_limit=$c0
cursor_char=$f5
blank_char=$20



charDataVectorLow = $30
charDataVectorHigh = $31
delay_COUNT_A = $32        
delay_COUNT_B = $33

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

start:
  jsr clear_display
  lda center_cursor
  sta cursor_position
  lda #center_cursor
  jsr lcd_send_instruction 
  lda #cursor_char
  jsr print_char
loop:
  jmp loop

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
  lda cursor_position
  cmp #right_cursor_limit
  beq not_move_right
  jsr erase_cursor
  inc cursor_position
  jsr draw_cursor
not_move_right:
  rts
  

move_cursor_left:
  lda cursor_position
  cmp #left_cursor_limit
  beq not_move_left
  jsr erase_cursor
  dec cursor_position
  jsr draw_cursor
not_move_left:
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
  bcc test_buttons_pa4
  bmi test_buttons_else_case; if one the pa3 was not pressed
  ;here button pa3 was pressed
  jsr move_cursor_right 
  rts
test_buttons_pa4:  
  jsr move_cursor_left
  rts
test_buttons_else_case:
  ;There was an interrupt but no button was pressed
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
  .ascii "Left Button"

button_press_pa3:
  .ascii "Right Button"

button_press_nmi:
  .ascii "NMI Interrupt"

button_press_irq:
  .ascii "IRQ Interrupt"

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff


; Positions of LCD characters
; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 1	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 2	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 3	94	95	96	97	98	99	A0	A1	A2	A3	A4	A5	A6	A7	A8	A9	AA	AB	AC	AD
; 4	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7