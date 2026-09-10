;Plan to create an ASCII BANNER command

;constants that have the ASCII letter as if they where blocks on a 5x8 character block
    ;make it byte values, the first is the ascii character code the next 8 are the byte components of the characters

;THERE IS NOTHING IN THE charRAMforASCII, still have to copy it to RAM

findLetterAscii:
;given the code of one ascii character in variable asciiLetter
;output the address where it begins on  asciiBannerAlphabet
;on variables asciiPointer_low asciiPointer_high
;example letter A is ascii $41
;the offset should be $0108 to add to the beginning of asciiBannerAlphabet
;so ascii $41 - $20 = $21 
;now i have to multiply the value for 8 because each line is 8 bytes long
;$21 * 8 = $108
  lda asciiLetter ;the number stored in variable asciiletter
  sec  
  sbc #$20 ;go through the ASCII index 0...94
  ;move the pointer to the beginning of the letter (ascii value - $20) * 8 
  sta asciiPointer_low
  lda #$00
  sta asciiPointer_High
  ;now i have to multiply by 8 or shift 3 times to the left
  clc ;clear the carry
  asl asciiPointer_low  ;C <- [76543210] <- 0
  rol asciiPointer_High ;C <- [76543210] <- C
  clc ;clear the carry
  asl asciiPointer_low  ;C <- [76543210] <- 0
  rol asciiPointer_High ;C <- [76543210] <- C
  clc ;clear the carry
  asl asciiPointer_low  ;C <- [76543210] <- 0
  rol asciiPointer_High ;C <- [76543210] <- C
  ;now I should have the address shifted 8 times
  ;add the low address to the low address of where the Alphabet begins
  clc
  lda #<asciiBannerAlphabet
  adc asciiPointer_low
  sta asciiPointer_low
  ;do not clear the flag keep it
  lda #>asciiBannerAlphabet
  adc asciiPointer_High ;also adding the carry
  sta asciiPointer_High
  ;and now I have in asciiPointer_low and asciiPointer_High the position of asciiBannerAlphabet
  ;that correspond to the ascii code in asciiLetter
  ;test the address of the ascii letter
  rts

fillLineRAM:
  ;process all letters on the string to print in a line
  txa
  pha
  tya
  pha
  ;initialize RAM with all spaces
  jsr clearLineRAM
  ;get the string and process for each letter changing the letter position
  ;we have a pointer to the string on asciiStringZp_low
  ;we will iterate on the pointer
  ;LOOP FOR ALL THE STRING----------------------------------------------
  ;testing with a string of lenght 4
  ;jsr printLineRAM
  ldy #$ff
fillLineRAM_Loop:
  iny
  cpy #4 ; for string of lenght 4 chars 0 to 3
  beq fillLineRAM_End
  tya
  sta ordinalLetterPosition
  lda (asciiStringZp_low),Y ;just load the first letter and do not iterate for now
  sta asciiLetter
  ;jsr send_rs232_char 
  ;lets find the ascii letter drawing and it will be stored on asciiPointer_low, asciiPointer_high
  jsr findLetterAscii
  jsr findLineLetterPosition
  lda lineLetterPosition
  ; jsr send_rs232_char 
  ; jsr send_rs232_CRLF

  ; lda #$0
  ; sta lineLetterPosition ;just hardcode letter position
  jsr drawLetterRAM
  ;brk
  jmp fillLineRAM_Loop 
fillLineRAM_End:  
  pla
  tay
  pla
  tax
  rts
  
findLineLetterPosition:
  ;it give us the relative number in the line for the first line according to the ordinal position
  ;for String 'Hola'
  ;H position 0
  ;o position 8
  ;l position 16
  ;a position 24
  ;store the result on variable lineLetterPosition
  txa
  pha
  lda ordinalLetterPosition
  tax ;load X with the position of the letter in the strind for 'Hola'the o is position 1
  lda #$0
  sta lineLetterPosition
findLineLetterPosition_Loop:
  cpx #$00 
  beq findLineLetterPosition_End
  clc
  lda lineLetterPosition
  adc #numberOfSymbolsPerLinePerChar ;it is a number #8
  sta lineLetterPosition ;if line 1 then the position to start is 8 
                         ;as we added #numberOfSymbolsPerLinePerChar that is number 8
  dex 
  jmp findLineLetterPosition_Loop
findLineLetterPosition_End:
  pla
  tax
  rts

printLineRAM:
  ;get the starting position in line of the RAM and print the line using printAsciiDrawing
  lda #<charRAMforAscii
  sta serialDataVectorLow
  lda #>charRAMforAscii
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

clearLineRAM:
  ;Starting at position charRAMforAscii=$500
  ;clear 8 lines of 80 characters using zero page variables asciiRAMPointer_low and asciiRAMPointer_high
  ;using to fill the RAM asciiCharDot or asciiCharBlank
  lda #<charRAMforAscii
  sta asciiRAMPointer_low
  lda #>charRAMforAscii
  sta asciiRAMPointer_high
  ;save the X and Y register
  txa
  pha
  tya
  pha
  ;do this 8 times from 0 to 7
  ldx #$ff
