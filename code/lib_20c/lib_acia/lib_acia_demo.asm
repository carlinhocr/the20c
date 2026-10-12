  .include "../lib_acia/lib_acia_memory.asm" ;define memory address for ACIA
 
  .include "../lib_utils/lib_utils_memory.asm" ;define memory address for ACIA
  


  .org $8000
  .include "../lib_init/lib_init.asm" ;reset vector and stack initialization
  
  jsr uartSerialInit
  lda #$0 ;if zero got to screen and not printer
  sta rs232Printer ;so we will go to screen and not printer

mainAciaDemo:  
  ;jsr send_ansi_reset
  lda #<demoConstantString
  sta serialDataVectorLow
  lda #>demoConstantString
  sta serialDataVectorHigh
;   jsr send_ansi_reset
;   jsr send_rs232_line
;   jsr send_ansi_red
;   jsr send_rs232_line
;   jsr send_ansi_blue   
;   jsr send_rs232_line
;   jsr delay_1_sec
;   jsr demoAllColors
;   jsr delay_1_sec
;  jsr demoAllColorStyles
  ;jsr demoScreen
  ;jsr demoCharMovHorizontal
  ;jsr demoSpriteMovHorizontal
  jsr demo256Colors
;   jmp mainAciaDemo
loop:
  jmp loop

  

demoScreen:
  jsr send_ansi_reset
  jsr send_ansi_cur_hide
  ;set foregound color
  jsr send_ansi_red
  ;clear the screen, set backgourn blue, and position home the cursor
  lda #<screen_blue
  sta ansiStringMemoryConstantLow
  lda #>screen_blue
  sta ansiStringMemoryConstantHigh
  jsr send_ansi_string
  lda #2
  sta screenRow
  lda #4
  sta screenCol
  jsr positionScreenRowCol
  jsr send_rs232_line  
  lda #10
  sta screenRow
  lda #20
  sta screenCol
  jsr positionScreenRowCol
  jsr send_rs232_line  
  rts

demoCharMovHorizontal:
  jsr send_ansi_reset
  jsr send_ansi_cur_hide
  ;set foregound color  
  jsr send_ansi_br_white 
  ;clear the screen background blue
  lda #<screen_blue
  sta ansiStringMemoryConstantLow
  lda #>screen_blue
  sta ansiStringMemoryConstantHigh
  jsr send_ansi_string  
  lda #<demoCharTrain
  sta serialDataVectorLow
  lda #>demoCharTrain
  sta serialDataVectorHigh
  lda #10
  sta screenRow
  ldx #$00 ;because columns start in 1  
demoCharMovHorizontal_loop:
  inx
  cpx #40
  beq demoCharMovHorizontal_end
  txa
  sta screenCol
  jsr positionScreenRowCol
  jsr send_rs232_line 
  inc screenRow
  jsr positionScreenRowCol
  jsr send_rs232_line 
  inc screenRow
  jsr positionScreenRowCol
  jsr send_rs232_line 
  inc screenRow
  jsr positionScreenRowCol
  jsr send_rs232_line   
  dec screenRow  
  dec screenRow  
  dec screenRow      
  jsr delay_1_sec
  jmp demoCharMovHorizontal_loop  
demoCharMovHorizontal_end:
  rts



demoSpriteMovHorizontal:
  jsr send_ansi_reset
  jsr send_ansi_cur_hide
  ;set foregound color  
  jsr send_ansi_br_white 
  ;clear the screen background blue
  lda #<screen_blue
  sta ansiStringMemoryConstantLow
  lda #>screen_blue
  sta ansiStringMemoryConstantHigh
  jsr send_ansi_string  
  lda #<demoCharShip
  sta serialDataVectorLow
  lda #>demoCharShip
  sta serialDataVectorHigh
  lda #10
  sta screenRow
  lda #$00 ;because columns start in 1  
  sta screenCol
demoSpriteMovHorizontal_loop:
  inc screenCol
  lda screenCol
  cmp #80
  beq demoSpriteMovHorizontal_end
  ;jsr preserveSerialDataVector  
  jsr printAsciiSpriteOneOnOne 
  ;jsr restoreSerialDataVector
  jsr DELAY_HALF_SEC
  ;jsr delay_1_sec
  jmp demoSpriteMovHorizontal_loop  
demoSpriteMovHorizontal_end:
  rts  

demoAllColorStyles:
  ;normal
  jsr send_ansi_reset
  jsr demoAllColors
  jsr delay_1_sec
  ;blink
  jsr send_ansi_reset
  jsr send_ansi_blink
  jsr demoAllColors
  jsr send_ansi_blink_off
  jsr delay_1_sec
  ;bold
  jsr send_ansi_reset
  jsr send_ansi_bold
  jsr demoAllColors
  jsr send_ansi_bold_off
  jsr delay_1_sec
  ;italics
  jsr send_ansi_reset
  jsr send_ansi_italic
  jsr demoAllColors
  jsr send_ansi_italic_off
  jsr delay_1_sec

  rts 

demo256Colors:
  jsr send_ansi_reset
  ldx #$00 
