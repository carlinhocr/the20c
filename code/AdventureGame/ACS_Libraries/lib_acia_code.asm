;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------UARTSERIALINIT-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

uartSerialInit:

  ;reset UART 6551 by writting to thestatus register
  lda #$00
  sta ACIA_STATUS
  sta ACIA_PRINTER_STATUS

  ;configure the control register
  ;bit 7 = 0 -> 1 Stop Bit
  ;bit 6 =0 and bit 5=0 -> 8 bits word lenght
  ;bit 4 = 1 -> receiver clock source is baud rate
  ;bit 3 =1 bit 2=1 bit 1=1 bit 0=0 -> 9600 baudios as a baud rate
  ;bit 3 =1 bit 2=1 bit 1=1 bit 0=1 -> 19200 baudios as a baud rate
  lda #%00011110 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 9600 baudios
  ;lda #%00011111 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 19200 baudios
  sta ACIA_CTRL
  sta ACIA_PRINTER_CTRL

  ;configure the command register
  ;bit 7 = 0 and bit 6 =0 -> odd parity but we will not be using parity
  ;bit 5=0 -> disable parity
  ;bit 4 = 0 -> disable ECHO
  ;bit 3 =1 bit 2=0 -> RTSB Active Low and Interrupts Disable
  ;bit 1 =1 -> Receiver interrupt request disable
  ;bit 0 =1 -> Data terminal Ready (DTRB Low)
  lda #%00001011 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 9600 baudios
  sta ACIA_CMD
  sta ACIA_PRINTER_CMD

  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------UARTSERIALINIT-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALUART-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
serialUART:

send_rs232_line:
  ldy #$0
send_rs232_line_loop:
  tya 
  clc
  adc serialDataVectorLow
  ;bcc send_rs232_line_loop_same_page
  ;inc serialDataVectorHigh
;send_rs232_line_loop_same_page:  
  lda (serialDataVectorLow),y 
  ;test for the NULL char that ends all ASCII strings
  beq send_rs232_line_end
  jsr send_rs232_char
  iny
  jmp send_rs232_line_loop 
send_rs232_line_end:
  ;add the number of characters printed + 1 for the null char
  ;store in serialCharperLines
  clc
  tya
  adc #1
  sta serialCharperLines
  jsr send_rs232_CRLF
  rts  

send_rs232_line_noCRLF:
  ldy #$0
send_rs232_line_noCRLF_loop:
  lda (serialDataVectorLow),y 
  ;test for the NULL char that ends all ASCII strings
  beq send_rs232_line_noCRLF_end
  jsr send_rs232_char
  iny
  jmp send_rs232_line_noCRLF_loop 
send_rs232_line_noCRLF_end:
  ;add the number of characters printed + 1 for the null char
  ;store in serialCharperLines
  clc
  tya
  adc #1
  sta serialCharperLines
  ;jsr send_rs232_CRLF
  rts    

send_rs232_CRLF:
  lda #$0d
  jsr send_rs232_char
  lda #$0a
  jsr send_rs232_char 
  rts   

listeningMode: 
  jmp loopReceiveData ;go to listening mode
  
  
  ;wait until the status register bit 3 receive data register is full =1, then 
  ;read the data register
loopReceiveData:
   
  lda ACIA_STATUS
  and #%00001000; and it to see if bit 3 is one, delete all the other bits
  beq loopReceiveData ; if zero we have not received anythinßg
  ;if we are here we have a byte to read
  lda ACIA_DATA ;read character
  jsr print_char ;print the char on the local lcd of the 20 c
  jsr send_rs232_char ;echo the character typed
  jmp loopReceiveData ;go to wait for next character
  rts

send_rs232_char:
  pha ;store the character to print
  lda rs232Printer
  bne send_rs232_char_printer
send_rs232_char_screen:
  pla ;restore the character to print
  sta ACIA_DATA ;wrie whatever is on the accumulator to the transmit register
  ; preserve accumulator
  pha 
  ; preserve Y register
  tya  
  pha
  ; preserve X register
  txa  
  pha  
  ;check to see if the transmit data register is empty bit 4 of the status register
tx_wait:  
  lda ACIA_STATUS
  and #%00010000 ;leave vae only bit 4 on the accumulator
  beq tx_wait ;if zero the transmit buffer is full so we wait
  jsr tx_delay ; solve bit 4 hardware issue on the wdc issue
  ;recover X register
  pla
  tax
  ;recover y register
  pla
  tay
  ; recover accumulator
  pla 
  rts