clearLineRAM_LineLoop:
  inx
  cpx #numberOfLinesPerChar ;#$8
  beq clearLineRAM_end
  ;inner character loop
  ldy #$ff
  lda #asciiCharDot
clearLineRAM_CharactersLoop:
  iny
  cpy #lineLenght ;#80 ;80 decimal for the lenght of the line
  beq clearLineRAM_CharactersLoop_EndLine
  sta (asciiRAMPointer_low),y
  jmp clearLineRAM_CharactersLoop
clearLineRAM_CharactersLoop_EndLine:
  ;add 80 to the asciiRAMPointer_low and asciiRAMPointer_high
  ;so I prepare it for the next line
  lda #$00
  sta (asciiRAMPointer_low),y ;add and extra null byte to finish the line column 80
  ;0-79 + null byte 80
  ;81-160 + null byte 161
  clc
  lda asciiRAMPointer_low
  adc #lineLenght + 1 ;#81 ;because i am adding an extra null byte to finish the line
  sta asciiRAMPointer_low
  lda asciiRAMPointer_high
  adc #0 ;only adding the carry
  sta asciiRAMPointer_high
  jmp clearLineRAM_LineLoop
clearLineRAM_end:
  ;add the letter 'e' + the null byte to signal end for printAsciiDrawing
  ldy #$00
  lda #$65 ;'e'
  sta (asciiRAMPointer_low),y
  iny
  lda #$00
  sta (asciiRAMPointer_low),y
  pla
  tay
  pla
  tax
  rts

drawLetterRAM:
  ;according to letter position call a function that writes the blocks on RAM
  ;the position of the letter 0,1,2,3,4,5,6,7,8 adds 8 to the offset of characters
  ;"HOLA"
  ;letter position for H is 0, letter position for O is 8, etc
  ;when i add as block the second line of a letter i have to add decimal 80 
  ;example 
  ;_ _ _ # _ _ # _     starts in 0 line goes from 0 to 79 and 80 null character
  ;_ _ _ # _ _ # _     starts in 81 to 160 and 161 null character
  ;_ _ _ # _ _ # _     starts in 162 to 241 and 242 null character
  ;_ _ _ # # # # _     starts in 240
  ;_ _ _ # _ _ # _     starts in 320
  ;_ _ _ # _ _ # _     starts in 400
  ;_ _ _ # _ _ # _     starts in 480
  ;_ _ _ _ _ _ _ _     starts in 560
  ;this offsets adds to the beginning of the memory position of the RAM
  ;update low and high byte and remember the carrys
  tya ;preserve the Y index
  pha ;preserve the Y index
  ;position at the beginning of the line and correct starting position
  ;start with line 0
  lda #<charRAMforAscii
  sta asciiRAMPointer_low
  lda #>charRAMforAscii
  sta asciiRAMPointer_high
  ldy #$ff
drawLetterRAM_Loop:  
  iny
  cpy #numberOfLinesPerChar ;#$8 
  beq drawLetterRAM_End
  ;calculate for each line the correct character start acording to ordinal position
  ;of the character in the screen
  ;line 1
  cpy #00
  bne drawLetterRAM_adding_line_lenght
  ;here we are on the special case of line zero do not add #lineLenght
  clc 
  lda lineLetterPosition ;0,8,16, etc
  sta charStarPosition
  jmp drawLetterRAM_defineRAMPosition
drawLetterRAM_adding_line_lenght:  
  clc
  lda #$0 ;0,8,16, etc
  adc #lineLenght + 1 ;to save the null byte of the end of line
  sta charStarPosition 
drawLetterRAM_defineRAMPosition:
  clc
  lda charStarPosition
  adc asciiRAMPointer_low
  sta asciiRAMPointer_low
  lda #$00
  adc asciiRAMPointer_high
  sta asciiRAMPointer_high 
  ;add the 8 blocks and spaces that correspond to a line
  ;the line is in the register Y
  ;Here i Have to process the byte from (asciiPointer_Low) and store 8 different blocks and spaces
  ;in asciiRAMPointer_low, this variable is already in the position and line to start filling
  lda (asciiPointer_low),Y ;load the byte of the correct line for the letter
  sta asciiBannerLineByte
  jsr writeLetterBannerLineinRAM
  jmp drawLetterRAM_Loop
drawLetterRAM_End:
  pla ;restore the Y index
  tay  ;restore the Y index
  rts  


writeLetterBannerLineinRAM:
  tya 
  pha 
  ldy #$FF 
writeLetterBannerLineinRAM_Loop:  
  iny
  cpy #numberOfSymbolsPerLinePerChar ;#8
  beq writeLetterBannerLineinRAM_End
  asl asciiBannerLineByte ;now i have on the carry if it is a 1 then print a block 
                          ;or a 0 print space
  bcc writeLetterBannerLineinRAM_Space
  ;here i have to print a block the carry is set
  lda #asciiCharBlock
  sta (asciiRAMPointer_low),Y
  jmp writeLetterBannerLineinRAM_Loop