demo256Colors_Loop:
  inx
  cpx #$ff
  beq demo256Colors_End
  lda #27 ;ESC 
  jsr send_rs232_char
  lda #91 ;[ 
  jsr send_rs232_char  
  ; Foregorund Text Red
  lda #'4'     ; 51
  jsr send_rs232_char
  lda #'8'     ; 49
  jsr send_rs232_char
  lda #59
  jsr send_rs232_char
  lda #"5"
  jsr send_rs232_char
  lda #59
  jsr send_rs232_char  
  txa 
  sta backgroundColor
  jsr bin_2_ascii_bgcolor 
  lda #109 ; m
  jsr send_rs232_char  
  jsr send_rs232_CRLF
  jsr delay_1_sec
  jmp demo256Colors_Loop
demo256Colors_End:
  rts

demoAllColors:
  jsr demoAllForegroundColors
  jsr delay_3_sec
  jsr demoAllForegroundBrightColors
  jsr delay_3_sec
  jsr demoAllBackgroundColors
  lda #"1"
  sta colorStyleHundred
  jsr delay_3_sec
  jsr demoAllBackgroundBrightColors
  jsr delay_3_sec
  rts

demoAllForegroundColors:
  lda #"0" ; to nullify the variable unless it is used
  sta colorStyleHundred
  lda #"3"
  sta colorStyleType 
  lda #8 ;last color
  sta lastColorStyleItem
  jsr demoAllStyles
  rts

demoAllForegroundBrightColors:
  lda #"9"
  sta colorStyleType 
  lda #8 ;last color
  sta lastColorStyleItem
  jsr demoAllStyles
  rts

demoAllBackgroundColors:
  lda #"4"
  sta colorStyleType 
  lda #8 ;last color
  sta lastColorStyleItem
  jsr demoAllStyles
  rts

demoAllBackgroundBrightColors:
  lda #"1"
  sta colorStyleHundred
  lda #"0"
  sta colorStyleType 
  lda #8 ;last color
  sta lastColorStyleItem
  jsr demoAllStyles
  lda #0 ;to nullify the variable unless it is used
  sta colorStyleHundred
  rts

demoAllStyles:
  ;style code for color is 3
  ;colors go from 0 to 7
  lda #<demoConstantString
  sta serialDataVectorLow
  lda #>demoConstantString
  sta serialDataVectorHigh
  ldx #$ff
demoAllColors_loop:  
  inx
  cpx lastColorStyleItem
  beq demoAllColors_end
  txa 
  ora #$30 ;to pass the value to ASCII
  sta colorStyleOffset
  lda colorStyleHundred
  cmp #"1"
  beq demoAllColors_hundred
  jsr send_ansi_generic
  jmp demoAllColors_send
demoAllColors_hundred: 
  jsr send_ansi_generic2forColorStyle
demoAllColors_send: 
  jsr send_rs232_line  
  jmp demoAllColors_loop
demoAllColors_end:  
  rts



printAsciiSpriteOneOnOne:
  jsr positionScreenRowCol 
  lda #<demoCharShip_l0
  sta serialDataVectorLow
  lda #>demoCharShip_l0
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  inc screenRow
  jsr positionScreenRowCol 
  lda #<demoCharShip_l1
  sta serialDataVectorLow
  lda #>demoCharShip_l1
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  inc screenRow
  jsr positionScreenRowCol 
  lda #<demoCharShip_l2
  sta serialDataVectorLow
  lda #>demoCharShip_l2
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  inc screenRow
  jsr positionScreenRowCol 
  lda #<demoCharShip_l3
  sta serialDataVectorLow
  lda #>demoCharShip_l3
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  inc screenRow
  jsr positionScreenRowCol 
  lda #<demoCharShip_l4
  sta serialDataVectorLow
  lda #>demoCharShip_l4
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  inc screenRow
  jsr positionScreenRowCol 
  lda #<demoCharShip_l5
  sta serialDataVectorLow
  lda #>demoCharShip_l5
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  inc screenRow
  jsr positionScreenRowCol 
  lda #<demoCharShip_l6
  sta serialDataVectorLow
  lda #>demoCharShip_l6
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  inc screenRow
  jsr positionScreenRowCol 
  lda #<demoCharShip_l7
  sta serialDataVectorLow
  lda #>demoCharShip_l7
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  dec screenRow
  dec screenRow
  dec screenRow
  dec screenRow
  dec screenRow
  dec screenRow
  dec screenRow
  rts


  .include "../lib_acia/lib_acia_code.asm" ;define code for ACIA t  
  .include "../lib_utils/lib_utils_code.asm" ;define code for ACIA t  

  .include "../lib_acia/lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "../lib_utils/lib_utils_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  

demoConstantString:
  .asciiz "Hola a todos"
demoCharTrain:
  .asciiz " **" 

demoCharShip:
  .asciiz " ***" 
  .asciiz "  *" 
  .asciiz " *********" 
  .asciiz " *********" 
  .asciiz "  *" 
  .asciiz " ***"   
  .asciiz "e"

demoCharShip_l0:
  .asciiz "           "   
demoCharShip_l1:
  .asciiz " ***" 
demoCharShip_l2:  
  .asciiz "  *" 
demoCharShip_l3:  
  .asciiz " ********* " 
demoCharShip_l4:  
  .asciiz " ********* " 
demoCharShip_l5:  
  .asciiz "  *" 
demoCharShip_l6:  
  .asciiz " ***"
demoCharShip_l7:
  .asciiz "           "

nmi:
irq:
  rti

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff