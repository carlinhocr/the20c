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
cauto1=$01
cauto2=$02
craya1=$03
craya2=$04
cpared_l=$05
cpared_r=$06
cauto_vert=$07
cpared=%01111100

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

cship=$00
cinv1=$01
cinv2=$fc
cshot1=%00101110
cshot2=%10100101
cexpl1=%10100001
cexpl2=%11011011


end_char=$ff

pos_line1=$8B
pos_line2=$CB
pos_line3=$9F
pos_line4=$DF

pos_line1_pacman=$8B
pos_line2_pacman=$CB
pos_line3_pacman=$9F
pos_line4_pacman=$DF

pos_line1_invaders=$8B
pos_line2_invaders=$CB
pos_line3_invaders=$9F
pos_line4_invaders=$DF

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

pscroll_l0_low=$C1
pscroll_l0_high=$C2
pscroll_l1_low=$C3
pscroll_l1_high=$C4
pscroll_l2_low=$C5
pscroll_l2_high=$C6
pscroll_l3_low=$C7
pscroll_l3_high=$C8
max_columns_scroll=$c9
columns_counter=$ca


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
  jsr demo_ms_p1;
  jsr pacman_start_ms;
  jsr pacman_playing_ms;
  jsr demo_ms_p2;
  jsr sprint_start_ms ;print title 
  jsr sprint_playing_ms ;each one is a new lap
  jsr sprint_playing_ms ;each one is a new lap
  jsr demo_ms_p3
  jsr invaders_start_ms
  jsr invaders_playing_ms
  jsr demo_ms_p4;
  jsr scroller_start;
  jsr demo_ms_p5;
  jsr lore_start_ms
  jsr lore_playing_ms
  jsr demo_ms_final
  jmp start_demo

invaders_start_ms:
  jsr add_custom_chars_invaders
  jsr initilize_display
  ;Draw title Space Invaders
  jsr clear_display
  lda #<title_invaders_1
  sta charDataVectorLow
  lda #>title_invaders_1
  sta charDataVectorHigh
  jsr print_message
  lda #$C0 ;position cursor at the start of second line
  jsr lcd_send_instruction
  lda #<title_invaders_2
  sta charDataVectorLow
  lda #>title_invaders_2
  sta charDataVectorHigh
  jsr print_message
  jsr DELAY_HALF_SEC
  rts

invaders_playing_ms:
  lda #$0A ; make the record lenght of 10 elements (one for position, 9 for graphics)
  sta mas_record_lenght  
  lda #$0A ; make the record lenght of 10 elements (one for position, 9 for graphics)
  sta record_lenght ;used inside print_screen
  lda #$0d ;set to 13 screens for space invaders
  sta mas_screen_top
  lda #$29 ;41 decimal
  sta mas_screen_total_lenght ; this is record lenght times 4, 40 characters plus one terminator
  ;load the first screen
  lda #<invaders_screen_1
  sta charDataVectorLow
  lda #>invaders_screen_1
  sta charDataVectorHigh
  jsr multi_screen_print
  rts

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

sprint_start_ms:
  jsr add_custom_chars_sprint
  jsr initilize_display
  ;Draw title sprint
  jsr clear_display
  lda #<title_sprint
  sta charDataVectorLow
  lda #>title_sprint
  sta charDataVectorHigh
  jsr print_message
  jsr DELAY_HALF_SEC
  rts

sprint_playing_ms:
  lda #$0A ; make the record lenght of 10 elements (one for position, 9 for graphics)
  sta mas_record_lenght  
  lda #$0A ; make the record lenght of 10 elements (one for position, 9 for graphics)
  sta record_lenght ;used inside print_screen
  lda #$12 ;set to decimal 18 screens for sprint
  sta mas_screen_top
  lda #$29 ;41 decimal
  sta mas_screen_total_lenght ; this is record lenght times 4, 40 characters plus one terminator
  ;load the first screen
  lda #<sprint_screen_1
  sta charDataVectorLow
  lda #>sprint_screen_1
  sta charDataVectorHigh
  jsr multi_screen_print
  rts  

scroll_start_ms:
  jsr add_custom_chars_scroll
  jsr initilize_display
  ;no Title for the Scroller
  jsr clear_display
  jsr DELAY_HALF_SEC
  rts

scroll_playing_ms:
  lda #$15 ; make the record lenght of 21 elements (one for position, 20 for graphics)
  sta mas_record_lenght  
  lda #$15 ; make the record lenght of 21 elements (one for position, 9 for graphics)
  sta record_lenght ;used inside print_screen
  lda #$04 ;set to decimal 18 screens for scroller
  sta mas_screen_top
  lda #$51 ;81 decimal
  sta mas_screen_total_lenght ; this is record lenght times 4, 40 characters plus one terminator
  ;load the first screen
  lda #<scroll_screen_1
  sta charDataVectorLow
  lda #>scroll_screen_1
  sta charDataVectorHigh
  jsr multi_screen_print
  rts  

lore_start_ms:
  jsr add_custom_chars_lore
  jsr initilize_display
  ;Draw title Space Invaders
  jsr clear_display
  rts

lore_playing_ms:
  lda #$15 ; make the record lenght of 21 elements (one for position, 20 for graphics)
  sta mas_record_lenght  
  lda #$15 ; make the record lenght of 21 elements (one for position, 20 for graphics)
  sta record_lenght ;used inside print_screen
  lda #$4C ;set to decimal 76 screens for lore
  sta mas_screen_top
  lda #$55 ;85 decimal
  sta mas_screen_total_lenght ; this is record lenght times 4, 85 characters plus one terminator each
  ;load the first screen
  lda #<lore_screen_0
  sta charDataVectorLow
  lda #>lore_screen_0
  sta charDataVectorHigh
  jsr multi_screen_print
  rts  

enter_into_loop:
  jmp loop


demo_ms_p1:
  lda #$15 ;set the record lenght on 21 characters, 20 letters and the terminator $00
  sta mas_record_lenght  
  lda #$10 ;set to 16 screens for part 1 of the demo
  sta mas_screen_top
  ;load the first screen
  lda #<screen1_demo_p1
  sta charDataVectorLow
  lda #>screen1_demo_p1
  sta charDataVectorHigh
  jsr multi_ascii_screen_print
  rts

demo_ms_p2:
  lda #$15 ;set the record lenght on 21 characters, 20 letters and the terminator $00
  sta mas_record_lenght  
  lda #$04 ;set to 4 screens for part 2 of the demo
  sta mas_screen_top
  ;load the first screen
  lda #<screen1_demo_p2
  sta charDataVectorLow
  lda #>screen1_demo_p2
  sta charDataVectorHigh
  jsr multi_ascii_screen_print
  rts

demo_ms_p3:
  lda #$15 ;set the record lenght on 21 characters, 20 letters and the terminator $00
  sta mas_record_lenght  
  lda #$02 ;set to 2 screens for part 3 of the demo
  sta mas_screen_top
  ;load the first screen
  lda #<screen1_demo_p3
  sta charDataVectorLow
  lda #>screen1_demo_p3
  sta charDataVectorHigh
  jsr multi_ascii_screen_print
  rts

demo_ms_p4:
  lda #$15 ;set the record lenght on 21 characters, 20 letters and the terminator $00
  sta mas_record_lenght  
  lda #$01 ;set to 8 screens for final part  of the demo
  sta mas_screen_top
  ;load the first screen
  lda #<screen1_demo_p4
  sta charDataVectorLow
  lda #>screen1_demo_p4
  sta charDataVectorHigh
  jsr multi_ascii_screen_print
  rts

demo_ms_p5:
  lda #$15 ;set the record lenght on 21 characters, 20 letters and the terminator $00
  sta mas_record_lenght  
  lda #$01 ;set to 8 screens for final part  of the demo
  sta mas_screen_top
  ;load the first screen
  lda #<screen1_demo_p5
  sta charDataVectorLow
  lda #>screen1_demo_p5
  sta charDataVectorHigh
  jsr multi_ascii_screen_print
  rts

demo_ms_final:
  lda #$15 ;set the record lenght on 21 characters, 20 letters and the terminator $00
  sta mas_record_lenght  
  lda #$08 ;set to 8 screens for final part  of the demo
  sta mas_screen_top
  ;load the first screen
  lda #<screen1_final_demo
  sta charDataVectorLow
  lda #>screen1_final_demo
  sta charDataVectorHigh
  jsr multi_ascii_screen_print
  rts

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

multi_ascii_screen_print:
  lda #$00 ; so I start at screen 1
  sta mas_screen_current
  lda #$15 ;set the record lenght on 21 characters, 20 letters and the terminator $00
  sta mas_record_lenght
  lda #$54 ;84
  sta mas_screen_total_lenght ; this is record lenght times 4, 84 characters including terminator

multi_ascii_screen_multiple:
  inc mas_screen_current ;star at screen 1
  jsr clear_display
  jsr print_ascii_screen ; print screen mas_screen_current
  jsr delay_3_sec ;add delay to wait with the screen printed
  ldx #$00
add_record_lenght:  
  inx
  inc charDataVectorLow
  bne done_add
  inc charDataVectorHigh
done_add:
  cpx mas_screen_total_lenght
  bne add_record_lenght
compare_screen_status:
  lda mas_screen_top
  cmp mas_screen_current
  bne multi_ascii_screen_multiple
  rts

inc_all_pscroll_lines:
  inc pscroll_l0_low
  bne done_l0
  inc pscroll_l0_high
