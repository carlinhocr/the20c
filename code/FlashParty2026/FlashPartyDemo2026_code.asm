
;
  .include "../lib_20c/lib_iec/lib_iec_memory.asm"
  .include "../lib_20c/lib_ascii_banner/lib_ascii_banner_memory.asm"
  .include "../lib_20c/lib_acia/lib_acia_memory.asm" ;define memory address for ACIA
  .include "../lib_20c/lib_utils/lib_utils_memory.asm" ;define memory address for ACIA
  .include "./FlashPartyDemo2026_memory.asm"

  .org $8000
  
  ;initialize RESET, Stack and processor Flags
  .include "../lib_20c/lib_init/lib_init.asm" ;reset vector and stack initialization

  ;Initialize UART for RS-232 Screen
  jsr uartSerialInit
  lda #$0 ;if zero got to screen and not printer
  sta rs232Printer ;so we will go to screen and not printer

  ;Initilize IEC disk drive
  jsr iecInit


mainFlashPartyFunction:
;STRUCTURE to show ASCII messages

;01 load buffer from GRAPH001

;02 show buffer

;03 load music from MUSIC001

;04 play music

;05 load buffer from GRAPH002 (still we do not show it)

;06 wait for music ends

;REPEAT from STEP 02


populate_GRAPH_Table:
  ;to populate the table you have to write to each byte
  ;to read the table you have to skip bytes
  ;set the contens of the zero page variables $d2 and $d3 to 00 03 or the address $0300
  lda #<graphTable
  sta graphTable_LB
  lda #>graphTable
  sta graphTable_HB
  ;now pivot on the graphTable_LB using the Y index register to store
  ;starting on address $3000
  ldy #$00
  lda #<graph001
  sta (graphTable_LB),y ;stores in $0300 + 0
  iny
  lda #>graph001
  sta (graphTable_LB),y ;stores in $0300 + 1
  iny
  ;go to populate the table with file2
  lda #<graph001
  sta (graphTable_LB),y ;stores in $0300 + 2
  iny
  lda #>graph001
  sta (graphTable_LB),y ;stores in $0300 + 3
  iny

read_GRAPH_Table:
  ;to populate the table you have to write to each byte
  ;to read the table you have to skip bytes
  ;set the contens of the zero page variables $d2 and $d3 to 00 03 or the address $0300
  lda #<graphTable
  sta graphTable_LB
  lda #>graphTable
  sta graphTable_HB
  ;read the table
  ldy #$00
  ;lets imagine we will read three files
read_GRAPH_Table_Loop:  
  cpy #$03
  beq read_GRAPH_Table_End
  ;load the file name
  lda (graphTable_LB),y ;reads from $0300 + 0
  sta ZP_PTR_LO
  iny 
  lda (graphTable_LB),y ;reads from $0300 + 0
  sta ZP_PTR_HI

  jsr readFilenameToBuffer

  ;now we have the file contents in the buffer
  ;we can print, whatever we want
   
  ;we go to the next File 
  jmp read_GRAPH_Table_Loop

read_GRAPH_Table_End:
  ;it continues for each file
  rts







  .include "../lib_20c/lib_iec/lib_iec_code.asm"
  .include "../lib_20c/lib_ascii_banner/lib_ascii_banner_code.asm"
  .include "../lib_20c/lib_acia/lib_acia_code.asm" ;define code for ACIA t  
  .include "../lib_20c/lib_utils/lib_utils_code.asm" ;define code for ACIA t  
  .include "../lib_20c/lib_iec/lib_iec_constants.asm"
  .include "../lib_20c/lib_ascii_banner/lib_ascii_banner_constants.asm"
  .include "../lib_20c/lib_acia/lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "../lib_20c/lib_utils/lib_utils_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "./FlashPartyDemo2026_constants.asm"

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