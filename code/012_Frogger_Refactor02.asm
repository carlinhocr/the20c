;CIA Ports and Constants
;PORTB = $6001
;PORTA = $6000
;DDRB = $6003
;DDRA = $6002

;VIA Ports and Constan ts
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

;RAM addresses
startRAMData =$2000
charDataVectorLow = $30
charDataVectorHigh = $31
delay_COUNT_A = $32        
delay_COUNT_B = $33
charLoadLow=$28
charLoadHigh=$29

cespacio=$20
ccasita=$01
cfrogger=$02
cfrogger_saltando=$03
cautito=$04
cautito2=$05
cfrogger_win=$06
cfrogger_izq=$07

pos_line1=$8B
pos_line2=$CB
pos_line3=$9F
pos_line4=$DF

record_lenght=$09

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
  

write_Screens:
;Draw title
  lda #<title_1
  sta charDataVectorLow
  lda #>title_1
  sta charDataVectorHigh
  jsr print_message
  jsr DELAY_SEC
  jsr DELAY_SEC
play_game:
;Draw Screen1 line 1 to line 4
  lda #<screen_1_Line1
  sta charDataVectorLow
  lda #>screen_1_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen1 line 4 bis
  lda #<screen_1_Line4_bis
  sta charDataVectorLow
  lda #>screen_1_Line4_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen2 line 1  to line 4
  lda #<screen_2_Line1
  sta charDataVectorLow
  lda #>screen_2_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen2 line 3 bis
  lda #<screen_2_Line3_bis
  sta charDataVectorLow
  lda #>screen_2_Line3_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen3 line 1 to line 4
  lda #<screen_3_Line1
  sta charDataVectorLow
  lda #>screen_3_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen3 line 2 bis
  lda #<screen_3_Line2_bis
  sta charDataVectorLow
  lda #>screen_3_Line2_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen4 line 1 to line 4
  lda #<screen_4_Line1
  sta charDataVectorLow
  lda #>screen_4_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen4 line 1 bis
  lda #<screen_4_Line1_bis
  sta charDataVectorLow
  lda #>screen_4_Line1_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen5 line 1 to line 4
  lda #<screen_5_Line1
  sta charDataVectorLow
  lda #>screen_5_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen5 line 4 bis
  lda #<screen_5_Line4_bis
  sta charDataVectorLow
  lda #>screen_5_Line4_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen6 line 1
  lda #<screen_6_Line1
  sta charDataVectorLow
  lda #>screen_6_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen6 line 3 bis 
  lda #<screen_6_Line3_bis
  sta charDataVectorLow
  lda #>screen_6_Line3_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen7 line 1 to line 4
  lda #<screen_7_Line1
  sta charDataVectorLow
  lda #>screen_7_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen7 line 3 bis
  lda #<screen_7_Line3_bis
  sta charDataVectorLow
  lda #>screen_7_Line3_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen8 line 1 to line 4
  lda #<screen_8_Line1
  sta charDataVectorLow
  lda #>screen_8_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen8 line 3 bis
  lda #<screen_8_Line3_bis
  sta charDataVectorLow
  lda #>screen_8_Line3_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen9 line 1 to line 4
  lda #<screen_9_Line1
  sta charDataVectorLow
  lda #>screen_9_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen9 line 3 bis
  lda #<screen_9_Line2_bis
  sta charDataVectorLow
  lda #>screen_9_Line2_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC

;Draw Screen10 line 1 to line 4
  lda #<screen_10_Line1
  sta charDataVectorLow
  lda #>screen_10_Line1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
;Draw Screen10 line 2 bis
  lda #<screen_10_Line1_bis
  sta charDataVectorLow
  lda #>screen_10_Line1_bis
  sta charDataVectorHigh
  jsr print_line
  jsr DELAY_HALF_SEC 

keep_playing:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jmp play_game

enter_into_loop:
  jmp loop


; screen_1_Line1:
;   .byte pos_line1,ccasita,cespacio,ccasita,cespacio,ccasita,cespacio,ccasita,cespacio
; screen_1_Line2:
;   .byte pos_line2,cautito2,cespacio,cespacio,cautito,cespacio,cespacio,cautito,cespacio
; screen_1_Line3:
;   .byte pos_line3,cespacio,cespacio,cautito,cespacio,cespacio,cautito2,cespacio,cespacio
; screen_1_Line4:
;   .byte pos_line4,cespacio,cespacio,cespacio,cfrogger,cespacio,cespacio,cespacio,cespacio,$00
; screen_1_Line4_bis:
;   .byte pos_line4,cespacio,cespacio,cespacio,cfrogger_saltando,cespacio,cespacio,cespacio,cespacio,$00

