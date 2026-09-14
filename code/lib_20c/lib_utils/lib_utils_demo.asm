  .include "lib_utils_memory.asm" ;define memory address for ACIA

  .include "../lib_acia/lib_acia_memory.asm" ;define memory address for ACIA  

  .org $8000
  .include "../lib_init/lib_init.asm" ;reset vector and stack initialization
 
  jsr uartSerialInit
  lda #$0 ;if zero got to screen and not printer
  sta rs232Printer ;so we will go to screen and not printer



  ;transfer any amount of bytes from one memory area to another
  ;load how many bytes to transfer
  ;example for 256 bytes
  lda #$ff
  sta utilMemoryTransfer_LowByte
  lda #$0
  sta utilMemoryTransfer_HighByte
;
;example for 500 bytes = $01F4
;lda #$F4
;sta utilMemoryTransfer_LowByte
;lda #$01
;sta utilMemoryTransfer_HighByte
;
;now load the memory FROM, for example to copy from ROM $9000
;or modify it for string example
  lda #<memoryTransferExample
  sta utilPivot_01_ZP_low
  lda #>memoryTransferExample
  sta utilPivot_01_ZP_high
;now load the memory TO, for example to copy to RAM $1000
  lda #$00
  sta utilPivot_02_ZP_low
  lda #$10
  sta utilPivot_02_ZP_high
;now run the transfer function
  jsr memoryTransfer  

;lets print from the new copied memory
  lda #$00
  sta serialDataVectorLow
  lda #$10
  sta serialDataVectorHigh
  jsr send_rs232_line  

loop:
  jmp loop

  .include "lib_utils_code.asm" ;define code for Utils
  .include "../lib_acia/lib_acia_code.asm" ;define code for ACIA t  

  .include "lib_utils_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "../lib_acia/lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  

nmi:
irq:
  rti

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff