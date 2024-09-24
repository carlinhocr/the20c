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

;RAM addresses
startRAMData =$2000
charDataVectorLow = $30
charDataVectorHigh = $31

;define LCD signals
E = %10000000 ;Enable Signal
RW = %01000000 ; Read/Write Signal
RS = %00100000 ; Register Select

  .org $8000


RESET:

  ;BEGIN Initialize stack pointer to $01FF
  ldx #$ff 
  txs   ;transfer the X register to the Stack pointer
  ;END Initialize stack pointer to $01FF

  ;BEGIN Initialize LCD Display
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta DDRB ;store the accumulator in the data direction register for Port B

  lda #%11100000  ;set the last 3 pins as output
  sta DDRA ;store the accumulator in the data direction register for Port A
  ;END Initialize LCD Display
  jsr add_custom_chars

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
  

write_Screens
data_low= $00
data_high= $d0
;Draw title
  lda #data_low
  sta charDataVectorLow
  lda #data_high
  sta charDataVectorHigh
  jsr print_message
  lda #(data_low+$06)
  sta charDataVectorLow
  lda #$C0 ; position second line
  jsr lcd_send_instruction
  jsr print_message
;Draw Ship
  lda #$E2
  jsr lcd_send_instruction 
  lda #$00 ;custom character for ship
  jsr print_char ;this prints the char and increments DDRAM 
;Draw invader line 1
  lda #$8B 
  jsr lcd_send_instruction 
  lda #(data_low+16)
  sta charDataVectorLow
  jsr print_message
;Draw invader line 2
  lda #$CB 
  jsr lcd_send_instruction 
  lda #(data_low+$19)
  sta charDataVectorLow
  jsr print_message
; ;Draw shoot 1
;   lda #$A8 
;   jsr lcd_send_instruction 
;   lda #%00101110
;   jsr print_char ;this prints the char and increments DDRAM 
;   lda #$A8 
;   jsr lcd_send_instruction 
;   lda #%10100101
;   jsr print_char ;this prints the char and increments DDRAM 
; ;Draw Explosion
;   lda #$CE 
;   jsr lcd_send_instruction 
;   lda #%10100001
;   jsr print_char ;this prints the char and increments DDRAM 
;   lda #$CE 
;   jsr lcd_send_instruction 
;   lda #%11011011
;   jsr print_char ;this prints the char and increments DDRAM 
;   lda #$CE 
;   jsr lcd_send_instruction 
;   lda #%00100000
;   jsr print_char ;this prints the char and increments DDRAM 

  
enter_into_loop:
  jmp loop

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

loop:
  jmp loop

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


; Set up the delay
COUNT_A = $20        ; Outer loop counter
COUNT_B = $FF        ; Inner loop counter

DELAY_SEC:
    LDX #COUNT_A     ; Load outer loop count
OUTER_LOOP:
    LDY #COUNT_B     ; Load inner loop count
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

; Main program
START:
    JSR DELAY_SEC    ; Call the delay subroutine


add_custom_chars:
  ;BEGIN Add custom char instruction
  ;8026 lda
char_1: 
  lda #$40;+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  ;BEGIN send data for custom character 5x8 char
  ldx #$FF
char_1_loop:
  inx  
  lda char_1_data,x
  jsr lcd_send_data
  cpx #07
  bne char_1_loop
  ;END send data for custom character 5x8 char
char_2: 
  lda #($40+$08) ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  ;BEGIN send data for custom character 5x8 char
  ldx #$FF
char_2_loop:
  inx  
  lda char_2_data,x
  jsr lcd_send_data
  cpx #07
  bne char_2_loop
add_custom_chars_end:  
  rts
  ;END send data for custom character 5x8 char

 .org $d000
title_1:
  .asciiz "SPACE" ;adds a 0 after the last byte
title_2:
  .asciiz "INVADERS" ;adds a 0 after the last byte
;  .byte $ef,$ef,$ef,$ef,$ef,$ef,$ef,$ef,$00
invader_ship_1:
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$00
invader_ship_2:
  .byte $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$00
char_1_data:  
  .byte $00,$04,$04,$0e,$1f,$04,$0e,$00
char_2_data:  
  .byte $00,$04,$0E,$15,$1B,$0E,$00,$00


;complete the file
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .word $0000 ;finish completing the values of the eeprom $fffe $ffff with values 00 00

; Positions of LCD characters
; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 1	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 2	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 3	94	95	96	97	98	99	A0	A1	A2	A3	A4	A5	A6	A7	A8	A9	AA	AB	AC	AD
; 4	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7