print_screen:  
  ;BEGIN Write all the letters 
  ldy #$00 ;first byte is the position of the line
print_screen_load_position:
  lda (charDataVectorLow),y
  beq print_screen_end ;jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr lcd_send_instruction 
  ldx #$00
print_screen_eeprom:  
  iny
  inx
  cpx #record_lenght
  beq print_screen_load_position
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  jsr print_char 
  jmp print_screen_eeprom
print_screen_end:
  rts 
  ;END Write all the letters

print_line:  
  ;BEGIN Write all the letters 
  ldy #$00 ;first byte is the position of the line
  lda (charDataVectorLow),y
  jsr lcd_send_instruction
  iny 
print_line_eeprom:  
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  beq print_line_end ; jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr print_char 
  iny
  jmp print_line_eeprom
print_line_end:
  rts 
  ;END Write all the letters

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
DELAY_SEC:
  lda #$FF
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

DELAY_HALF_SEC:
  lda #$70
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



; Main program
START:
    JSR DELAY_SEC    ; Call the delay subroutine


add_custom_chars:
  ;BEGIN Add custom char instruction
  ;8026 lda

char_1: 
  lda #($40+$08);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<casita
  sta charLoadLow
  lda #>casita
  sta charLoadHigh
  jsr char_load

char_2: 
  lda #($40+$10);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<frogger
  sta charLoadLow
  lda #>frogger
  sta charLoadHigh
  jsr char_load

char_3: 
  lda #($40+$18);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<frogger_saltando
  sta charLoadLow
  lda #>frogger_saltando
  sta charLoadHigh
  jsr char_load

char_4: 
  lda #($40+$20);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<autito
  sta charLoadLow
  lda #>autito
  sta charLoadHigh
  jsr char_load

char_5: 
  lda #($40+$28);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<autito2
  sta charLoadLow
  lda #>autito2
  sta charLoadHigh
  jsr char_load

char_6: 
  lda #($40+$30);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<frogger_win
  sta charLoadLow
  lda #>frogger_win
  sta charLoadHigh
  jsr char_load

char_7: 
  lda #($40+$38);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<frogger_izq
  sta charLoadLow
  lda #>frogger_izq
  sta charLoadHigh
  jsr char_load

add_custom_chars_end:  
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

 .org $d000
startDATA: 
title_1:
  .asciiz "FROGGER" ;adds a 0 after the last byte

screen_1_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cespacio,ccasita,cespacio,ccasita,cespacio
screen_1_Line2:
  .byte pos_line2,cautito2,cespacio,cespacio,cautito,cespacio,cespacio,cautito,cespacio
screen_1_Line3:
  .byte pos_line3,cespacio,cespacio,cautito,cespacio,cespacio,cautito2,cespacio,cespacio
screen_1_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cfrogger,cespacio,cespacio,cespacio,cespacio,$00
screen_1_Line4_bis:
  .byte pos_line4,cespacio,cespacio,cespacio,cfrogger_saltando,cespacio,cespacio,cespacio,cespacio,$00

screen_2_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cespacio,ccasita,cespacio,ccasita,cespacio
screen_2_Line2:
  .byte pos_line2,cespacio,cespacio,cautito,cespacio,cespacio,cautito,cespacio,cespacio
screen_2_Line3:
  .byte pos_line3,cespacio,cautito,cespacio,cfrogger,cautito2,cespacio,cespacio,cespacio
screen_2_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,$00
screen_2_Line3_bis:
  .byte pos_line3,cespacio,cautito,cespacio,cfrogger_saltando,cautito2,cespacio,cespacio,cespacio,$00

screen_3_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cespacio,ccasita,cespacio,ccasita,cespacio
screen_3_Line2:
  .byte pos_line2,cespacio,cautito,cespacio,cfrogger,cautito,cespacio,cespacio,cautito2
screen_3_Line3:
  .byte pos_line3,cautito,cespacio,cespacio,cautito2,cespacio,cespacio,cespacio,cespacio
screen_3_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,$00
screen_3_Line2_bis:
  .byte pos_line2,cespacio,cautito,cespacio,cfrogger_saltando,cautito,cespacio,cespacio,cautito2,$00

screen_4_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cfrogger,ccasita,cespacio,ccasita,cespacio
screen_4_Line2:
  .byte pos_line2,cautito,cespacio,cespacio,cautito,cespacio,cespacio,cautito2,cespacio
screen_4_Line3:
  .byte pos_line3,cespacio,cespacio,cautito2,cespacio,cespacio,cespacio,cespacio,cautito
