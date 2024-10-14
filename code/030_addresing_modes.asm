

;see all the addressing modes with and without page boundaries
;go step by step on the program
;short video 
;first show the command
;then explain the theory with the t0 to t5
;then show the code running


  .org $8000

RESET:
;accumulator addressing
  asl ;rotate left the bits of the accumulator
;implicit addresing
  inx ;increment X
;inmediate addresing
  lda #$42 
; zero page addresing
  lda $20
; absolute addresing
  lda $0201
; indirect x addressing
  ldx #$5
  lda ($20,x) ;lda from $25 Low byte and $26 High Byte, then go to the address and then get the data
; absolute addresing with X no page boundary
  ldx #$5
  lda $0201,x ;address $0206
; absolute addresing with X with page boundary
  ldx #$5
  lda $02ff,x ;address $0304
; absolute addresing with y no page boundary
  ldy #$7
  lda $0201,y ;address $0208
; absolute addresing with y with page boundary
  ldy #$7
  lda $02ff,y ;address $0306
; zero page with X no page boundary as is always zero page
  ldx #$5
  lda $01,x ;address $06
; zero page with y no page boundary as is always zero page
  ldy #$7
  lda $01,y ;address $08
; indirect Y addressing no page boundary
  ldy #$7
  lda #$05
  sta $20 ;store address alow
  lda #$03
  sta $21 ;store address high
  lda ($20),y ;got to $20 for ADL and $21 for address high and then add Y to the address
              ;the address will be $0305 + y = $030C
; indirect Y addressing with page boundary
  ldy #$7
  lda #$FF
  sta $20 ;store address alow
  lda #$03
  sta $21 ;store address high
  lda ($20),y ;got to $20 for ADL and $21 for address high and then add Y to the address
              ;the address will be $03FF + y = $0406
;loop to finish program
loop:
  jmp loop
  



  

;complete the file
  .org $fffa
  .word RESET ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word RESET ;a word is 16 bits or two bytes in this case $fffe and $ffff
