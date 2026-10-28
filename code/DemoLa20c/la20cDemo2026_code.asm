;
  .include "../lib_20c/lib_iec/lib_iec_memory.asm"
  .include "../lib_20c/lib_ascii_banner/lib_ascii_banner_memory.asm"
  .include "../lib_20c/lib_acia/lib_acia_memory.asm" ;define memory address for ACIA
  .include "../lib_20c/lib_utils/lib_utils_memory.asm" ;define memory address for ACIA
  .include "./la20cDemo2026_memory.asm"

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


 


mainLa20cDemo:
  ;cargar primera imagen de ROM
  ;cargar sid de rom y empezar a tocarlo 
  ;jsr loadAndPrintLA20C_lz

  jsr printRomPlacas
  jmp mainLa20cDemo


  ; jsr delay_1_sec
  ; ;start SID from ROM
  ; jsr musicaDesdeROM
  ; ;quienes somos
  ; jsr delay_3_sec
  ; jsr loadAndPrintNOSOTROS_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintBERDYX_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintKRAKATOA_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintVENTILA_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintOSO_lz
  ; ;hablar de la maquina
  ; jsr delay_3_sec
  ; jsr delay_3_sec
  ; jsr loadAndPrintASISI_SID_lz ;quetenemos musica
  ; jsr delay_1_sec
  ; jsr loadAndPrintSID6581_lz  ;pantalla SID
  ; ;y que toda la demo es ASCII puro por RS232
  ; jsr delay_3_sec
  ; jsr delay_3_sec
  ; jsr loadAndPrintPANACIA_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintACIA6551_lz
  ; ;amigos
  ; jsr delay_3_sec
  ; jsr delay_3_sec
  ; jsr loadAndPrintAMIGOS_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintPVM_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintCIRUGRP_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintESPTEC_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintAPIX_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintCAFEC64_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintDIEGO_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintGALAEPI_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintBRINDIS_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintICUY_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintJORGE_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintMODO_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintTECSORO_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintTENO_lz
  ; ;imagen del final 
  ; jsr delay_3_sec
  ; jsr loadAndPrintVOTEN_lz
  ; ;con esto vamos cerrando
  ; jsr delay_3_sec
  ; jsr loadAndPrintHABLO1_lz  
  ; jsr delay_3_sec
  ; jsr loadAndPrintHABLO2_lz
  ; jsr delay_1_sec
  ; jsr loadAndPrintHABLO3_lz 
  ; jsr loadAndPlayHola40 ;aca adentro imprimi HABLO3
loopLa20cDemo:
  jmp loopLa20cDemo

musicaDesdeROM:
  ;start SID from ROM
  lda #0
  sta SID_LIMIT
  sta SID_LIMIT+1
  ldy #$C0
  jsr SID_START_ROM
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

; loadAndPlayVoice:
;   ; ---- "Hola, soy la 20c" ----
;   lda #<fileVoz
;   sta ZP_PTR_LO
;   lda #>fileVoz
;   sta ZP_PTR_HI
;   jsr loadAndPlayOnce
;   rts

; loadAndPlayHimno:
;   lda #<fileSoundHimno
;   sta ZP_PTR_LO
;   lda #>fileSoundHimno
;   sta ZP_PTR_HI
;   jsr loadAndPlayContinuos
;   rts

; loadAndPlayDesierto:
;   lda #<fileSoundDesierto
;   sta ZP_PTR_LO
;   lda #>fileSoundDesierto
;   sta ZP_PTR_HI
;   jsr loadAndPlayContinuos
;   rts


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

; loadAndPlayHola40:         ; ahora desde ROM (ver copyHola40ToRAM)
;   jsr copyHola40ToRAM      ; ROM -> $4000 en ~0,15 s, deja sidSize
;   ldy #$40
;   jsr playSid              ; corta el tema de ROM y arranca la voz en $4000
;   rts

; loadAndPlayHola40Disco:    ; la versión vieja, por IEC
;   lda #<fileHola40
;   ldx #>fileHola40
;   ldy #$40
;   jsr loadSid
;   bcs .noHola
;   ldy #$40
;   jsr playSid
; .noHola
;   rts

; loadAndPlayDesierto40:
;   lda #<fileDesierto40
;   ldx #>fileDesierto40
;   ldy #$40
;   jsr loadSid
;   bcs .noSid                  ; si no cargó, no tocar SID_START_AT
;   ldy #$40
;   jsr playSid
; .noSid  
;   rts

