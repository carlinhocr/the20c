;Zero Page
serialDataVectorLow2 = $3b
serialDataVectorHigh2 = $3c
serialDataVectorLow = $3d
serialDataVectorHigh = $3e
serialCharperLines = $3f
;serialTotalLinesAscii =$40
;serialDrawindEndChar=$41

;RAM
simulationTimePassedLowDigits=    $0224
simulationTimePassedHighDigits=   $0225

maxSimulationTimeLowByte=         $022e
maxSimulationTimeHighByte=        $022f

divisorBarSegment=                $0257
printableNumberOfBars=            $0258

simulationSegments=               $025c

barMaximumTimerLow=               $0260
barMaximumTimerHigh=              $0261
segmentBarSizeHigh=               $0262
segmentBarSizeLow=                $0263
currentTimeBarHigh=               $0264
currentTimeBarLow=                $0265
currentSegmentBarSizeHigh=        $0266
currentSegmentBarSizeLow=         $0267
barSegmentNumbers=                $0268
emptyBars=                        $0269
currentNumberOfBars=              $026a
rs232Printer=                     $0278
preserveSerialDataVectorLow=      $0279
preserveSerialDataVectorHigh=     $027a 
colorStyleOffset=                 $027b
colorStyleType=                   $027c
colorStyleHundred=                $027d
lastColorStyleItem=               $027e
screenCol=                        $027f
screenRow=                        $0280
backgroundColor=                  $0281
asciiBinaryRows=                  $0282
serialCharperLinesLow=            $0283
serialCharperLinesHigh=           $0284
ansi_string=                      $0290 ;to $0300  
ansiStringMemoryConstantLow=$90
ansiStringMemoryConstantHigh=$02


;ACIA/UART ports PRINTER
ACIA_BASE_PRINTER    = $7900 

ACIA_PRINTER_DATA   = ACIA_BASE_PRINTER + $00
ACIA_PRINTER_STATUS = ACIA_BASE_PRINTER + $01
ACIA_PRINTER_CMD    = ACIA_BASE_PRINTER + $02
ACIA_PRINTER_CTRL   = ACIA_BASE_PRINTER + $03

;ACIA/UART ports

ACIA_BASE    = $7000             ; Base address of the 6522 VIA

ACIA_DATA   = ACIA_BASE + $00 
ACIA_STATUS = ACIA_BASE + $01
ACIA_CMD    = ACIA_BASE + $02
ACIA_CTRL   = ACIA_BASE + $03

;---------------------------------------------------------------------------
; VELOCIDAD DEL RS232 (CPU a 1 MHz, 1 ciclo = 1 us)
;   El W65C51 tiene el bit 4 (TDRE) trabado en 1: no avisa cuando termino de
;   mandar. La unica forma segura es esperar 10 bits por caracter con un lazo.
;     19200  -> 10 bits = 521 ciclos
;     115200 -> 10 bits =  87 ciclos
;   TX_DELAY        lo usa send_rs232_char      (47 + 5*N ciclos entre bytes)
;   TX_DELAY_STREAM lo usa printAsciiBinaryFast (17 + 5*N ciclos entre bytes)
;   Los valores dejan ~5% de margen. Elegir UN bloque y comentar el otro.
;---------------------------------------------------------------------------
; --- 19200 baudios (como estaba) ---
; ACIA_CTRL_SCREEN = %00011111   ; 1 stop, 8 bits, RCS=1, SBR=1111 -> 19200
; TX_DELAY         = 100         ; 47+500 = 547 ciclos
; TX_DELAY_STREAM  = 106         ; 17+530 = 547 ciclos
; --- 115200 baudios (cristal 1.8432 MHz / 16, SBR=0000) ---
ACIA_CTRL_SCREEN = %00010000  ; 1 stop, 8 bits, RCS=1, SBR=0000 -> 115200
TX_DELAY         = 9          ; 47+45 = 92 ciclos
TX_DELAY_STREAM  = 15         ; 17+75 = 92 ciclos

; la impresora queda siempre a 19200 con el retardo de antes
ACIA_CTRL_PRINTER = %00011111
TX_DELAY_PRINTER  = 102