done_l0:  
  inc pscroll_l1_low
  bne done_l1
  inc pscroll_l1_high
done_l1:  
  inc pscroll_l2_low
  bne done_l2
  inc pscroll_l2_high
done_l2:    
  inc pscroll_l3_low
  bne done_l3
  inc pscroll_l3_high
done_l3: 
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

scroller_start:
  jsr add_custom_chars_scroll
  jsr initilize_display
  jsr clear_display
  lda #$C0 ;max columns scroll
  sta max_columns_scroll
  lda #$00
  sta columns_counter
  lda #<scroll_linea_0
  sta pscroll_l0_low
  lda #>scroll_linea_0
  sta pscroll_l0_high
  lda #<scroll_linea_1
  sta pscroll_l1_low
  lda #>scroll_linea_1
  sta pscroll_l1_high
  lda #<scroll_linea_2
  sta pscroll_l2_low
  lda #>scroll_linea_2
  sta pscroll_l2_high
  lda #<scroll_linea_3
  sta pscroll_l3_low
  lda #>scroll_linea_3
  sta pscroll_l3_high
  jsr print_scroll_screen_loop
  rts

print_scroll_screen_loop:
  jsr print_scroll_l0
  jsr print_scroll_l1
  jsr print_scroll_l2
  jsr print_scroll_l3
  inc columns_counter;keep only here to count only 20 columns per screen and not one column per line
      ;as it would be if I keep it on l1, l2 and l0
  lda columns_counter
  cmp max_columns_scroll ;end all when we are at the last column of line 3
  beq print_scroll_end
  jsr DELAY_HALF_SEC ; delay half a second to see the effect
  jsr inc_all_pscroll_lines
  jmp print_scroll_screen_loop

print_scroll_l0:
  lda #pos_lcd_initial_line0
  jsr lcd_send_instruction 
  ldy #$FF
print_scroll_loop_l0:
  ;print line zero 20 chars
  iny
  lda (pscroll_l0_low),y
  jsr print_char 
  cpy #$13 ;20 decimal characters printed on the line
  bne print_scroll_loop_l0
  rts

print_scroll_l1:
  lda #pos_lcd_initial_line1
  jsr lcd_send_instruction 
  ldy #$FF
print_scroll_loop_l1:
  ;print line zero 20 chars
  iny
  lda (pscroll_l1_low),y
  jsr print_char 
  cpy #$13 ;19 20 decimal characters printed on the line from 0 to 19
  bne print_scroll_loop_l1
  rts

print_scroll_l2:
  lda #pos_lcd_initial_line2
  jsr lcd_send_instruction 
  ldy #$FF
print_scroll_loop_l2:
  ;print line zero 20 chars
  iny
  lda (pscroll_l2_low),y
  jsr print_char 
  cpy #$13 ;19 20 decimal characters printed on the line from 0 to 19
  bne print_scroll_loop_l2
  rts

print_scroll_l3:
  lda #pos_lcd_initial_line3
  jsr lcd_send_instruction 
  ldy #$FF
print_scroll_loop_l3:
  ;print line zero 20 chars

  iny
  lda (pscroll_l3_low),y
  jsr print_char 
  cpy #$13 ;19 20 decimal characters printed on the line from 0 to 19
  bne print_scroll_loop_l3
  rts

print_scroll_end:
  rts


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

print_line:  
  ;BEGIN Write all the letters 
  ldy #$00 ;first byte is the position of the line
  lda (charDataVectorLow),y
  jsr lcd_send_instruction
  iny 
print_line_eeprom:  
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  cpx record_lenght
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

add_custom_chars_sprint:
  ;BEGIN Add custom char instruction
  ;8026 lda

char_1_sprint: 
  lda #($40+$08);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<auto1
  sta charLoadLow
  lda #>auto1
  sta charLoadHigh
  jsr char_load

char_2_sprint: 
  lda #($40+$10);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<auto2
  sta charLoadLow
  lda #>auto2
  sta charLoadHigh
  jsr char_load

char_3_sprint: 
  lda #($40+$18);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<raya1
  sta charLoadLow
  lda #>raya1
  sta charLoadHigh
  jsr char_load

char_4_sprint: 
  lda #($40+$20);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<raya2
  sta charLoadLow
  lda #>raya2
  sta charLoadHigh
  jsr char_load

char_5_sprint: 
  lda #($40+$28);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<pared_l
  sta charLoadLow
  lda #>pared_l
  sta charLoadHigh
  jsr char_load

char_6_sprint: 
  lda #($40+$30);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<pared_r
  sta charLoadLow
  lda #>pared_r
  sta charLoadHigh
  jsr char_load

char_7_sprint: 
  lda #($40+$38);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<auto_vert
  sta charLoadLow
  lda #>auto_vert
  sta charLoadHigh
  jsr char_load

add_custom_chars_end_sprint:  
  rts

add_custom_chars_scroll:
  ;BEGIN Add custom char instruction
  ;8026 lda

char_0_scroll: 
  lda #($40+$00);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_0
  sta charLoadLow
  lda #>scroll_char_0
  sta charLoadHigh
  jsr char_load

char_1_scroll: 
  lda #($40+$08);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_1
  sta charLoadLow
  lda #>scroll_char_1
  sta charLoadHigh
  jsr char_load

char_2_scroll: 
  lda #($40+$10);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_2
  sta charLoadLow
  lda #>scroll_char_2
  sta charLoadHigh
  jsr char_load

char_3_scroll: 
  lda #($40+$18);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_3
  sta charLoadLow
  lda #>scroll_char_3
  sta charLoadHigh
  jsr char_load

char_4_scroll: 
  lda #($40+$20);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_4
  sta charLoadLow
  lda #>scroll_char_4
  sta charLoadHigh
  jsr char_load

char_5_scroll: 
  lda #($40+$28);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_5
  sta charLoadLow
  lda #>scroll_char_5
  sta charLoadHigh
  jsr char_load

char_6_scroll: 
  lda #($40+$30);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_6
  sta charLoadLow
  lda #>scroll_char_6
  sta charLoadHigh
  jsr char_load

char_7_scroll: 
  lda #($40+$38);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_7
  sta charLoadLow
  lda #>scroll_char_7
  sta charLoadHigh
  jsr char_load

add_custom_chars_end_scroll:  
  rts

add_custom_chars_lore:
  ;BEGIN Add custom char instruction
  ;8026 lda

char_0_lore: 
  lda #($40+$00);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<scroll_char_0
  sta charLoadLow
  lda #>scroll_char_0
  sta charLoadHigh
  jsr char_load

char_1_lore: 
  lda #($40+$08);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<lore_char_1
  sta charLoadLow
  lda #>lore_char_1
  sta charLoadHigh
  jsr char_load

char_2_lore: 
  lda #($40+$10);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<lore_char_2
  sta charLoadLow
  lda #>lore_char_2
  sta charLoadHigh
  jsr char_load

char_3_lore: 
  lda #($40+$18);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<lore_char_3
  sta charLoadLow
  lda #>lore_char_3
  sta charLoadHigh
  jsr char_load

char_4_lore: 
  lda #($40+$20);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<lore_char_4
  sta charLoadLow
  lda #>lore_char_4
  sta charLoadHigh
  jsr char_load

char_5_lore: 
  lda #($40+$28);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<lore_char_5
  sta charLoadLow
  lda #>lore_char_5
  sta charLoadHigh
  jsr char_load

char_6_lore: 
  lda #($40+$30);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<lore_char_6
  sta charLoadLow
  lda #>lore_char_6
  sta charLoadHigh
  jsr char_load

char_7_lore: 
  lda #($40+$38);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<lore_char_7
  sta charLoadLow
  lda #>lore_char_7
  sta charLoadHigh
  jsr char_load

add_custom_chars_end_lore:  
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

screen1_demo_p1:
  .asciiz "      Hoooola       "
  .asciiz "                    "
  .asciiz "    Flash Party     "
  .asciiz "       20 24        "

screen2_demo_p1:
  .asciiz "Hola                "
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "

screen3_demo_p1:
  .asciiz "                    "
  .asciiz "     Soy la 20c     "
  .asciiz "                    "
  .asciiz "                    "

screen4_demo_p1:
  .asciiz "    Soy una compu   "
  .asciiz "       MO           "
  .asciiz "         DU         "
  .asciiz "           LAR      "

screen5_demo_p1:
  .asciiz "    Y tengo solo    "
  .asciiz "                    "
  .asciiz "       8 BITS       "
  .asciiz "                    "

screen6_demo_p1:
  .asciiz "Me hicieron         "
  .asciiz "para explicar       "
  .asciiz "como funcionan      "
  .asciiz "las COMPUTADORAS    "

screen7_demo_p1:
  .asciiz "  Soy  OpenSource   "
  .asciiz "                    "
  .asciiz "    Hard y Soft     "
  .asciiz "                    "

screen8_demo_p1:
  .asciiz "   Mi cuerpo son    "
  .asciiz "                    "
  .asciiz "   Plaquitas PCB    "
  .asciiz "                    "

screen9_demo_p1:
  .asciiz "  Hay modulos de    "
  .asciiz "                    "
  .asciiz "   CPU   CLOCK      "
  .asciiz "      RAM     ROM   "

screen10_demo_p1:
  .asciiz "     Mi Cerebro     "
  .asciiz "       es un        "
  .asciiz "      CPU 6502      "
  .asciiz "                    "

screen11_demo_p1:
  .asciiz "                    "
  .asciiz "      Que onda      "
  .asciiz "                    "
  .asciiz "                    "
  
screen12_demo_p1:
  .asciiz "     Primera vez    "
  .asciiz "                    "
  .asciiz " Que hago  una DEMO "
  .asciiz "                    "

screen13_demo_p1:
  .asciiz "                    "
  .asciiz "      . . . . .     "
  .asciiz "                    "
  .asciiz "                    "

screen14_demo_p1:
  .asciiz "                    "
  .asciiz "      Silencio      "
  .asciiz "      Incomodo      "
  .asciiz "                    "

screen15_demo_p1:
  .asciiz "   Me gusta jugar   "
  .asciiz "     Jueguitos      "
  .asciiz "                    "
  .asciiz "TODOS DE LOS OCHENTA"

screen16_demo_p1:
  .asciiz "     Tengo  el      "
  .asciiz "                    "
  .asciiz "      PAC MAN       "
  .asciiz "                    "

;End first demo here an run PAC MAN

screen1_demo_p2:
  .asciiz "      el  de        "
  .asciiz "      Juegos        "
  .asciiz "        de          "
  .asciiz "      Guerra        "

screen2_demo_p2:
  .asciiz "GREETINGS           "
  .asciiz "PROFESSOR FALKEN.   "
  .asciiz "SHALL WE PLAY       "
  .asciiz "A GAME?             "

screen3_demo_p2:
  .asciiz "    No se mataron   "
  .asciiz "  programando mucho "
  .asciiz "       el de        "
  .asciiz "  juegos de guerra  "

screen4_demo_p2:
  .asciiz "Aaa pero el         "
  .asciiz "                    "
  .asciiz "   de carreras....  "
  .asciiz "                    "

;End second demo here an run SPRINT


screen1_demo_p3:
  .asciiz "                    "
  .asciiz "     Uno mas??      "
  .asciiz "                    "
  .asciiz "                    "

screen2_demo_p3:
  .asciiz " Bueno vamos con el "
  .asciiz "                    "
  .asciiz "   SPACE INVADERS   "
  .asciiz "                    "

;End third demo here an run FROGGER

screen1_demo_p4:
  .asciiz "                    "
  .asciiz "    Se Scrollear    "
  .asciiz "                    "
  .asciiz "                    "

screen1_demo_p5:
  .asciiz "   y soy amiga de   "
  .asciiz "                    "
  .asciiz "      SABREMAN      "
  .asciiz "                    "

screen1_final_demo:
  .asciiz "     Y buenoooo     "
  .asciiz "                    "
  .asciiz "Esto es todo por hoy"
  .asciiz "                    "

screen2_final_demo:
  .asciiz "Esta Demo fue traida"
  .asciiz "                    "
  .asciiz "A ustedes por . . . "
  .asciiz "                    "

screen3_final_demo:
  .asciiz "  Alecu             "
  .asciiz "      Carlinho      "
  .asciiz "             Kraca  "
  .asciiz "                    "

screen4_final_demo:
  .asciiz "      OsoLabs       "
  .asciiz "                    "
  .asciiz "Armo el             "
  .asciiz "      Hardware      "

screen5_final_demo:
  .asciiz "  Para saber como   "
  .asciiz "                    "
  .asciiz "  Hacerte una 20c   "
  .asciiz "                    "

screen6_final_demo:
  .asciiz "anda a              "
  .asciiz "                    "
  .asciiz "    OSOLABS.TECH    "
  .asciiz "                    "
  
screen7_final_demo:
  .asciiz "      Gracias!      "
  .asciiz "    Como dice el    "
  .asciiz "   Alcalde Quimby   "
  .asciiz "                    "

screen8_final_demo:
  .asciiz "        VOTEN       "
  .asciiz "         POR        "
  .asciiz "!!!!     MI     !!!!"
  .asciiz "                    "
  
;-------------------------------------
screenXX_demo:
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "
  

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

title_invaders_1:
  .asciiz "SPACE" ;adds a 0 after the last byte

title_invaders_2:
  .asciiz "INVADERS" ;adds a 0 after the last byte

invaders_screen_1:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cespacio
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cespacio
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_2:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cespacio
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cespacio
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cshot1,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_3:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cespacio
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cinv2,cespacio
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cshot2,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_4:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cespacio
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cexpl1,cinv2,cinv2,cinv2,cinv2,cespacio
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_5:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cespacio
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cexpl2,cinv2,cinv2,cinv2,cinv2,cespacio
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_6:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cespacio
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cespacio,cinv2,cinv2,cinv2,cinv2,cespacio
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_7:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cespacio
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cespacio,cinv2,cinv2,cinv2,cinv2,cespacio
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_8:
  .byte pos_line1_invaders,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cespacio
  .byte pos_line2_invaders,cinv2,cinv2,cinv2,cespacio,cinv2,cinv2,cinv2,cinv2,cespacio
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cshot1,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_9:
  .byte pos_line1_invaders,cespacio,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1
  .byte pos_line2_invaders,cespacio,cinv2,cinv2,cinv2,cespacio,cinv2,cinv2,cinv2,cinv2
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cshot2,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_10:
  .byte pos_line1_invaders,cespacio,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1
  .byte pos_line2_invaders,cespacio,cinv2,cinv2,cinv2,cshot1,cinv2,cinv2,cinv2,cinv2
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_11:
  .byte pos_line1_invaders,cespacio,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1,cinv1
  .byte pos_line2_invaders,cespacio,cinv2,cinv2,cinv2,cshot2,cinv2,cinv2,cinv2,cinv2
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_12:
  .byte pos_line1_invaders,cespacio,cinv1,cinv1,cinv1,cexpl1,cinv1,cinv1,cinv1,cinv1
  .byte pos_line2_invaders,cespacio,cinv2,cinv2,cinv2,cespacio,cinv2,cinv2,cinv2,cinv2
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,end_char

invaders_screen_13:
  .byte pos_line1_invaders,cespacio,cinv1,cinv1,cinv1,cexpl2,cinv1,cinv1,cinv1,cinv1
  .byte pos_line2_invaders,cespacio,cinv2,cinv2,cinv2,cespacio,cinv2,cinv2,cinv2,cinv2
  .byte pos_line3_invaders,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio,cespacio
  .byte pos_line4_invaders,cespacio,cespacio,cespacio,cespacio,cship,cespacio,cespacio,cespacio,cespacio,end_char

title_sprint:
  .asciiz "SPRINT" ;adds a 0 after the last byte

sprint_screen_1:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,cauto1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,cauto2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_2:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,cauto1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,cauto2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_3:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cauto1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,cauto2,craya2,craya2,cpared_r,end_char

sprint_screen_4:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cauto_vert,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,cauto2,craya2,cpared_r,end_char

sprint_screen_5:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cauto_vert,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,cauto2,cpared_r,end_char

sprint_screen_6:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cauto1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cauto_vert,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_7:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,cauto1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cauto_vert,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_8:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,cauto1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cauto2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_9:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,cauto1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,cauto2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_10:
  .byte pos_line1,cpared_l,craya1,craya1,cauto1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,cauto2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_11:
  .byte pos_line1,cpared_l,craya1,cauto1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,cauto2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_12:
  .byte pos_line1,cpared_l,craya1,cauto1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,cauto2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_13:
  .byte pos_line1,cpared_l,cauto1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cauto_vert,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_14:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cauto_vert,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cauto_vert,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_15:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cauto_vert,craya1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,cauto2,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_16:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,cauto1,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,cauto2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_17:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,cauto1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,cauto2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_18:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,cauto1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,cauto2,craya2,craya2,craya2,craya2,cpared_r,end_char



;                     ███ █ █ ███ ◢█◣ ◢█◣ ◢█◣  ◢█◣ ◢█◣ █ █  █ █ ◢█◣ ███  ◢█◣ █ █ ███ ◢█◣ ◢█◣ ◣ ◢ ███  ◢█◣ ◢█◣ ██◣ ◢█◣ █   █   ███ ██◣  ███ ◢█◣ ◢█◣       ◢█◣ ███ ◢█◣ ◢█◣  ██◣ █ █ █   ███ ███                     
;                      █  █ █ █    ◢◤ █ █ █    █   █ █ █◣█  █ █ █ █  ◢◤  █ █ █ █ █   █   █ █ █▀█ █    █   █   █ █ █ █ █   █   █   █ █   █  █ █ █ █       █   █   █ █  ◢◤  █ █ █ █ █   █    ◢◤                     
;                      █  █▀█ █▀  ◢◤  █ █ █    █   █▀█ █◥█  █▀█ █▀█ ◢◤   █▀█ ███ █▀  ▀▀█ █ █ █ █ █▀   ▀▀█ █   ██◤ █ █ █   █   █▀  ██◤   █  █ █ █ █   ▀   █▀◣ ▀▀█ █ █ ◢◤   ██◤ █ █ █   █▀  ◢◤                      
;                      █  █ █ ███ ███ ◥█◤ ◥█◤  ◥█◤ █ █ █ █  █ █ █ █ ███  █ █ ◤ ◥ ███ ◥█◤ ◥█◤ █ █ ███  ◥█◤ ◥█◤ █◥◣ ◥█◤ ███ ███ ███ █◥◣   █  ◥█◤ ◥█◤       ◥█◤ ◥█◤ ◥█◤ ███  █◥◣ ◥█◤ ███ ███ ███                     
scroll_linea_0:
  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $07, $07, $00, $07, $00, $07, $00, $07, $07, $07, $00, $01, $07, $02, $00, $01, $07, $02, $00, $01, $07, $02, $00, $00, $01, $07, $02, $00, $01, $07, $02, $00, $07, $00, $07, $00, $00, $07, $00, $07, $00, $01, $07, $02, $00, $07, $07, $07, $00, $00, $01, $07, $02, $00, $07, $00, $07, $00, $07, $07, $07, $00, $01, $07, $02, $00, $01, $07, $02, $00, $02, $00, $01, $00, $07, $07, $07, $00, $00, $01, $07, $02, $00, $01, $07, $02, $00, $07, $07, $02, $00, $01, $07, $02, $00, $07, $00, $00, $00, $07, $00, $00, $00, $07, $07, $07, $00, $07, $07, $02, $00, $00, $07, $07, $07, $00, $01, $07, $02, $00, $01, $07, $02, $00, $00, $00, $00, $00, $00, $00, $01, $07, $02, $00, $07, $07, $07, $00, $01, $07, $02, $00, $01, $07, $02, $00, $00, $07, $07, $02, $00, $07, $00, $07, $00, $07, $00, $00, $00, $07, $07, $07, $00, $07, $07, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
