

; ;test simpre instructions in an epprom

 .org $0000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
;              ;the rest is zero
  lda #$55 ;just to fill the memory from 0000 to $1000 and make it work fine

 .org $1000  
RESET:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM:  
  inc $0200
  jmp INCRAM
    

;complete the file
  .org $1ffa
  .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $1ffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $1ffe
  .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff

  .org $7fff;just to fill the memory from 2000 to $7fff and complete the 32 kb
  nop 

