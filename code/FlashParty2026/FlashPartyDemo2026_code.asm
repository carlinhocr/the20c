
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


 


mainFlashParty:
  ;cargar primera imagen de ROM
  ;cargar sid de rom y empezar a tocarlo 
  jsr bannerHola
  ;cargar el resto de los gráficos
  ;jsr delay_3_sec
  jsr loadAndPrintLA20C_lz
  jsr delay_1_sec
  ;start SID from ROM
  jsr musicaDesdeROM
  ;quienes somos
  jsr delay_3_sec
  jsr loadAndPrintNOSOTROS_lz
  jsr delay_1_sec
  jsr loadAndPrintBERDYX_lz
  jsr delay_1_sec
  jsr loadAndPrintKRAKATOA_lz
  jsr delay_1_sec
  jsr loadAndPrintVENTILA_lz
  jsr delay_1_sec
  jsr loadAndPrintOSO_lz
  ;hablar de la maquina
  jsr delay_3_sec
  jsr delay_3_sec
  jsr loadAndPrintASISI_SID_lz ;quetenemos musica
  jsr delay_1_sec
  jsr loadAndPrintSID6581_lz  ;pantalla SID
  ;y que toda la demo es ASCII puro por RS232
  jsr delay_3_sec
  jsr delay_3_sec
  jsr loadAndPrintPANACIA_lz
  jsr delay_1_sec
  jsr loadAndPrintACIA6551_lz
  ;amigos
  jsr delay_3_sec
  jsr delay_3_sec
  jsr loadAndPrintAMIGOS_lz
  jsr delay_1_sec
  jsr loadAndPrintPVM_lz
  jsr delay_1_sec
  jsr loadAndPrintCIRUGRP_lz
  jsr delay_1_sec
  jsr loadAndPrintESPTEC_lz
  jsr delay_1_sec
  jsr loadAndPrintAPIX_lz
  jsr delay_1_sec
  jsr loadAndPrintCAFEC64_lz
  jsr delay_1_sec
  jsr loadAndPrintDIEGO_lz
  jsr delay_1_sec
  jsr loadAndPrintGALAEPI_lz
  jsr delay_1_sec
  jsr loadAndPrintBRINDIS_lz
  jsr delay_1_sec
  jsr loadAndPrintICUY_lz
  jsr delay_1_sec
  jsr loadAndPrintJORGE_lz
  jsr delay_1_sec
  jsr loadAndPrintMODO_lz
  jsr delay_1_sec
  jsr loadAndPrintTECSORO_lz
  jsr delay_1_sec
  jsr loadAndPrintTENO_lz
  ;imagen del final 
  jsr delay_3_sec
  jsr loadAndPrintVOTEN_lz
  ;con esto vamos cerrando
  jsr delay_3_sec
  jsr loadAndPrintHABLO1_lz  
  jsr delay_3_sec
  jsr loadAndPrintHABLO2_lz
  jsr delay_1_sec
  jsr loadAndPlayHola40 ;aca adentro imprimi HABLO3
loopFlashParty2026:
  jmp loopFlashParty2026

musicaDesdeROM:
  ;start SID from ROM
  lda #0
  sta SID_LIMIT
  sta SID_LIMIT+1
  ldy #$C0
  jsr SID_START_ROM
  rts

bannerHola:  
  ;load the alphabet
  lda #<asciiBannerAlphabet_c64
  sta asciiBannerAlphabet_low
  lda #>asciiBannerAlphabet_c64  
  sta asciiBannerAlphabet_high
  ;load the asciiString that will be processed
  jsr send_ansi_reset
  jsr send_ansi_cls
  jsr send_ansi_br_green
  lda #<asciiSHola1
  sta asciiStringZp_low
  lda #>asciiSHola1
  sta asciiStringZp_high
  jsr fillLineRAM
  jsr printLineRAM
  lda #<asciiSHola2
  sta asciiStringZp_low
  lda #>asciiSHola2
  sta asciiStringZp_high
  jsr fillLineRAM
  jsr printLineRAM
  lda #<asciiSHola3
  sta asciiStringZp_low
  lda #>asciiSHola3
  sta asciiStringZp_high
  jsr fillLineRAM
  jsr printLineRAM
  jsr delay_3_sec
  rts

bannerNosotros:
  jsr send_ansi_reset
  jsr send_ansi_cls
  jsr send_ansi_br_green
  lda #<asciiSNosotros1
  sta asciiStringZp_low
  lda #>asciiSNosotros1
  sta asciiStringZp_high
  jsr fillLineRAM
  jsr printLineRAM
  lda #<asciiSNosotros2
  sta asciiStringZp_low
  lda #>asciiSNosotros2
  sta asciiStringZp_high
  jsr fillLineRAM
  jsr printLineRAM
  jsr delay_3_sec
  rts



