

; ;test simpre instructions in an epprom

   .org $2000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
;              ;the rest is zero

RESET:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM:  
  inc $0200
  jmp INCRAM
    

;complete the file
  .org $2ffa
  .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $2ffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $2ffe
  .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff

