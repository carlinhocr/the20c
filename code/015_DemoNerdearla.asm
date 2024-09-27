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

end_char=$ff

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
  jsr initilize_display
start_demo:  
  jsr demo_first_part
  jsr sprint_start ;print title an do a lap
  jsr sprint_playing ;each one is a new lap
  jsr sprint_playing ;each one is a new lap
  jmp start_demo

demo_first_part:
  ;Draw Screen 1 Demo
  lda #<screen1_demo
  sta charDataVectorLow
  lda #>screen1_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  ;Draw Screen 2 Demo
  lda #<screen2_demo
  sta charDataVectorLow
  lda #>screen2_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  ;Draw Screen 3 Demo
  lda #<screen3_demo
  sta charDataVectorLow
  lda #>screen3_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  ;Draw Screen 4 Demo
  lda #<screen4_demo
  sta charDataVectorLow
  lda #>screen4_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  ;Draw Screen 5 Demo
  lda #<screen5_demo
  sta charDataVectorLow
  lda #>screen5_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  ;Draw Screen 6 Demo
  lda #<screen6_demo
  sta charDataVectorLow
  lda #>screen6_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  ;Draw Screen 7 Demo
  lda #<screen7_demo
  sta charDataVectorLow
  lda #>screen7_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  ;Draw Screen 8 Demo
  lda #<screen8_demo
  sta charDataVectorLow
  lda #>screen8_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  rts

sprint_start:
  ;Draw title Sprint
  jsr clear_display
  lda #<title_sprint
  sta charDataVectorLow
  lda #>title_sprint
  sta charDataVectorHigh
  jsr print_message
  jsr DELAY_SEC
  jsr DELAY_SEC
sprint_playing:
  ;Draw Screen1
  lda #<sprint_screen_1
  sta charDataVectorLow
  lda #>sprint_screen_1
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen2
  lda #<sprint_screen_2
  sta charDataVectorLow
  lda #>sprint_screen_2
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen3
  lda #<sprint_screen_3
  sta charDataVectorLow
  lda #>sprint_screen_3
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen4
  lda #<sprint_screen_4
  sta charDataVectorLow
  lda #>sprint_screen_4
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen 5
  lda #<sprint_screen_5
  sta charDataVectorLow
  lda #>sprint_screen_5
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen 6
  lda #<sprint_screen_6
  sta charDataVectorLow
  lda #>sprint_screen_6
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen 7
  lda #<sprint_screen_7
  sta charDataVectorLow
  lda #>sprint_screen_7
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen 8
  lda #<sprint_screen_8
  sta charDataVectorLow
  lda #>sprint_screen_8
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen 9
  lda #<sprint_screen_9
  sta charDataVectorLow
  lda #>sprint_screen_9
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen10
  lda #<sprint_screen_10
  sta charDataVectorLow
  lda #>sprint_screen_10
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen11
  lda #<sprint_screen_11
  sta charDataVectorLow
  lda #>sprint_screen_11
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen12
  lda #<sprint_screen_12
  sta charDataVectorLow
  lda #>sprint_screen_12
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen13
  lda #<sprint_screen_13
  sta charDataVectorLow
  lda #>sprint_screen_13
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  ;Draw Screen14
  lda #<sprint_screen_14
  sta charDataVectorLow
  lda #>sprint_screen_14
  sta charDataVectorHigh
  jsr print_screen
  jsr DELAY_HALF_SEC
  rts

enter_into_loop:
  jmp loop

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
  cpx #record_lenght
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
  lda #<auto1
  sta charLoadLow
  lda #>auto1
  sta charLoadHigh
  jsr char_load

char_2: 
  lda #($40+$10);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<auto2
  sta charLoadLow
  lda #>auto2
  sta charLoadHigh
  jsr char_load

char_3: 
  lda #($40+$18);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<raya1
  sta charLoadLow
  lda #>raya1
  sta charLoadHigh
  jsr char_load