tx_delay:
  ;at 19200 bauds it is 1 bit every 52 clock cycles
  ;so 8 bits + start and stop bit it is 10 bits or 520 cycles
  ldy #102
tx_delay_loop:  
  dey ;2 cycles
  bne tx_delay_loop ; 3 cycles
  rts

send_rs232_char_printer:
  pla ;restore the character to print
  sta ACIA_PRINTER_DATA ;wrie whatever is on the accumulator to the transmit register
  ; preserve accumulator
  pha 
  ; preserve Y register
  tya  
  pha
  ; preserve X register
  txa  
  pha  

  ;check to see if the transmit data register is empty bit 4 of the status register
tx_wait_printer:  
  lda ACIA_PRINTER_STATUS
  and #%00010000 ;leave vae only bit 4 on the accumulator
  beq tx_wait_printer ;if zero the transmit buffer is full so we wait
  jsr tx_delay_printer ; solve bit 4 hardware issue on the wdc issue
  ;recover X register
  pla
  tax
  ;recover y register
  pla
  tay
  ; recover accumulator
  pla 
  rts

tx_delay_printer:
  ;at 19200 bauds it is 1 bit every 52 clock cycles
  ;so 8 bits + start and stop bit it is 10 bits or 520 cycles
  ldy #102
tx_delay_printer_loop:  
  dey ;2 cycles
  bne tx_delay_printer_loop ; 3 cycles
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALUART-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;----------------------------PRINT RS232 ASCII--------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

delayClear:
  jsr delay_3_sec  
  jsr printClearRS232Screen
  rts

printClearRS232Screen:
  lda #< clearRS232Screen
  sta serialDataVectorLow
  lda #> clearRS232Screen 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

printAsciiDrawingPrinter:  
  ;lets print on the printer
  lda #$1
  sta rs232Printer  
  jsr initializePrinter
  jsr printAsciiDrawing 
  lda #$0
  sta rs232Printer
  rts

printSimulationTimerBarsPrinter:
  ;lets print on the printer
  lda #$1
  sta rs232Printer  
  jsr initializePrinter
  jsr printSimulationTimerBars
  lda #$0
  sta rs232Printer
  rts

printAsciiDrawing:
  sei ;disable interrupts to run
  ;save accumulator x and y registers
  pha
  txa
  pha
  tya
  pha
  ;here print first line
  ;initialize in cero serialCharperLines
  lda #$0
  sta serialCharperLines
  jsr send_rs232_line
  ldx #$0 ;the first line 0 we aleready printed
printAsciiDrawing_lenghts_loop:
  inx ;now going to line 1
  ;here increment on additional lines
  clc
  lda serialDataVectorLow ;load marioascii low
  adc serialCharperLines ; add the number of records of the last send_rs232_line
  sta serialDataVectorLow ; store the new value
  bcc printAsciiDrawing_lenghts_no_carry ;branch on carry clear or no carry
  ;if there is a carry it is in the carry flag
  ; clear the carry and add one to the high order byte
  clc
  inc serialDataVectorHigh
printAsciiDrawing_lenghts_no_carry  
  ldy #0
  lda (serialDataVectorLow),y 
  cmp #$65;"e"
  beq printAsciiDrawing_checkNull
  jmp printAsciiDrawing_keepgoing
printAsciiDrawing_checkNull:  
  ldy #1
  lda (serialDataVectorLow),y 
  cmp #$00
  beq printAsciiDrawing_end
printAsciiDrawing_keepgoing:  
  jsr send_rs232_line
  jmp printAsciiDrawing_lenghts_loop
  ;cpx serialTotalLinesAscii ;check to see if 27 lines where printed from 1 to 26
  ;bne printAsciiDrawing_lenghts_loop
  ;return and increment according to the lenght of the mario screen
  ;end by jumping to listening mode
printAsciiDrawing_end:
  ;save accumulator x and y registers
  pla
  tay
  pla
  tax
  pla
  ;cli let them be on when it is ok for them to be on
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;----------------------------PRINT RS232 ASCII--------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------PRINTER-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initializePrinter:
  jsr printerReset
  rts

testPrinter:
  lda #$1
  sta rs232Printer
  jsr printerReset
  jsr probandoPrinter
  jsr printerBoldOn
  jsr probandoPrinter
  jsr printerBoldOff
  jsr printerJustificationRight
  jsr probandoPrinter
  jsr printerJustificationCenter
  jsr probandoPrinter
  jsr printerJustificationLeft
  jsr probandoPrinter
