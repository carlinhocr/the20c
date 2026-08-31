  .include "lib_ascii_banner_memory.asm"

  .include "../lib_acia/lib_acia_memory.asm" ;define memory address for ACIA
 
  .include "../lib_utils/lib_utils_memory.asm" ;define memory address for ACIA
 




  .org $8000
  .include "../lib_init/lib_init.asm" ;reset vector and stack initialization
  

;Plan to create an ASCII BANNER command

;constants that have the ASCII letter as if they where blocks on a 5x8 character block
;fucntion to read an ASCII character code and find the ASCII Letter block
;function to read the encoded characters and copy them to RAM memory
;function to read several ascii characters in the same Line and copy them to RAM
;function to get ascii in RAM and print it to RS-232 (the ACIA module has this function)

  jsr uartSerialInit
  lda #$0 ;if zero got to screen and not printer
  sta rs232Printer ;so we will go to screen and not printer
  lda #'A';load the ascii character of the letter A
  ;sta asciiLetter ;save the ascii letter to find
  ;lda asciiLetter
  ; jsr send_rs232_char
  ; jsr delay_1_sec
  ; lda #'.'
  ; jsr send_rs232_char
  ; lda #asciiCharBlock
  ; jsr send_rs232_char
  jsr drawLetterABasic
  jsr drawLetterA
loop:
  jmp loop  


  .include "lib_ascii_banner_code.asm"
  .include "lib_ascii_banner_debug.asm"
  .include "../lib_acia/lib_acia_code.asm" ;define code for ACIA t  
  .include "../lib_utils/lib_utils_code.asm" ;define code for ACIA t  
  .include "lib_ascii_banner_constants.asm"
  .include "../lib_acia/lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "../lib_utils/lib_utils_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  

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