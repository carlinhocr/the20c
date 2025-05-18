

;test simpre instructions in an epprom

  .org $1000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
             ;the rest is zero
RESET:
  ;initialize stack
  lda #$42
  jmp RESET
  

;complete the file
  .org $fffa
  .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff
