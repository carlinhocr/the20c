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
  jmp printBannerLine_Loop
printBannerLine_Space:
  lda #asciiCharBlank
  jsr send_rs232_char
  jmp printBannerLine_Loop
printBannerLine_End: 
  ;print a next line
  jsr send_rs232_CRLF
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

drawLetterARAM:
  tya ;preserve the Y index
  pha ;preserve the Y index
  lda #<charRAMforAscii 
  sta asciiRAMPointer_low
  lda #>charRAMforAscii
  sta asciiRAMPointer_High
  lda #$FF
  sta indexByteChar

;process the 8 bytes from the letter A of the ASCII Alphabet
  lda #<asciiLetterA 
  sta asciiPointer_low
  lda #>asciiLetterA
  sta asciiPointer_High
  ldy #$ff
drawLetterARAM_Loop:  
  iny
  cpy #8
  beq drawLetterARAM_End
  lda (asciiPointer_low),Y
  sta asciiBannerLineByte
  jsr memoryBannerOneLetter
  jmp drawLetterARAM_Loop
drawLetterARAM_End:
  ; lda indexByteChar
  ; tay
  ; lda 'e'
  ; sta (asciiRAMPointer_low),Y
  ; lda #<charRAMforAscii
  ; sta serialDataVectorLow
  ; lda #>charRAMforAscii
  ; sta serialDataVectorHigh
  ; jsr printAsciiDrawing
  jsr printBanner
  pla ;restore the Y index
  tay  ;restore the Y index
  rts

printBanner:
  lda #<charRAMforAscii
  sta serialDataVectorLow
  lda #>charRAMforAscii
  sta serialDataVectorHigh
  jsr send_rs232_line  
  clc
  lda #$9
  adc serialDataVectorLow
  sta serialDataVectorLow
  jsr send_rs232_line 
  clc
  lda #$9
  adc serialDataVectorLow
  sta serialDataVectorLow  
  jsr send_rs232_line   
  rts 


memoryBannerOneLetter:
  tya 
  pha 
  txa
  pha
  ldx #$FF 
memoryBannerOneLetter_Loop:  
  inc indexByteChar
  lda indexByteChar
  tay  
  inx 
  cpx #8
  beq memoryBannerOneLetter_End
  asl asciiBannerLineByte ;now i have on the carry if it is a 1 then print a block 
                          ;or a zero print space


  bcc memoryBannerOneLetter_Space
  ;here i have to print a block the carry is set
  lda #asciiCharBlock
  sta (asciiRAMPointer_low),Y
  jmp memoryBannerOneLetter_Loop
memoryBannerOneLetter_Space:
  lda #asciiCharBlank
  sta (asciiRAMPointer_low),Y
  jmp memoryBannerOneLetter_Loop
memoryBannerOneLetter_End: 
  ;print a next line
  lda #$00
  sta (asciiRAMPointer_low),Y
  inc indexByteChar ;store 8 bytes per line + a null character
  ;jsr send_rs232_CRLF
  pla
  tax
  pla
  tay
  rts