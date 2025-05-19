

;test simpre instructions in an epprom

  .org $1000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
             ;the rest is zero

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
;test simpre instructions in an epprom


;complete the file
 .org $2ffa
 .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $2ffc ;go to memory address $fffc of the reset vector
 .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $2ffe
 .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff

 ;complete the file
 .org $3ffa
 .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $3ffc ;go to memory address $fffc of the reset vector
 .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $3ffe
 .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff

 ;complete the file
 .org $4ffa
 .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $4ffc ;go to memory address $fffc of the reset vector
 .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $4ffe
 .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff

 ;complete the file
 .org $5ffa
 .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $5ffc ;go to memory address $fffc of the reset vector
 .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $5ffe
 .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff
;test simpre instructions in an epprom

 ;complete the file
 .org $6ffa
 .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $6ffc ;go to memory address $fffc of the reset vector
 .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $6ffe
 .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff
;test simpre instructions in an epprom

 ;complete the file
 .org $7ffa
 .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $7ffc ;go to memory address $fffc of the reset vector
 .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $7ffe
 .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff
;test simpre instructions in an epprom

 ;complete the file
 .org $8ffa
 .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $8ffc ;go to memory address $fffc of the reset vector
 .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $8ffe
 .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff
;test simpre instructions in an epprom