scroll_linea_1:
  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00, $00, $07, $00, $07, $00, $07, $00, $00, $00, $00, $01, $03, $00, $07, $00, $07, $00, $07, $00, $00, $00, $00, $07, $00, $00, $00, $07, $00, $07, $00, $07, $02, $07, $00, $00, $07, $00, $07, $00, $07, $00, $07, $00, $00, $01, $03, $00, $00, $07, $00, $07, $00, $07, $00, $07, $00, $07, $00, $00, $00, $07, $00, $00, $00, $07, $00, $07, $00, $07, $06, $07, $00, $07, $00, $00, $00, $00, $07, $00, $00, $00, $07, $00, $00, $00, $07, $00, $07, $00, $07, $00, $07, $00, $07, $00, $00, $00, $07, $00, $00, $00, $07, $00, $00, $00, $07, $00, $07, $00, $00, $00, $07, $00, $00, $07, $00, $07, $00, $07, $00, $07, $00, $00, $00, $00, $00, $00, $00, $07, $00, $00, $00, $07, $00, $00, $00, $07, $00, $07, $00, $00, $01, $03, $00, $00, $07, $00, $07, $00, $07, $00, $07, $00, $07, $00, $00, $00, $07, $00, $00, $00, $00, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
scroll_linea_2:
  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00, $00, $07, $06, $07, $00, $07, $06, $00, $00, $01, $03, $00, $00, $07, $00, $07, $00, $07, $00, $00, $00, $00, $07, $00, $00, $00, $07, $06, $07, $00, $07, $04, $07, $00, $00, $07, $06, $07, $00, $07, $06, $07, $00, $01, $03, $00, $00, $00, $07, $06, $07, $00, $07, $07, $07, $00, $07, $06, $00, $00, $06, $06, $07, $00, $07, $00, $07, $00, $07, $00, $07, $00, $07, $06, $00, $00, $00, $06, $06, $07, $00, $07, $00, $00, $00, $07, $07, $03, $00, $07, $00, $07, $00, $07, $00, $00, $00, $07, $00, $00, $00, $07, $06, $00, $00, $07, $07, $03, $00, $00, $00, $07, $00, $00, $07, $00, $07, $00, $07, $00, $07, $00, $00, $00, $06, $00, $00, $00, $07, $06, $02, $00, $06, $06, $07, $00, $07, $00, $07, $00, $01, $03, $00, $00, $00, $07, $07, $03, $00, $07, $00, $07, $00, $07, $00, $00, $00, $07, $06, $00, $00, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
scroll_linea_3:
  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00, $00, $07, $00, $07, $00, $07, $07, $07, $00, $07, $07, $07, $00, $04, $07, $03, $00, $04, $07, $03, $00, $00, $04, $07, $03, $00, $07, $00, $07, $00, $07, $00, $07, $00, $00, $07, $00, $07, $00, $07, $00, $07, $00, $07, $07, $07, $00, $00, $07, $00, $07, $00, $03, $00, $04, $00, $07, $07, $07, $00, $04, $07, $03, $00, $04, $07, $03, $00, $07, $00, $07, $00, $07, $07, $07, $00, $00, $04, $07, $03, $00, $04, $07, $03, $00, $07, $04, $02, $00, $04, $07, $03, $00, $07, $07, $07, $00, $07, $07, $07, $00, $07, $07, $07, $00, $07, $04, $02, $00, $00, $00, $07, $00, $00, $04, $07, $03, $00, $04, $07, $03, $00, $00, $00, $00, $00, $00, $00, $04, $07, $03, $00, $04, $07, $03, $00, $04, $07, $03, $00, $07, $07, $07, $00, $00, $07, $04, $02, $00, $04, $07, $03, $00, $07, $07, $07, $00, $07, $07, $07, $00, $07, $07, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00


scroll_screen_1:
  .byte pos_lcd_initial_line0,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
  .byte pos_lcd_initial_line1,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
  .byte pos_lcd_initial_line2,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
  .byte pos_lcd_initial_line3,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,end_char

scroll_screen_2:
  .byte pos_lcd_initial_line0,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,$07
  .byte pos_lcd_initial_line1,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,$00
  .byte pos_lcd_initial_line2,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,$00
  .byte pos_lcd_initial_line3,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,$00 ,end_char

scroll_screen_3:
  .byte pos_lcd_initial_line0,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $07
  .byte pos_lcd_initial_line1,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07
  .byte pos_lcd_initial_line2,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07
  .byte pos_lcd_initial_line3,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07,end_char

scroll_screen_4:
  .byte pos_lcd_initial_line0,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $07, $07
  .byte pos_lcd_initial_line1,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00
  .byte pos_lcd_initial_line2,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00
  .byte pos_lcd_initial_line3,$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00,end_char

;LORE SCREENS


lore_screen_0:
;                     
;                     
;                     
;                     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_1:
;                     
;                     
;                     
;           ▄▄ ▄      
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 5, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_2:
;                     
;                     
;                     
;         ▄▄█▀▄▀▄     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 7, 6, 5, 6, 5, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_3:
;                     
;                     
;           ▄▄ ▄      
;        ▄██▀▄█▄▀▄    
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 5, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 5, 7, 7, 6, 5, 7, 5, 6, 5, 0, 0, 0, 0
  .byte end_char
lore_screen_4:
;                     
;                     
;         ▄▄█▀▄▀▄     
;        ▀▀▀ ▀██▄▀▄   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 7, 6, 5, 6, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 6, 7, 7, 5, 6, 5, 0, 0, 0
  .byte end_char
lore_screen_5:
;                     
;           ▄▄ ▄      
;        ▄██▀▄█▄▀▄    
;      ▄▄▄▄▄▄▄▀▀█ █   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 5, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 5, 7, 7, 6, 5, 7, 5, 6, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 6, 6, 7, 0, 7, 0, 0, 0
  .byte end_char
lore_screen_6:
;                     
;         ▄▄█▀▄▀▄     
;        ▀▀▀ ▀██▄▀▄   
;    ▄▄▀▀▀▀▀▀▀▄▄▀ █▄  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 7, 6, 5, 6, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 6, 7, 7, 5, 6, 5, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 5, 5, 6, 6, 6, 6, 6, 6, 6, 5, 5, 6, 0, 7, 5, 0, 0
  .byte end_char
lore_screen_7:
;           ▄▄ ▄      
;        ▄██▀▄█▄▀▄    
;      ▄▄▄▄▄▄▄▀▀█ █   
;   ▄▀▀       ▀▀▄▄▀█  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 5, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 5, 7, 7, 6, 5, 7, 5, 6, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 6, 6, 7, 0, 7, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 5, 6, 6, 0, 0, 0, 0, 0, 0, 0, 6, 6, 5, 5, 6, 7, 0, 0
  .byte end_char
lore_screen_8:
;         ▄▄█▀▄▀▄     
;        ▀▀▀ ▀██▄▀▄   
;    ▄▄▀▀▀▀▀▀▀▄▄▀ █▄  
;   █    ▄▄ ▄▄  ▀▀▄▀  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 7, 6, 5, 6, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 6, 7, 7, 5, 6, 5, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 5, 5, 6, 6, 6, 6, 6, 6, 6, 5, 5, 6, 0, 7, 5, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 7, 0, 0, 0, 0, 5, 5, 0, 5, 5, 0, 0, 6, 6, 5, 6, 0, 0
  .byte end_char
lore_screen_9:
;        ▄██▀▄█▄▀▄    
;      ▄▄▄▄▄▄▄▀▀█ █   
;   ▄▀▀       ▀▀▄▄▀█  
;   ▀▄   █▀▄▀█    ▀▄  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 5, 7, 7, 6, 5, 7, 5, 6, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 6, 6, 7, 0, 7, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 5, 6, 6, 0, 0, 0, 0, 0, 0, 0, 6, 6, 5, 5, 6, 7, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 6, 5, 0, 0, 0, 7, 6, 5, 6, 7, 0, 0, 0, 0, 6, 5, 0, 0
  .byte end_char
lore_screen_10:
;        ▀▀▀ ▀██▄▀▄   
;    ▄▄▀▀▀▀▀▀▀▄▄▀ █▄  
;   █    ▄▄ ▄▄  ▀▀▄▀  
;    ▀▄  ▀▄█ ▀     ▀▄ 
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 6, 7, 7, 5, 6, 5, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 5, 5, 6, 6, 6, 6, 6, 6, 6, 5, 5, 6, 0, 7, 5, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 7, 0, 0, 0, 0, 5, 5, 0, 5, 5, 0, 0, 6, 6, 5, 6, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 6, 5, 0, 0, 6, 5, 7, 0, 6, 0, 0, 0, 0, 0, 6, 5, 0
  .byte end_char
lore_screen_11:
;      ▄▄▄▄▄▄▄▀▀█ █   
;   ▄▀▀       ▀▀▄▄▀█  
;   ▀▄   █▀▄▀█    ▀▄  
;     ▀▄  ██   ▄    █ 
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 6, 6, 7, 0, 7, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 5, 6, 6, 0, 0, 0, 0, 0, 0, 0, 6, 6, 5, 5, 6, 7, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 6, 5, 0, 0, 0, 7, 6, 5, 6, 7, 0, 0, 0, 0, 6, 5, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 6, 5, 0, 0, 7, 7, 0, 0, 0, 5, 0, 0, 0, 0, 7, 0
  .byte end_char
lore_screen_12:
;    ▄▄▀▀▀▀▀▀▀▄▄▀ █▄  
;   █    ▄▄ ▄▄  ▀▀▄▀  
;    ▀▄  ▀▄█ ▀     ▀▄ 
;      ▀▄ ▀▀   █▄▄ ▄▀ 
  .byte pos_lcd_initial_line0, 0, 0, 0, 5, 5, 6, 6, 6, 6, 6, 6, 6, 5, 5, 6, 0, 7, 5, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 7, 0, 0, 0, 0, 5, 5, 0, 5, 5, 0, 0, 6, 6, 5, 6, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 6, 5, 0, 0, 6, 5, 7, 0, 6, 0, 0, 0, 0, 0, 6, 5, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 6, 5, 0, 6, 6, 0, 0, 0, 7, 5, 5, 0, 5, 6, 0
  .byte end_char
lore_screen_13:
;   ▄▀▀       ▀▀▄▄▀█  
;   ▀▄   █▀▄▀█    ▀▄  
;     ▀▄  ██   ▄    █ 
;      ▄█▄   ▄▄███▄█  
  .byte pos_lcd_initial_line0, 0, 0, 5, 6, 6, 0, 0, 0, 0, 0, 0, 0, 6, 6, 5, 5, 6, 7, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 6, 5, 0, 0, 0, 7, 6, 5, 6, 7, 0, 0, 0, 0, 6, 5, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 6, 5, 0, 0, 7, 7, 0, 0, 0, 5, 0, 0, 0, 0, 7, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 5, 7, 5, 0, 0, 0, 5, 5, 7, 7, 7, 5, 7, 0, 0
  .byte end_char
lore_screen_14:
;   █    ▄▄ ▄▄  ▀▀▄▀  
;    ▀▄  ▀▄█ ▀     ▀▄ 
;      ▀▄ ▀▀   █▄▄ ▄▀ 
;     ▄███▄▄▄███████▄ 
  .byte pos_lcd_initial_line0, 0, 0, 7, 0, 0, 0, 0, 5, 5, 0, 5, 5, 0, 0, 6, 6, 5, 6, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 6, 5, 0, 0, 6, 5, 7, 0, 6, 0, 0, 0, 0, 0, 6, 5, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 6, 5, 0, 6, 6, 0, 0, 0, 7, 5, 5, 0, 5, 6, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 5, 7, 7, 7, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 5, 0
  .byte end_char
lore_screen_15:
;   ▀▄   █▀▄▀█    ▀▄  
;     ▀▄  ██   ▄    █ 
;      ▄█▄   ▄▄███▄█  
;    ▄███▀███████████▄
  .byte pos_lcd_initial_line0, 0, 0, 6, 5, 0, 0, 0, 7, 6, 5, 6, 7, 0, 0, 0, 0, 6, 5, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 6, 5, 0, 0, 7, 7, 0, 0, 0, 5, 0, 0, 0, 0, 7, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 5, 7, 5, 0, 0, 0, 5, 5, 7, 7, 7, 5, 7, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 5, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5
  .byte end_char
lore_screen_16:
;    ▀▄  ▀▄█ ▀     ▀▄ 
;      ▀▄ ▀▀   █▄▄ ▄▀ 
;     ▄███▄▄▄███████▄ 
;    ▀███ ██████▀████▀
  .byte pos_lcd_initial_line0, 0, 0, 0, 6, 5, 0, 0, 6, 5, 7, 0, 6, 0, 0, 0, 0, 0, 6, 5, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 6, 5, 0, 6, 6, 0, 0, 0, 7, 5, 5, 0, 5, 6, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 5, 7, 7, 7, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 5, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 6, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 6, 7, 7, 7, 7, 6
  .byte end_char
lore_screen_17:
;     ▀▄  ██   ▄    █ 
;      ▄█▄   ▄▄███▄█  
;    ▄███▀███████████▄
;   ▄▄▀█▀▄██████▄▀██▀▄
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 6, 5, 0, 0, 7, 7, 0, 0, 0, 5, 0, 0, 0, 0, 7, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 5, 7, 5, 0, 0, 0, 5, 5, 7, 7, 7, 5, 7, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 5, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5
  .byte pos_lcd_initial_line3, 0, 0, 5, 5, 6, 7, 6, 5, 7, 7, 7, 7, 7, 7, 5, 6, 7, 7, 6, 5
  .byte end_char
lore_screen_18:
;      ▀▄ ▀▀   █▄▄ ▄▀ 
;     ▄███▄▄▄███████▄ 
;    ▀███ ██████▀████▀
;  ▄██▄▀ ████████ ▀▀▄█
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 6, 5, 0, 6, 6, 0, 0, 0, 7, 5, 5, 0, 5, 6, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 5, 7, 7, 7, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 5, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 6, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 6, 7, 7, 7, 7, 6
  .byte pos_lcd_initial_line3, 0, 5, 7, 7, 5, 6, 0, 7, 7, 7, 7, 7, 7, 7, 7, 0, 6, 6, 5, 7
  .byte end_char
lore_screen_19:
;      ▄█▄   ▄▄███▄█  
;    ▄███▀███████████▄
;   ▄▄▀█▀▄██████▄▀██▀▄
; ▄███▀  ▀▀▀███▀▀▄ ▄██
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 5, 7, 5, 0, 0, 0, 5, 5, 7, 7, 7, 5, 7, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 5, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5
  .byte pos_lcd_initial_line2, 0, 0, 5, 5, 6, 7, 6, 5, 7, 7, 7, 7, 7, 7, 5, 6, 7, 7, 6, 5
  .byte pos_lcd_initial_line3, 5, 7, 7, 7, 6, 0, 0, 6, 6, 6, 7, 7, 7, 6, 6, 5, 0, 5, 7, 7
  .byte end_char
lore_screen_20:
;     ▄███▄▄▄███████▄ 
;    ▀███ ██████▀████▀
;  ▄██▄▀ ████████ ▀▀▄█
; ██▀▀   ▄▄▄▀▀▀▄▄█ ███
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 5, 7, 7, 7, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 5, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 6, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 6, 7, 7, 7, 7, 6
  .byte pos_lcd_initial_line2, 0, 5, 7, 7, 5, 6, 0, 7, 7, 7, 7, 7, 7, 7, 7, 0, 6, 6, 5, 7
  .byte pos_lcd_initial_line3, 7, 7, 6, 6, 0, 0, 0, 5, 5, 5, 6, 6, 6, 5, 5, 7, 0, 7, 7, 7
  .byte end_char
lore_screen_21:
;    ▄███▀███████████▄
;   ▄▄▀█▀▄██████▄▀██▀▄
; ▄███▀  ▀▀▀███▀▀▄ ▄██
; ▀▀     ███ ▄▄██▀▄██▀
  .byte pos_lcd_initial_line0, 0, 0, 0, 5, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5
  .byte pos_lcd_initial_line1, 0, 0, 5, 5, 6, 7, 6, 5, 7, 7, 7, 7, 7, 7, 5, 6, 7, 7, 6, 5
  .byte pos_lcd_initial_line2, 5, 7, 7, 7, 6, 0, 0, 6, 6, 6, 7, 7, 7, 6, 6, 5, 0, 5, 7, 7
  .byte pos_lcd_initial_line3, 6, 6, 0, 0, 0, 0, 0, 7, 7, 7, 0, 5, 5, 7, 7, 6, 5, 7, 7, 6
  .byte end_char
lore_screen_22:
;    ▀███ ██████▀████▀
;  ▄██▄▀ ████████ ▀▀▄█
; ██▀▀   ▄▄▄▀▀▀▄▄█ ███
;        ▀██ ████ ██▀ 
  .byte pos_lcd_initial_line0, 0, 0, 0, 6, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 6, 7, 7, 7, 7, 6
  .byte pos_lcd_initial_line1, 0, 5, 7, 7, 5, 6, 0, 7, 7, 7, 7, 7, 7, 7, 7, 0, 6, 6, 5, 7
  .byte pos_lcd_initial_line2, 7, 7, 6, 6, 0, 0, 0, 5, 5, 5, 6, 6, 6, 5, 5, 7, 0, 7, 7, 7
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 0, 7, 7, 7, 7, 0, 7, 7, 6, 0
  .byte end_char
