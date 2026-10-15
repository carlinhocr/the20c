
;
  .include "../lib_20c/lib_iec/lib_iec_memory.asm"
  .include "../lib_20c/lib_ascii_banner/lib_ascii_banner_memory.asm"
  .include "../lib_20c/lib_acia/lib_acia_memory.asm" ;define memory address for ACIA
  .include "../lib_20c/lib_utils/lib_utils_memory.asm" ;define memory address for ACIA
  .include "./FlashPartyDemo2026_memory.asm"

  .org $8000
  
  ;initialize RESET, Stack and processor Flags
  .include "../lib_20c/lib_init/lib_init.asm" ;reset vector and stack initialization

  ;Initialize SID & SID VIA1
  sei
  jsr SID_SETUP

  ;Initialize UART for RS-232 Screen
  jsr uartSerialInit
  lda #$0 ;if zero got to screen and not printer
  sta rs232Printer ;so we will go to screen and not printer
  

  ;Initilize IEC disk drive VIA2
  jsr iecInit


 



mainFlashPartyFunction:
  ; cargar el .sid en $4000 por IEC
  ; readFilenameToBuffer de cada gráfico -> $1000, e imprimirlo
  ;sr loadAndPlayVoice
  jsr loadAndPlayHimno 
  jsr loadAndPrintBandera
  jsr delay_3_sec
  jsr loadAndPrintF1
  jsr delay_3_sec

loopFlashParty2026:
  jmp loopFlashParty2026


loadAndPrintBandera:
  lda #<fileBandera
  sta ZP_PTR_LO
  lda #>fileBandera
  sta ZP_PTR_HI
  jsr loadAndPrint
  rts
loadAndPrintF1:
  lda #<fileF1
  sta ZP_PTR_LO
  lda #>fileF1
  sta ZP_PTR_HI
  jsr loadAndPrint
  rts

loadAndPrint:  
  lda #<BUFFER_GRAPHICS_START
  sta ZP_BufferStartLow
  lda #>BUFFER_GRAPHICS_START
  sta ZP_BufferStartHigh  
  jsr readFilenameToBuffer
  jsr printDiskBuffer
  rts

printDiskBuffer:  
  lda ZP_BufferStartLow
  sta serialDataVectorLow
  lda ZP_BufferStartHigh
  sta serialDataVectorHigh
  jsr printAsciiBinary
  rts  

loadAndPlayVoice:
  ; ---- "Hola, soy la 20c" ----
  lda #<fileVoz
  sta ZP_PTR_LO
  lda #>fileVoz
  sta ZP_PTR_HI
  jsr loadAndPlayOnce
  rts

loadAndPlayHimno:
  lda #<fileSoundHimno
  sta ZP_PTR_LO
  lda #>fileSoundHimno
  sta ZP_PTR_HI
  jsr loadAndPlayContinuos
  rts

loadAndPlayOnce:
  jsr loadMusic
  lda #<1                 ; SID_LIMIT = 1: vuelve apenas termina la frase
  sta SID_LIMIT
  lda #>1
  sta SID_LIMIT+1
  lda FILE_SIZE_LO
  ldx FILE_SIZE_HI
  jsr SID_PLAY            ; por polling: nada de IEC mientras habla
  rts

loadAndPlayContinuos:
  jsr loadMusic
  lda #0               ; sin corte (o el límite de frames que quieras)
  sta SID_LIMIT
  sta SID_LIMIT+1
  lda FILE_SIZE_LO
  ldx FILE_SIZE_HI
  jsr SID_START           ; suena de fondo
  rts

loadMusic:                  ; para lo que esté sonando y carga ZP_PTR en $4000
  jsr SID_STOP            ; nunca cargar encima de un tema que está sonando
  lda #<BUFFER_MUSIC_START
  sta ZP_BufferStartLow
  lda #>BUFFER_MUSIC_START
  sta ZP_BufferStartHigh
  jsr readFilenameToBuffer
  rts



playSong10Seconds:  
  lda #<1000              ; frames hasta cortar (0 = no corta)
  sta SID_LIMIT
  lda #>1000
  sta SID_LIMIT+1
  lda #<BUFFER_MUSIC_START
  sta ZP_BufferStartLow
  lda #>BUFFER_MUSIC_START
  sta ZP_BufferStartHigh
  jsr readFilenameToBuffer
  lda FILE_SIZE_LO        ; tamaño que te dejó el IEC
  ldx FILE_SIZE_HI
  jsr SID_PLAY  
  rts

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
  lda #<graph002
  sta (graphTable_LB),y ;stores in $0300 + 2
  iny
  lda #>graph002
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






  .include "../lib_20c/lib_sid/lib_sid_player.asm"

  .org $90A2                                   ; IEC fijo: mismo offset de página que cuando andaba ($82A2)
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
  ;goes to the sid IRQ routine
  rti

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word SID_IRQ
  ;a word is 16 bits or two bytes in this case $fffe and $ffff  