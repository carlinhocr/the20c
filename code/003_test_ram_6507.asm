

; ;test simpre instructions in an epprom

   .org $0000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
;              ;the rest is zero

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

; RESET:
;   ;initialize stack
;   lda #$42 
;   sta $0200
; INCRAM:  
;   inc $0200
;   jmp INCRAM2
    


;complete the file
 .org $2ffa
 .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $2ffc ;go to memory address $fffc of the reset vector
 .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $2ffe
 .word RESET;a word is 16 bits or two bytes in this case $fffe and $ffff

  .org $3000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
             ;the rest is zero

RESET3:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM3:  
  inc $0200
  jmp INCRAM3

 ;complete the file
 .org $3ffa
 .word RESET3 ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $3ffc ;go to memory address $fffc of the reset vector
 .word RESET3 ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $3ffe
 .word RESET3 ;a word is 16 bits or two bytes in this case $fffe and $ffff

  .org $4000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
             ;the rest is zero

RESET4:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM4:  
  inc $0200
  jmp INCRAM

 ;complete the file
 .org $4ffa
 .word RESET4 ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $4ffc ;go to memory address $fffc of the reset vector
 .word RESET4 ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $4ffe
 .word RESET4 ;a word is 16 bits or two bytes in this case $fffe and $ffff
  .org $5000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
             ;the rest is zero

RESET5:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM5:  
  inc $0200
  jmp INCRAM5
 
 ;complete the file
 .org $5ffa
 .word RESET5 ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $5ffc ;go to memory address $fffc of the reset vector
 .word RESET5 ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $5ffe
 .word RESET5 ;a word is 16 bits or two bytes in this case $fffe and $ffff
;test simpre instructions in an epprom


  .org $6000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
             ;the rest is zero

RESET6:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM6:  
  inc $0200
  jmp INCRAM6

 ;complete the file
 .org $6ffa
 .word RESET6 ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $6ffc ;go to memory address $fffc of the reset vector
 .word RESET6 ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $6ffe
 .word RESET6 ;a word is 16 bits or two bytes in this case $fffe and $ffff
;test simpre instructions in an epprom

  .org $7000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
             ;the rest is zero

RESET7:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM7:  
  inc $0200
  jmp INCRAM7
 ;complete the file
 .org $7ffa
 .word RESET7 ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $7ffc ;go to memory address $fffc of the reset vector
 .word RESET7 ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $7ffe
 .word RESET7 ;a word is 16 bits or two bytes in this case $fffe and $ffff
;test simpre instructions in an epprom

  .org $8000 ;changed for the 6507 to use with A12 to A0 addresses A12=1
             ;the rest is zero

RESET8:
  ;initialize stack
  lda #$42 
  sta $0200
INCRAM8:  
  inc $0200
  jmp INCRAM8

 ;complete the file
 .org $8ffa
 .word RESET8 ;a word is 16 bits or two bytes in this case $fffa and $fffb
 .org $8ffc ;go to memory address $fffc of the reset vector
 .word RESET8 ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
 .org $8ffe
 .word RESET8 ;a word is 16 bits or two bytes in this case $fffe and $ffff
;test simpre instructions in an epprom