; ---- cargadores de las pantallas .LZ4 (generado por lz4asm.py) ----
loadAndPrintACIA6551_lz:
  lda #<fileACIA6551_lz
  sta ZP_PTR_LO
  lda #>fileACIA6551_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintAMIGOS_lz:
  lda #<fileAMIGOS_lz
  sta ZP_PTR_LO
  lda #>fileAMIGOS_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintAPIX_lz:
  lda #<fileAPIX_lz
  sta ZP_PTR_LO
  lda #>fileAPIX_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts
  
loadAndPrintASISI_SID_lz:
  lda #<fileASISI_SID_lz
  sta ZP_PTR_LO
  lda #>fileASISI_SID_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintBERDYX_lz:
  lda #<fileBERDYX_lz
  sta ZP_PTR_LO
  lda #>fileBERDYX_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintBRINDIS_lz:
  lda #<fileBRINDIS_lz
  sta ZP_PTR_LO
  lda #>fileBRINDIS_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintCAFEC64_lz:
  lda #<fileCAFEC64_lz
  sta ZP_PTR_LO
  lda #>fileCAFEC64_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintCIRUGRP_lz:
  lda #<fileCIRUGRP_lz
  sta ZP_PTR_LO
  lda #>fileCIRUGRP_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintCPU6502_lz:
  lda #<fileCPU6502_lz
  sta ZP_PTR_LO
  lda #>fileCPU6502_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintDIEGO_lz:
  lda #<fileDIEGO_lz
  sta ZP_PTR_LO
  lda #>fileDIEGO_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintESPTEC_lz:
  lda #<fileESPTEC_lz
  sta ZP_PTR_LO
  lda #>fileESPTEC_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintGALAEPI_lz:
  lda #<fileGALAEPI_lz
  sta ZP_PTR_LO
  lda #>fileGALAEPI_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintHABLO1_lz:
  lda #<fileHABLO1_lz
  sta ZP_PTR_LO
  lda #>fileHABLO1_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts  

loadAndPrintHABLO2_lz:
  lda #<fileHABLO2_lz
  sta ZP_PTR_LO
  lda #>fileHABLO2_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts  

loadAndPrintHABLO3_lz:
  lda #<fileHABLO3_lz
  sta ZP_PTR_LO
  lda #>fileHABLO3_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts  

loadAndPrintICUY_lz:
  lda #<fileICUY_lz
  sta ZP_PTR_LO
  lda #>fileICUY_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintJORGE_lz:
  lda #<fileJORGE_lz
  sta ZP_PTR_LO
  lda #>fileJORGE_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintKRAKATOA_lz:
  lda #<fileKRAKATOA_lz
  sta ZP_PTR_LO
  lda #>fileKRAKATOA_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintLA20C_lz:
  lda #<fileLA20C_lz
  sta ZP_PTR_LO
  lda #>fileLA20C_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintMODO_lz:
  lda #<fileMODO_lz
  sta ZP_PTR_LO
  lda #>fileMODO_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintNOSOTROS_lz:
  lda #<fileNOSOTROS_lz
  sta ZP_PTR_LO
  lda #>fileNOSOTROS_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintOSO_lz:
  lda #<fileOSO_lz
  sta ZP_PTR_LO
  lda #>fileOSO_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintOSOLABS_lz:
  lda #<fileOSOLABS_lz
  sta ZP_PTR_LO
  lda #>fileOSOLABS_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintPANACIA_lz:
  lda #<filePANACIA_lz
  sta ZP_PTR_LO
  lda #>filePANACIA_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintPVM_lz:
  lda #<filePVM_lz
  sta ZP_PTR_LO
  lda #>filePVM_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintSID6581_lz:
  lda #<fileSID6581_lz
  sta ZP_PTR_LO
  lda #>fileSID6581_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintTECSORO_lz:
  lda #<fileTECSORO_lz
  sta ZP_PTR_LO
  lda #>fileTECSORO_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintTENO_lz:
  lda #<fileTENO_lz
  sta ZP_PTR_LO
  lda #>fileTENO_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintVENTILA_lz:
  lda #<fileVENTILA_lz
  sta ZP_PTR_LO
  lda #>fileVENTILA_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts

loadAndPrintVOTEN_lz:
  lda #<fileVOTEN_lz
  sta ZP_PTR_LO
  lda #>fileVOTEN_lz
  sta ZP_PTR_HI
  jsr loadRetryAndPrintLZ
  rts


  