; loadAndPlayDesierto10:
;   lda #<fileDesierto10
;   ldx #>fileDesierto10
;   ldy #$40
;   jsr loadSid
;   ldy #$40
;   jsr playSid
;   rts

; loadAndPlayHimno10:  
;   lda #<fileHimno10
;   ldx #>fileHimno10
;   ldy #$10
;   jsr loadSid
;   ldy #$10
;   jsr playSid          ; corta el de $1000 y arranca el de $4000
;   rts

; loadAndPlayHimno40:  
;   lda #<fileHimno40
;   ldx #>fileHimno40
;   ldy #$40
;   jsr loadSid
;   ldy #$40
;   jsr playSid          ; corta el de $1000 y arranca el de $4000
;   rts

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
  bcs .err                    ; carry = 1: falló
  lda FILE_SIZE_LO
  sta sidSize
  lda FILE_SIZE_HI
  sta sidSize+1
  clc
  rts
.err:
  lda #0
  sta sidSize
  sta sidSize+1
  sta BUFFER_MUSIC_START      ; $4000: borra la "P" de PSID
  sta BUFFER_MUSIC2_START     ; $1000
  sec
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
  ;jsr printFailInfo
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
  ;jsr printFailInfo
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

;------------------------------------------------------------------------------
; HOLA_40.SID en ROM (partido en 3 pedazos, no hay 9 KB seguidos libres)
; copyHola40ToRAM: copia los pedazos uno atrás del otro a $4000 (~0,15 s)
;   y deja sidSize = HOLA40_SIZE. Después se toca igual que si viniera del
;   disco (SID_START_AT parchea $D4xx->$73xx en RAM, nunca toca la ROM).
;   Pisa A, X, Y. Usa romCopySrc/Dst/Len (ZP $D4-$D9).
;   $4000 lo usa lib_lz4: llamarla después de la última pantalla .LZ4.
;------------------------------------------------------------------------------

; romCopy: copia romCopyLen bytes de (romCopySrc) a (romCopyDst).
;   Deja romCopyDst apuntando al byte siguiente al último copiado. Pisa A, X, Y.
romCopy:
  ldy #0
  ldx romCopyLen+1            ; páginas enteras
  beq .tail
.page:
  lda (romCopySrc),y
  sta (romCopyDst),y
  iny
  bne .page
  inc romCopySrc+1
  inc romCopyDst+1
  dex
  bne .page
.tail:
  ldx romCopyLen              ; bytes sueltos (Y = 0 acá)
  beq .done
.rest:
  lda (romCopySrc),y
  sta (romCopyDst),y
  iny
  dex
  bne .rest
  tya                         ; romCopyDst += Y
  clc
  adc romCopyDst
  sta romCopyDst
  bcc .done
  inc romCopyDst+1
.done:
  rts



  .org $90A2                                   ; IEC fijo: mismo offset de página que cuando andaba ($82A2)
  .include "../lib_20c/lib_iec/lib_iec_code.asm"
  ;.include "../lib_20c/lib_ascii_banner/lib_ascii_banner_code.asm"
  .include "../lib_20c/lib_acia/lib_acia_code.asm" ;define code for ACIA t  
  .include "../lib_20c/lib_utils/lib_utils_code.asm" ;define code for ACIA t  
  .include "../lib_20c/lib_lz4/lib_lz4.asm"

  .include "../lib_20c/lib_iec/lib_iec_constants.asm"
  .include "../lib_20c/lib_ascii_banner/lib_ascii_banner_constants.asm"
  .include "../lib_20c/lib_acia/lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "../lib_20c/lib_utils/lib_utils_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "./la20cDemo2026_constants.asm"

  ;------------------------------------------------------------------------------
