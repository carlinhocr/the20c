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
cesquina_rd=$00
cfantasma=$01
cpacman_boca_abierta=$02
cpacman_boca_cerrada=$03
cfantasma_comido=$04
cpared_h=$05
cpared_v=$06
cesquina_ld=$07
cpunto=$a5
cpill=$a1

end_char=$ff

pos_line1_pacman=$8B
pos_line2_pacman=$CB
pos_line3_pacman=$9F
pos_line4_pacman=$DF

record_lenght=$CC

lenght_screen_lines=$04; 0 to 3
lenght_ascii_line_characters=$20
lenght_screen_characters=$50 ;80 in decimal
pos_lcd_initial_line0=$80
pos_lcd_initial_line1=$C0
pos_lcd_initial_line2=$94
pos_lcd_initial_line3=$D4

mas_screen_top = $d3 ;zero page address with the number of continuos ascii screens to print
mas_screen_current = $d4 ;zero page address with the number the current ascii screens to print
mas_record_lenght=$d5 ;zero page address with the size of the ascii record
mas_screen_total_lenght=$d6 ; all the record on one screen


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
  jsr initilize_display

start_demo:   
  jsr pacman_start_ms;
  jsr pacman_playing_ms;
  jmp start_demo

pacman_start_ms:
  jsr add_custom_chars_pacman
  jsr initilize_display
  ;Draw title Space Invaders
  jsr clear_display
  lda #<title_pacman
  sta charDataVectorLow
  lda #>title_pacman
  sta charDataVectorHigh
  jsr print_message
  jsr DELAY_HALF_SEC
  rts

pacman_playing_ms:
  lda #$0A ; make the record lenght of 10 elements (one for position, 9 for graphics)
  sta mas_record_lenght  
  lda #$0A ; make the record lenght of 10 elements (one for position, 9 for graphics)
  sta record_lenght ;used inside print_screen
  lda #$12 ;set to decimal 18 screens for pacman
  sta mas_screen_top
  lda #$29 ;41 decimal
  sta mas_screen_total_lenght ; this is record lenght times 4, 40 characters plus one terminator
  ;load the first screen
  lda #<pacman_screen_1
  sta charDataVectorLow
  lda #>pacman_screen_1
  sta charDataVectorHigh
  jsr multi_screen_print
  rts  
 
enter_into_loop:
  jmp loop

multi_screen_print:
  lda #$00 ; so I start at screen 1
  sta mas_screen_current

multi_screen_multiple:
  inc mas_screen_current ;star at screen 1
  jsr print_screen ; print NON ASCII screen mas_screen_current
  jsr DELAY_HALF_SEC ;add delay to wait with the screen printed
  ldx #$00
add_record_lenght_ms:  
  inx
  inc charDataVectorLow
  bne done_add_ms
  inc charDataVectorHigh
done_add_ms:
  cpx mas_screen_total_lenght
  bne add_record_lenght_ms
compare_screen_status_ms:
  lda mas_screen_top
  cmp mas_screen_current
  bne multi_screen_multiple
  rts

test_custom_chars:
  ldx #$ff
test_custom_chars_loop 
  inx
  txa
  jsr print_char
  cpx #$07
  bne test_custom_chars_loop
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

delay_2_sec:
  jsr DELAY_SEC
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



; Main program
START:
    JSR DELAY_SEC    ; Call the delay subroutine


add_custom_chars_pacman:
  ;BEGIN Add custom char instruction
  ;8026 lda

char_0_pacman: 
  lda #($40+$00);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<esquina_rd
  sta charLoadLow
  lda #>esquina_rd
  sta charLoadHigh
  jsr char_load

char_1_pacman: 
  lda #($40+$08);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<fantasma
  sta charLoadLow
  lda #>fantasma
  sta charLoadHigh
  jsr char_load

char_2_pacman: 
  lda #($40+$10);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<pacman_boca_abierta
  sta charLoadLow
  lda #>pacman_boca_abierta
  sta charLoadHigh
  jsr char_load

char_3_pacman: 
  lda #($40+$18);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<pacman_boca_cerrada
  sta charLoadLow
  lda #>pacman_boca_cerrada
  sta charLoadHigh
  jsr char_load

char_4_pacman: 
  lda #($40+$20);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<fantasma_comido
  sta charLoadLow
  lda #>fantasma_comido
  sta charLoadHigh
  jsr char_load

char_5_pacman: 
  lda #($40+$28);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<pared_h
  sta charLoadLow
  lda #>pared_h
  sta charLoadHigh
  jsr char_load

char_6_pacman: 
  lda #($40+$30);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<pared_v
  sta charLoadLow
  lda #>pared_v
  sta charLoadHigh
  jsr char_load

char_7_pacman: 
  lda #($40+$38);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<esquina_ld
  sta charLoadLow
  lda #>esquina_ld
  sta charLoadHigh
  jsr char_load

add_custom_chars_end_pacman:  
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

 .org $c000
startDATA: 

title_pacman:
  .asciiz "PACMAN" ;adds a 0 after the last byte

pacman_screen_1:
  .byte pos_line1_pacman,cpared_v,cpacman_boca_abierta,cpared_v,cfantasma,cfantasma,cfantasma,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cpunto,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cpill,cpunto,cpunto,cpunto,cpunto,cfantasma,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_2:
  .byte pos_line1_pacman,cpared_v,cpacman_boca_abierta,cpared_v,cfantasma,cfantasma,cfantasma,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cpunto,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cpill,cpunto,cpunto,cpunto,cpunto,cfantasma,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_3:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma,cfantasma,cfantasma,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cpacman_boca_cerrada,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cpill,cpunto,cpunto,cpunto,cfantasma,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_4:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma,cfantasma,cfantasma,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cpacman_boca_abierta,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cpill,cpunto,cpunto,cfantasma,cpunto,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_5:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cpacman_boca_cerrada,cpunto,cpunto,cfantasma_comido,cpunto,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_6:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cpacman_boca_abierta,cpunto,cpunto,cfantasma_comido,cpunto,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_7:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cpacman_boca_cerrada,cpunto,cpunto,cfantasma_comido,cpunto,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_8:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cpacman_boca_abierta,cpunto,cpunto,cfantasma_comido,cpunto,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char  

pacman_screen_9:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cpacman_boca_cerrada,cpunto,cpunto,cfantasma_comido,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_10:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cpacman_boca_abierta,cpunto,cpunto,cfantasma_comido,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_11:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cespacio,cpacman_boca_cerrada,cpunto,cfantasma_comido,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_12:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cespacio,cpacman_boca_abierta,cpunto,cfantasma_comido,cpunto,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_13:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cespacio,cespacio,cpacman_boca_cerrada,cpunto,cfantasma_comido,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_14:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cespacio,cespacio,cpacman_boca_abierta,cpunto,cfantasma_comido,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_15:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cespacio,cespacio,cespacio,cpacman_boca_cerrada,cfantasma_comido,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_16:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cespacio,cespacio,cespacio,cpacman_boca_abierta,cfantasma_comido,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_17:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cespacio,cespacio,cespacio,cespacio,cpacman_boca_cerrada,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

pacman_screen_18:
  .byte pos_line1_pacman,cpared_v,cespacio,cpared_v,cfantasma_comido,cfantasma_comido,cfantasma_comido,cpared_v,cpunto,cpared_v
  .byte pos_line2_pacman,cpared_v,cespacio,cesquina_ld,cpared_h,cpared_h,cpared_h,cesquina_rd,cpunto,cpared_v
  .byte pos_line3_pacman,cpared_v,cespacio,cespacio,cespacio,cespacio,cespacio,cpacman_boca_abierta,cpunto,cpared_v
  .byte pos_line4_pacman,cesquina_ld,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cpared_h,cesquina_rd,end_char

esquina_rd
  .byte $04,$04,$04,$1c,$00,$00,$00,$0 
fantasma:
  .byte $00,$0E,$15,$1f,$1f,$1f,$15,$00
pacman_boca_abierta:
  .byte $00,$0e,$1f,$1e,$1c,$1e,$1f,$0e
pacman_boca_cerrada:  
  .byte $00,$0e,$1f,$1f,$1f,$1f,$1f,$0e
fantasma_comido:
  .byte $00,$0E,$15,$1F,$11,$1B,$15,$00
esquina_ld
  .byte $04,$04,$04,$07,$00,$00,$00,$0   
pared_v:
  .byte $04,$04,$04,$04,$04,$04,$04,$04 
pared_h:
  .byte $00,$00,$00,$1f,$00,$00,$00,$00 



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