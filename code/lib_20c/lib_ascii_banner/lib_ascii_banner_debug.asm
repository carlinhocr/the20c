;Plan to create an ASCII BANNER command

;constants that have the ASCII letter as if they where blocks on a 5x8 character block
    ;make it byte values, the first is the ascii character code the next 8 are the byte components of the characters

;THERE IS NOTHING IN THE charRAMforASCII, still have to copy it to RAM


drawLetterABasic:
  tya ;preserve the Y index
  pha ;preserve the Y index
;process the 8 bytes from the letter A of the ASCII Alphabet
;one by one   .byte $0E,$11,$11,$1F,$11,$11,$11,$00 ; A 
  lda #$0E
  sta asciiBannerLineByte
  jsr printBannerLine
  lda #$11
  sta asciiBannerLineByte
  jsr printBannerLine
  lda #$11
  sta asciiBannerLineByte
  jsr printBannerLine
  lda #$1F
  sta asciiBannerLineByte
  jsr printBannerLine
  lda #$11
  sta asciiBannerLineByte
  jsr printBannerLine
  lda #$11
  sta asciiBannerLineByte
  jsr printBannerLine
  lda #$11
  sta asciiBannerLineByte
  jsr printBannerLine
  lda #$00
  sta asciiBannerLineByte
  jsr printBannerLine
drawLetterABasic_End:
  pla ;restore the Y index
  tay ;restore the Y index
  rts

printBannerLine:
  tya 
  pha 
  ldy #$FF 
printBannerLine_Loop:  
  iny 
  cpy #8
  beq printBannerLine_End
  asl asciiBannerLineByte ;now i have on the carry if it is a 1 then print a block 
                          ;or a zero print space
  bcc printBannerLine_Space
  ;here i have to print a block the carry is set
  lda #asciiCharBlock
  jsr send_rs232_char
  ;jsr delay_3_sec
  jmp printBannerLine_Loop
printBannerLine_Space:
  lda #asciiCharBlank
  jsr send_rs232_char
  ;jsr delay_3_sec  
  jmp printBannerLine_Loop
printBannerLine_End: 
  ;print a next line
  ;jsr send_rs232_CRLF
  lda #$0d ;CR
  jsr send_rs232_char
  jsr delay_1_sec
  lda #$0a ;LF
  jsr send_rs232_char
  jsr delay_1_sec
  pla
  tay
  rts



drawLetterA:
  tya ;preserve the Y index
  pha ;preserve the Y index
;process the 8 bytes from the letter A of the ASCII Alphabet
  lda #<asciiLetterA 
  sta asciiPointer_low
  lda #>asciiLetterA
  sta asciiPointer_High
  ldy #$ff
drawLetterA_Loop:  
  iny
  cpy #8
  beq drawLetterA_End
  lda (asciiPointer_low),Y
  sta asciiBannerLineByte
  jsr printBannerLine
  jmp drawLetterA_Loop
drawLetterA_End:
  pla ;restore the Y index
  tay  ;restore the Y index
  rts

