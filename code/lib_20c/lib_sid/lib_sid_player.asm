; ============================================================================
;  LIB_SID_PLAYER.ASM  v3  -  PSID player para la "20c" (6502 + SID 6581 @ $7300)
;  v3: VIA1 $7100 dedicado a la música (IRQ del T1). SID_PLAY por polling,
;      SID_START por IRQ, SID_SETUP con puertos como entradas.
;  Librería: tu programa carga el .sid con el driver IEC en SIDFILE ($4000)
;  y llama a SID_PLAY (bloqueante) o SID_START (en segundo plano).
; ----------------------------------------------------------------------------
;  Sintaxis: vasm6502_oldstyle
;
;  AL ARRANCAR TU PROGRAMA (una vez, antes de habilitar IRQs):
;      jsr SID_SETUP           ; deja el VIA $7100 y el SID quietos y en silencio
;
;  USO (bloqueante: vuelve a tu programa cuando termina el tema):
;      ; ... tu IEC carga el .sid en $4000 y deja el tamaño en FILE_SIZE_LO/HI
;      lda #<1000              ; cortar a los 1000 frames (20 s). 0 = sin corte
;      sta SID_LIMIT
;      lda #>1000
;      sta SID_LIMIT+1
;      lda FILE_SIZE_LO        ; A = tamaño del archivo (low)
;      ldx FILE_SIZE_HI        ; X = tamaño del archivo (high)
;      jsr SID_PLAY            ; vuelve con carry=0 al terminar, carry=1 si no es PSID
;      ; ... seguís con tu programa: cargar otra canción, etc.
;
;  SID_PLAY NO usa interrupciones (hace polling del T1): anda aunque la IRQ
;  del VIA no llegue a la CPU.
;
;  USO (en segundo plano, ESTE SÍ necesita la IRQ del VIA $7100 en la CPU):
;      jsr SID_START           ; mismos parámetros; vuelve enseguida, suena por IRQ
;      ...                     ; SID_BUSY <> 0 mientras suena
;      ...                     ; SID_FRAMES / SID_FRAMES+1 = frames tocados
;      jsr SID_STOP            ; corta cuando quieras
;
;  Requisitos:
;   - Solo para SID_START: el vector de IRQ ($FFFE) tiene que apuntar a SID_IRQ
;     y la salida IRQ del VIA $7100 tiene que llegar a la pata IRQ de la CPU.
;   - Para cargar por IEC con la música sonando usá lib_iec_code.asm v29
;     (tiene los PHP/SEI ... PLP en las partes con tiempos del bus).
;     Con la v28 o anterior, cargá con la música parada (SID_STOP).
;   - Temas "en el lugar": si la dirección de carga del PSID es SIDFILE+$7E
;     el tema corre donde lo cargaste y la copia no mueve nada. Si la dirección
;     de carga es otra, se copia ahí (ascendente: el destino tiene que estar
;     DEBAJO del archivo o no solaparse).
; ============================================================================

; ---------------------------------------------------------------- CONFIG ----
SIDFILE     = $4000                 ; donde tu IEC deja el .sid ($4000-$6FFF)
SID         = $7300                 ; 6581 real en la 20c
SIDPAGE     = $D4                   ; página que escribe el tema (se parchea)
SIDREG_MAX  = $1C                   ; último registro válido del SID

VIA         = $7100                 ; VIA1: solo música (el IEC usa el VIA2 de $7200)
VIA_DDRB    = VIA+$02
VIA_DDRA    = VIA+$03
VIA_T1CL    = VIA+$04
VIA_T1CH    = VIA+$05
VIA_T1LL    = VIA+$06
VIA_T1LH    = VIA+$07
VIA_ORB     = VIA+$00
VIA_ORA     = VIA+$01
VIA_ACR     = VIA+$0B
VIA_PCR     = VIA+$0C
VIA_IFR     = VIA+$0D
VIA_IER     = VIA+$0E

VIA_PORT_DDR = $00                  ; puertos A/B del VIA de música: $00 = entradas (no maneja
                                    ; ninguna pata). Ponelo en $FF solo si PA/PB no van a nada
                                    ; o van a cosas que esperan salidas.
CPUCLK_KHZ  = 1000                  ; <-- clock de la CPU en kHz (1000 = 1 MHz)
T1_LATCH    = (CPUCLK_KHZ * 20) - 2 ; T1 libre: ~50 Hz

