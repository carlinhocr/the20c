;Zero Page
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
