  .include "lib_ascii_banner_memory.asm"

  .include "../lib_acia/lib_acia_memory.asm" ;define memory address for ACIA
 
  .include "../lib_utils/lib_utils_memory.asm" ;define memory address for ACIA

  .org $8000
  .include "../lib_init/lib_init.asm" ;reset vector and stack initialization
  
  jsr uartSerialInit
  lda #$0 ;if zero got to screen and not printer
  sta rs232Printer ;so we will go to screen and not printer

  ;load the asciiString that will be processed
  lda #<asciiStringTest
  sta asciiStringZp_low
  lda #>asciiStringTest
  sta asciiStringZp_high
  ;load the alphabet
  lda #<asciiBannerAlphabet_c64
  sta asciiBannerAlphabet_low
  lda #>asciiBannerAlphabet_c64  
  sta asciiBannerAlphabet_high

  jsr fillLineRAM
  jsr printLineRAM
  jsr delay_1_sec

  ;load a new alphabet
  lda #<asciiBannerAlphabet_neo
  sta asciiBannerAlphabet_low
  lda #>asciiBannerAlphabet_neo
  sta asciiBannerAlphabet_high

  jsr fillLineRAM
  jsr printLineRAM
  jsr delay_1_sec

  ;load the asciiString that will be processed
  lda #<asciiStringTestDings
  sta asciiStringZp_low
  lda #>asciiStringTestDings
  sta asciiStringZp_high

  ;load a new alphabet
  lda #<asciiBannerAlphabet_dings
  sta asciiBannerAlphabet_low
  lda #>asciiBannerAlphabet_dings
  sta asciiBannerAlphabet_high

  jsr fillLineRAM
  jsr printLineRAM
  jsr delay_1_sec

  ;load the alphabet
  lda #<asciiBannerAlphabet_c64
  sta asciiBannerAlphabet_low
  lda #>asciiBannerAlphabet_c64  
  sta asciiBannerAlphabet_high
  ;load the string
  lda #<asciiStringShort
  sta asciiLongStringZp_low
  lda #>asciiStringShort
  sta asciiLongStringZp_high
  ;slice and print the string of lenght asciiPrintLenght
  jsr sliceAsciiStrings


  ;load the alphabet
  lda #<asciiBannerAlphabet_c64
  sta asciiBannerAlphabet_low
  lda #>asciiBannerAlphabet_c64  
  sta asciiBannerAlphabet_high
  ;load the string
  lda #<asciiStringLong
  sta asciiLongStringZp_low
  lda #>asciiStringLong
  sta asciiLongStringZp_high
  ;slice and print the string of lenght asciiPrintLenght
  jsr sliceAsciiStrings
 

loop:
  jmp loop  


  .include "lib_ascii_banner_code.asm"
  ;.include "lib_ascii_banner_debug.asm"
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