; ---- página cero: $10-$1F (el driver IEC usa $00-$09) ----------------------
zp_src      = $10                   ; 16 bits: origen / puntero de escaneo
zp_dst      = $12                   ; 16 bits: destino de la copia
zp_len      = $14                   ; 16 bits: cantidad de bytes
init_vec    = $16                   ; init del tema (del header PSID)
play_vec    = $18                   ; play del tema (del header PSID)
SID_FRAMES  = $1A                   ; 16 bits: frames de 50 Hz tocados (lo,hi)
SID_LIMIT   = $1C                   ; 16 bits: corta al llegar acá. 0 = sin corte
SID_BUSY    = $1E                   ; <> 0 mientras suena
song_no     = $1F                   ; canción del PSID (0 = la primera)

; ---- campos del header PSID (los de 16 bits son BIG-ENDIAN) ----------------
H_MAGIC     = SIDFILE+$00
H_DATAOFF   = SIDFILE+$06
H_LOADADDR  = SIDFILE+$08
H_INITADDR  = SIDFILE+$0A
H_PLAYADDR  = SIDFILE+$0C
H_STARTSONG = SIDFILE+$10

; ============================================================================
;  SID_PLAY  -  A/X = tamaño del archivo. Toca hasta SID_LIMIT frames y vuelve.
;  Funciona POR POLLING del flag del T1 (IFR bit 6) con las IRQ deshabilitadas:
;  no necesita que la línea IRQ del VIA llegue a la CPU, y las IRQ de otros
;  chips (ACIA, VIA del IEC) no lo molestan mientras suena.
;  Con SID_LIMIT = 0 no vuelve nunca.
;  Sale con carry=1 si el archivo no es PSID/RSID.
; ============================================================================
SID_PLAY:
    php
    sei
    jsr SID_LOAD                    ; parsea, copia, parchea, init
    bcs .bad
    jsr TIMER_ON                    ; T1 libre a 50 Hz...
    lda #%01000000
    sta VIA_IER                     ; ...pero SIN IRQ: lo miramos a mano
    lda #1
    sta SID_BUSY
.poll:
    lda VIA_IFR
    and #%01000000                  ; ¿venció el T1?
    beq .poll
    lda VIA_T1CL                    ; baja el flag
    jsr SID_TICK                    ; play + cuenta; carry=1 al llegar al límite
    bcc .poll
    jsr SID_HALT
    plp
    clc
    rts
.bad:
    plp
    sec
    rts

; ============================================================================
;  SID_START  -  A/X = tamaño del archivo cargado en SIDFILE.
;  Parsea el header, copia/parchea, llama a init, arranca el T1 y vuelve.
;  carry=0 OK (ya está sonando) / carry=1 no es PSID/RSID.
; ============================================================================
SID_START:
    php
    sei
    jsr SID_LOAD
    bcs .bad
    jsr TIMER_ON
    lda #%11000000                  ; IER: habilita la IRQ del T1
    sta VIA_IER
    lda #1
    sta SID_BUSY
    plp                             ; recupera el estado de I de quien llamó...
    cli                             ; ...pero la música necesita las IRQ
    clc
    rts
.bad:
    plp
    sec
    rts

; ---- SID_LOAD: A/X = tamaño. Header, copia, parcheo, init. carry=1 si no es PSID
SID_LOAD:
    sta zp_len+0                    ; guardo el tamaño mientras tanto
    stx zp_len+1
    lda #0
    sta SID_BUSY
    sta SID_FRAMES+0
    sta SID_FRAMES+1

    lda H_MAGIC+0
    cmp #'P'
    beq .magic_ok
    cmp #'R'                        ; RSID también
    bne .badmagic
.magic_ok:
    lda H_MAGIC+1
    cmp #'S'
    bne .badmagic
    lda H_MAGIC+2
    cmp #'I'
    bne .badmagic
    lda H_MAGIC+3
    cmp #'D'
    beq .hdr_ok
.badmagic:
    sec
    rts
