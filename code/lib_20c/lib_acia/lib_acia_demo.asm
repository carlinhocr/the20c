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
  jmp mainAciaDemo
 

demoAllColors:
  lda #<demoConstantString
  sta serialDataVectorLow
  lda #>demoConstantString
  sta serialDataVectorHigh
  jsr send_ansi_reset
  lda #"3"
  sta colorStyleType  
  ldx #$ff
demoAllColors_loop:  
  inx
  cpx #8
  beq demoAllColors_end
  txa 
  ora #$30 ;to pass the value to ASCII
  sta colorStyleOffset
  jsr send_ansi_generic
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