lore_screen_23:
;   ▄▄▀█▀▄██████▄▀██▀▄
; ▄███▀  ▀▀▀███▀▀▄ ▄██
; ▀▀     ███ ▄▄██▀▄██▀
;         ██ ████▄▀▀  
  .byte pos_lcd_initial_line0, 0, 0, 5, 5, 6, 7, 6, 5, 7, 7, 7, 7, 7, 7, 5, 6, 7, 7, 6, 5
  .byte pos_lcd_initial_line1, 5, 7, 7, 7, 6, 0, 0, 6, 6, 6, 7, 7, 7, 6, 6, 5, 0, 5, 7, 7
  .byte pos_lcd_initial_line2, 6, 6, 0, 0, 0, 0, 0, 7, 7, 7, 0, 5, 5, 7, 7, 6, 5, 7, 7, 6
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 0, 7, 7, 7, 7, 5, 6, 6, 0, 0
  .byte end_char
lore_screen_24:
;  ▄██▄▀ ████████ ▀▀▄█
; ██▀▀   ▄▄▄▀▀▀▄▄█ ███
;        ▀██ ████ ██▀ 
;         ▀▀ ██▀▀▀    
  .byte pos_lcd_initial_line0, 0, 5, 7, 7, 5, 6, 0, 7, 7, 7, 7, 7, 7, 7, 7, 0, 6, 6, 5, 7
  .byte pos_lcd_initial_line1, 7, 7, 6, 6, 0, 0, 0, 5, 5, 5, 6, 6, 6, 5, 5, 7, 0, 7, 7, 7
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 0, 7, 7, 7, 7, 0, 7, 7, 6, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 7, 7, 6, 6, 6, 0, 0, 0, 0
  .byte end_char
lore_screen_25:
; ▄███▀  ▀▀▀███▀▀▄ ▄██
; ▀▀     ███ ▄▄██▀▄██▀
;         ██ ████▄▀▀  
;          ▄ ▀▀ ▄▄    
  .byte pos_lcd_initial_line0, 5, 7, 7, 7, 6, 0, 0, 6, 6, 6, 7, 7, 7, 6, 6, 5, 0, 5, 7, 7
  .byte pos_lcd_initial_line1, 6, 6, 0, 0, 0, 0, 0, 7, 7, 7, 0, 5, 5, 7, 7, 6, 5, 7, 7, 6
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 0, 7, 7, 7, 7, 5, 6, 6, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 6, 6, 0, 5, 5, 0, 0, 0, 0
  .byte end_char
lore_screen_26:
; ██▀▀   ▄▄▄▀▀▀▄▄█ ███
;        ▀██ ████ ██▀ 
;         ▀▀ ██▀▀▀    
;          ▀▄▄▄ ██    
  .byte pos_lcd_initial_line0, 7, 7, 6, 6, 0, 0, 0, 5, 5, 5, 6, 6, 6, 5, 5, 7, 0, 7, 7, 7
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 0, 7, 7, 7, 7, 0, 7, 7, 6, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 7, 7, 6, 6, 6, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 5, 5, 5, 0, 7, 7, 0, 0, 0, 0
  .byte end_char
lore_screen_27:
; ▀▀     ███ ▄▄██▀▄██▀
;         ██ ████▄▀▀  
;          ▄ ▀▀ ▄▄    
;       ▄▄ ▄███ ▀▀▄   
  .byte pos_lcd_initial_line0, 6, 6, 0, 0, 0, 0, 0, 7, 7, 7, 0, 5, 5, 7, 7, 6, 5, 7, 7, 6
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 0, 7, 7, 7, 7, 5, 6, 6, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 6, 6, 0, 5, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 5, 5, 0, 5, 7, 7, 7, 0, 6, 6, 5, 0, 0, 0
  .byte end_char
lore_screen_28:
;        ▀██ ████ ██▀ 
;         ▀▀ ██▀▀▀    
;          ▀▄▄▄ ██    
;       ██▄█▀▀▀▄▄▄█   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 0, 7, 7, 7, 7, 0, 7, 7, 6, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 7, 7, 6, 6, 6, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 5, 5, 5, 0, 7, 7, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 7, 7, 5, 7, 6, 6, 6, 5, 5, 5, 7, 0, 0, 0
  .byte end_char
lore_screen_29:
;         ██ ████▄▀▀  
;          ▄ ▀▀ ▄▄    
;       ▄▄ ▄███ ▀▀▄   
;       ███▀▄  ▀███   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 0, 7, 7, 7, 7, 5, 6, 6, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 6, 6, 0, 5, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 5, 5, 0, 5, 7, 7, 7, 0, 6, 6, 5, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 7, 7, 7, 6, 5, 0, 0, 6, 7, 7, 7, 0, 0, 0
  .byte end_char
lore_screen_30:
;         ▀▀ ██▀▀▀    
;          ▀▄▄▄ ██    
;       ██▄█▀▀▀▄▄▄█   
;       ▀▀▀ █▄▄▄█▀▀   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 7, 7, 6, 6, 6, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 5, 5, 5, 0, 7, 7, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 7, 7, 5, 7, 6, 6, 6, 5, 5, 5, 7, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 7, 5, 5, 5, 7, 6, 6, 0, 0, 0
  .byte end_char
lore_screen_31:
;          ▄ ▀▀ ▄▄    
;       ▄▄ ▄███ ▀▀▄   
;       ███▀▄  ▀███   
;           ▀██▀▀     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 6, 6, 0, 5, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 5, 5, 0, 5, 7, 7, 7, 0, 6, 6, 5, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 7, 7, 7, 6, 5, 0, 0, 6, 7, 7, 7, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 6, 6, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_32:
;          ▀▄▄▄ ██    
;       ██▄█▀▀▀▄▄▄█   
;       ▀▀▀ █▄▄▄█▀▀   
;            ▀▀       
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 5, 5, 5, 0, 7, 7, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 7, 7, 5, 7, 6, 6, 6, 5, 5, 5, 7, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 7, 5, 5, 5, 7, 6, 6, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_33:
;       ▄▄ ▄███ ▀▀▄   
;       ███▀▄  ▀███   
;           ▀██▀▀     
;                     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 5, 7, 7, 7, 0, 6, 6, 5, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 7, 7, 7, 6, 5, 0, 0, 6, 7, 7, 7, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 6, 6, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_34:
;       ██▄█▀▀▀▄▄▄█   
;       ▀▀▀ █▄▄▄█▀▀   
;            ▀▀       
;                     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 7, 7, 5, 7, 6, 6, 6, 5, 5, 5, 7, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 7, 5, 5, 5, 7, 6, 6, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_35:
;       ███▀▄  ▀███   
;           ▀██▀▀     
;                     
;                     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 6, 5, 0, 0, 6, 7, 7, 7, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 6, 6, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_36:
;       ▀▀▀ █▄▄▄█▀▀   
;            ▀▀       
;                     
;    ▄              ▄ 
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 7, 5, 5, 5, 7, 6, 6, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0
  .byte end_char
lore_screen_37:
;           ▀██▀▀     
;                     
;                     
;    ▀▄▄          ▄▄▀ 
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 6, 6, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 6, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 6, 0
  .byte end_char
lore_screen_38:
;            ▀▀       
;                     
;    ▄              ▄ 
;     ██▄▄ ▄▄▄▄▄ ▄██  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 7, 7, 5, 5, 0, 5, 5, 5, 5, 5, 0, 5, 7, 7, 0, 0
  .byte end_char
lore_screen_39:
;                     
;                     
;    ▀▄▄          ▄▄▀ 
;     ▀███▄█████▄▀██  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 6, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 6, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 6, 7, 7, 7, 5, 7, 7, 7, 7, 7, 5, 6, 7, 7, 0, 0
  .byte end_char
lore_screen_40:
;                     
;    ▄              ▄ 
;     ██▄▄ ▄▄▄▄▄ ▄██  
;      ██████████▄▀█  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 7, 7, 5, 5, 0, 5, 5, 5, 5, 5, 0, 5, 7, 7, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 6, 7, 0, 0
  .byte end_char
lore_screen_41:
;                     
;    ▀▄▄          ▄▄▀ 
;     ▀███▄█████▄▀██  
;      ▀████▀▀█▀▀█▄▀  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 6, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 6, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 6, 7, 7, 7, 5, 7, 7, 7, 7, 7, 5, 6, 7, 7, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 6, 7, 7, 7, 7, 6, 6, 7, 6, 6, 7, 5, 6, 0, 0
  .byte end_char
lore_screen_42:
;    ▄              ▄ 
;     ██▄▄ ▄▄▄▄▄ ▄██  
;      ██████████▄▀█  
;       ████ ▄█▄ █▀   
  .byte pos_lcd_initial_line0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 7, 7, 5, 5, 0, 5, 5, 5, 5, 5, 0, 5, 7, 7, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 6, 7, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 0, 5, 7, 5, 0, 7, 6, 0, 0, 0
  .byte end_char
lore_screen_43:
;    ▀▄▄          ▄▄▀ 
;     ▀███▄█████▄▀██  
;      ▀████▀▀█▀▀█▄▀  
;      ▄▀███▄███▄█    
  .byte pos_lcd_initial_line0, 0, 0, 0, 6, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 6, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 6, 7, 7, 7, 5, 7, 7, 7, 7, 7, 5, 6, 7, 7, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 6, 7, 7, 7, 7, 6, 6, 7, 6, 6, 7, 5, 6, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 5, 6, 7, 7, 7, 5, 7, 7, 7, 5, 7, 0, 0, 0, 0
  .byte end_char
