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
  jsr send_ansi_reset
  jsr send_rs232_line
  jsr send_ansi_red
  jsr send_rs232_line
  jsr send_ansi_blue   
  jsr send_rs232_line
  jsr delay_1_sec
  jsr demoAllColors
  jsr demoAllColorStyles
  jmp mainAciaDemo
 
demoAllColorStyles:
  ;normal
  jsr demoAllColors
  jsr delay_1_sec
  ;blink
  jsr send_ansi_blink
  jsr demoAllColors
  jsr send_ansi_blink_off
  jsr delay_1_sec
  ;bold
  jsr send_ansi_bold
  jsr demoAllColors
  jsr send_ansi_bold_off
  jsr delay_1_sec
  rts 

demoAllColors:
  lda #0 ; to nullify the variable unless it is used
  sta colorStyleHundred
  jsr demoAllForegroundColors
  jsr demoAllForegroundBrightColors
  jsr demoAllBackgroundColors
  lda #"1"
  sta colorStyleHundred
  jsr demoAllBackgroundBrightColors
  rts

demoAllForegroundColors:
  lda #"3"
  sta colorStyleType 
  lda #7 ;last color
  sta lastColorStyleItem
  jsr demoAllStyles
  rts

demoAllForegroundBrightColors:
  lda #"9"
  sta colorStyleType 
  lda #7 ;last color
  sta lastColorStyleItem
  jsr demoAllStyles
  rts

demoAllBackgroundColors:
  lda #"4"
  sta colorStyleType 
  lda #7 ;last color
  sta lastColorStyleItem
  jsr demoAllStyles
  rts

demoAllBackgroundBrightColors:
  lda #"1"
  sta colorStyleHundred
  lda #"0"
  sta colorStyleType 
  lda #7 ;last color
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
  jsr send_ansi_reset
  ldx #$ff
demoAllColors_loop:  
  inx
  cpx lastColorStyleItem + 1
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

  .include "../lib_acia/lib_acia_code.asm" ;define code for ACIA t  
  .include "../lib_utils/lib_utils_code.asm" ;define code for ACIA t  

  .include "../lib_acia/lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "../lib_utils/lib_utils_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  

demoConstantString:
  .asciiz "Hola a todos"

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