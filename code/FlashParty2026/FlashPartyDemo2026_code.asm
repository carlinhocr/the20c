
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
  jsr loadAndPrintOsoMatrix
  jsr delay_1_sec
  jsr loadAndPlayHimno10
  jsr delay_1_sec
  jsr loadAndPrintBandera
  jsr delay_3_sec
  ;jsr SID_STOP
  jsr loadAndPlayDesierto40
  ;jsr delay_1_sec
  jsr loadAndPrintTutankamon
  ;jsr loadAndPlayVoice
  ; jsr delay_1_sec
  ; jsr loadAndPlayHimno 
  ; jsr delay_1_sec
  ; jsr loadAndPrintBandera
  jsr delay_3_sec
  jsr loadAndPrintF1
  ; jsr delay_3_sec
  ; jsr delay_3_sec
loopFlashParty2026:
  jmp loopFlashParty2026


loadAndPrintBandera:
  lda #<fileBandera
  sta ZP_PTR_LO
  lda #>fileBandera
  sta ZP_PTR_HI
  jsr loadAndPrintRS232
  rts

loadAndPrintF1:
  lda #<fileF1
  sta ZP_PTR_LO
  lda #>fileF1
  sta ZP_PTR_HI
  jsr loadAndPrint
  rts

loadAndPrintOsoMatrix:
  lda #<fileOsoMatrix
  sta ZP_PTR_LO
  lda #>fileOsoMatrix
  sta ZP_PTR_HI
  jsr loadAndPrintRS232
  ;jsr loadAndPrint
  rts

loadAndPrintTutankamon:
  lda #<fileTutankamon
  sta ZP_PTR_LO
  lda #>fileTutankamon
  sta ZP_PTR_HI
  jsr loadAndPrintRS232
  ;jsr loadAndPrint
  rts  

loadAndPrint:  
  lda #<BUFFER_GRAPHICS_START
  sta ZP_BufferStartLow
  lda #>BUFFER_GRAPHICS_START
  sta ZP_BufferStartHigh  
  jsr readFilenameToBuffer
  jsr printDiskBuffer
  rts

loadAndPrintRS232:  
  jsr readFilenameToRS232
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

loadAndPlayDesierto:
  lda #<fileSoundDesierto
  sta ZP_PTR_LO
  lda #>fileSoundDesierto
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
; ---- Ejemplo: alternar dos slots de música ($1000 y $4000) ------------------
; Constantes de nombres (en FlashPartyDemo2026_constants.asm):
;   fileDes10:   .byte "0:DES60_10.SID,P,R", $00
;   fileHimno40: .byte "0:HIMNO_40.SID,P,R", $00

  ; 1) primer tema en el slot $1000 y a sonar
loadAndPlayDesierto40:
  lda #<fileDesierto40
  ldx #>fileDesierto40
  ldy #$40
  jsr loadSid
  ldy #$40
  jsr playSid
  rts

loadAndPlayHimno10:  
  lda #<fileHimno10
  ldx #>fileHimno10
  ldy #$10
  jsr loadSid
  ldy #$10
  jsr playSid          ; corta el de $1000 y arranca el de $4000
  rts

  ; 4) el siguiente vuelve a $1000 (ya no suena nada ahí), y así...

;------------------------------------------------------------------------------
; loadSid: A/X = nombre del archivo, Y = página del slot ($10 o $40)
loadSid:
  sta ZP_PTR_LO
  stx ZP_PTR_HI
  sty ZP_BufferStartHigh
  lda #0
  sta ZP_BufferStartLow
  jsr readFilenameToBuffer
  lda FILE_SIZE_LO        ; guardo el tamaño: la carga de un gráfico lo pisa
  sta sidSize
  lda FILE_SIZE_HI
  sta sidSize+1
  rts

; playSid: Y = página del slot donde se cargó
playSid:
  lda #0                  ; sin corte (o los frames que quieras)
  sta SID_LIMIT
  sta SID_LIMIT+1
  lda sidSize
  ldx sidSize+1
  jsr SID_START_AT
  rts

sidSize = $0390           ; 2 bytes de RAM libres ($0382/83 ya los usa tu IEC)




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