screen_4_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,$00
screen_4_Line1_bis:
  .byte pos_line1,ccasita,cespacio,ccasita,cfrogger_win,ccasita,cespacio,ccasita,cespacio,$00

screen_5_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cfrogger_win,ccasita,cespacio,ccasita,cespacio
screen_5_Line2:
  .byte pos_line2,cautito,cespacio,cespacio,cautito,cespacio,cespacio,cautito2,cespacio
screen_5_Line3:
  .byte pos_line3,cespacio,cespacio,cautito2,cespacio,cespacio,cespacio,cespacio,cautito
screen_5_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cfrogger,cespacio,cespacio,cespacio,cespacio,$00
screen_5_Line4_bis:
  .byte pos_line4,cespacio,cespacio,cespacio,cfrogger_saltando,cespacio,cespacio,cespacio,cespacio,$00


screen_6_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cfrogger_win,ccasita,cespacio,ccasita,cespacio
screen_6_Line2:
  .byte pos_line2,cespacio,cespacio,cautito,cespacio,cespacio,cautito2,cespacio,cespacio
screen_6_Line3:
  .byte pos_line3,cespacio,cautito2,cespacio,cfrogger,cespacio,cespacio,cautito,cespacio
screen_6_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,$00
screen_6_Line3_bis:
  .byte pos_line3,cespacio,cautito2,cespacio,cfrogger_izq,cespacio,cespacio,cautito,cespacio,$00

screen_7_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cfrogger_win,ccasita,cespacio,ccasita,cespacio
screen_7_Line2:
  .byte pos_line2,cespacio,cespacio,cautito,cespacio,cespacio,cautito2,cespacio,cespacio
screen_7_Line3:
  .byte pos_line3,cespacio,cautito2,cfrogger,cespacio,cespacio,cespacio,cautito,cespacio
screen_7_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,$00
screen_7_Line3_bis:
  .byte pos_line3,cespacio,cautito2,cfrogger_izq,cespacio,cespacio,cespacio,cautito,cespacio,$00

screen_8_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cfrogger_win,ccasita,cespacio,ccasita,cespacio
screen_8_Line2:
  .byte pos_line2,cespacio,cautito,cespacio,cespacio,cautito2,cespacio,cespacio,cautito
screen_8_Line3:
  .byte pos_line3,cautito2,cfrogger,cespacio,cespacio,cespacio,cautito,cespacio,cespacio
screen_8_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,$00
screen_8_Line3_bis:
  .byte pos_line3,cautito2,cfrogger_saltando,cespacio,cespacio,cespacio,cautito,cespacio,cespacio,$00


screen_9_Line1:
  .byte pos_line1,ccasita,cespacio,ccasita,cfrogger_win,ccasita,cespacio,ccasita,cespacio
screen_9_Line2:
  .byte pos_line2,cautito,cfrogger,cespacio,cautito2,cespacio,cespacio,cautito,cespacio
screen_9_Line3:
  .byte pos_line3,cespacio,cespacio,cespacio,cespacio,cautito,cespacio,cespacio,cautito2
screen_9_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,$00
screen_9_Line2_bis:
  .byte pos_line2,cautito,cfrogger_saltando,cespacio,cautito2,cespacio,cespacio,cautito,cespacio,$00

screen_10_Line1:
  .byte pos_line1,ccasita,cfrogger,ccasita,cfrogger_win,ccasita,cespacio,ccasita,cespacio
screen_10_Line2:
  .byte pos_line2,cautito,cespacio,cespacio,cautito2,cespacio,cespacio,cautito,cespacio
screen_10_Line3:
  .byte pos_line3,cespacio,cespacio,cespacio,cespacio,cautito,cespacio,cespacio,cautito2
screen_10_Line4:
  .byte pos_line4,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,$00 ;terminate the screen with $00
screen_10_Line1_bis:
  .byte pos_line1,ccasita,cfrogger_win,ccasita,cfrogger_win,ccasita,cespacio,ccasita,cespacio,$00


;usar el primer byte como la posición de la linea
casita:
  .byte $11,$11,$11,$11,$1f,$00,$00,$00
frogger:
  .byte $00,$00,$00,$00,$0a,$04,$0e,$0a
frogger_saltando:  
  .byte $0a,$04,$0e,$0a,$0a,$00,$00,$00
autito:
  .byte $00,$00,$1b,$0e,$0e,$1B,$00,$00
autito2:
  .byte $00,$00,$09,$06,$09,$00,$00,$00
frogger_win:
  .byte $1b,$1b,$04,$0e,$11,$1b,$11,$11  
frogger_izq:
  .byte $00,$11,$13,$0e,$0e,$13,$11,$00  



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