; loadAndPrintBandera:
;   lda #<fileBandera
;   sta ZP_PTR_LO
;   lda #>fileBandera
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts

; loadAndPrintICUY:
;   lda #<fileICUY
;   sta ZP_PTR_LO
;   lda #>fileICUY
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts

; loadAndPrintBerdyx:
;   lda #<fileBerdyx
;   sta ZP_PTR_LO
;   lda #>fileBerdyx
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts

; loadAndPrintESPTEC:
;   lda #<fileESPTEC
;   sta ZP_PTR_LO
;   lda #>fileESPTEC
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts

; loadAndPrintKRAKATOA:
;   lda #<fileKRAKATOA
;   sta ZP_PTR_LO
;   lda #>fileKRAKATOA
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts    




; loadAndPrintLA20c:
;   lda #<fileLA20C
;   sta ZP_PTR_LO
;   lda #>fileLA20C
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts

; loadAndPrintMODO:
;   lda #<fileMODO
;   sta ZP_PTR_LO
;   lda #>fileMODO
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts

; loadAndPrintOSO:
;   lda #<fileOSO
;   sta ZP_PTR_LO
;   lda #>fileOSO
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts

; loadAndPrintPVM:
;   lda #<filePVM
;   sta ZP_PTR_LO
;   lda #>filePVM
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts

; loadAndPrintVENTILA:
;   lda #<fileVENTILA
;   sta ZP_PTR_LO
;   lda #>fileVENTILA
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts      

; loadAndPrintOSOLABS:
;   lda #<fileOSOLABS
;   sta ZP_PTR_LO
;   lda #>fileOSOLABS
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   rts     




; loadAndPrintF1:
;   lda #<fileF1
;   sta ZP_PTR_LO
;   lda #>fileF1
;   sta ZP_PTR_HI
;   ;jsr loadAndPrint
;   jsr loadRetryRS232
;   rts

; loadAndPrintOsoMatrix:
;   lda #<fileOsoMatrix
;   sta ZP_PTR_LO
;   lda #>fileOsoMatrix
;   sta ZP_PTR_HI
;   jsr loadRetryAndPrint
;   ;jsr loadRetryRS232
;   ;jsr loadAndPrintRS232
;   ;jsr loadAndPrint
;   rts

loadAndPrintTutankamon:
  lda #<fileTutankamon
  sta ZP_PTR_LO
  lda #>fileTutankamon
  sta ZP_PTR_HI
  jsr loadRetryRS232
  ;jsr loadAndPrintRS232
  ;jsr loadAndPrint
  rts  

loadRetryAndPrint:  
  lda #<BUFFER_GRAPHICS_START
  sta ZP_BufferStartLow
  lda #>BUFFER_GRAPHICS_START
  sta ZP_BufferStartHigh  
  lda #1
  sta checkTrailer      
  jsr loadRetry
  jsr printDiskBuffer
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
  ;jsr printAsciiBinary
  jsr printAsciiBinaryFast
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

loadAndPlayHola40:  
  lda #<fileHola40
  ldx #>fileHola40
  ldy #$40
  jsr loadSid
  jsr loadAndPrintHABLO3_lz
  ldy #$40
  jsr playSid          ; corta el de $1000 y arranca el de $4000
  rts  

loadAndPlayDesierto40:
  lda #<fileDesierto40
  ldx #>fileDesierto40
  ldy #$40
  jsr loadSid
  ldy #$40
  jsr playSid
  rts

loadAndPlayDesierto10:
  lda #<fileDesierto10
  ldx #>fileDesierto10
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

loadAndPlayHimno40:  
  lda #<fileHimno40
  ldx #>fileHimno40
  ldy #$40
  jsr loadSid
  ldy #$40
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
  sta checkTrailer
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


; animationDNAASCII:
;   txa
;   pha
;   ldx #$00
; .loop  
;   inx ;cuando llega a cero el beq sale del loop
;   beq .end
;   lda #<dnaAscii
;   sta serialDataVectorLow
;   lda #>dnaAscii
;   sta serialDataVectorHigh
;   jsr printAsciiDrawing
;   inx
;   jmp .loop
; .end
;   pla
;   tax
;   rts

