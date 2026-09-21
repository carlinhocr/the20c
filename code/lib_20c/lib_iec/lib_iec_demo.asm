;DEMO for the IEC library
;
;PART 1 SAVE FILE
;define an area in memory (RAM or ROM)
;define the number of bytes to copy (16 bits)
;get FILENAME, DEVICE
;save a file with that content to disk.
;
;PART 2 LOAD FILE
;define an area in memory RAM
;load the file to that area
;
;PART 3 DELETE A FILE
;
;
  .include "lib_iec_memory.asm"
  .include "../lib_acia/lib_acia_memory.asm" ;define memory address for ACIA
  .include "../lib_utils/lib_utils_memory.asm" ;define memory address for ACIA

  .org $8000
  .include "../lib_init/lib_init.asm" ;reset vector and stack initialization

  jsr uartSerialInit
  lda #$0 ;if zero got to screen and not printer
  sta rs232Printer ;so we will go to screen and not printer

  lda #<messageIECStart
  sta serialDataVectorLow
  lda #>messageIECStart
  sta serialDataVectorHigh
  jsr send_rs232_line

  jsr iecInit


;   lda #<messageRunningMainDemo
;   sta serialDataVectorLow
;   lda #>messageRunningMainDemo
;   sta serialDataVectorHigh
;   jsr send_rs232_line  

;   jsr mainIECDemo

  lda #<messageRunningAsciiDemo
  sta serialDataVectorLow
  lda #>messageRunningAsciiDemo
  sta serialDataVectorHigh
  jsr send_rs232_line   
 
  jsr writeAsciiFromROM
   
loop:
  jmp loop  

writeAsciiFromROM:

  ;===================================================================
  ; DEMO 2: WRITE DATA FROM ROM TO RAM and then TO A DISK FILE
  ;===================================================================
  ;
  ; To write a file, we:
  ;   1. copy the data from a ROM constant to BUFFER_START using lib_util
  ;   2. call writeAsciiFromRAM
  ;

  ;transfer any amount of bytes from one memory area to another
  ;load how many bytes to transfer
  ;example for 256 bytes
  lda #$ff
  sta utilMemoryTransfer_LowByte
  lda #$A
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
  jsr memoryTransfer  
  jsr writeFileFromRAM
  rts


  .include "lib_iec_code.asm"
  ;.include "lib_ascii_banner_debug.asm"
  .include "../lib_acia/lib_acia_code.asm" ;define code for ACIA t  
  .include "../lib_utils/lib_utils_code.asm" ;define code for ACIA t  
  .include "lib_iec_constants.asm"
  .include "../lib_acia/lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "../lib_utils/lib_utils_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  

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