;   jsr printerUnderlineOn
;   jsr probandoPrinter
;   jsr printerUnderlineOff
  jsr printerLetterSizeBig
  jsr probandoPrinter
  jsr printerLetterSizeMedium
  jsr probandoPrinter
  jsr printerLetterSizeNormal
  jsr probandoPrinter
  jsr printerFeedManyLines
  jsr printerCut
  rts

printerReset:
  ;Initialization sequence ESC @
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$40 ;@
  jsr send_rs232_char
  rts

printerCut:
  ;Initialization sequence ESC @
  lda #$1d 
  jsr send_rs232_char
  lda #$56
  jsr send_rs232_char
  lda #$00
  jsr send_rs232_char  
  rts

printerBoldOn:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$45 ;E
  jsr send_rs232_char
  lda #$1 ;bold on
  jsr send_rs232_char  
  rts

printerBoldOff:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$45 ;E
  jsr send_rs232_char
  lda #$0 ;bold off
  jsr send_rs232_char  
  rts  

probandoPrinter:
  lda #<msj_printer
  sta serialDataVectorLow  
  inx 
  lda #>msj_printer
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

printerJustificationLeft:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$61 ;a
  jsr send_rs232_char
  lda #$0 ;left
  jsr send_rs232_char  
  rts      

printerJustificationCenter:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$61 ;a
  jsr send_rs232_char
  lda #$1 ;Center
  jsr send_rs232_char  
  rts       

printerJustificationRight:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$61 ;a
  jsr send_rs232_char
  lda #$2 ;right
  jsr send_rs232_char  
  rts       

printerFeedOneLine:
  lda #$0a ;LF
  jsr send_rs232_char
  rts

printerFeedManyLines:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$64 ;a
  jsr send_rs232_char
  lda #$5 ;5 lines
  jsr send_rs232_char  
  rts    

printerUnderlineOn:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$2d ;n
  jsr send_rs232_char
  lda #$1
  jsr send_rs232_char  
  rts    

printerUnderlineOff:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$2d ;n
  jsr send_rs232_char
  lda #$0 
  jsr send_rs232_char  
  rts    
  
printerLetterSizeMedium:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$21 ;n
  jsr send_rs232_char
  ;bits 7 to 4 widht, bits 3 to 0 height 
  ;00 normal size
  lda #$11 ;medium size 
  jsr send_rs232_char  
  rts     

printerLetterSizeBig:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$21 ;n
  jsr send_rs232_char
  ;bits 7 to 4 widht, bits 3 to 0 height 
  ;00 normal size
  lda #$33 ;big size 
  jsr send_rs232_char  
  rts   

printerLetterSizeNormal:
  lda #$1b ;ESC 
  jsr send_rs232_char
  lda #$21 ;n
  jsr send_rs232_char
  ;bits 7 to 4 widht, bits 3 to 0 height 
  ;00 normal size
  lda #$00 ;medium size 
  jsr send_rs232_char  
  rts     

msj_printer:
  .ascii "Probando Printer"
  .ascii "e"   

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------PRINTER-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-------------------------------------BARRA-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

setBarSegmentSize:
  ;lets asume we use 8 as the division
  lda barMaximumTimerHigh
  sta segmentBarSizeHigh
  lda barMaximumTimerLow
  sta segmentBarSizeLow  
  lda barSegmentNumbers
  sta divisorBarSegment
  beq setBarSegmentSizeLoop_End
setBarSegmentSize_Loop:  
  lda divisorBarSegment
  clc ;clear the carry flag for ror so we can divide by two
  ror ;with this i am diding by the sbarSEgmentSize
  sta divisorBarSegment
  beq setBarSegmentSizeLoop_End
  ;example for 8 segments we do 3 shift example for 600 (600/8)
  ;0000 1000
  ;first ror
  ;0000 0100 = 600/2 = 300
  ;second ror
  ;0000 0010 = 300/2 = 150
  ;third ror
  ;0000 0001 = 150/2 = 75 equal to 600/8  
  ;the fourth ror is zero    
  lda segmentBarSizeHigh
  clc ;clear the carry flag for ror so we can divide by two
  ror
  sta segmentBarSizeHigh
  ;here we keep the carry flag to have the 7 bit of the low segments
  lda segmentBarSizeLow
  ror
  sta segmentBarSizeLow
  jmp setBarSegmentSize_Loop
setBarSegmentSizeLoop_End:
  ;here we have the segment size on segmentBarSizeHigh and segmentBarSizeLow
  rts