.hdr_ok:
    lda H_STARTSONG+1               ; canción 0-based
    sec
    sbc #1
    sta song_no

    ; src = SIDFILE + dataOffset
    clc
    lda #<(SIDFILE)
    adc H_DATAOFF+1
    sta zp_src
    lda #>(SIDFILE)
    adc H_DATAOFF+0
    sta zp_src+1

    ; vectores init / play (big-endian en el header)
    lda H_INITADDR+1
    sta init_vec+0
    lda H_INITADDR+0
    sta init_vec+1
    lda H_PLAYADDR+1
    sta play_vec+0
    lda H_PLAYADDR+0
    sta play_vec+1

    ; dirección de carga
    lda H_LOADADDR+0
    ora H_LOADADDR+1
    bne .hdr_load
    ldy #0                          ; viene en los 2 primeros bytes de los datos
    lda (zp_src),y
    sta zp_dst+0
    iny
    lda (zp_src),y
    sta zp_dst+1
    clc
    lda zp_src
    adc #2
    sta zp_src
    lda zp_src+1
    adc #0
    sta zp_src+1
    jmp .have_dst
.hdr_load:
    lda H_LOADADDR+1
    sta zp_dst+0
    lda H_LOADADDR+0
    sta zp_dst+1
.have_dst:
    ; len = (SIDFILE + tamaño) - src
    clc
    lda zp_len+0
    adc #<(SIDFILE)
    sta zp_len+0
    lda zp_len+1
    adc #>(SIDFILE)
    sta zp_len+1
    sec
    lda zp_len+0
    sbc zp_src+0
    sta zp_len+0
    lda zp_len+1
    sbc zp_src+1
    sta zp_len+1

    ; guardo el destino para el parcheo (la copia avanza zp_dst+1)
    lda zp_dst+1
    pha
    lda zp_dst+0
    pha

    ; copia ascendente len bytes (zp_src)->(zp_dst). Si dst = src no cambia nada.
    ldy #0
    ldx zp_len+1
    beq .cp_rem
.cp_page:
    lda (zp_src),y
    sta (zp_dst),y
    iny
    bne .cp_page
    inc zp_src+1
    inc zp_dst+1
    dex
    bne .cp_page
.cp_rem:
    ldx zp_len+0
    beq .cp_done
.cp_last:
    lda (zp_src),y
    sta (zp_dst),y
    iny
    dex
    bne .cp_last
.cp_done:
    pla                             ; zp_src = inicio del tema; zp_len intacto
    sta zp_src+0
    pla
    sta zp_src+1
    jsr PATCH_SID_ADDR              ; $D4xx -> $73xx

    lda song_no
    ldx #0
    ldy #0
    jsr call_init
    clc
    rts

; ============================================================================
;  SID_SETUP  -  llamalo una vez al arrancar, antes del CLI.
;  Deja el VIA de música en un estado conocido aunque su /RES no venga del
;  reset del sistema (o después de un reset en caliente con un tema sonando):
;  sin IRQs, timers sin efecto, puertos según VIA_PORT_DDR y el SID con
;  todos sus registros en 0 (mudo, sin zumbido).
; ============================================================================
SID_SETUP:
    php
    sei
    lda #%01111111
    sta VIA_IER                     ; deshabilita TODAS las IRQ del VIA
    sta VIA_IFR                     ; y limpia los flags pendientes
    lda #0
    sta VIA_ACR                     ; T1/T2 one-shot, sin shift register, sin latch
    sta VIA_PCR                     ; CA/CB en modo entrada, flanco negativo
    sta VIA_ORA                     ; si son salidas, quedan en 0
    sta VIA_ORB
    lda #VIA_PORT_DDR
    sta VIA_DDRA                    ; dirección de los puertos (ver VIA_PORT_DDR)
    sta VIA_DDRB
    lda VIA_T1CL                    ; lee T1CL por si quedó un flag del T1
    ldx #$18                        ; SID: los 25 registros a 0
    lda #0
.clr:
    sta SID,x
    dex
    bpl .clr
    sta SID_BUSY
    plp
    rts

; ============================================================================
;  SID_STOP  -  corta el tema desde tu programa (se puede llamar siempre)
; ============================================================================
SID_STOP:
    php
    sei
    jsr SID_HALT
    plp
    rts

; ---- apaga todo: IRQ del T1, latch a 50 Hz, voces y volumen ----------------
SID_HALT:
    lda #%01000000                  ; IER: deshabilita la IRQ del T1
    sta VIA_IER
    lda #<(T1_LATCH)                ; por si el tema lo cambió (voz digital)
    sta VIA_T1LL
    lda #>(T1_LATCH)
    sta VIA_T1LH
    lda #0
    sta SID+$04                     ; gate off en las 3 voces
    sta SID+$0B
    sta SID+$12
    sta SID+$17                     ; filtro off
    sta SID+$18                     ; volumen 0
    sta SID_BUSY
    rts

