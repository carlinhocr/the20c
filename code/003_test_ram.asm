

;test simpre instructions in an epprom

  .org $8000

RESET:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM:  
  inc $0200
  jmp INCRAM
  

;complete the file
  .org $fffa
  .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff
