;Zero Page
serialDataVectorLow = $3d
serialDataVectorHigh = $3e
serialCharperLines = $3f
;serialTotalLinesAscii =$40
;serialDrawindEndChar=$41

;RAM

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
ACIA_PRINTER_DATA = $4000
ACIA_PRINTER_STATUS = $4001
ACIA_PRINTER_CMD = $4002
ACIA_PRINTER_CTRL = $4003

;ACIA/UART ports
ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003