char_4: 
  lda #($40+$20);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<raya2
  sta charLoadLow
  lda #>raya2
  sta charLoadHigh
  jsr char_load

char_5: 
  lda #($40+$28);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<pared_l
  sta charLoadLow
  lda #>pared_l
  sta charLoadHigh
  jsr char_load

char_6: 
  lda #($40+$30);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<pared_r
  sta charLoadLow
  lda #>pared_r
  sta charLoadHigh
  jsr char_load

char_7: 
  lda #($40+$38);+#position_custom_char ;the instruction itself is 0001, write a custom character cgram
  ;or set cg ram address charter positions are 00,08,10,18,20,28,30,38
  ;8028 jumps to send intrsuction
  jsr lcd_send_instruction
  lda #<auto_vert
  sta charLoadLow
  lda #>auto_vert
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

screen1_demo:
  .asciiz "      Hoooola       "
  .asciiz "                    "
  .asciiz "   NEEEEEERDDDDS    "
  .asciiz "                    "

screen2_demo:
  .asciiz "Hola                "
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "

screen3_demo:
  .asciiz "                    "
  .asciiz "     Soy la 20c     "
  .asciiz "                    "
  .asciiz "                    "

screen4_demo:
  .asciiz "   Soy una compu    "
  .asciiz "      MO            "
  .asciiz "        DU          "
  .asciiz "          LAR       "

screen5_demo:
  .asciiz "   Y tengo solo     "
  .asciiz "                    "
  .asciiz "      8 BITS        "
  .asciiz "                    "

screen6_demo:
  .asciiz "Me hicieron         "
  .asciiz "para explicar       "
  .asciiz "Como funcionan      "
  .asciiz "las COMPUTADORAS    "

screen7_demo:
  .asciiz "                    "
  .asciiz "  Soy  OpenSource   "
  .asciiz "    Hard y Soft     "
  .asciiz "                    "

screen8_demo:
  .asciiz "     Jugamos        "
  .asciiz "    un Juego        "
  .asciiz "   de Carreras?     "
  .asciiz "                    "

screen9_demo:
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "

screen10_demo:
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "


;-------------------------------------
screenXX_demo:
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "
  .asciiz "                    "
  


title_sprint:
  .asciiz "SPRINT" ;adds a 0 after the last byte

sprint_screen_demo:
  .byte pos_line1,cpared_l,craya1,cauto1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,cauto2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,cauto1,craya1,cauto_vert,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,cauto2,craya2,craya2,cpared_r,end_char

sprint_screen_1:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,cauto1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,cauto2,craya2,craya2,cpared_r,end_char

sprint_screen_2:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,cauto1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,cauto2,craya2,craya2,cpared_r,end_char

sprint_screen_3:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cauto_vert,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,cauto2,craya2,cpared_r,end_char

sprint_screen_4:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cauto_vert,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,cauto2,cpared_r,end_char

sprint_screen_5:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,cauto1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cauto_vert,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_6:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,cauto1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cauto_vert,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_7:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,cauto1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,cauto2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_8:
  .byte pos_line1,cpared_l,craya1,craya1,cauto1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,cauto2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_9:
  .byte pos_line1,cpared_l,craya1,cauto1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,cauto2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_10:
  .byte pos_line1,cpared_l,cauto1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cauto_vert,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_11:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cauto_vert,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cauto_vert,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_12:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cauto_vert,craya1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,cauto2,craya2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_13:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,cauto1,craya1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,cauto2,craya2,craya2,craya2,craya2,cpared_r,end_char

sprint_screen_14:
  .byte pos_line1,cpared_l,craya1,craya1,craya1,craya1,craya1,craya1,cpared_r
  .byte pos_line2,cpared_l,cespacio,craya2,craya2,craya2,craya2,cespacio,cpared_r
  .byte pos_line3,cpared_l,cespacio,craya1,cauto1,craya1,craya1,cespacio,cpared_r
  .byte pos_line4,cpared_l,craya2,craya2,cauto2,craya2,craya2,craya2,cpared_r,end_char

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