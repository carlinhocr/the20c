
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
  jsr delay_3_sec
  jsr loadAndPrintBandera
  jsr loadAndPlayHimno10
  jsr delay_3_sec
  jsr delay_3_sec
  jsr delay_3_sec
  jsr SID_STOP
  jsr loadAndPrintTutankamon
  jsr loadAndPlayDesierto40
  jsr delay_3_sec
  jsr delay_3_sec
  jsr delay_3_sec
  jsr SID_STOP
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
  ;jsr loadAndPrintRS232
  jsr loadRetryRS232
  rts

loadAndPrintF1:
  lda #<fileF1
  sta ZP_PTR_LO
  lda #>fileF1
  sta ZP_PTR_HI
  ;jsr loadAndPrint
  jsr loadRetryRS232
  rts

loadAndPrintOsoMatrix:
  lda #<fileOsoMatrix
  sta ZP_PTR_LO
  lda #>fileOsoMatrix
  sta ZP_PTR_HI
  jsr loadRetryRS232
  ;jsr loadAndPrintRS232
  ;jsr loadAndPrint
  rts

loadAndPrintTutankamon:
  lda #<fileTutankamon
  sta ZP_PTR_LO
  lda #>fileTutankamon
  sta ZP_PTR_HI
  jsr loadRetryRS232
  ;jsr loadAndPrintRS232
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
  jsr loadRetry
  ;jsr readFilenameToBuffer
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



;   LOAD_RETRIES = 3
;   retryCount   = $0392      ; 1 byte de RAM libre
;   namePtr      = $0393      ; 2 bytes de RAM libres
 
;------------------------------------------------------------------------------
; loadRetry - carga un archivo por IEC y reintenta si falla
;   Entrada: ZP_PTR_LO/HI = nombre ("0:ARCHIVO,P,R",0)
;            ZP_BufferStartLow/High = destino
;   Salida:  carry = 0 cargó bien (FILE_SIZE_LO/HI = bytes)
;            carry = 1 falló LOAD_RETRIES veces seguidas
;
;   Cómo sabe si anduvo: IEC_STATUS = 0 Y IEC_EOI_FLAG <> 0.
;   IEC_STATUS solo NO alcanza: IEC_READ_FILE termina con IEC_CLOSE_FILE, que
;   pone IEC_STATUS = 0, así que un timeout en el medio de la lectura se borra.
;   IEC_EOI_FLAG queda en $FF solo si llegó el último byte (el que trae EOI).
;   IEC_READ_FILE pisa ZP_PTR (lo usa como puntero al buffer): por eso el
;   nombre se guarda en namePtr y se repone en cada intento.
;------------------------------------------------------------------------------
loadRetry:
  lda ZP_PTR_LO
  sta namePtr
  lda ZP_PTR_HI
  sta namePtr+1
  lda #LOAD_RETRIES
  sta retryCount
.try:
  lda namePtr
  sta ZP_PTR_LO
  lda namePtr+1
  sta ZP_PTR_HI
  jsr IEC_READ_FILE
  lda IEC_STATUS
  bne .fail              ; error al abrir (sin disquetera, etc.)
  lda IEC_EOI_FLAG
  bne .ok                ; $FF = llegó entero
.fail:
  jsr IEC_BUS_IDLE
  lda #200
  jsr DELAY_LONG         ; 200 ms para que la disquetera se reponga
  dec retryCount
  bne .try
  sec                    ; no hubo caso
  rts
.ok:
  clc
  rts
 
loadRetryRS232:
  lda ZP_PTR_LO
  sta namePtr
  lda ZP_PTR_HI
  sta namePtr+1
  lda #LOAD_RETRIES
  sta retryCount
.try:
  lda namePtr
  sta ZP_PTR_LO
  lda namePtr+1
  sta ZP_PTR_HI
  jsr IEC_READ_FILE_TO_RS232
  lda IEC_STATUS
  bne .fail              ; error al abrir (sin disquetera, etc.)
  lda IEC_EOI_FLAG
  bne .ok                ; $FF = llegó entero
.fail:
  jsr IEC_BUS_IDLE
  lda #200
  jsr DELAY_LONG         ; 200 ms para que la disquetera se reponga
  dec retryCount
  bne .try
  sec                    ; no hubo caso
  rts
.ok:
  clc
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