lore_screen_44:
;     ██▄▄ ▄▄▄▄▄ ▄██  
;      ██████████▄▀█  
;       ████ ▄█▄ █▀   
;      █▄█████████▄   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 7, 7, 5, 5, 0, 5, 5, 5, 5, 5, 0, 5, 7, 7, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 6, 7, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 0, 5, 7, 5, 0, 7, 6, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 7, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 0, 0, 0
  .byte end_char
lore_screen_45:
;     ▀███▄█████▄▀██  
;      ▀████▀▀█▀▀█▄▀  
;      ▄▀███▄███▄█    
;      █████▀██▀█▀█   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 6, 7, 7, 7, 5, 7, 7, 7, 7, 7, 5, 6, 7, 7, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 6, 7, 7, 7, 7, 6, 6, 7, 6, 6, 7, 5, 6, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 5, 6, 7, 7, 7, 5, 7, 7, 7, 5, 7, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 6, 7, 7, 6, 7, 6, 7, 0, 0, 0
  .byte end_char
lore_screen_46:
;      ██████████▄▀█  
;       ████ ▄█▄ █▀   
;      █▄█████████▄   
;      █████▄▀█▄█▄█   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 6, 7, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 0, 5, 7, 5, 0, 7, 6, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 7, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 5, 6, 7, 5, 7, 5, 7, 0, 0, 0
  .byte end_char
lore_screen_47:
;      ▀████▀▀█▀▀█▄▀  
;      ▄▀███▄███▄█    
;      █████▀██▀█▀█   
;    ▄▄▀▀▀▀██ █▀▀▀█   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 6, 7, 7, 7, 7, 6, 6, 7, 6, 6, 7, 5, 6, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 5, 6, 7, 7, 7, 5, 7, 7, 7, 5, 7, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 6, 7, 7, 6, 7, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 5, 5, 6, 6, 6, 6, 7, 7, 0, 7, 6, 6, 6, 7, 0, 0, 0
  .byte end_char
lore_screen_48:
;       ████ ▄█▄ █▀   
;      █▄█████████▄   
;      █████▄▀█▄█▄█   
;   ▄██▄▄▄▄▀█ █ ▄ ▀   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 0, 5, 7, 5, 0, 7, 6, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 7, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 5, 6, 7, 5, 7, 5, 7, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 5, 7, 7, 5, 5, 5, 5, 6, 7, 0, 7, 0, 5, 0, 6, 0, 0, 0
  .byte end_char
lore_screen_49:
;      ▄▀███▄███▄█    
;      █████▀██▀█▀█   
;    ▄▄▀▀▀▀██ █▀▀▀█   
;   ███████▄▀ ▀▄█▄    
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 5, 6, 7, 7, 7, 5, 7, 7, 7, 5, 7, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 6, 7, 7, 6, 7, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 5, 5, 6, 6, 6, 6, 7, 7, 0, 7, 6, 6, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 7, 7, 7, 7, 7, 7, 7, 5, 6, 0, 6, 5, 7, 5, 0, 0, 0, 0
  .byte end_char
lore_screen_50:
;      █▄█████████▄   
;      █████▄▀█▄█▄█   
;   ▄██▄▄▄▄▀█ █ ▄ ▀   
;   ████████▄▄▄▀▀▀    
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 7, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 5, 6, 7, 5, 7, 5, 7, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 5, 7, 7, 5, 5, 5, 5, 6, 7, 0, 7, 0, 5, 0, 6, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 6, 6, 6, 0, 0, 0, 0
  .byte end_char
lore_screen_51:
;      █████▀██▀█▀█   
;    ▄▄▀▀▀▀██ █▀▀▀█   
;   ███████▄▀ ▀▄█▄    
;  ▄████▀██████▄▄     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 6, 7, 7, 6, 7, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 5, 5, 6, 6, 6, 6, 7, 7, 0, 7, 6, 6, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 7, 7, 7, 7, 7, 7, 7, 5, 6, 0, 6, 5, 7, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 5, 7, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 5, 5, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_52:
;      █████▄▀█▄█▄█   
;   ▄██▄▄▄▄▀█ █ ▄ ▀   
;   ████████▄▄▄▀▀▀    
;  █████ ████████ ▄▄  
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 5, 6, 7, 5, 7, 5, 7, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 5, 7, 7, 5, 5, 5, 5, 6, 7, 0, 7, 0, 5, 0, 6, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 6, 6, 6, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 7, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 0, 5, 5, 0, 0
  .byte end_char
lore_screen_53:
;    ▄▄▀▀▀▀██ █▀▀▀█   
;   ███████▄▀ ▀▄█▄    
;  ▄████▀██████▄▄     
;  ████▀▄████████ ██▄ 
  .byte pos_lcd_initial_line0, 0, 0, 0, 5, 5, 6, 6, 6, 6, 7, 7, 0, 7, 6, 6, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 7, 7, 7, 7, 7, 7, 7, 5, 6, 0, 6, 5, 7, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 5, 7, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 5, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 7, 7, 7, 7, 6, 5, 7, 7, 7, 7, 7, 7, 7, 7, 0, 7, 7, 5, 0
  .byte end_char
lore_screen_54:
;   ▄██▄▄▄▄▀█ █ ▄ ▀   
;   ████████▄▄▄▀▀▀    
;  █████ ████████ ▄▄  
; ▄████ █████████ ▀██▄
  .byte pos_lcd_initial_line0, 0, 0, 5, 7, 7, 5, 5, 5, 5, 6, 7, 0, 7, 0, 5, 0, 6, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 6, 6, 6, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 7, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 0, 5, 5, 0, 0
  .byte pos_lcd_initial_line3, 5, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 6, 7, 7, 5
  .byte end_char
lore_screen_55:
;   ███████▄▀ ▀▄█▄    
;  ▄████▀██████▄▄     
;  ████▀▄████████ ██▄ 
; ▀████ █████████  ▀██
  .byte pos_lcd_initial_line0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 5, 6, 0, 6, 5, 7, 5, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 5, 7, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 5, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 7, 7, 7, 7, 6, 5, 7, 7, 7, 7, 7, 7, 7, 7, 0, 7, 7, 5, 0
  .byte pos_lcd_initial_line3, 6, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 0, 6, 7, 7
  .byte end_char
lore_screen_56:
;   ████████▄▄▄▀▀▀    
;  █████ ████████ ▄▄  
; ▄████ █████████ ▀██▄
;  ▀███▄▀███████▀   █▀
  .byte pos_lcd_initial_line0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 6, 6, 6, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 7, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 0, 5, 5, 0, 0
  .byte pos_lcd_initial_line2, 5, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 6, 7, 7, 5
  .byte pos_lcd_initial_line3, 0, 6, 7, 7, 7, 5, 6, 7, 7, 7, 7, 7, 7, 7, 6, 0, 0, 0, 7, 6
  .byte end_char
lore_screen_57:
;  ▄████▀██████▄▄     
;  ████▀▄████████ ██▄ 
; ▀████ █████████  ▀██
;   ▀███▄▀██▀███▄  ▄▀ 
  .byte pos_lcd_initial_line0, 0, 5, 7, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 5, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 7, 7, 7, 7, 6, 5, 7, 7, 7, 7, 7, 7, 7, 7, 0, 7, 7, 5, 0
  .byte pos_lcd_initial_line2, 6, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 0, 6, 7, 7
  .byte pos_lcd_initial_line3, 0, 0, 6, 7, 7, 7, 5, 6, 7, 7, 6, 7, 7, 7, 5, 0, 0, 5, 6, 0
  .byte end_char
lore_screen_58:
;  █████ ████████ ▄▄  
; ▄████ █████████ ▀██▄
;  ▀███▄▀███████▀   █▀
;    ▀▀██▄▀█ ████  ▀  
  .byte pos_lcd_initial_line0, 0, 7, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 0, 5, 5, 0, 0
  .byte pos_lcd_initial_line1, 5, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 6, 7, 7, 5
  .byte pos_lcd_initial_line2, 0, 6, 7, 7, 7, 5, 6, 7, 7, 7, 7, 7, 7, 7, 6, 0, 0, 0, 7, 6
  .byte pos_lcd_initial_line3, 0, 0, 0, 6, 6, 7, 7, 5, 6, 7, 0, 7, 7, 7, 7, 0, 0, 6, 0, 0
  .byte end_char
lore_screen_59:
;  ████▀▄████████ ██▄ 
; ▀████ █████████  ▀██
;   ▀███▄▀██▀███▄  ▄▀ 
;      ▀██▄▀ ███▀     
  .byte pos_lcd_initial_line0, 0, 7, 7, 7, 7, 6, 5, 7, 7, 7, 7, 7, 7, 7, 7, 0, 7, 7, 5, 0
  .byte pos_lcd_initial_line1, 6, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 0, 6, 7, 7
  .byte pos_lcd_initial_line2, 0, 0, 6, 7, 7, 7, 5, 6, 7, 7, 6, 7, 7, 7, 5, 0, 0, 5, 6, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 6, 7, 7, 5, 6, 0, 7, 7, 7, 6, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_60:
; ▄████ █████████ ▀██▄
;  ▀███▄▀███████▀   █▀
;    ▀▀██▄▀█ ████  ▀  
;      ▄▀██ ▄███      
  .byte pos_lcd_initial_line0, 5, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 6, 7, 7, 5
  .byte pos_lcd_initial_line1, 0, 6, 7, 7, 7, 5, 6, 7, 7, 7, 7, 7, 7, 7, 6, 0, 0, 0, 7, 6
  .byte pos_lcd_initial_line2, 0, 0, 0, 6, 6, 7, 7, 5, 6, 7, 0, 7, 7, 7, 7, 0, 0, 6, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 5, 6, 7, 7, 0, 5, 7, 7, 7, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_61:
