

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
  lda #$ff
  sta utilMemoryTransfer_LowByte
  lda #$2
  sta utilMemoryTransfer_HighByte
  ;now load the memory FROM, for example to copy from ROM $9000
  ;or modify it for string example
  lda #<la20cAscii
  sta utilPivot_01_ZP_low
  lda #>la20cAscii
  sta utilPivot_01_ZP_high
  ;now load the memory TO, for example to copy to RAM $1000
  lda #<BUFFER_START
  sta utilPivot_02_ZP_low
  lda #>BUFFER_START
  sta utilPivot_02_ZP_high
  ;now run the transfer function
  ;jsr memoryTransferFullPagesOnly  
  jsr memoryTransferFullPagesOnly
  lda #<BUFFER_START
  sta serialDataVectorLow
  lda #>BUFFER_START
  sta serialDataVectorHigh
  jsr delay_3_sec
  jsr printAsciiDrawing
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