; ============================================================================
;  PATCH_SID_ADDR  -  zp_src = inicio del tema, zp_len = largo.
;  Patrón: <opcode abs de load/store> <lo <= $1C> <hi == $D4>  ->  hi = $73
; ============================================================================
PATCH_SID_ADDR:
.scan:
    lda zp_len+1                    ; hacen falta al menos 3 bytes
    bne .enough
    lda zp_len+0
    cmp #3
    bcc .done
.enough:
    ldy #0
    lda (zp_src),y
    jsr is_abs_opcode
    bcc .next
    ldy #2
    lda (zp_src),y
    cmp #SIDPAGE
    bne .next
    ldy #1
    lda (zp_src),y
    cmp #(SIDREG_MAX+1)
    bcs .next
    ldy #2
    lda #>(SID)
    sta (zp_src),y
.next:
    inc zp_src+0
    bne .nocarry
    inc zp_src+1
.nocarry:
    lda zp_len+0
    bne .noborrow
    dec zp_len+1
.noborrow:
    dec zp_len+0
    jmp .scan
.done:
    rts

; carry=1 si A es un opcode abs / abs,X / abs,Y de load o store
is_abs_opcode:
    cmp #$8D                        ; STA abs
    beq .yes
    cmp #$9D                        ; STA abs,X
    beq .yes
    cmp #$99                        ; STA abs,Y
    beq .yes
    cmp #$8C                        ; STY abs
    beq .yes
    cmp #$8E                        ; STX abs
    beq .yes
    cmp #$AD                        ; LDA abs
    beq .yes
    cmp #$BD                        ; LDA abs,X
    beq .yes
    cmp #$B9                        ; LDA abs,Y
    beq .yes
    clc
    rts
.yes:
    sec
    rts

; ---- trampolines indirectos -------------------------------------------------
call_init:
    jmp (init_vec)
call_play:
    jmp (play_vec)

; ============================================================================
;  TIMER_ON  -  T1 del VIA en modo libre a ~50 Hz (la IRQ la decide quien llama)
; ============================================================================
TIMER_ON:
    lda #%01000000                  ; ACR: T1 libre, PB7 off
    sta VIA_ACR
    lda #<(T1_LATCH)
    sta VIA_T1CL
    lda #>(T1_LATCH)                ; carga + arranca + limpia el flag
    sta VIA_T1CH
    rts

; ============================================================================
;  SID_TICK  -  llama a play y cuenta frames. carry=1 si llegó a SID_LIMIT.
;  Solo cuenta cuando el T1 está a 50 Hz: los temas de voz digital suben el
;  T1 a ~6800 Hz y esas llamadas no son frames.
; ============================================================================
SID_TICK:
    jsr call_play
    lda VIA_T1LH                    ; ¿T1 a 50 Hz? (la voz lo cambia)
    cmp #>(T1_LATCH)
    bne .no
    inc SID_FRAMES+0
    bne .chk
    inc SID_FRAMES+1
.chk:
    lda SID_LIMIT+0
    ora SID_LIMIT+1
    beq .no                         ; 0 = sin corte
    lda SID_FRAMES+0
    cmp SID_LIMIT+0
    bne .no
    lda SID_FRAMES+1
    cmp SID_LIMIT+1
    bne .no
    sec
    rts
.no:
    clc
    rts

; ============================================================================
;  SID_IRQ  -  apuntá el vector de IRQ acá
;  Llama a play y cuenta frames. Solo cuenta cuando el T1 está a 50 Hz:
;  los temas de voz digital suben el T1 a ~6800 Hz y esas llamadas no son frames.
;  Al llegar a SID_LIMIT (si no es 0) corta todo y SID_BUSY queda en 0.
; ============================================================================
SID_IRQ:
    pha
    txa
    pha
    tya
    pha
    lda VIA_T1CL                    ; ack del T1
    lda SID_BUSY
    beq .out                        ; IRQ sin tema sonando: no hacer nada
    jsr SID_TICK
    bcc .out
    jsr SID_HALT                    ; llegó al límite: fin del tema
.out:
    pla
    tay
    pla
    tax
    pla
    rti