; printRomLZ - A = byte bajo, X = byte alto de un .LZ4 que está en la ROM.
;   Descomprime a $1000, verifica largo y final ESC[0m,00 e imprime.
;   Sale con carry = 0 si imprimió, 1 si el archivo estaba mal (no imprime).
;   No escribe nada en la ROM: solo lee el .LZ4 desde ahí.
;------------------------------------------------------------------------------
printRomLZ:
  sta romLzPtr
  stx romLzPtr+1
  sta LZ_SRC
  stx LZ_SRC+1
  ldy #1
  lda (LZ_SRC),y                ; largo original, byte alto
  cmp #>LZ_MAX_RAW
  bcc .fits
  jmp .bad                      ; no entra en $1000-$3FFF
.fits:
  ldy #2                        ; LZ_END = dirección + 4 + largo del bloque
  lda (LZ_SRC),y
  clc
  adc #4
  sta LZ_LEN
  iny
  lda (LZ_SRC),y
  adc #0
  sta LZ_LEN+1                  ; LZ_LEN = 4 + bloque (los dos bytes antes de sumar)
  lda LZ_LEN
  clc
  adc romLzPtr
  sta LZ_END
  lda LZ_LEN+1
  adc romLzPtr+1
  sta LZ_END+1
  lda romLzPtr                  ; LZ_SRC = dirección + 4 (el bloque)
  clc
  adc #4
  sta LZ_SRC
  lda romLzPtr+1
  adc #0
  sta LZ_SRC+1
  lda #<LZ_UNPACKED
  sta LZ_DST
  lda #>LZ_UNPACKED
  sta LZ_DST+1
  jsr lz4Decode
  ; ---- verificación: LZ_DST tiene que ser $1000 + largo original ----
  lda romLzPtr
  sta LZ_MATCH
  lda romLzPtr+1
  sta LZ_MATCH+1
  ldy #0
  lda (LZ_MATCH),y
  clc
  adc #<LZ_UNPACKED
  sta LZ_LEN
  iny
  lda (LZ_MATCH),y
  adc #>LZ_UNPACKED
  sta LZ_LEN+1                  ; primero calcular, después comparar (CMP pisa el carry)
  lda LZ_LEN
  cmp LZ_DST
  bne .bad
  lda LZ_LEN+1
  cmp LZ_DST+1
  bne .bad
  ; ---- y que termine en ESC[0m,00 ----
  lda LZ_DST
  sec
  sbc #5
  sta LZ_MATCH
  lda LZ_DST+1
  sbc #0
  sta LZ_MATCH+1
  ldy #4
.tr:
  lda (LZ_MATCH),y
  cmp TRAILER,y
  bne .bad
  dey
  bpl .tr
  lda #<LZ_UNPACKED
  sta serialDataVectorLow
  lda #>LZ_UNPACKED
  sta serialDataVectorHigh
  jsr printAsciiBinaryFast
  clc
  rts
.bad:
  sec
  rts

;------------------------------------------------------------------------------
; printRomPlacas - todas seguidas, 3 s entre cada una (orden: placasRomTabla)
;------------------------------------------------------------------------------

printRomPlacas:
  lda #0
  sta placaRomIndex
.next:
  lda placaRomIndex
  asl
  tay
  lda placasRomTabla,y
  ldx placasRomTabla+1,y
  bne .go                       ; alto = 0 -> fin de la tabla (en ROM nunca es $00xx)
  rts
.go:
  jsr printRomLZ
  bcs .skip
  jsr delay_3_sec
.skip:
  inc placaRomIndex
  jmp .next

; la tabla placasRomTabla está en placas_rom_tabla.asm (lista solo las que metiste en la ROM)

printRomACIA6551:
  lda #<romACIA6551
  ldx #>romACIA6551
  jmp printRomLZ
romACIA6551: .incbin "./media/ACIA6551.LZ4"   ; 1487 bytes

printRomCPU:
  lda #<romCPU
  ldx #>romCPU
  jmp printRomLZ
romCPU: .incbin "./media/CPU6502.LZ4"   ; 1557 bytes
printRomBUS:
  lda #<romBUS
  ldx #>romBUS
  jmp printRomLZ
romBUS: .incbin "./media/BUS.LZ4"   ; 1278 bytes
printRomVIA:
  lda #<romVIA
  ldx #>romVIA
  jmp printRomLZ
romVIA: .incbin "./media/VIA6522.LZ4"   ; 1460 bytes
printRomROMRAM:
  lda #<romROMRAM
  ldx #>romROMRAM
  jmp printRomLZ
romROMRAM: .incbin "./media/ROMRAM.LZ4"   ; 1487 bytes

placasRomTabla:
  .word romCPU, romROMRAM, romBUS, romVIA, romACIA6551
  .word $0000

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