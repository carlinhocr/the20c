

debugIEC_printROM:
  lda #<la20cAscii
  sta serialDataVectorLow
  lda #>la20cAscii
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

debugIEC_transferToBuffer:
;transfer any amount of bytes from one memory area to another
  ;load how many bytes to transfer
  ;example for 256 bytes
  lda #212
  sta utilMemoryTransfer_LowByte
  lda #10
  sta utilMemoryTransfer_HighByte
  ;now load the memory FROM, for example to copy from ROM $9000
  ;or modify it for string example
  lda #<la20cAscii
  sta utilPivot_01_ZP_low
  lda #>la20cAscii
  sta utilPivot_01_ZP_high
  ;now load the memory TO, for example to copy to RAM $1000
  lda #00
  sta ZP_BufferStartLow
  lda #10
  sta ZP_BufferStartHigh
  lda ZP_BufferStartLow
  sta utilPivot_02_ZP_low
  lda ZP_BufferStartHigh
  sta utilPivot_02_ZP_high
  ;now run the transfer function
  ;jsr memoryTransferFullPagesOnly  
  jsr memoryTransfer 
  lda ZP_BufferStartLow
  sta serialDataVectorLow
  lda ZP_BufferStartHigh
  sta serialDataVectorHigh
  ;jsr delay_3_sec
  jsr printAsciiDrawing
  ;jsr send_rs232_line
  rts


;   lda #$ff
;   sta utilMemoryTransfer_LowByte
;   lda #$0
;   sta utilMemoryTransfer_HighByte
;   ;now load the memory FROM, for example to copy from ROM $9000
;   ;or modify it for string example
;   lda #<la20cAscii
;   sta utilPivot_01_ZP_low
;   lda #>la20cAscii
;   sta utilPivot_01_ZP_high
;   ;now load the memory TO, for example to copy to RAM $1000
;   lda #<BUFFER_START
;   sta utilPivot_02_ZP_low
;   lda #>BUFFER_START
;   sta utilPivot_02_ZP_high
;   ;now run the transfer function
;   ;jsr memoryTransferFullPagesOnly  
;   jsr memoryTransfer_256bytes
;   jsr delay_3_sec