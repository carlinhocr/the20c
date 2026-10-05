  
  
  .include "lib_sid_memory.asm"
  .include "../lib_utils/lib_utils_memory.asm" ;define memory address for UTILS

  .org $8000
  .include "../lib_init/lib_init.asm" ;reset vector and stack initialization


programStart:
  ;jsr sidTest
  jsr parseSong
  jsr sidNotesExamplePlay
  jmp programStart

  .include "lib_sid_code.asm"
  .include "../lib_utils/lib_utils_code.asm" ;define code for ACIA t  

  .include "lib_sid_constants.asm"
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