; Agregá a FlashPartyDemo2026_memory.asm:
;   LOAD_RETRIES = 3
;   retryCount   = $0392      ; 1 byte de RAM libre
;   namePtr      = $0393      ; 2 bytes de RAM libres
;   driveStatus  = $03A0      ; 48 bytes: mensaje del canal 15
 
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
  lda #100
  jsr DELAY_LONG          ; 100 ms: que el SD2IEC 
  lda namePtr
  sta ZP_PTR_LO
  lda namePtr+1
  sta ZP_PTR_HI
  jsr IEC_READ_FILE
  lda IEC_STATUS
  bne .fail              ; error al abrir (sin disquetera, etc.)
  lda IEC_EOI_FLAG
  beq .fail
  lda checkTrailer       ; 0 = .sid, 1 = gráfico .BIN, 2 = gráfico .LZ4
  beq .ok
  cmp #2
  bne .trailer
  jsr lzCheckSize        ; .LZ4: llegaron todos los bytes que dice el header?
  bcc .ok
  bcs .fail
.trailer:
  lda TR_MATCH
  cmp #TRAILER_LEN
  beq .ok
.fail:
  jsr printFailInfo
  jsr IEC_BUS_IDLE       ; suelto todo
  lda #250
  jsr DELAY_LONG
  jsr IEC_UNTALK         ; si quedó hablando, que se calle
  jsr IEC_UNLISTEN       ; y que nadie quede escuchando
  lda #250
  jsr DELAY_LONG         ; medio segundo en total para que se reponga
  jsr readDriveStatus    ; recién ahí el canal 15
  lda #<driveStatus
  sta serialDataVectorLow
  lda #>driveStatus
  sta serialDataVectorHigh
  jsr send_rs232_line
  dec retryCount
  bne .try
  sec
  rts
.ok:
  clc
  rts
 
;------------------------------------------------------------------------------
; readDriveStatus - lee el canal de errores (15) de la disquetera / SD2IEC.
;   Deja "nn,MENSAJE,tt,ss",0 en driveStatus (ej. "62,FILE NOT FOUND,00,00").
;   Leerlo es lo que apaga la luz que parpadea. No toca ZP_BufferStart.
;------------------------------------------------------------------------------
readDriveStatus:
  lda ZP_BufferStartLow
  pha
  lda ZP_BufferStartHigh
  pha
  lda #<driveStatus
  sta ZP_BufferStartLow
  lda #>driveStatus
  sta ZP_BufferStartHigh
  jsr IEC_READ_STATUS
  pla
  sta ZP_BufferStartHigh
  pla
  sta ZP_BufferStartLow
  rts
 
 
loadRetryRS232:
  lda ZP_PTR_LO
  sta namePtr
  lda ZP_PTR_HI
  sta namePtr+1
  lda #LOAD_RETRIES
  sta retryCount
.try:
  lda #100
  jsr DELAY_LONG          ; 100 ms: que el SD2IEC 
  lda namePtr
  sta ZP_PTR_LO
  lda namePtr+1
  sta ZP_PTR_HI
  jsr IEC_READ_FILE_TO_RS232
  lda IEC_STATUS
  bne .fail
  lda IEC_EOI_FLAG
  beq .fail
  lda TR_MATCH
  cmp #TRAILER_LEN       ; ¿llegó el final ESC[0m,00?
  beq .ok
.fail:
  jsr printFailInfo
  jsr IEC_BUS_IDLE       ; suelto todo
  lda #250
  jsr DELAY_LONG
  jsr IEC_UNTALK         ; si quedó hablando, que se calle
  jsr IEC_UNLISTEN       ; y que nadie quede escuchando
  lda #250
  jsr DELAY_LONG         ; medio segundo en total para que se reponga
  jsr readDriveStatus    ; recién ahí el canal 15
  lda #<driveStatus
  sta serialDataVectorLow
  lda #>driveStatus
  sta serialDataVectorHigh
  jsr send_rs232_line
  dec retryCount
  bne .try
  sec
  rts
.ok:
  clc
  rts  

;------------------------------------------------------------------------------
; printFailInfo - imprime por RS232 qué vio el driver al fallar una carga:
;     ST=$xx EOI=$xx BYTES=$xxxx
;   ST    = IEC_STATUS   ($02 timeout al recibir, $03 sin ACK/RFD al mandar,
;                         $04 buffer lleno, $80 no hay disquetera)
;   EOI   = IEC_EOI_FLAG ($FF = llegó el último byte)
;   BYTES = FILE_SIZE    (cuántos bytes llegaron antes del corte)
; Llamala en .fail ANTES de readDriveStatus (que pisa IEC_STATUS y FILE_SIZE).
; Usa send_rs232_char (A = carácter).
;------------------------------------------------------------------------------
printFailInfo:
  lda IEC_STATUS          ; copio todo antes de imprimir
  sta failSt
  lda IEC_EOI_FLAG
  sta failEoi
  lda FILE_SIZE_LO
  sta failSize
  lda FILE_SIZE_HI
  sta failSize+1
  jsr send_rs232_CRLF
  ldx #0
