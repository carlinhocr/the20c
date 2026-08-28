;Plan to create an ASCII BANNER command

;constants that have the ASCII letter as if they where blocks on a 5x8 character block
    ;make it byte values, the first is the ascii character code the next 8 are the byte components of the characters

;THERE IS NOTHING IN THE charRAMforASCII, still have to copy it to RAM

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
  beq drawOneLetterA_End
  lda (asciiPointer_low),Y

drawOneLetterA_End:
  pla ;restore the Y index
  tay ;restore the Y index
  rts

drawOneLetterBanner:
  tya ;preserve the Y index
  pha ;preserve the Y index
  lda #<charRAMforAscii 
  sta asciiPointer_low
  lda #>charRAMforAscii
  sta asciiPointer_High
  ;load letter from text
  lda asciiLetter
  ;find letter in the Banner Alphabet
  sec  
  sbc #$20 ;go through the ASCII index A=0...94
  ;move the pointer to the beginning of the letter (ascii value - $20) * 8   
  sta asciiPointer_low
  lda #$00
  sta asciiPointer_High
  ;now i have to multiply the value for 8 because each line is 8 bytes long
  ;if I had the ascii value $21 now i have stored 1 and i have to go to 8 the actual offset
  asl asciiPointer_low
  rol asciiPointer_High
  asl asciiPointer_low
  rol asciiPointer_High
  asl asciiPointer_low
  rol asciiPointer_High
  ;now I have the offset on the pointers, lets go to the actual memory address
  lda asciiPointer_low
  clc    
  adc #<asciiBannerAlphabet 
  sta asciiPointer_low ;now I have on the low byte the actual memory low address
  lda asciiPointer_High
  ;do not clear the carry bit so I can carry it if I have changed the byte number    
  adc #>asciiBannerAlphabet 
  sta asciiPointer_High
  ;Now we are at the beginning of the code lets process each line
  ldy #$ff   
  sty indexByteLetter 
drawOneLetterBanner_nextCharInLine:
  inc indexByteLetter ;it goes from 0 to 7 to process 8 bytes
  lda indexByteLetter
  cmp #$8
  beq drawOneLetterBanner_PrintLetter
  lda indexByteLetter
  sty indexByteLetter
  lda (asciiPointer_low),Y
  sta asciiBannerLineByte
  ;now we have the first byte the read it bit by bit and process each block of the character
  ; ;process each line
  jsr processBits
  jmp drawOneLetterBanner_nextCharInLine 
drawOneLetterBanner_PrintLetter:
  jsr printOneLetter
drawOneLetterBanner_End:
  pla ;restore the Y index
  tay ;restore the Y index
  rts



;for each line copy to memory the form of the banner letter per line  
processBits:  
  tya ;preserve the Y index
  pha ;preserve the Y index
  ldy #$FF
processBits_Loop:  
  iny
  cpy #$8
  beq processBits_End
  clc 
  asl asciiBannerLineByte
  bcs processBits_addBlock
  ;carry clear add a space
  lda #$20
  sta charToAdd
  jmp processBits_StoreRAM 
processBits_addBlock:
  lda #$23
  sta charToAdd
processBits_StoreRAM:
  lda charToAdd
  sta (asciiRAMPointer_low),Y ;podria usar un jmp indirect sin índice en este caso
  jmp processBits_Loop
processBits_End  
  ;keep the ram pointer to the next free byte to add more line characters
  ;add null character to finish the line and be able to use send_rs232_line
  lda #$00
  sta (asciiRAMPointer_low),Y ;y is now 8
  ;lets first icrement y to the 9 position
  iny
  tya
  clc
  adc asciiRAMPointer_low
  sta asciiRAMPointer_low
  lda asciiRAMPointer_High
  adc #$0 ;just to add the carry
  pla ;restore the Y index
  tay ;restore the Y index
  rts

  ;print lettert from memoty to the screen
printOneLetter:
  tya ;preserve the Y index
  pha ;preserve the Y index
  ;letters are always 8 lines by 5 columns maybe 8 colums to make it easier now
  lda #<charRAMforAscii 
  sta asciiPointer_low
  lda #>charRAMforAscii
  sta asciiPointer_High
  ldy #$00
printOneLetterLine_Loop:  
  cpy #72 ;decimal 72
  beq printOneLetter_End
  lda (asciiPointer_low),Y
  sta serialDataVectorLow ;to use the send_rs232_line function
  jsr send_rs232_line
  ;now add 9 bytes to the y index (the 8 chars + the null byte) it ends on 72 chars
  ;0,9,18,27,36,45,54,63,72
  tya
  clc
  adc #$9
  tay
printOneLetter_End:
  pla ;restore the Y index
  tay ;restore the Y index
  rts
  

;fucntion to read an ASCII character code and find the ASCII Letter block
;function to read the encoded characters and copy them to RAM memory
;function to read several ascii characters in the same Line and copy them to RAM
;function to get ascii in RAM and print it to RS-232 (the ACIA module has this function)