calculateNumberOfBars:
  ;check for maximum size fo segments
  lda simulationSegments
  sta barSegmentNumbers
  lda simulationTimePassedLowDigits
  sta currentTimeBarLow
  lda simulationTimePassedHighDigits
  sta currentTimeBarHigh
  sec 
  lda barMaximumTimerLow
  sbc currentTimeBarLow
  lda barMaximumTimerHigh
  sbc currentTimeBarHigh
  ;if there is no carry then result is negative
  ;we are past simulation time
  ;we should print only the maximum bar size and no more
  bcs calculateNumberOfBars_CalculateBars 
  ;if we are here it was negative
  ldx barSegmentNumbers
  jmp calculateNumberOfBars_Print
calculateNumberOfBars_CalculateBars:  
  ;if not lets calculate the bars
  lda segmentBarSizeHigh
  sta currentSegmentBarSizeHigh
  lda segmentBarSizeLow
  sta currentSegmentBarSizeLow
  ldx #$00
calculateNumberOfBars_Loop  
  inx
  ;we will get the segment size startign with the size in seconds
  ;16 bit number for just one segment and substract it from the current time
  ;we do not care about the resulting number only about the carry
  ;to find who is less
  sec 
  lda currentSegmentBarSizeLow
  sbc currentTimeBarLow
  lda currentSegmentBarSizeHigh
  sbc currentTimeBarHigh
  ;if there is a carry the result was positive
  ;and the current segment bar is greater than the current time
  ;in the index register X we have our number of segments
  bcs calculateNumberOfBars_Print
  ;here it was negative we have to increase the segments so we add one segment more
  clc ;clear the carry flag for rol so we can add 
  lda currentSegmentBarSizeLow
  adc segmentBarSizeLow 
  sta currentSegmentBarSizeLow
  ;we do not clear the carry so we can add a carry from Low to High
  lda currentSegmentBarSizeHigh
  adc segmentBarSizeHigh
  sta currentSegmentBarSizeHigh
  ;now we try again to find out if we have our correct segmente
  jmp calculateNumberOfBars_Loop
calculateNumberOfBars_Print:
  txa
  sta currentNumberOfBars
  rts

printSegments:
  ;check for maximum size fo segments
  sec 
  lda barMaximumTimerLow
  sbc currentTimeBarLow
  lda barMaximumTimerHigh
  sbc currentTimeBarHigh
  ;if there is no carry then result is negative
  ;we are past simulation time
  ;we should print only the maximum bar size and no more
  bcs printSegments_CalculateBars 
  ;if we are here it was negative
  ldx barSegmentNumbers
  jmp printSegments_Print
printSegments_CalculateBars:  
  ;if not lets calculate the bars
  lda segmentBarSizeHigh
  sta currentSegmentBarSizeHigh
  lda segmentBarSizeLow
  sta currentSegmentBarSizeLow
  ldx #$00
printSegments_Loop  
  inx
  ;we will get the segment size startign with the size in seconds
  ;16 bit number for just one segment and substract it from the current time
  ;we do not care about the resulting number only about the carry
  ;to find who is less
  sec 
  lda currentSegmentBarSizeLow
  sbc currentTimeBarLow
  lda currentSegmentBarSizeHigh
  sbc currentTimeBarHigh
  ;if there is a carry the result was positive
  ;and the current segment bar is greater than the current time
  ;in the index register X we have our number of segments
  bcs printSegments_Print
  ;here it was negative we have to increase the segments so we add one segment more
  clc ;clear the carry flag for rol so we can add 
  lda currentSegmentBarSizeLow
  adc segmentBarSizeLow 
  sta currentSegmentBarSizeLow
  ;we do not clear the carry so we can add a carry from Low to High
  lda currentSegmentBarSizeHigh
  adc segmentBarSizeHigh
  sta currentSegmentBarSizeHigh
  ;now we try again to find out if we have our correct segmente
  jmp printSegments_Loop

printSegments_Print:
  txa
  sta currentNumberOfBars
  sta printableNumberOfBars
  lda barSegmentNumbers
  sec
  sbc printableNumberOfBars
  sta emptyBars
  lda #$5b;"["
  jsr send_rs232_char  
printSegments_Print_Bars_Loop:  
  lda #$23 ;"#"
  jsr send_rs232_char 
  dec printableNumberOfBars
  bne printSegments_Print_Bars_Loop  
  lda emptyBars
printSegments_Print_Empty_Loop:   
  beq printSegments_End
  lda #$5f ;"_"
  jsr send_rs232_char 
  dec emptyBars
  jmp printSegments_Print_Empty_Loop
printSegments_End:  
  lda #$5d;"]"
  jsr send_rs232_char  
  jsr send_rs232_CRLF
  rts  

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-------------------------------------BARRA-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------