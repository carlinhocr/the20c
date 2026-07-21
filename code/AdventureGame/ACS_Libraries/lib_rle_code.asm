
;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------RLE------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;REQUIRES 
;lib_acia_memory.asm
;lib_acia_constants.asm
;lib_acia_code.asm

;for using the method
;----------------------
;send_rs232_char
;----------------------



;algoritm
;read first char and read second char
;if first char is 255 end
;if second char <32 print first char second char times
;if second char = 255 print first char one time and end
;else all conditions print first char one time
rle_init:
  lda #< rle_data
  sta rleVectorLow
  lda #> rle_data 
  sta rleVectorHigh
  rts

rle_screen:
  lda #< screen_20c_compressed
  sta rleVectorLow
  lda #> screen_20c_compressed
  sta rleVectorHigh
  ;first byte is size
  ldy #$00
  lda (rleVectorLow),y 
  sta rleScreenLines 
rle_screen_cont:  
  ldx #$ff
rle_screen_process_line:
  inx
  cpx rleScreenLines
  beq rle_screen_end
  jsr rle_expand
  jmp rle_screen_process_line
rle_screen_end:
  rts



rle_expand:
  txa 
  pha
  ldy #$00 ;to bypass the first byte of number of lines
rle_expand_loop:
  iny
rle_expand_loop_cont1:  
  lda (rleVectorLow),y  
  cmp #$ff
  beq rle_expand_end
  sta rleChar
  iny
rle_expand_loop_cont2:   
  lda (rleVectorLow),y 
  cmp #$ff
  beq rle_expand_print_one_and_end
  lda (rleVectorLow),y   
  cmp #32
  ;when accumulator is minor that data (do not use bmi)
  bcc rle_expand_several_times
  ;if we are here is just print one time and continue
  lda #$1
  sta rleTimes
  ;print the char
  jsr rle_print_char
  dey ;decrement y as it was a new character there and not times Byte
  jmp rle_expand_loop

rle_expand_several_times:
  sta rleTimes
  ;print the char
  jsr rle_print_char
  jmp rle_expand_loop 
rle_expand_print_one_and_end:
  lda #1
  sta rleTimes
  ;print the char
  jsr rle_print_char
rle_expand_end:
  ;print line feed and carriege return
  jsr send_rs232_CRLF
  tya
  clc
  adc rleVectorLow
  sta rleVectorLow
  bcc rle_expand_end_end
  inc rleVectorHigh
rle_expand_end_end:  
  ;retreive x value for each line
  pla
  tax 
  rts  

rle_print_char:
  pha
  tya
  pha 
  txa
  pha 
  ldx #$0
rle_print_char_loop:
  cpx rleTimes
  beq rle_print_char_end
  txa
  pha 
  lda rleChar
  jsr send_rs232_char   
  pla
  tax
  inx
  jmp rle_print_char_loop
rle_print_char_end:
  pla
  tax
  pla
  tay
  pla
  rts


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------RLE------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
