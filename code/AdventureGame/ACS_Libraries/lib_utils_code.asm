;timer constants needs a VIA


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------UTILITY------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


bin_2_ascii_print_message
  ldx #$0
bin_2_ascii_printMessageLoop:
  lda message,x  
  beq bin_2_ascii_printMessageLoopEnd ;on null character stop printing
  jsr send_rs232_char
  inx
  jmp bin_2_ascii_printMessageLoop
bin_2_ascii_printMessageLoopEnd:  
  jsr send_rs232_CRLF
  rts

bin_2_ascii_segmentBarSizeLow:
  lda #$0
  sta message ;string with nul character
  sei
  lda segmentBarSizeLow
  sta value
  lda segmentBarSizeHigh
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts   

bin_2_ascii_multiply:
  lda #$0
  sta message ;string with nul character
  sei
  lda multiResultLow
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts

bin_2_ascii:
divide:
  ;initialize the remainder to be 0
  lda #0
  sta mod10
  sta mod10 + 1
  clc ; we will clear the carry bit
  ;END Initialization of the 4 bytes

  ldx #16
divloop:
  ;rotate the quotient and the remainder
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ;substract 1010, we will do it 8 bits at a time
  sec ; set the carry bit
  lda mod10
  sbc #10 ;substract with carry from 10
  tay ; save the low part of the 16 bits of the remainder to register y
  lda mod10 + 1
  sbc #0 ;substract with carry zero as the 8 high bits are all zeroes from 10 division
  ; the answer is on the combination of the a register and the y register
  ; a,y = dividend - divisor
  ; if the carry is clear for a then the dividend was less that the divisor and we will
  ; discard the result and do a shift left
  bcc ignore_result ; we will branch if the carry bit is clear (the carry of the last operation)
  ; if we do not ignore the result we want to store the intermediate result a,y
  ; in mod10+1 for a register and mod10 for the y register
  sty mod10
  sta mod10 + 1

  ; and then we will keep with the division if we did less than 16 left shifts

ignore_result:
  dex ; decrement the X time that we shifted left
    ; dex affects the Z flag if the content of the x register is zero
  bne divloop ;if what is on the X register
  ;we will rotate the carry bit inside value to have the result of the division
  rol value
  rol value + 1

  ;now we have to store the remainder
  lda mod10
  clc
  adc #"0" ;by adding zero to the a register we will have the ascii number of its value
  jsr push_char ;and now we store our character in the string
  ; we will be done dividen whne the result of the division is a zero
  ; we will check value and value + 1 and if any bit is one we are not done
  lda value
  ora value + 1 ; combine all ones from the 16 bits of value
  bne divide ; if a is not zero keep dividing
  rts
;add the content of the a register to a null terminated string message
push_char:
  pha ;push new character into the stack first 
  ldy #0
char_loop:
  lda message,y ;get char on string and put into x
  tax
  pla
  sta message,y ; we replaced the old first character with the new one
  iny ; lets go to the next character
  txa
  pha ; we have the character that used to be on the beginning of the message on the stack
  ;if a is zero we are at the end of the string
  bne char_loop
  pla
  sta message,y ; store the null terminator again
  rts

multiplyTest:
  lda #2
  sta multiFactor1
  lda #125
  sta multiFactor2
  jsr multiplyTwoNumbers8bitnumbers
  jsr bin_2_ascii_multiply
  rts 

multiplyTwoNumbers8bitnumbers:
  lda #$0
  sta multiResultLow
  sta multiResultHigh; Clear the 16-bit result 
  ldx #$8 ; Loop counter (8 bits to process)
multiplyTwoNumbers8bitnumbers_loop:
  lsr multiFactor1 ; Shift the multiplier right, putting LSB into Carry
  bcc multiplyTwoNumbers8bitnumbers_no_add ; If Carry is clear (bit was 0), skip addition
  ; Add multiplicand to the high/low result pair  
  clc
  lda multiResultLow
  adc multiFactor2
  sta multiResultLow
  lda multiResultHigh
  adc #$00 ; add any carry for low byte addition
  sta multiResultHigh
multiplyTwoNumbers8bitnumbers_no_add:
  asl multiFactor2
  ; Rotate a zero-page address (example placeholder, replace with ROL of a second byte if multiplicand were 16-bit)
  ;rol #$00
  dex 
  bne multiplyTwoNumbers8bitnumbers_loop
  rts
;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------UTILITY------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

delay_1_sec:
  jsr DELAY_SEC
  rts

; delay_2_sec:
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   rts

delay_3_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

; delay_4_sec:
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; rts 

; delay_5_sec:
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   rts

; DELAY_onetenth_SEC:
;   lda #$10
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN

; DELAY_two_tenth_SEC:
;   lda #$10
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN   

DELAY_SEC:
  lda #$FF
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

; DELAY_HALF_SEC:
;   lda #$50
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN

DELAY_MAIN:
    LDX delay_COUNT_A     ; Load outer loop count
OUTER_LOOP:
    LDY delay_COUNT_B     ; Load inner loop count
INNER_LOOP:
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    DEY               ; Decrement inner loop counter
    BNE INNER_LOOP    ; Branch if not zero
    DEX               ; Decrement outer loop counter
    BNE OUTER_LOOP    ; Branch if not zero
    RTS               ; Return from subroutine

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------