.t1:
  lda txtSt,x
  beq .v1
  jsr pfiChar
  inx
  bne .t1
.v1:
  lda failSt
  jsr pfiHex
  ldx #0
.t2:
  lda txtEoi,x
  beq .v2
  jsr pfiChar
  inx
  bne .t2
.v2:
  lda failEoi
  jsr pfiHex
  ldx #0
.t3:
  lda txtBytes,x
  beq .v3
  jsr pfiChar
  inx
  bne .t3
.v3:
  lda failSize+1
  jsr pfiHex
  lda failSize
  jsr pfiHex
  jsr send_rs232_CRLF
  rts
 
pfiHex:                   ; A en hexa (2 caracteres)
  pha
  lsr
  lsr
  lsr
  lsr
  jsr .nib
  pla
  and #$0f
.nib:
  cmp #10
  bcc .dig
  adc #6
.dig:
  adc #'0'
pfiChar:                  ; send_rs232_char guardando X e Y
  pha
  txa
  pha
  tya
  pha
  tsx
  lda $0103,x             ; el carácter que guardé primero
  jsr send_rs232_char
  pla
  tay
  pla
  tax
  pla
  rts
 
; txtSt:    .byte "ST=$",0
; txtEoi:   .byte " EOI=$",0
; txtBytes: .byte " BYTES=$",0
; failSt       = $0395
; failEoi      = $0396
; failSize     = $0397         ; 2 bytes
 
  
; =============================================================================
;  sid_rom.asm - tocar un tema que está en ROM (sin copiar ni parchear)
;  Va después de lib_sid_player.asm (usa SID_HALT, TIMER_ON, call_init, etc.)
;
;  El tema tiene que estar armado para ROM (SID_ROM=1): escribe directo al SID
;  de la 20c ($7300) y sus variables están en RAM. Ejemplo: NAVES_C0.SID en $C000.
;
;      ldy #$C0            ; página donde está el .sid en la ROM
;      jsr SID_START_ROM   ; suena por IRQ (igual que SID_START)
;
;  No escribe NADA en la zona del tema: con una EEPROM con /WE conectado, un
;  SID_START_AT común intentaría "copiar" y "parchear" sobre la ROM.
; =============================================================================
SID_START_ROM:
    php
    sei
    sty SID_BASE+1
    lda #0
    sta SID_BASE+0
    jsr SID_HALT                    ; apaga el tema anterior
    lda #0
    sta SID_FRAMES+0
    sta SID_FRAMES+1
    ldy #H_STARTSONG+1
    lda (SID_BASE),y
    sec
    sbc #1
    sta song_no
    ldy #H_INITADDR+1               ; vectores (big-endian en el header)
    lda (SID_BASE),y
    sta init_vec+0
    dey
    lda (SID_BASE),y
    sta init_vec+1
    ldy #H_PLAYADDR+1
    lda (SID_BASE),y
    sta play_vec+0
    dey
    lda (SID_BASE),y
    sta play_vec+1
    lda song_no
    ldx #0
    ldy #0
    jsr call_init
    jsr TIMER_ON
    lda #%11000000                  ; IRQ del T1
    sta VIA_IER
    lda #1
    sta SID_BUSY
    plp
    cli
    rts



  .include "../lib_20c/lib_sid/lib_sid_player.asm"

  .org $90A2                                   ; IEC fijo: mismo offset de página que cuando andaba ($82A2)
  .include "../lib_20c/lib_iec/lib_iec_code.asm"
  .include "../lib_20c/lib_ascii_banner/lib_ascii_banner_code.asm"
  .include "../lib_20c/lib_acia/lib_acia_code.asm" ;define code for ACIA t  
  .include "../lib_20c/lib_utils/lib_utils_code.asm" ;define code for ACIA t  
  .include "../lib_20c/lib_lz4/lib_lz4.asm"

  .include "../lib_20c/lib_iec/lib_iec_constants.asm"
  .include "../lib_20c/lib_ascii_banner/lib_ascii_banner_constants.asm"
  .include "../lib_20c/lib_acia/lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "../lib_20c/lib_utils/lib_utils_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "./FlashPartyDemo2026_constants.asm"

  .org $C000
    .incbin "../FlashParty2026/media/CARNAV_C0.SID"
    ;.include "../FlashParty2026/media/DNASCII.asm"

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