; ▀████ █████████  ▀██
;   ▀███▄▀██▀███▄  ▄▀ 
;      ▀██▄▀ ███▀     
;    ▄▄█ █▀ ███▀      
  .byte pos_lcd_initial_line0, 6, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 0, 6, 7, 7
  .byte pos_lcd_initial_line1, 0, 0, 6, 7, 7, 7, 5, 6, 7, 7, 6, 7, 7, 7, 5, 0, 0, 5, 6, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 6, 7, 7, 5, 6, 0, 7, 7, 7, 6, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 5, 5, 7, 0, 7, 6, 0, 7, 7, 7, 6, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_62:
;  ▀███▄▀███████▀   █▀
;    ▀▀██▄▀█ ████  ▀  
;      ▄▀██ ▄███      
;   ▄██▀▄▀  ██▀       
  .byte pos_lcd_initial_line0, 0, 6, 7, 7, 7, 5, 6, 7, 7, 7, 7, 7, 7, 7, 6, 0, 0, 0, 7, 6
  .byte pos_lcd_initial_line1, 0, 0, 0, 6, 6, 7, 7, 5, 6, 7, 0, 7, 7, 7, 7, 0, 0, 6, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 5, 6, 7, 7, 0, 5, 7, 7, 7, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 5, 7, 7, 6, 5, 6, 0, 0, 7, 7, 6, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_63:
;   ▀███▄▀██▀███▄  ▄▀ 
;      ▀██▄▀ ███▀     
;    ▄▄█ █▀ ███▀      
;  ▄███▄▀  ▄██▄       
  .byte pos_lcd_initial_line0, 0, 0, 6, 7, 7, 7, 5, 6, 7, 7, 6, 7, 7, 7, 5, 0, 0, 5, 6, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 6, 7, 7, 5, 6, 0, 7, 7, 7, 6, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 5, 5, 7, 0, 7, 6, 0, 7, 7, 7, 6, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 5, 7, 7, 7, 5, 6, 0, 0, 5, 7, 7, 5, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_64:
;    ▀▀██▄▀█ ████  ▀  
;      ▄▀██ ▄███      
;   ▄██▀▄▀  ██▀       
;  ▀████▄▄ ████▄▄     
  .byte pos_lcd_initial_line0, 0, 0, 0, 6, 6, 7, 7, 5, 6, 7, 0, 7, 7, 7, 7, 0, 0, 6, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 5, 6, 7, 7, 0, 5, 7, 7, 7, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 5, 7, 7, 6, 5, 6, 0, 0, 7, 7, 6, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 6, 7, 7, 7, 7, 5, 5, 0, 7, 7, 7, 7, 5, 5, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_65:
;      ▀██▄▀ ███▀     
;    ▄▄█ █▀ ███▀      
;  ▄███▄▀  ▄██▄       
;   ▀▀████▄▀▀████▄▄   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 6, 7, 7, 5, 6, 0, 7, 7, 7, 6, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 5, 5, 7, 0, 7, 6, 0, 7, 7, 7, 6, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 5, 7, 7, 7, 5, 6, 0, 0, 5, 7, 7, 5, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 6, 6, 7, 7, 7, 7, 5, 6, 6, 7, 7, 7, 7, 5, 5, 0, 0, 0
  .byte end_char
lore_screen_66:
;      ▄▀██ ▄███      
;   ▄██▀▄▀  ██▀       
;  ▀████▄▄ ████▄▄     
;     ▀▀███  ▀▀████   
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 5, 6, 7, 7, 0, 5, 7, 7, 7, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 5, 7, 7, 6, 5, 6, 0, 0, 7, 7, 6, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 6, 7, 7, 7, 7, 5, 5, 0, 7, 7, 7, 7, 5, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 6, 6, 7, 7, 7, 0, 0, 6, 6, 7, 7, 7, 7, 0, 0, 0
  .byte end_char
lore_screen_67:
;    ▄▄█ █▀ ███▀      
;  ▄███▄▀  ▄██▄       
;   ▀▀████▄▀▀████▄▄   
;       ▀▀█    ▀▀▀█   
  .byte pos_lcd_initial_line0, 0, 0, 0, 5, 5, 7, 0, 7, 6, 0, 7, 7, 7, 6, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 5, 7, 7, 7, 5, 6, 0, 0, 5, 7, 7, 5, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 6, 6, 7, 7, 7, 7, 5, 6, 6, 7, 7, 7, 7, 5, 5, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 6, 6, 7, 0, 0, 0, 0, 6, 6, 6, 7, 0, 0, 0
  .byte end_char
lore_screen_68:
;   ▄██▀▄▀  ██▀       
;  ▀████▄▄ ████▄▄     
;     ▀▀███  ▀▀████   
;         ▀       ▀   
  .byte pos_lcd_initial_line0, 0, 0, 5, 7, 7, 6, 5, 6, 0, 0, 7, 7, 6, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 6, 7, 7, 7, 7, 5, 5, 0, 7, 7, 7, 7, 5, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 6, 6, 7, 7, 7, 0, 0, 6, 6, 7, 7, 7, 7, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0
  .byte end_char
lore_screen_69:
;  ▄███▄▀  ▄██▄       
;   ▀▀████▄▀▀████▄▄   
;       ▀▀█    ▀▀▀█   
;                     
  .byte pos_lcd_initial_line0, 0, 5, 7, 7, 7, 5, 6, 0, 0, 5, 7, 7, 5, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 6, 6, 7, 7, 7, 7, 5, 6, 6, 7, 7, 7, 7, 5, 5, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 6, 6, 7, 0, 0, 0, 0, 6, 6, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_70:
;  ▀████▄▄ ████▄▄     
;     ▀▀███  ▀▀████   
;         ▀       ▀   
;                     
  .byte pos_lcd_initial_line0, 0, 6, 7, 7, 7, 7, 5, 5, 0, 7, 7, 7, 7, 5, 5, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 6, 6, 7, 7, 7, 0, 0, 6, 6, 7, 7, 7, 7, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_71:
;   ▀▀████▄▀▀████▄▄   
;       ▀▀█    ▀▀▀█   
;                     
;                     
  .byte pos_lcd_initial_line0, 0, 0, 6, 6, 7, 7, 7, 7, 5, 6, 6, 7, 7, 7, 7, 5, 5, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 6, 6, 7, 0, 0, 0, 0, 6, 6, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_72:
;     ▀▀███  ▀▀████   
;         ▀       ▀   
;                     
;                     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 6, 6, 7, 7, 7, 0, 0, 6, 6, 7, 7, 7, 7, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_73:
;       ▀▀█    ▀▀▀█   
;                     
;                     
;                     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 6, 6, 7, 0, 0, 0, 0, 6, 6, 6, 7, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_74:
;         ▀       ▀   
;                     
;                     
;                     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char
lore_screen_75:
;                     
;                     
;                     
;                     
  .byte pos_lcd_initial_line0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte pos_lcd_initial_line3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte end_char


;usar el primer byte como la posición de la linea
auto1:
  .byte $00,$1F,$00,$11,$0E,$11,$00,$00
auto2:
  .byte $00,$00,$11,$0e,$11,$00,$1f,$00
raya1:
  .byte $00,$1F,$00,$00,$00,$00,$00,$00
raya2:
  .byte $00,$00,$00,$00,$00,$00,$1f,$00 
pared_l:
  .byte $00,$01,$01,$01,$01,$01,$01,$00 
pared_r:
  .byte $00,$10,$10,$10,$10,$10,$10,$00 
auto_vert:
  .byte $00,$0A,$04,$04,$04,$0A,$00,$00 


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


invader_ship_1:
  .byte $00,$04,$04,$0e,$1f,$04,$0e,$00
invader_ship_2:
  .byte $00,$04,$0E,$15,$1B,$0E,$00,$00

scroll_char_0:
  .byte $00,$00,$00,$00,$00,$00,$00,$00
scroll_char_1:
  .byte $01, $03,$03,$07,$07,$0f,$0f,$1f
scroll_char_2:
  .byte $10,$18,$18,$1c,$1c,$1e,$1e,$1f
scroll_char_3:
  .byte $1f,$1e,$1e,$1c,$1c,$18,$18,$10
scroll_char_4:
  .byte $1f,$0f,$0f,$07,$07,$03,$03,$01
scroll_char_5:
  .byte $00,$00,$00,$00,$1f,$1f,$1f,$1f 
scroll_char_6:
  .byte $1f,$1f,$1f,$1f,$00,$00,$00,$00 
scroll_char_7:
  .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f

lore_char_0:
  .byte $00,$00,$00,$00,$00,$00,$00,$00
lore_char_1:
  .byte $01, $03,$03,$07,$07,$0f,$0f,$1f
lore_char_2:
  .byte $10,$18,$18,$1c,$1c,$1e,$1e,$1f
lore_char_3:
  .byte $1f,$1e,$1e,$1c,$1c,$18,$18,$10
lore_char_4:
  .byte $1f,$0f,$0f,$07,$07,$03,$03,$01
lore_char_5:
  .byte $00,$00,$00,$00,$1f,$1f,$1f,$1f 
lore_char_6:
  .byte $1f,$1f,$1f,$1f,$00,$00,$00,$00 
lore_char_7:
  .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f







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