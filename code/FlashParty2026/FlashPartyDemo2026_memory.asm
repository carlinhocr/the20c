;Zero Page

;Table to store the address of the filenames to load
pivot_LB = $d0 
pivot_HB = $d1 

graphTable_LB = $d2
graphTable_HB = $d3


graphTable = $0300

sidSize = $0390           ; 2 bytes de RAM libres ($0382/83 ya los usa tu IEC)
LOAD_RETRIES = 6
retryCount   = $0392      ; 1 byte de RAM libre
namePtr      = $0393      ; 2 bytes de RAM libres

failSt       = $0395
failEoi      = $0396
failSize     = $0397         ; 2 bytes

driveStatus  = $03A0      ; 48 bytes: mensaje del canal 15
checkTrailer = $039A



BUFFER_GRAPHICS_START=$1000
BUFFER_GRAPHICS_END=$3FFF

BUFFER_MUSIC_START=$4000
BUFFER_MUSIC_END=$6FFF

BUFFER_MUSIC2_START=$1000
BUFFER_MUSIC2_END=$3FFF

; ---- HOLA_40.SID en ROM (copyHola40ToRAM) ----
romCopySrc = $D4          ; 2 bytes ZP
romCopyDst = $D6          ; 2 bytes ZP
romCopyLen = $D8          ; 2 bytes ZP
HOLA40_SIZE = 9195        ; tamaño de HOLA_40.SID (si lo regenerás, cambiá esto)
HOLA_P1_LEN = 2048        ; antes de $90A2 (libre: ~2190 con la rutina)
HOLA_P2_LEN = 1792        ; antes de $C000 (libre: 1921)
HOLA_P3_LEN = HOLA40_SIZE-HOLA_P1_LEN-HOLA_P2_LEN   ; 5355, después de CARNAV (libre: 5588)