writeLetterBannerLineinRAM_Space:
  lda #asciiCharBlank
  sta (asciiRAMPointer_low),Y
  jmp writeLetterBannerLineinRAM_Loop
writeLetterBannerLineinRAM_End: 
  pla
  tay
  rts


; drawOneLetterBanner:
;   tya ;preserve the Y index
;   pha ;preserve the Y index
;   lda #<charRAMforAscii 
;   sta asciiPointer_low
;   lda #>charRAMforAscii
;   sta asciiPointer_High
;   ;load letter from text
;   lda asciiLetter
;   ;find letter in the Banner Alphabet
;   sec  
;   sbc #$20 ;go through the ASCII index A=0...94
;   ;move the pointer to the beginning of the letter (ascii value - $20) * 8   
;   sta asciiPointer_low
;   lda #$00
;   sta asciiPointer_High
;   ;now i have to multiply the value for 8 because each line is 8 bytes long
;   ;if I had the ascii value $21 now i have stored 1 and i have to go to 8 the actual offset
;   asl asciiPointer_low
;   rol asciiPointer_High
;   asl asciiPointer_low
;   rol asciiPointer_High
;   asl asciiPointer_low
;   rol asciiPointer_High
;   ;now I have the offset on the pointers, lets go to the actual memory address
;   lda asciiPointer_low
;   clc    
;   adc #<asciiBannerAlphabet 
;   sta asciiPointer_low ;now I have on the low byte the actual memory low address
;   lda asciiPointer_High
;   ;do not clear the carry bit so I can carry it if I have changed the byte number    
;   adc #>asciiBannerAlphabet 
;   sta asciiPointer_High
;   ;Now we are at the beginning of the code lets process each line
;   ldy #$ff   
;   sty indexByteLetter 
; drawOneLetterBanner_nextCharInLine:
;   inc indexByteLetter ;it goes from 0 to 7 to process 8 bytes
;   lda indexByteLetter
;   cmp #$8
;   beq drawOneLetterBanner_PrintLetter
;   lda indexByteLetter
;   sty indexByteLetter
;   lda (asciiPointer_low),Y
;   sta asciiBannerLineByte
;   ;now we have the first byte the read it bit by bit and process each block of the character
;   ; ;process each line
;   jsr processBits
;   jmp drawOneLetterBanner_nextCharInLine 
; drawOneLetterBanner_PrintLetter:
;   jsr printOneLetter
; drawOneLetterBanner_End:
;   pla ;restore the Y index
;   tay ;restore the Y index
;   rts



; ;for each line copy to memory the form of the banner letter per line  
; processBits:  
;   tya ;preserve the Y index
;   pha ;preserve the Y index
;   ldy #$FF
; processBits_Loop:  
;   iny
;   cpy #$8
;   beq processBits_End
;   clc 
;   asl asciiBannerLineByte
;   bcs processBits_addBlock
;   ;carry clear add a space
;   lda #$20
;   sta charToAdd
;   jmp processBits_StoreRAM 
; processBits_addBlock:
;   lda #$23
;   sta charToAdd
; processBits_StoreRAM:
;   lda charToAdd
;   sta (asciiRAMPointer_low),Y ;podria usar un jmp indirect sin índice en este caso
;   jmp processBits_Loop
; processBits_End  
;   ;keep the ram pointer to the next free byte to add more line characters
;   ;add null character to finish the line and be able to use send_rs232_line
;   lda #$00
;   sta (asciiRAMPointer_low),Y ;y is now 8
;   ;lets first icrement y to the 9 position
;   iny
;   tya
;   clc
;   adc asciiRAMPointer_low
;   sta asciiRAMPointer_low
;   lda asciiRAMPointer_high
;   adc #$0 ;just to add the carry
;   pla ;restore the Y index
;   tay ;restore the Y index
;   rts

;   ;print lettert from memoty to the screen
; printOneLetter:
;   tya ;preserve the Y index
;   pha ;preserve the Y index
;   ;letters are always 8 lines by 5 columns maybe 8 colums to make it easier now
;   lda #<charRAMforAscii 
;   sta asciiPointer_low
;   lda #>charRAMforAscii
;   sta asciiPointer_High
;   ldy #$00
; printOneLetterLine_Loop:  
;   cpy #72 ;decimal 72
;   beq printOneLetter_End
;   lda (asciiPointer_low),Y
;   sta serialDataVectorLow ;to use the send_rs232_line function
;   jsr send_rs232_line
;   ;now add 9 bytes to the y index (the 8 chars + the null byte) it ends on 72 chars
;   ;0,9,18,27,36,45,54,63,72
;   tya
;   clc
;   adc #$9
;   tay
; printOneLetter_End:
;   pla ;restore the Y index
;   tay ;restore the Y index
;   rts
  

;fucntion to read an ASCII character code and find the ASCII Letter block
;function to read the encoded characters and copy them to RAM memory
;function to read several ascii characters in the same Line and copy them to RAM
;function to get ascii in RAM and print it to RS-232 (the ACIA module has this function)