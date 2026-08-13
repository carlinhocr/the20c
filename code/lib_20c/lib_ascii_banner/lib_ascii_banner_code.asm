;Plan to create an ASCII BANNER command

;constants that have the ASCII letter as if they where blocks on a 5x8 character block
    ;make it byte values, the first is the ascii character code the next 8 are the byte components of the characters

drawOneLetterBanner:
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
  beq drawOneLetterBanner_End
  lda indexByteLetter
  sty indexByteLetter
  lda (asciiPointer_low),Y
  sta asciiBannerLineByte
  ;now we have the first byte the read it bit by bit and process each block of the character
  ; ;process each line
  jsr processBits
  jmp drawOneLetterBanner_nextCharInLine 
drawOneLetterBanner_End:
  rts



;for each line copy to memory the form of the banner letter per line  
processBits:  
  ldx #$FF
processBits_Loop:  
  inx
  cpx #$8
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
  ldy #$0
  lda charToAdd
  sta (asciiRAMPointer_low),Y 
  clc
  lda #$1
  adc asciiRAMPointer_low
  sta asciiRAMPointer_low
  lda asciiRAMPointer_High
  adc #$0 ;only here to add the carry
  sta asciiRAMPointer_High
processBits_End  
  rts

  ;print lettert from memoty to the screen



;fucntion to read an ASCII character code and find the ASCII Letter block
;function to read the encoded characters and copy them to RAM memory
;function to read several ascii characters in the same Line and copy them to RAM
;function to get ascii in RAM and print it to RS-232 (the ACIA module has this function)