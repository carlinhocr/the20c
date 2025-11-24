;test nop instructions in an epprom

  .org $8000 ;first address of the program

RESET:
  ;program instructions
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop  

;complete the file
  .org $fffa
  .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label
              ;  00 80 ($8000 in little endian)
  .org $fffe
  .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff
