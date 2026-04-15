;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2

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

;VIA Ports and Constant ds
LCD_VIA_BASE  = $6000
; IFR       = VIA_BASE + $0D   ; Interrupt Flag Register
; IER       = VIA_BASE + $0E   ; Interrupt Enable Register

; ── Timer 1 IFR bit mask ──────────────────────────────────

LCD_T1_FLAG   = %01000000         ; bit 6

LCD_PORTB = $6000
LCD_PORTA = $6001
LCD_DDRB = $6002 
LCD_DDRA = $6003
LCD_T1CL = LCD_VIA_BASE + $04   ; Timer 1 counter low   (R: clears T1 IFR bit)
LCD_T1CH = LCD_VIA_BASE + $05   ; Timer 1 counter high  (W: starts timer)
LCD_T1LL = LCD_VIA_BASE + $06   ; Timer 1 latch low
LCD_T1LH = LCD_VIA_BASE + $07   ; Timer 1 latch high
LCD_T2CL = LCD_VIA_BASE + $08   ; Timer 1 counter low   (R: clears T1 IFR bit)
LCD_T2CH = LCD_VIA_BASE + $09   ; Timer 1 counter high  (W: starts timer)
LCD_ACR  = LCD_VIA_BASE + $0B   ; Auxiliary Control Register
LCD_PCR = $600c
LCD_IFR = $600d
LCD_IER = $600e

RS_PORTB = $7000
RS_PORTA = $7001
RS_DDRB = $7002
RS_DDRA = $7003
RS_PCR = $700c
RS_IFR = $700d
RS_IER = $700e

;CIA Ports and Constants
; RS_PORTB = $7001
; RS_PORTA = $7000
; RS_DDRB = $7003
; RS_DDRA = $7002

;zero page memory positions for Vectors and Data


charDataVectorLow = $30
charDataVectorHigh = $31
delay_COUNT_A = $32        
delay_COUNT_B = $33
screenMemoryLow=$34 ;80 bytes
screenMemoryHigh=$35 
lcdCharPositionsLowZeroPage =$36 
lcdCharPositionsHighZeroPage =$37
lcdROMPositionsLowZeroPage =$38 
lcdROMPositionsHighZeroPage =$39
initialScreenZeroPageLow=$3a
initialScreenZeroPageHigh=$3b
;record_lenght=$3c ;it is a memory position
serialDataVectorLow = $3d
serialDataVectorHigh = $3e
serialCharperLines = $3f
serialTotalLinesAscii =$40
serialDrawindEndChar=$41
TIMER_ZP_SEC    = $42               ; loop counter for WAIT_ONE_SECOND  (1 byte)
TIMER_ZP_MIN    = $43               ; seconds counter for WAIT_ONE_MINUTE (1 byte)

soundLowByte=$50
soundHighByte=$51
soundDelay=$52

;Vectors RLE
rleVectorLow=$a0
rleVectorHigh=$a1

;LCD buttons
LCD_PORTSTATUS=$a2

;Zero Page Vectors Screen
ramScreenVectorLow=$b0
ramScreenVectorHigh=$b1
dashboardScreenVectorLow=$b2
dashboardScreenVectorHigh=$b3
actionCheckVectorLow=$b4
actionCheckVectorHigh=$b5
actionDataVectorLow=$b6
actionDataVectorHigh=$b7
sourceScreenVectorLow=$b8
sourceScreenVectorHigh=$b9
sourceDashboardVectorLow=$ba
sourceDashboardVectorHigh=$bb
sensorDataVectorLow=$bc
sensorDataVectorHigh=$bd

pivotZpLow=$fe
pivotZpHigh=$ff

;Memory locations RLE
rleChar=$0200
rleTimes=$0201
rleScreenLines=$0202

value=                  $0203
value_1=                $0204
mod10=                    $0205
mod10_1=                  $0206
message = $0207 ; the result up to 6 bytes to $020b
;used by message= $0207
;$0208
;$0209
;$020a
;$020b
multiFactor1=                     $020c
multiFactor2=                     $020d
multiResultLow=                   $020e
multiResultHigh=                  $020f
screenCurrentID=                  $0210
max_actions_per_screen=           $0211
actionCurrentID=                  $0212
actionPosition=                   $0213
current_screen_offset=            $0214
screenPrintOffset=                $0215
selectedAction=                   $0216
print_no_CRLF=                    $0217
flashlightOff=                    $0218
userOptionSelection=              $0219
heartRateLevel=                   $021a
waterLevel=                       $021b
heartRateSensor=                  $021c
waterLevelSensor=                 $021d
flashlightStatus=                 $021e
actionCostTotal=                  $021f
currentActionCost=                $0220
currentActionHideWater=           $0221
currentActionHideFear=            $0222
currentActionHideFlashlightOff=   $0223
simulationTimePassedLowDigits=    $0224
simulationTimePassedHighDigits=   $0225
dashboardCurrentID=               $0226
current_dashboard_offset=         $0227
extraSecondsFlashlightOffLowByte= $0228
extraSecondsFlashlightOffHighByte=$0229
extraSecondsHeartRateLowByte=     $022a
extraSecondsHeartRateHighByte=    $022b
extraSecondsWaterLevelLowByte=    $022c
extraSecondsWaterLevelHighByte=   $022d
maxSimulationTimeLowByte=         $022e
maxSimulationTimeHighByte=        $022f
simulationTimeExpired=            $0230
endScreenSimulationTimeisUp=      $0231
timeRemainingLowByte=             $0232
timeRemainingHighByte=            $0233
isEndScreenVariable=              $0234
flashlightToggleFlag=             $0235
flashlightSecondsUsedLowByte=     $0236
flashlightSecondsUsedHighByte=    $0237
maxFlashlightTimeLowByte=         $0238
maxFlashlightTimeHighByte=        $0239
timeRemainingFlashLightLowByte=   $023a
timeRemainingFlashLightHighByte=  $023b
randomNumber=                     $023c
enemyProbActionReset=             $023d
enemyProbActionCost=              $023e
enemyProbActionCostCummulative=   $023f
enemyProbActionCummPlusFlashlight=$0240
enemyProbFlashlight=              $0241
enemyProbCurrentScreen=           $0242
enemyProbabilityTotal=            $0243
idleTimerStartMinute=             $0244
sensorCurrentID=                  $0245
sensorCurrentStatus=              $0246
timerExpired=                     $0247
gameEnded=                        $0248
fearLevel=                        $0249
watertLevel=                      $024a
actionHidden=                     $024b
highWaterLevel=                   $024c
highFearLevel=                    $024d
moveNextScreen=                   $024e
actionFailedProb=                 $024f
actionFailedProbWaterPerLevel=    $0250
actionFailedProbFlashlight=       $0251
actionFailedProbHeartRate=        $0252
actionFailedWaterFlashLightHeartRate=    $0253
actionFailedProbabilityTotal=     $0254
endScreenByEnemy=                 $0255
endScreenByActionFailed=          $0256
divisorBarSegment=                $0257
printableNumberOfBars=            $0258
levelsToIncreaseWater=            $0259
timerOn=                          $025a
maximumWaterLevel=                $025b
simulationSegments=               $025c
flashlightSegments=               $025d
dashboardStartScreen=             $025e
dashboardEndScreenDefault=        $025f
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
endByTimeUp=                      $026b
endByEnemy=                       $026c
endByActionFailed=                $026d
endByDirectAction=                $026e
additionalWaterLevel=             $026f
dashboardEndScreenEnemy=          $0270
dashboardEndScreenTimeUp=         $0271
dashboardEndScreenActionFailed=   $0272
dashboardHighFearLevel=           $0273
dashboardHighWaterLevel=          $0274
isSecretScreenVariable=           $0275
secretsFound=                     $0276
rs232Printer=                     $0277
flashLightSensor=                 $0278

actionIDOptionsRAM=$0440 ;32 bytes but i only use 6
currentScreenAllActionsRAM=$0460 ; i only use 6 bytes
screenPointersRAM=$0500
dashboardPointersRAM=$0600

;constants
fill=$43 ;letter C
totalScreenLenght4Lines=$50
totalScreenLenght=$3c ;make it only 3 lines long 3c = 60 decimal
totalLineLenght=$13 ;20 positions in hexadecimal is 13
end_char=$ff
cblank=$20

pos_line1=$8B
pos_line2=$CB
pos_line3=$9F
pos_line4=$DF

record_lenght=$09

lenght_screen_lines=$04; 0 to 3
lenght_ascii_line_characters=$20
lenght_screen_characters=$50 ;80 in decimal
pos_lcd_initial_line0=$80
pos_lcd_initial_line1=$C0
pos_lcd_initial_line2=$94
pos_lcd_initial_line3=$D4

;Timer Constants
; ── Timer load values for 1 MHz clock ────────────────────
;
;  Timer counts DOWN from the loaded value to 0, then sets
;  IFR bit 6.  At 1 MHz each tick = 1 µs.
;
;  Maximum single load = 65535 µs ≈ 65.535 ms
;  So to reach 1 second we need ~15.259 overflows of 65535,
;  but it's cleaner to use exactly 50 000 µs (50 ms) and
;  count 20 overflows  →  20 × 50 000 µs = 1 000 000 µs = 1 s
;
;  TICKS_50MS = 50 000 - 2 = 49 998
;    (subtract 2 because the VIA takes 2 extra cycles to
;     reload and set the flag — datasheet §4.2.1)
;  49 998 = $C34E
;  Low  byte: $4E
;  High byte: $C3

TIMER_TICKS_LO  = $4E               ; low  byte of 49 998
TIMER_TICKS_HI  = $C3               ; high byte of 49 998

TIMER_LOOPS_1S  = 20                ; 20 × 50 ms = 1 second
TIMER_LOOPS_5S  = 100               ;5 seconds
TIMER_LOOPS_10S  = 200               ;10 seconds

TIMER_LOOPS_1M  = 6                ; 6 × 10 seconds = 1 minute
TIMER_LOOPS_10M  = 60                ; 60 × 10 seconds = 10 minute

;Memory Mappings
;these are constants where we reflect the number of the memory position

screenBufferLow =$00 ;goes to $50 which is 80 decimal
screenBufferHigh =$30

lcdCharPositionsLow =$00 ;goes to $50 which is 80 decimal
lcdCharPositionsHigh =$31

;bin 2 ascii values
; value =$0200 ;2 bytes, Low 16 bit half
; mod10 =$0202 ;2 bytes, high 16 bit half and as it has the remainder of dividing by 10
;              ;it is the mod 10 of the division (the remainder)
; message = $0204 ; the result up to 6 bytes
; counter = $020a ; 2 bytes

;define LCD signals
E = %10000000 ;Enable Signal
RW = %01000000 ; Read/Write Signal
RS = %00100000 ; Register Select

  .org $8000


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------STACK, INTERRUPTs----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

RESET:
  ;initialize stack
  ldx #$ff
  txs ;transfer x index register to stack register
  ;clear interrupt disable bit
  cli ;sets at zero the interrupt disable bit 
      ;N Z C I D V
      ;- - - 0 - -


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------STACK, INTERRUPTs----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;in bank0
;screen base =0
;screen id = screen_base+screen_id
programStart:
  ;initialize variables, vectors, memory mappings and constans DONE
  ;configure stack and enable interrupts DONE
  ;Initialize HARDWARE
  jsr viaLcdInit
  jsr viaRsInit
  ;jsr viaSoundInit
  jsr uartSerialInit
  jsr screenInit
  jsr lcdDemoMessage
  ;jmp listeningMode
  ;start MainProgran and I save stack space by not jumping to it
mainProgram:
  ;initialize Variables 
  ;initialize screen as screen zero
  jsr initilizationRoutines
  jsr select_dashboard
  jsr printerWelcomeMessage
  ; ;switch bank to 1  
  ; jsr bankswitch1
  ; jsr select_screen
  ; jsr draw_current_screen_table
  ; ;switch bank to 0   
  ; jsr bankswitch0
mainProgramLoop:
  lda #$0
  sta moveNextScreen ;reset the move next screen flag
  ;switch bank to 1    
  jsr bankswitch1  
  jsr select_screen
  jsr draw_current_screen_table
  ;switch bank to 0   
  jsr bankswitch0
  jsr checkEndScreen  
  lda gameEnded
  bne mainProgram
  jsr printSimulationTimeStatus
  jsr printFlashlightStatus
  jsr action_selector
  jsr sensor_selector  
  jsr checkSecretScreen
  jsr checkActionFailed
  jsr checkEnemyAppeared
  jsr checkSimulationTimeisUp
  lda moveNextScreen
  beq mainProgramLoop;if zero do not move to next screen and ask for actions
  ; lda #$0
  ; sta moveNextScreen ;reset the move next screen flag
  ; ;switch bank to 1  
  ; jsr bankswitch1  
  ; jsr select_screen
  ; jsr draw_current_screen_table
  ; ;switch bank to 0   
  ; jsr bankswitch0
  ;we 
  ;here the games continue so we jump to the loop and continue
  jmp mainProgramLoop   
  rts

; mainProgram:
;   ;initialize Variables 
;   ;initialize screen as screen zero
;   jsr initilizationRoutines
;   jsr select_dashboard
;   jsr printerWelcomeMessage
;   ;switch bank to 1  
;   jsr bankswitch1
;   jsr select_screen
;   jsr draw_current_screen_table
;   ;switch bank to 0   
;   jsr bankswitch0
; mainProgramLoop:
;   ;jsr simulationTimeWaterLevelCheck
;   jsr printFlashlightStatus
;   jsr action_selector
;   jsr sensor_selector  
;   jsr checkSecretScreen
;   lda gameEnded
;   bne mainProgram
;   jsr checkActionFailed
;   jsr checkEnemyAppeared
;   jsr checkSimulationTimeisUp
;   lda moveNextScreen
;   beq mainProgramLoop;if zero do not move to next screen and ask for actions
;   lda #$0
;   sta moveNextScreen ;reset the move next screen flag
;   ;switch bank to 1  
;   jsr bankswitch1  
;   jsr select_screen
;   jsr draw_current_screen_table
;   ;switch bank to 0   
;   jsr bankswitch0
;   jsr checkEndScreen
;   ;we 
;   ;here the games continue so we jump to the loop and continue
;   jmp mainProgramLoop   
;   rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------BANKSWITCHING ROUTINES-------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------------------------------------------------------- 

bankswitch0:
  pha
  tya ;save Y because i am going to another process
  pha ;save Y because i am going to another process
  txa ;save X because i am going to another process
  pha ;save X because i am going to another process
  ldx #$1
  lda #$0 ;select bank 1
  sta RS_PORTA
bankswitch0_loop:
  txa
  beq bankswitch0_continue
  inx  
  jmp bankswitch0_loop  
bankswitch0_continue:  
  jsr delay_1_sec
  pla
  tax
  pla
  tay
  pla
  rts  

bankswitch1:
  pha
  tya ;save Y because i am going to another process
  pha ;save Y because i am going to another process
  txa ;save X because i am going to another process
  pha ;save X because i am going to another process
  ldx #$1
  lda #$1 ;select bank 1
  sta RS_PORTA
bankswitch1_loop:
  txa
  beq bankswitch1_continue
  inx  
  jmp bankswitch1_loop  
bankswitch1_continue:  
  jsr delay_1_sec
  pla
  tax
  pla
  tay
  pla
  rts   

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------BANKSWITCHING ROUTINES-------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------------------------------------------------------- 


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------ENDING---------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

checkActionFailed:
  ; jsr bin_2_ascii_random
  ; jsr bin_2_ascii_waterLevel
  ; jsr bin_2_ascii_actionFailedProbWaterPerLevel
  ; jsr bin_2_ascii_actionFailedProbFlashlight
  ; jsr bin_2_ascii_actionFailedProbHeartRate
  ; jsr bin_2_ascii_actionFailedWaterFlashLightHeartRate
  ; jsr bin_2_ascii_actionFailedProb
  ; jsr bin_2_ascii_actionFailedProbabilityTotal 
  sec
  lda randomNumber
  sbc actionFailedProbabilityTotal
  ; if the carry is clear random number is
  ;less than enemyProbabilityTotal
  bcc checkActionFailed_failed
  ;here you are free
  ; lda #<msj_actionSuceeded
  ; sta serialDataVectorLow
  ; lda #>msj_actionSuceeded
  ; sta serialDataVectorHigh
  ; jsr printAsciiDrawing
  rts
checkActionFailed_failed:  
  ;here you where caught
  ; lda #<msj_actionFailed
  ; sta serialDataVectorLow
  ; lda #>msj_actionFailed
  ; sta serialDataVectorHigh
  ; jsr printAsciiDrawing  
  ;prints the description of the failed action
  lda action_desc_action_failed_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  lda #$1
  sta endByActionFailed
  lda endScreenByActionFailed
  sta screenCurrentID
  lda #$1
  sta moveNextScreen  
  lda #$1
  sta gameEnded  
  rts


checkEnemyAppeared:
  ; jsr bin_2_ascii_random
  ; jsr bin_2_ascii_enemyActionProb
  ; jsr bin_2_ascii_enemyProbActionCostCummulative
  ; jsr bin_2_ascii_enemyProbFlashlight
  ; jsr bin_2_ascii_Action_Plus_Flashlight
  ; jsr bin_2_ascii_currentScreen
  ; jsr bin_2_ascii_enemy
  ;if random is bigger than probability enemy you are ok
  sec
  lda randomNumber
  sbc enemyProbabilityTotal
  ; if the carry is clear random number is
  ;less than enemyProbabilityTotal
  bcc checkEnemyAppeared_caught
  ;here you are free
  ; lda #<msj_enemyEscape
  ; sta serialDataVectorLow
  ; lda #>msj_enemyEscape
  ; sta serialDataVectorHigh
  ; jsr printAsciiDrawing
  rts
checkEnemyAppeared_caught:  
  ;here you where caught
  ; lda #<msj_enemyCaught
  ; sta serialDataVectorLow
  ; lda #>msj_enemyCaught
  ; sta serialDataVectorHigh
  ; jsr printAsciiDrawing  
  lda #$1
  sta endByEnemy
  lda endScreenByEnemy
  sta screenCurrentID
  lda #$1
  sta moveNextScreen  
  lda #$1
  sta gameEnded
  rts

printSimulationTimeStatus:
  lda waterLevel
  beq printSimulationTimeStatus_end
  lda #<msj_waterTimer
  sta serialDataVectorLow  
  lda #>msj_waterTimer
  sta serialDataVectorHigh 
  jsr send_rs232_line_noCRLF
  jsr setSimulationTimerBars
  jsr printSimulationTimerBars
printSimulationTimeStatus_end:
  rts

checkSimulationTimeisUp:
  ;jsr bin_2_ascii_simulationTime
  ;substract current simulationTimePassed from maxSimulationTime
  lda timerOn
  beq checkSimulationTimeisUp_End
  sec
  lda maxSimulationTimeLowByte
  sbc simulationTimePassedLowDigits
  sta timeRemainingLowByte
  lda maxSimulationTimeHighByte
  sbc simulationTimePassedHighDigits
  sta timeRemainingHighByte
  ;if there is a carry the result was positive
  bcs checkSimulationTimeisUp_WaterLevel
  ;here there is a carry clear so the result is negative and time is up
  lda endScreenSimulationTimeisUp ;endScreens1s1 id
  sta screenCurrentID
  lda #$1
  sta moveNextScreen  
  lda #$1
  sta gameEnded
  lda #$1
  sta simulationTimeExpired
  sta endByTimeUp
  jmp checkSimulationTimeisUp_End
checkSimulationTimeisUp_WaterLevel:
  ; lda #<msj_waterTimer
  ; sta serialDataVectorLow  
  ; lda #>msj_waterTimer
  ; sta serialDataVectorHigh 
  ; jsr send_rs232_line_noCRLF
  ; jsr setSimulationTimerBars
  ; jsr printSimulationTimerBars
;   lda currentNumberOfBars
;   clc 
;   adc #$30
;   jsr send_rs232_char
  jsr setSimulationTimerBars
  jsr calculateNumberOfBars
  sec
  lda currentNumberOfBars
  sbc waterLevel
  sta levelsToIncreaseWater
  bcc checkSimulationTimeisUp_End
  beq checkSimulationTimeisUp_End
  ;here increase the water level
;  lda levelsToIncreaseWater
;   clc 
;   adc #$30
;   jsr send_rs232_char
  ldx levelsToIncreaseWater
checkSimulationTimeisUp_IncWaterLevel:  
  cpx #0
  beq checkSimulationTimeisUp_End
  ;here we increase the water level
  txa
  pha
  jsr increaseWaterLevel
  pla
  tax
  dex
  jmp checkSimulationTimeisUp_IncWaterLevel
checkSimulationTimeisUp_End:  
  ; jsr bin_2_ascii_simulationTime
  ; jsr bin_2_ascii_waterLevel
  rts

checkSecretScreen:
  lda isSecretScreenVariable
  beq checkSecretScreen_end
  inc secretsFound
checkSecretScreen_end:
  rts  

checkEndScreen_End_Up:
  ;here to avoid teh 127 byte distance for beq
  rts  
  
checkEndScreen:
  lda isEndScreenVariable
  beq checkEndScreen_End_Up
  lda #<msj_progressScreen1
  sta serialDataVectorLow  
  lda #>msj_progressScreen1
  sta serialDataVectorHigh
  jsr printAsciiDrawing 
  lda #<msj_end_printer
  sta serialDataVectorLow  
  lda #>msj_end_printer
  sta serialDataVectorHigh
  jsr printAsciiDrawingPrinter
  lda #<msj_progressScreen1
  sta serialDataVectorLow  
  lda #>msj_progressScreen1
  sta serialDataVectorHigh  
  jsr printAsciiDrawingPrinter 
  lda #<msj_progressScreen2
  sta serialDataVectorLow  
  lda #>msj_progressScreen2
  sta serialDataVectorHigh  
  jsr send_rs232_line_noCRLF
  lda #<msj_progressScreen2
  sta serialDataVectorLow  
  lda #>msj_progressScreen2
  sta serialDataVectorHigh
  jsr printAsciiDrawingPrinter  
  lda #$1
  sta gameEnded
  jsr setSimulationTimerBars
  jsr printSimulationTimerBars
  jsr printSimulationTimerBarsPrinter
  ;jsr bin_2_ascii_simulationTime
  lda #<msj_progressScreen3
  sta serialDataVectorLow  
  lda #>msj_progressScreen3
  sta serialDataVectorHigh
  jsr printAsciiDrawing 
  lda #<msj_progressScreen3
  sta serialDataVectorLow  
  lda #>msj_progressScreen3
  sta serialDataVectorHigh  
  jsr printAsciiDrawingPrinter 
  lda endByActionFailed
  beq checkEndScreen_TimeUp
  lda #<msj_progressScreen4
  sta serialDataVectorLow  
  lda #>msj_progressScreen4
  sta serialDataVectorHigh
  jsr printAsciiDrawing 
  lda #<msj_progressScreen4_printer
  sta serialDataVectorLow  
  lda #>msj_progressScreen4_printer
  sta serialDataVectorHigh
  jsr printAsciiDrawingPrinter 
checkEndScreen_TimeUp:
  lda endByTimeUp
  beq checkEndScreen_Enemy
  lda #<msj_progressScreen5
  sta serialDataVectorLow  
  lda #>msj_progressScreen5
  sta serialDataVectorHigh
  jsr printAsciiDrawing   
  lda #<msj_progressScreen5
  sta serialDataVectorLow  
  lda #>msj_progressScreen5
  sta serialDataVectorHigh  
  jsr printAsciiDrawingPrinter 
checkEndScreen_Enemy:  
  lda endByEnemy
  beq checkEndScreen_ActionDirect
  lda #<msj_progressScreen6
  sta serialDataVectorLow  
  lda #>msj_progressScreen6
  sta serialDataVectorHigh
  jsr printAsciiDrawing 
  lda #<msj_progressScreen6
  sta serialDataVectorLow  
  lda #>msj_progressScreen6
  sta serialDataVectorHigh  
  jsr printAsciiDrawingPrinter 
checkEndScreen_ActionDirect:
  lda endByDirectAction
  beq checkEndScreen_Secrets
  lda #<msj_progressScreen7
  sta serialDataVectorLow  
  lda #>msj_progressScreen7
  sta serialDataVectorHigh
  jsr printAsciiDrawing 
  lda #<msj_progressScreen7_printer
  sta serialDataVectorLow  
  lda #>msj_progressScreen7_printer
  sta serialDataVectorHigh  
  jsr printAsciiDrawingPrinter 
checkEndScreen_Secrets:
  lda #<msj_secretsFound
  sta serialDataVectorLow  
  lda #>msj_secretsFound
  sta serialDataVectorHigh
  jsr printAsciiDrawing 
  jsr bin_2_ascii_secrets
  lda #<msj_secretsFound
  sta serialDataVectorLow  
  lda #>msj_secretsFound
  sta serialDataVectorHigh  
  jsr printAsciiDrawingPrinter
  jsr bin_2_ascii_secrets_printer
checkEndScreen_End:
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------ENDING---------------------------------------------
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
;--------------------------------INITIALIZATION-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initilizationRoutines:
  ;sei ;disable interrupts only to be enabled prior to user input or timer
  ;the only time interrupts will work is while waiting for user input
  jsr loadConstants
  jsr initiatilizeActionsIDs
  jsr startTimerForRandom
  jsr heartbeatOffSensor
  rts

loadConstants:
  ;add it to the SCREEN FILE the max number of actions calculated from the amount of actions in the screen
  lda #$4 
  sta max_actions_per_screen
  lda dashboardHighWaterLevel ; user zero to check and hide options
  sta highWaterLevel
  lda dashboardHighFearLevel
  sta highFearLevel
;VARIABLE  
  lda #$0
  sta print_no_CRLF  
  lda #$0
  sta actionCostTotal
  lda #$0
  sta moveNextScreen
  ;add it to the SCREEN FILE to choose in the dashboard in which screen to start
  lda dashboardStartScreen
  sta screenCurrentID  
  lda #$ff
  sta userOptionSelection  
  ;new added
  lda #$0
  sta fearLevel
  lda #$0
  sta waterLevel
  lda #$8
  sta maximumWaterLevel
  sta simulationSegments
  lda #$4
  sta flashlightSegments
  lda #$0 ;flashlight off
  ;lda #$1 ; you cannot turn on the flashlight
  sta flashlightOff ;flashlight off  
  lda #$0 ;flashlight off
  ;lda #$1 ; flashlight on
  sta flashlightStatus ;flashlight off
  lda #$0
  sta gameEnded
  lda #$0
  sta simulationTimePassedLowDigits
  sta simulationTimePassedHighDigits
  lda #$0  
  sta flashlightSecondsUsedLowByte
  sta flashlightSecondsUsedHighByte
  lda #$0
  sta dashboardCurrentID
  lda dashboardEndScreenTimeUp
  sta endScreenSimulationTimeisUp
  lda dashboardEndScreenEnemy
  sta endScreenByEnemy ;endScreens1s1 id
  lda dashboardEndScreenActionFailed
  sta endScreenByActionFailed

  lda #$0
  sta randomNumber
  sta enemyProbActionReset
  sta enemyProbActionCost
  sta enemyProbActionCostCummulative
  sta enemyProbActionCummPlusFlashlight
  sta enemyProbFlashlight
  sta enemyProbCurrentScreen
  sta enemyProbabilityTotal
  sta actionFailedProb
  sta actionFailedProbWaterPerLevel
  sta actionFailedProbFlashlight
  sta actionFailedProbHeartRate
  sta actionFailedWaterFlashLightHeartRate
  sta actionFailedProbabilityTotal
  sta barMaximumTimerLow
  sta barMaximumTimerHigh
  sta segmentBarSizeHigh
  sta segmentBarSizeLow
  sta currentTimeBarHigh
  sta currentTimeBarLow
  sta currentSegmentBarSizeHigh
  sta currentSegmentBarSizeLow
  sta barSegmentNumbers
  sta emptyBars
  sta currentNumberOfBars 
  sta printableNumberOfBars
  sta endByTimeUp
  sta endByEnemy
  sta endByActionFailed
  sta endByDirectAction
  sta timerOn
  sta secretsFound
  sta rs232Printer
  sta flashLightSensor
  rts 


startTimerForRandom:
  lda #$50
  sta LCD_T1CL
  lda #$20
  sta LCD_T1CH ;here starts the timer
  lda #$70
  sta LCD_T2CL
  lda #$60
  sta LCD_T2CH
  ;to read a random value just read LCD_T1CL
  rts

initiatilizeActionsIDs:  
  lda #$ff
  ldx #$0
initiatilizeActionsIDs_loop:
  sta actionIDOptionsRAM,x
  inx
  cpx max_actions_per_screen
  bne initiatilizeActionsIDs_loop
  rts  

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------INITIALIZATION-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------DASHBOARD----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

select_dashboard:
  lda dashboardCurrentID
  jsr load_dashboard_ram
    ;read from the dashboard the cost of flashlight off in seconds
  ldx dashboard_extra_flashlight_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta extraSecondsFlashlightOffHighByte 
  iny 
  lda (sourceDashboardVectorLow),Y
  sta extraSecondsFlashlightOffLowByte   
  ldx dashboard_extra_heartrate_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta extraSecondsHeartRateHighByte 
  iny 
  lda (sourceDashboardVectorLow),Y
  sta extraSecondsHeartRateLowByte   
  ;load water level offsets
  ldx dashboard_extra_water_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta extraSecondsWaterLevelHighByte 
  iny 
  lda (sourceDashboardVectorLow),Y
  sta extraSecondsWaterLevelLowByte    
  ;load maxi simulation Times
  ldx dashboard_total_sim_time_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta maxSimulationTimeHighByte 
  iny 
  lda (sourceDashboardVectorLow),Y
  sta maxSimulationTimeLowByte   
  ;load flashlight simulation Times
  ldx dashboard_total_flash_time_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta maxFlashlightTimeHighByte 
  iny 
  lda (sourceDashboardVectorLow),Y
  sta maxFlashlightTimeLowByte  
  ;load Enemy Probability per Flashlight
  ldx dashboard_enemy_flash_on_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta enemyProbFlashlight   
  ;load action Failed prob flashlight
  ldx dashboard_death_flashlight_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta actionFailedProbFlashlight 
  ;load action Failed prob hearrate
  ldx dashboard_death_heartrate_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta actionFailedProbHeartRate
  ;load action Failed prob flashlight
  ldx dashboard_death_water_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta actionFailedProbWaterPerLevel      
  ;load start screen
  ldx dashboard_start_screen_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta dashboardStartScreen   
  ;load end screen default
  ldx dashboard_end_screen_default_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta dashboardEndScreenDefault 
  ;load end screen enemy
  ldx dashboard_end_screen_enemy_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta dashboardEndScreenEnemy
  ;load end screen time up
  ldx dashboard_end_screen_timeup_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta dashboardEndScreenTimeUp
  ;load end screen action failed
  ldx dashboard_end_screen_enemy_af_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta dashboardEndScreenActionFailed 
  ;load high water level
  ldx dashboard_high_water_level_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta dashboardHighWaterLevel
  ;load high fear
  ldx dashboard_high_heart_level_offset
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorLow
  inx
  lda dashboardPointersRAM,x
  sta sourceDashboardVectorHigh
  ldy #$0
  lda (sourceDashboardVectorLow),Y
  sta dashboardHighFearLevel
  rts

load_dashboard_ram:
  lda dashboardCurrentID
  ;multiply by 2 the id
  asl ;if not screen zero multiple by 2
  sta current_dashboard_offset
  ldx current_dashboard_offset ;byte 6 if it is screen 3
  ;store in sourceScreenVector the address of screen_x_id
  ;use screen zero
  lda dashboard_index,x
  sta sourceDashboardVectorLow
  inx
  lda dashboard_index,x
  sta sourceDashboardVectorHigh
  ;store in ramScreenVectorLow the address of the RAM portin for the screen
  lda #<dashboardPointersRAM
  sta dashboardScreenVectorLow
  lda #>dashboardPointersRAM
  sta dashboardScreenVectorHigh
  ldy #$ff
load_dashboard_ram_loop:
  iny
  cpy dashboard_record_length
  beq load_dashboard_ram_end
  lda (sourceDashboardVectorLow),Y
  sta (dashboardScreenVectorLow),Y
  jmp load_dashboard_ram_loop
load_dashboard_ram_end:
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------DASHBOARD----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

select_screen:
  lda screenCurrentID
  jsr load_screen_ram
  jsr load_screen_variables
  rts

load_screen_ram:
  lda screenCurrentID
  ;multiply by 2 the id
  asl ;if not screen zero multiple by 2
  sta current_screen_offset
  ldx current_screen_offset ;byte 6 if it is screen 3
  ;store in sourceScreenVector the address of screen_x_id
  ;use screen zero
  lda screens_index,x
  sta sourceScreenVectorLow
  inx
  lda screens_index,x
  sta sourceScreenVectorHigh
  ;store in ramScreenVectorLow the address of the RAM portin for the screen
  lda #$00
  sta ramScreenVectorLow
  lda #$05
  sta ramScreenVectorHigh
  ldy #$ff
load_screen_ram_loop:
  iny
  cpy screen_record_length
  beq load_screen_ram_end
  lda (sourceScreenVectorLow),Y
  sta (ramScreenVectorLow),Y
  jmp load_screen_ram_loop
load_screen_ram_end:
  rts

load_screen_variables:
  ;end screen variable
  ldx screen_is_end_screen_offset
  lda screenPointersRAM,X
  sta sourceScreenVectorLow
  inx
  lda screenPointersRAM,X
  sta sourceScreenVectorHigh
  ldy #$0
  lda (sourceScreenVectorLow),Y  
  sta isEndScreenVariable
  ;secret screen variable
  ldx screen_is_secret_screen_offset
  lda screenPointersRAM,X
  sta sourceScreenVectorLow
  inx
  lda screenPointersRAM,X
  sta sourceScreenVectorHigh
  ldy #$0
  lda (sourceScreenVectorLow),Y  
  sta isSecretScreenVariable
  ;screen enemy probability
  ldx screen_enemy_probability_offset
  lda screenPointersRAM,X
  sta sourceScreenVectorLow
  inx
  lda screenPointersRAM,X
  sta sourceScreenVectorHigh
  ldy #$0
  lda (sourceScreenVectorLow),Y
  sta enemyProbCurrentScreen
  ;screen actions
  ldx screen_action_offset
  lda screenPointersRAM,X
  sta sourceScreenVectorLow
  inx
  lda screenPointersRAM,X
  sta sourceScreenVectorHigh
  ldy #$0
  ldx #$0
screen_actions_loop:
  lda (sourceScreenVectorLow),Y
  sta currentScreenAllActionsRAM,x ;is goes from 0 to 3 in max aciotns = 4
  iny
  inx
  cpx max_actions_per_screen
  bne screen_actions_loop
  rts

draw_current_screen_table:
  jsr draw_screen_ascii
  jsr draw_screen_description
  jsr draw_screen_description_flashlight
  rts

draw_screen_ascii:
  lda screen_ascii_offset
  sta screenPrintOffset
  jsr draw_screen
  rts  

draw_screen_description:
  lda screen_description_offset
  sta screenPrintOffset
  jsr draw_screen
  rts  

draw_screen_description_flashlight:
  lda flashlightStatus
  ;if it is not zero then it is on
  bne draw_screen_description_flashlight_on
  ;flashlight off, the flashlightStatus was zero
  lda screen_flashlight_off_offset
  sta screenPrintOffset  
  jsr draw_screen
  rts   
draw_screen_description_flashlight_on:  
  lda screen_flashlight_on_offset
  sta screenPrintOffset
  jsr draw_screen
  rts    

draw_screen:  
  ldx screenPrintOffset  ;description offset
  lda screenPointersRAM,x 
  sta serialDataVectorLow  
  inx 
  lda screenPointersRAM,x
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

draw_screen_by_ram_ascii:  
  ldx screen_ascii_offset  ; offset ascii
  lda screenPointersRAM,x
  ;lda $051e ;the 30 offset starting ascii low byte
  sta serialDataVectorLow  
  inx 
  lda screenPointersRAM,x
  ;lda $051f ;the 31 offset starting ascii high byte
  sta serialDataVectorHigh
  jsr printAsciiDrawing

; draw_screen_by_hand:  
;   ldx screenPrintOffset  ;description offset
;   lda #<screen_0_ascii
;   sta serialDataVectorLow  
;   inx 
;   lda #>screen_0_ascii
;   sta serialDataVectorHigh
;   jsr printAsciiDrawing

;   lda #<screen_0_flashlight_on
;   sta serialDataVectorLow  
;   inx 
;   lda #>screen_0_flashlight_on
;   sta serialDataVectorHigh
;   jsr printAsciiDrawing  
  rts    


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------ACTION------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

addActionCost:
  ;do not add time on timerOn 0 (timer is off)
  lda timerOn
  beq addActionCost_WaterLevel_End
  ;add direct action costs in simulation seconds
  lda currentActionCost
  ;lda #1
  clc
  adc simulationTimePassedLowDigits
  sta simulationTimePassedLowDigits
  ;add the carry if there was one
  lda #$0
  adc simulationTimePassedHighDigits
  sta simulationTimePassedHighDigits
  ;add cost for Flashlight Off
  lda flashlightStatus
  bne addActionCost_HearRate
  ;here the flashlight is Off as flashlight status is zero
  ;read from the dashboard the cost of flashlight off in seconds
  lda extraSecondsFlashlightOffLowByte
  clc
  adc simulationTimePassedLowDigits
  sta simulationTimePassedLowDigits
  ;add the carry if there was one
  lda extraSecondsFlashlightOffHighByte
  adc simulationTimePassedHighDigits
  sta simulationTimePassedHighDigits 
addActionCost_HearRate:  
  lda fearLevel
  beq addActionCost_WaterLevel
  ;here the fearLevel is on 1 or more 
  lda extraSecondsHeartRateLowByte
  clc
  adc simulationTimePassedLowDigits
  sta simulationTimePassedLowDigits
  ;add the carry if there was one
  lda extraSecondsHeartRateHighByte
  adc simulationTimePassedHighDigits
  sta simulationTimePassedHighDigits
addActionCost_WaterLevel:  
  ;load the water level on the X register
  ;add seconds per level until we reach level zero
  ;if we start at level zero we add no seconds
  ldx waterLevel
addActionCost_WaterLevel_Loop:
  txa
  beq addActionCost_WaterLevel_End
  lda extraSecondsWaterLevelLowByte
  clc
  adc simulationTimePassedLowDigits
  sta simulationTimePassedLowDigits
  ;add the carry if there was one
  lda extraSecondsWaterLevelHighByte
  adc simulationTimePassedHighDigits
  sta simulationTimePassedHighDigits
  dex
  jmp addActionCost_WaterLevel_Loop
addActionCost_WaterLevel_End  
  rts



loadScreenActionOptions:
  jsr printActionsHeader
  ldy #$0
loadScreenActionOptions_loop:
  lda currentScreenAllActionsRAM,y
  sta actionCurrentID
  ;check to see if action is hidden
  ;according to 
  ;fearLevel
  ;waterLevel
  ;Flashlight Off
  tya ;save Y because i am going to another process
  pha ;save Y because i am going to another process
  jsr checkActionVisibility
  pla ;retrieve Y after processAction
  tay ;retrieve Y after processAction
  lda actionHidden
  bne nextAction ;action  hidden is not zero hide the action
  ;if we are here the action is visible
  tya ;save Y because i am going to another process
  pha ;save Y because i am going to another process
  sty actionPosition
  ldx actionPosition
  lda actionCurrentID
  sta actionIDOptionsRAM,x ;save the action on the position to show for options
  jsr processAction
  pla ;retrieve Y after processAction
  tay ;retrieve Y after processAction
nextAction:  
  iny ;go to next action of the screen
  cpy max_actions_per_screen ;max objects per screen 0-3 for now 
  ;check if the actions menu goes 4 time
  bne loadScreenActionOptions_loop
  rts

checkActionVisibility:
  lda #$0 ;by default the actions are not hidden
  sta actionHidden ;the action is not hidden on 0 and hidden on 1
  lda actionCurrentID
  asl ;multiply by two 
  tax
  lda actions_index,x
  sta pivotZpLow
  inx
  lda actions_index,x
  sta pivotZpHigh
  ldy action_hide_water_offset
  ;on pivotZpLow and High I have the address of the action pointer
  ;for example action pointer 3, this is another address table
  ;by adding the offset to Y, we will now retrieve another address
  ;that final address will have the the data we seek
  lda (pivotZpLow),Y
  sta actionCheckVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionCheckVectorHigh  
  ;now on actionCheckVector Low and High I have the address
  ;where the action_3_hide_water is, we do not need and offset but we need indirect access
  ;so we use 0 as offset
  ldy #$0
  lda (actionCheckVectorLow),Y
  sta currentActionHideWater
  ;now we load fear
  ldy action_hide_fear_offset
  lda (pivotZpLow),Y
  sta actionCheckVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionCheckVectorHigh  
  ldy #$0
  lda (actionCheckVectorLow),Y  
  sta currentActionHideFear
  ;now we load flashlight  
  ldy action_hide_flashlight_offset
  lda (pivotZpLow),Y
  sta actionCheckVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionCheckVectorHigh  
  ldy #$0
  lda (actionCheckVectorLow),Y  
  sta currentActionHideFlashlightOff
checkActionVisibility_checkWater:  
  ;Now we start checking
  lda currentActionHideWater  
  beq checkActionVisibility_checkFear ;not hide on water levelif it is zero 
  ;here we check the water level we are on high for water
  lda waterLevel ;current water level
  ;lda highWaterLevel ;force hight water level tohide action
  cmp highWaterLevel
  bne checkActionVisibility_checkFear
  jmp checkActionVisibility_hide
  ;For now only checking on water Level
checkActionVisibility_checkFear:  
  lda currentActionHideFear
  beq checkActionVisibility_checkFlashlight ;not hide on water levelif it is zero 
  lda fearLevel
  ;lda highFearLevel ;force high fear level to hide action
  cmp highFearLevel
  bne checkActionVisibility_checkFlashlight
  jmp checkActionVisibility_hide
checkActionVisibility_checkFlashlight:  
  lda currentActionHideFlashlightOff
  beq checkActionVisibility_End
  lda flashlightStatus ;if it is zero the flash light is off
  ;lda #$1 ;force flashlight on to check on visilibity of action
  cmp flashlightOff ;it is zero the flash is off
  ;if flash ligth is on return
  bne checkActionVisibility_End
  ;here the flashlight is off
  jmp checkActionVisibility_hide
checkActionVisibility_hide:
  lda #$1
  sta actionHidden
  rts  
checkActionVisibility_End:  
  lda #$0
  sta actionHidden
  rts  

printLettersAction:
  ldx actionPosition
  lda letterActions,X
  jsr send_rs232_char
  lda #$29
  jsr send_rs232_char
  lda #$20
  jsr send_rs232_char
  rts  

printActionsHeader:
  lda #< actions_header
  sta serialDataVectorLow  
  lda #> actions_header
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

processAction:
  lda actionCurrentID
  cmp #$ff ;invalid object so that slot is empty do not process
  beq end_processAction
  ;jsr action_multiple_calculate
  jsr printLettersAction
  ;jsr print_current_action_name
  jsr print_current_action_alias
end_processAction:  
  rts  

print_current_action_alias
  lda actionCurrentID
  asl ;multiply by two 
  tax
  lda actions_index,x
  sta pivotZpLow
  inx
  lda actions_index,x
  sta pivotZpHigh
  lda action_alias_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

print_current_action_name:
  lda actionCurrentID
  asl ;multiply by two 
  tax
  lda actions_index,x
  sta pivotZpLow
  inx
  lda actions_index,x
  sta pivotZpHigh
  lda action_name_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

receiveUserOptionSelection:
  ;ask for user input and wait
  ;wait infinity loop only interrupted by user input
  lda #$ff
  sta userOptionSelection
  cli ;enable interrupts to accept user action also the timer can interrupt here
receiveUserOptionSelection_loop:  
  lda userOptionSelection
  cmp #$ff   
  beq receiveUserOptionSelection_loop
  cmp #$4 ; fire button is disabled
  beq receiveUserOptionSelection_loop
  ;we have a valid user input 
  sei ;disable user action until we know if valid action if not ask again
  lda LCD_T2CL
  sta randomNumber
  ;jsr bin_2_ascii_random ;print the random number
  rts  

action_selector:;
  sei ;do not inrerrupt while running actions
  jsr initiatilizeActionsIDs
  jsr loadScreenActionOptions
  cli
action_selection_ask_again:  
  jsr receiveUserOptionSelection  
  ldx userOptionSelection
  lda actionIDOptionsRAM,x ;here we have the action ID
  sta selectedAction
  lda selectedAction
  cmp #$ff
  bne action_selection_option_ok
  jsr print_option_unknown
  jmp action_selection_ask_again
action_selection_option_ok:  
  jsr runAction
  cli
  rts

runActionEndBack:
  rts
  ;it is here so i can do a beq and it will not fail
  ;because it is more than 127 bytes away


runAction:
  ;an action does three things
  ;add the cost of executing the action
  ;substract battery from the flashlight
  ;prints a description
  ;moves you to a screen
  ;turn off or off a sensor
  ;select the offset of the Action
  lda selectedAction
  cmp #$ff ;invalid object so that slot is empty do not process
  beq runActionEndBack
  asl ;multiply by two 
  tax
  lda actions_index,x
  sta pivotZpLow
  inx
  lda actions_index,x
  sta pivotZpHigh
  ;add the cost of the action
  ldy action_cost_offset
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  sta currentActionCost
  jsr addActionCost
  jsr consumeFlashlight    
  ;prints the description of the action
  lda action_description_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  ;turns on/off a sensor
  lda action_sensor_id_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  ;always store the sensor ID for the Action specially if it is $FF
  sta sensorCurrentID 
  ;load if the sensor is or not active
  lda action_sensor_active_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  sta sensorCurrentStatus ;on off  
  ;load if the enemy accumulated probability should be reset
  lda action_reset_enemy_prob_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  sta enemyProbActionReset
  ;add the action probability to the enemy accumulated probability
  lda action_enemy_probability_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  sta enemyProbActionCost
  jsr enemyProbabilityCalculation
  ;add the action probability to fail
  lda action_death_probability_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  sta actionFailedProb
  jsr actionFailedProbCalculation  
  ;moves you to next screen
  lda action_screen_offset
  tay
  lda (pivotZpLow),Y
  sta actionDataVectorLow
  iny 
  lda (pivotZpLow),Y
  sta actionDataVectorHigh  
  ldy #$0
  lda (actionDataVectorLow),Y
  cmp #$ff ;invalid screen so that slot is empty do not process
  beq runActionEnd
  sta screenCurrentID
  lda #$1
  sta moveNextScreen
runActionEnd:
  rts

print_option_unknown
  lda #< option_unknown
  sta serialDataVectorLow  
  lda #> option_unknown
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

print_with_or_without_CRLF  
  lda print_no_CRLF
  bne printing_NOCRLF
  jsr printAsciiDrawing
  rts
printing_NOCRLF:
  jsr send_rs232_line_noCRLF   
  rts

actionFailedProbCalculation:
  ;formula
  ;actionFailedProbabilityTotal = actionFailedProb x ((water x DeathProbWater Level)+DeathProbFlashlightOff+deathProbHighHeartRate)
  ;calculate water probability
  lda #$0
  sta actionFailedWaterFlashLightHeartRate
  ldx waterLevel
actionFailedProbCalculation_Water_Loop:
  cpx #$0
  beq actionFailedProbCalculation_FlashlightOff 
  lda actionFailedProbWaterPerLevel
  clc
  adc actionFailedWaterFlashLightHeartRate
  sta actionFailedWaterFlashLightHeartRate
  bcs actionFailedProbCalculation_MaximumLevel
  ;if the carry was set we reached 255
  ;if we are we have not and we keep accumulation water levels
  dex 
  jmp actionFailedProbCalculation_Water_Loop
actionFailedProbCalculation_FlashlightOff:
  ;only do this on flashlight off
  lda flashlightStatus
  ;if 1 the flashlight is on and we should skip
  bne actionFailedProbCalculation_HeartRate
  lda actionFailedProbFlashlight
  clc
  adc actionFailedWaterFlashLightHeartRate
  sta actionFailedWaterFlashLightHeartRate
  bcs actionFailedProbCalculation_MaximumLevel
actionFailedProbCalculation_HeartRate:
  ;only do this is hearrate is on
  lda heartRateLevel
  ;if zero the flashrate is off
  beq actionFailedMultiply
  lda actionFailedProbHeartRate
  clc
  adc actionFailedWaterFlashLightHeartRate
  sta actionFailedWaterFlashLightHeartRate
  bcs actionFailedProbCalculation_MaximumLevel
  beq actionFailedProbCalculation_one
  jmp actionFailedMultiply
actionFailedProbCalculation_one:
  lda #$1
  sta actionFailedWaterFlashLightHeartRate
  jmp actionFailedMultiply  
actionFailedProbCalculation_MaximumLevel:
  lda #255
  sta actionFailedWaterFlashLightHeartRate
  jmp actionFailedMultiply
actionFailedMultiply:
  ;multiply the action probability of failling
  ;against the WaterLevel, FlashlightOff and Heartrate Cumullative failing
  lda actionFailedProb
  sta multiFactor1
  lda actionFailedWaterFlashLightHeartRate
  sta multiFactor2
  jsr multiplyTwoNumbers8bitnumbers
  lda multiResultHigh
  beq actionFailedProbCalculation_less256
  ;here the high byte is not zero so we put the enemyProbabilityTotal
  ;at maximun of 255
  lda #255
  sta actionFailedProbabilityTotal
  jmp actionFailedProbCalculation_End
actionFailedProbCalculation_less256:
  lda multiResultLow
  sta actionFailedProbabilityTotal
actionFailedProbCalculation_End:
  ; jsr bin_2_ascii_random
  ; jsr bin_2_ascii_actionFailedProbHeartRate
  ; jsr bin_2_ascii_actionFailedWaterFlashLightHeartRate
  ; jsr bin_2_ascii_actionFailedProb
  ; jsr bin_2_ascii_actionFailedProbabilityTotal
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------ACTION------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SENSORS------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

sensor_selector:
;   lda #$73
;   jsr send_rs232_char 
;   lda sensorCurrentID
;   clc
;   adc #$30
;   jsr send_rs232_char  
  lda sensorCurrentID
  cmp #$ff
  beq sensor_selector_end
  cmp #$0
  beq sensor_selector_0
  cmp #$1
  beq sensor_selector_1
  cmp #$2
  beq sensor_selector_2
  cmp #$6
  beq sensor_selector_6  
  ;if we run out of sensors lets end
  jmp sensor_selector_end
sensor_selector_0:
  jsr sensor_0_run
  rts  
sensor_selector_1:
  jsr sensor_1_run
  rts    
sensor_selector_2:
  ;flashlightSensor
  jsr sensor_2_run
  rts    
sensor_selector_6:
  jsr sensor_6_run
  rts  
sensor_selector_end:
  rts

  
sensor_0_run:
  ;water sensor
  lda sensorCurrentStatus
  beq sensor_0_run_off
  lda sensorCurrentID
  asl
  tax
  lda sensors_index,X
  sta pivotZpLow
  inx
  lda sensors_index,X
  sta pivotZpHigh
  lda sensor_dialog_on_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr increaseWaterLevel
  rts
sensor_0_run_off:  
  rts

sensor_1_run:
  ;water sensor
  lda sensorCurrentID
  asl
  tax
  lda sensors_index,X
  sta pivotZpLow
  inx
  lda sensors_index,X
  sta pivotZpHigh
  lda sensorCurrentStatus
  beq sensor_1_run_off
  lda sensor_dialog_on_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr turnOnHearRate
  rts
sensor_1_run_off:  
  lda sensor_dialog_off_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr turnOffHearRate
  rts  

sensor_2_run:
  lda flashlightOff
  beq sensor_2_run_flashlight_with_batteries
  lda #<msj_flashlightOff
  sta serialDataVectorLow  
  lda #>msj_flashlightOff
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr flashLightOffSensor
  lda #$0
  sta flashlightStatus
  jmp sensor_2_run_End
sensor_2_run_flashlight_with_batteries:
  lda sensorCurrentID
  asl
  tax
  lda sensors_index,X
  sta pivotZpLow
  inx
  lda sensors_index,X
  sta pivotZpHigh
  ldy sensor_toggle_offset
  lda (pivotZpLow),Y
  sta sensorDataVectorLow
  iny
  lda (pivotZpLow),Y
  sta sensorDataVectorHigh
  ldy #$0
  lda (sensorDataVectorLow),y
  sta flashlightToggleFlag
  ; clc
  ; adc #$30
  ; jsr send_rs232_char
  ;here we have in the acummulator the togle for the sensor
  lda flashlightToggleFlag
  beq sensor_2_run_not_toggle
  ;here the sensor is a toggle one
  ;we know it is the one for the flashlight per design
  ; lda flashlightStatus
  ; clc
  ; adc #$30
  ; jsr send_rs232_char  
  lda flashlightStatus  
  beq sensor_2_toggle_one 
  jsr flashLightOffSensor
  lda #$0
  sta flashlightStatus
  sta sensorCurrentStatus
  jmp sensor_2_run_not_toggle
sensor_2_toggle_one:
  jsr flashLightOnSensor
  lda #$1
  sta flashlightStatus
  sta sensorCurrentStatus
sensor_2_run_not_toggle:  
  ; lda flashlightStatus
  ; clc
  ; adc #$30
  ; jsr send_rs232_char    
  lda sensorCurrentStatus
  beq printOffStatus
  ;if here status is not zero so it is on 
  lda sensor_dialog_on_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr flashLightOnSensor
  lda #$1
  sta flashlightStatus
  jmp sensor_2_run_End
printOffStatus:  
  lda sensor_dialog_off_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr flashLightOffSensor
  lda #$0
  sta flashlightStatus
sensor_2_run_End:
  rts

sensor_6_run:
  ;start sensor program
  lda flashlightOff
  beq sensor_6_run_flashlight_with_batteries
  lda #<msj_flashlightOff
  sta serialDataVectorLow  
  lda #>msj_flashlightOff
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr flashLightOffSensor
  lda #$0
  sta flashlightStatus
  lda #$1
  sta heartRateLevel
  jsr heartbeatOnSensor
  jmp sensor_6_run_End
sensor_6_run_flashlight_with_batteries:
  lda sensorCurrentID
  asl
  tax
  lda sensors_index,X
  sta pivotZpLow
  inx
  lda sensors_index,X
  sta pivotZpHigh
  ldy sensor_toggle_offset
  lda (pivotZpLow),Y
  sta sensorDataVectorLow
  iny
  lda (pivotZpLow),Y
  sta sensorDataVectorHigh
  ldy #$0
  lda (sensorDataVectorLow),y
  sta flashlightToggleFlag
  ; clc
  ; adc #$30
  ; jsr send_rs232_char
  ;here we have in the acummulator the togle for the sensor
  lda flashlightToggleFlag
  beq sensor_6_run_not_toggle
  ;here the sensor is a toggle one
  ;we know it is the one for the flashlight per design
  ; lda flashlightStatus
  ; clc
  ; adc #$30
  ; jsr send_rs232_char  
  lda flashlightStatus  
  beq sensor_6_toggle_one 
  jsr flashLightOffSensor
  lda #$0
  sta flashlightStatus
  sta sensorCurrentStatus
  lda #$1
  sta heartRateLevel
  jsr heartbeatOnSensor
  jmp sensor_6_run_not_toggle
sensor_6_toggle_one:
  jsr flashLightOnSensor
  lda #$1
  sta flashlightStatus
  sta sensorCurrentStatus  
  lda #$0
  sta heartRateLevel
  jsr heartbeatOffSensor
sensor_6_run_not_toggle:  
  ; lda flashlightStatus
  ; clc
  ; adc #$30
  ; jsr send_rs232_char    
  lda sensorCurrentStatus
  beq sensor_6_printOffStatus
  ;if here status is not zero so it is on 
  lda sensor_dialog_on_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
;   jsr setFlashlightTimerBars
;   jsr printFlashlightTimerBars_Reverse
  jmp sensor_6_run_End
sensor_6_printOffStatus:  
  lda sensor_dialog_off_offset
  tay
  lda (pivotZpLow),Y
  sta serialDataVectorLow  
  iny 
  lda (pivotZpLow),Y
  sta serialDataVectorHigh
  jsr printAsciiDrawing
sensor_6_run_End:
  rts

consumeFlashlight:
  lda flashlightStatus
  beq consumeFlashlight_End
  ;if we are here the flashlight is on
  lda currentActionCost
  ;lda #1
  clc
  adc flashlightSecondsUsedLowByte
  sta flashlightSecondsUsedLowByte
  ;add the carry if there was one
  lda #$0
  adc flashlightSecondsUsedHighByte
  sta flashlightSecondsUsedHighByte
  ;substract current flashlightSecondsUsedHighByte from maxFlashlightTime
  sec
  lda maxFlashlightTimeLowByte
  sbc flashlightSecondsUsedLowByte
  sta timeRemainingFlashLightLowByte
  lda maxFlashlightTimeHighByte
  sbc flashlightSecondsUsedHighByte
  sta timeRemainingFlashLightHighByte
  ;if there is a carry the result was positive
  bcs consumeFlashlight_KeepGoing
  ;here there is a carry clear so the result is negative and time is up    
  ;turn off the flashlight
  lda #$0
  sta flashlightStatus
  ;disable the hability to turn on the flashlight
  lda #$1
  sta flashlightOff
  lda #<msj_flashlightOff
  sta serialDataVectorLow  
  lda #>msj_flashlightOff
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jmp consumeFlashlight_End
consumeFlashlight_KeepGoing:  
  ;here we still have battery
  lda #$0
  sta flashlightOff
consumeFlashlight_End:
  rts  


timerAllGame:
  lda #<msj_timerAllGame
  sta serialDataVectorLow  
  inx 
  lda #>msj_timerAllGame
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  ;jsr timerWaitOneMinute 
  rts  

startTimerIdle:
  lda TIMER_ZP_MIN
  sta idleTimerStartMinute
  rts

timerCheckTimeIdleElapsed: ;called from interruptions
  lda idleTimerStartMinute
  sec
  sbc TIMER_ZP_MIN
  cmp #12;60 - 12 = 48 so it is 12  
  ;branch on carry clear is less than 2 minutes 
  bcc timerCheckTimeIdleElapsedEnd
  ;if we are here we ended the game
  rts
timerCheckTimeIdleElapsedEnd
  rts

check_sensor:
  jsr turnOnHearRate
  jsr delay_3_sec
  jsr turnOffHearRate
  jsr delay_3_sec
  jsr increaseWaterLevel
  jmp check_sensor

printFlashlightStatus:
  lda flashlightStatus
  beq printFlashlightStatus_End
  lda #<msj_flashlighBateria
  sta serialDataVectorLow
  lda #>msj_flashlighBateria
  sta serialDataVectorHigh
  jsr send_rs232_line_noCRLF
  jsr setFlashlightTimerBars
  jsr printFlashlightTimerBars_Reverse
printFlashlightStatus_End:
  rts

heartbeatOnSensor:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000001 ;bit 0 on 1 turn on heartrate 
  sta heartRateSensor
  jsr heartbeatSet
  rts

heartbeatOffSensor:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000000 ;bit 0 on 0 turn off heartrate
  sta heartRateSensor
  jsr heartbeatSet
  rts

flashLightOnSensor:
  lda #$1
  sta flashlightStatus
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000100 ;bit 0 on 1 turn on heartrate 
  sta flashLightSensor
  jsr flashLightSet
  rts

flashLightOffSensor:
  lda #$0
  sta flashlightStatus
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000000 ;bit 0 on 0 turn off heartrate
  sta flashLightSensor
  jsr flashLightSet
  rts

flashLightSet:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  ;we will modify port b bits PB1 and PB0
  lda RS_PORTB ;load what is already on port B
  and #%10111011 ;keep bits 7,5,4,3,2,1 and reset bits 6, 2 of port b
  sta RS_PORTB
  ora flashLightSensor ;set bit 6 for sync and bit 0.
  sta RS_PORTB ;set the new value
  rts  

increaseWaterLevelSensor:
  jsr waterOnSensor
  jsr waterSet
  jsr delay_3_sec
  jsr waterOffSensor
  jsr waterSet
  rts

waterSet:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  ;we will modify port b bits PB1 
  lda RS_PORTB ;load what is already on port B
  and #%10111101 ;keep bits 7,5,4,3,2,0 and reset bits 6, 1 of port b
  sta RS_PORTB
  ora waterLevelSensor ;set bit 6 for sync and bit 0.
  sta RS_PORTB ;set the new value
  rts  
  
waterOnSensor:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000010 ;bit 0 on 1 turn on heartrate 
  sta waterLevelSensor
  rts

waterOffSensor:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  lda #%01000000 ;bit 0 on 0 turn off heartrate
  sta waterLevelSensor
  rts

heartbeatSet:
  ;bit 6 activates SYNC and starts the reading on the Arduino of bit 0
  ;we will modify port b bits PB1 and PB0
  lda RS_PORTB ;load what is already on port B
  and #%10111110 ;keep bits 7,5,4,3,2,1 and reset bits 6, 1 and 0 of port b
  sta RS_PORTB
  ora heartRateSensor ;set bit 6 for sync and bit 0.
  sta RS_PORTB ;set the new value
  rts  
;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SENSORS------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------------ENEMY-------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

enemyProbabilityCalculation:
  lda enemyProbActionReset
  ;if zero no dot reset the Probability
  beq enemyProbabilityCalculation_addActionProb
  ;here the reset is one
  lda #$0
  sta enemyProbActionCostCummulative  
enemyProbabilityCalculation_addActionProb:
  clc
  lda enemyProbActionCostCummulative  
  adc enemyProbActionCost
  sta enemyProbActionCostCummulative
  bcc enemyProbabilityCalculation_addFlashlight
  ;if we are here the sum was greater than 255
  lda #255
  sta enemyProbActionCostCummulative
enemyProbabilityCalculation_addFlashlight:
  lda flashlightStatus
  ;if zero the flashlight is off
  beq enemyProbabilityCalculation_FlashLightOff
  ;here is one the flashlight is on we add the probabilty
  clc
  lda enemyProbActionCostCummulative
  adc enemyProbFlashlight
  sta enemyProbActionCummPlusFlashlight
  bcc enemyProbabilityCalculation_MultiplyScreenProb
  ;if we are here the sum was greater than 255
  lda #255
  sta enemyProbActionCummPlusFlashlight
  jmp enemyProbabilityCalculation_MultiplyScreenProb
enemyProbabilityCalculation_FlashLightOff:
  lda enemyProbActionCostCummulative 
  sta enemyProbActionCummPlusFlashlight  
enemyProbabilityCalculation_MultiplyScreenProb:
  ;multiply the enemy probability on the screen
  ;against the action cumullative and flashlight On prob
  lda enemyProbActionCummPlusFlashlight
  sta multiFactor1
  lda enemyProbCurrentScreen
  sta multiFactor2
  jsr multiplyTwoNumbers8bitnumbers
  lda multiResultHigh
  ;if it is zero is an 8 bit number
  beq enemyProbabilityCalculation_less256
  ;here the high byte is not zero so we put the enemyProbabilityTotal
  ;at maximun of 255
  lda #255
  sta enemyProbabilityTotal
  jmp enemyProbabilityCalculation_End
enemyProbabilityCalculation_less256:
  lda multiResultLow
  sta enemyProbabilityTotal
enemyProbabilityCalculation_End:
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------------ENEMY-------------------------------------------;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------HEARTRATE------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initializeHearRate:
  ;five heart rate levels 0 to 4
  lda #$0  
  sta heartRateLevel
  rts

increaseHeartRate:
  inc heartRateLevel
  rts

decreaseHeartRate:
  dec heartRateLevel
  rts  

checkHearRateLevel:
  lda #$2
  cmp heartRateLevel
  bcs checkHearRateLevel_greater ;is_greater_or_equal Branch if Carry Set (variable >= 6502)
  jsr turnOffHearRate 
checkHearRateLevel_greater: 
  jsr turnOnHearRate
  rts

turnOnHearRate:
  ; lda #< msj_heartOn
  ; sta serialDataVectorLow  
  ; lda #> msj_heartOn
  ; sta serialDataVectorHigh
  ; jsr printAsciiDrawing
  jsr heartbeatOnSensor
  lda #$1
  sta heartRateLevel
  ;add jump to a routine to show hate rate on the sensor
  rts   

turnOffHearRate:
  ; lda #< msj_heartOff
  ; sta serialDataVectorLow  
  ; lda #> msj_heartOff
  ; sta serialDataVectorHigh
  ; jsr printAsciiDrawing
  jsr heartbeatOffSensor
  lda #$0
  sta heartRateLevel  
  rts     

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------HEARTRATE------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------WATERLEVEL------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initializeWaterLevel:
  ;five heart rate levels 0 to 4
  lda #$0  
  sta waterLevel
  rts  

increaseWaterLevel:
  lda waterLevel
  cmp maximumWaterLevel
  beq increaseWaterLevelEnd
  inc waterLevel
  ; lda waterLevel
  ; clc 
  ; adc #$30
  ; jsr send_rs232_char
  ; lda #< msj_waterOn
  ; sta serialDataVectorLow  
  ; lda #> msj_waterOn
  ; sta serialDataVectorHigh
  ; jsr printAsciiDrawing  
  lda #$1
  sta timerOn
  jsr increaseWaterLevelSensor
increaseWaterLevelEnd:  
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------WATERLEVEL------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



  byte 00,00,00,00,00,00,00,00,00,00

;=============================================================
;Phrases
;=============================================================
actions_header:
  .ascii ""
  .ascii "Puedes realizar las siguientes acciones:"
  .ascii "e"  

letterActions:
  .ascii "ABCDE"  

pasamos:
  .ascii "Por aca pasamos"
  .ascii "e"

msj_heartOn:
  .ascii "Tu corazón se acelera y no puedes pensar"
  .ascii "e"    

msj_heartOff:
  .ascii "Tu corazón esta tranquilo"
  .ascii "e"

msj_waterOn:
  .ascii "El Agua Sube"
  .ascii "e"    

msj_secondElapsed:
  .ascii "Paso el tiempo"
  .ascii "e"    

msj_timerAllGame:
  .ascii "Comienza la Aventura tiene 10 minutos"
  .ascii "e"    

msj_timerExpired:
  .ascii "El tiempo pasa..."
  .ascii "e"    

msj_iddleTimer1:
  .ascii "El constante goteo era hipnotico. Gota, pausa, gota. "
  .ascii "El agua comenzo a entumecer tus extremidades hasta que dejaste de sentirlas. "
  .ascii "Un eterno sueño te dio la bienvenida. "    
  .ascii "e"     

option_unknown:
  .ascii "Mmmm esa opción no es válida"
  .ascii "e"    
  
msj_progressScreen1:
  .ascii "Tu recorrido en el juego "
  .ascii "e"     

msj_progressScreen2:  
  .ascii "Segundos Transcurridos: "
  .ascii "e" 

msj_progressScreen3:
  .ascii "Moriste porque.... "
  .ascii "e" 

msj_progressScreen4:
  .ascii "Tu acción tuvo probabilidad de fallar y falló"
  .ascii "e"   

msj_progressScreen4_printer:
  .ascii "Tu accion tuvo probabilidad"
  .ascii "de fallar y fallo"
  .ascii "e"

msj_progressScreen5:
  .ascii "Te quedaste sin tiempo"
  .ascii "e"     

msj_progressScreen6:
  .ascii "Te atrapó el enemigo"
  .ascii "e"   

msj_progressScreen7:
  .ascii "Tu acción fue super temeraria y nunca iba a funcionar"
  .ascii "e"    

msj_progressScreen7_printer:
  .ascii "Tu accion fue temeraria"
  .ascii "nunca iba a funcionar"  
  .ascii "e" 

msj_flashlightOff:
  .ascii "Tu linterna no tiene más bateria"
  .ascii "e"    

msj_flashlighBateria:
  .ascii "Bateria:       "

msj_enemyCaught:  
  .ascii "Atrapado"
  .ascii "e"    

msj_enemyEscape:  
  .ascii "Zafaste"
  .ascii "e"     

msj_actionFailed:  
  .ascii "La acción Falló"
  .ascii "e"    

msj_actionSuceeded:  
  .ascii "La acción fue exitosa"
  .ascii "e"      

msj_waterTimer:  
  .ascii "Nivel de Agua: "
  .ascii "e"

msj_bienvenida:
  .ascii "Entraste En la Caverna"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

msj_secretsFound:
  .ascii "Cantidad de Secretos encontrados"
  .ascii "e"

msj_end_printer:
  .ascii "  _________  "
  .ascii " ########### "
  .ascii "#############"
  .ascii "###  ###  ###"
  .ascii "#############"
  .ascii " ##### ##### "
  .ascii "  #########  "
  .ascii "   # # # #   "
  .ascii "   #######   "
  .ascii "    -----    "
  .ascii "             "
  .ascii " LA CAVERNA  "
  .ascii "             "
  .ascii "   DECIDIO   "
  .ascii "             "
  .ascii " TU DESTINO  "
  .ascii " "
  .ascii "e"

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------TEST BUTTONS-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

test_buttons:
  ;sei ;disable interrupts to process user buton selection
  lda LCD_PORTA
  sta LCD_PORTSTATUS
  ;move PA4 to PA7 and PA3 to PA6
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS ; now we have PA4 on the carry and PA3 on the negative flag 
  lda LCD_PORTSTATUS
  bcc pressed_buttons_pa4 ;no carry  means that Pa4 was zero then it was pressed
  bmi test_buttons_keep_testing; if one the pa3 was not pressed
pressed_buttons_pa3:
  ;here button pa3 was pressed
  jsr pa3_button_action 
  rts
pressed_buttons_pa4:  
  jsr pa4_button_action
  rts
test_buttons_keep_testing:
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS ; now we have PA2 on the carry and PA1 on the negative flag 
  bcc pressed_buttons_pa2 ;no carry  means that Pa2 was zero then it was pressed
  bmi test_buttons_keep_testing_again; if one the pa1 was not pressed
pressed_buttons_pa1:
  ;here button pa1 was pressed
  jsr pa1_button_action 
  rts
pressed_buttons_pa2:  
  jsr pa2_button_action
  rts
test_buttons_keep_testing_again:
  rol LCD_PORTSTATUS
  rol LCD_PORTSTATUS ; now we have PA0 on the carry 
  bcc pressed_buttons_pa0
  ;no button was pressed but we had an interrupt
  rts
pressed_buttons_pa0:
  jsr pa0_button_action
  rts

pa4_button_action:
  ;fire button on LCD PCB
  lda #$4 ;option 4 es e option
  sta userOptionSelection
;   lda #$34 ;number 4 in ascii
;   jsr send_rs232_char
  rts

pa3_button_action:
  ;up button on LCD PCB
  lda #$1 ;option 1 es B option
  sta userOptionSelection  
;   lda #$31 ;number 1 in ascii
;   jsr send_rs232_char
  rts

pa2_button_action:
  ;right button on LCD PCB
  lda #$2 ;option 2 es C option
  sta userOptionSelection  
;   lda #$32 ;number 2 in ascii
;   jsr send_rs232_char
  rts

pa1_button_action:
  ;down button on LCD PCB
  lda #$3 ;option 1 es D option
  sta userOptionSelection
;   lda #$33 ;number 1 in ascii
;   jsr send_rs232_char
  rts

pa0_button_action:
  ;left button on LCD PCB
  lda #$0 ;option 0 es A option
  sta userOptionSelection
;   lda #$30 ;number 0 in ascii
;   jsr send_rs232_char
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------TEST BUTTONS-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------RLE------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;one line for RLE
screen_20c_compressed:
rle_data:
  .byte 97,3,98,98,32,31,32,9,99,101,99,97,102,102,98,98,32,104,111,108,97
  .byte 32,99,111,109,111,32,101,115,116,97,115,255 ;255 is the end character
  .ascii "aaabb                                        cecaffbb hola como estas"

;algoritm
;read first char and read second char
;if first char is 255 end
;if second char <32 print first char second char times
;if second char = 255 print first char one time and end
;else all conditions print first char one time
rle_init:
  lda #< rle_data
  sta rleVectorLow
  lda #> rle_data 
  sta rleVectorHigh
  rts

rle_screen:
  lda #< screen_20c_compressed
  sta rleVectorLow
  lda #> screen_20c_compressed
  sta rleVectorHigh
  ;first byte is size
  ldy #$00
  lda (rleVectorLow),y 
  sta rleScreenLines 
rle_screen_cont:  
  ldx #$ff
rle_screen_process_line:
  inx
  cpx rleScreenLines
  beq rle_screen_end
  jsr rle_expand
  jmp rle_screen_process_line
rle_screen_end:
  rts



rle_expand:
  txa 
  pha
  ldy #$00 ;to bypass the first byte of number of lines
rle_expand_loop:
  iny
rle_expand_loop_cont1:  
  lda (rleVectorLow),y  
  cmp #$ff
  beq rle_expand_end
  sta rleChar
  iny
rle_expand_loop_cont2:   
  lda (rleVectorLow),y 
  cmp #$ff
  beq rle_expand_print_one_and_end
  lda (rleVectorLow),y   
  cmp #32
  ;when accumulator is minor that data (do not use bmi)
  bcc rle_expand_several_times
  ;if we are here is just print one time and continue
  lda #$1
  sta rleTimes
  ;print the char
  jsr rle_print_char
  dey ;decrement y as it was a new character there and not times Byte
  jmp rle_expand_loop

rle_expand_several_times:
  sta rleTimes
  ;print the char
  jsr rle_print_char
  jmp rle_expand_loop 
rle_expand_print_one_and_end:
  lda #1
  sta rleTimes
  ;print the char
  jsr rle_print_char
rle_expand_end:
  ;print line feed and carriege return
  jsr send_rs232_CRLF
  tya
  clc
  adc rleVectorLow
  sta rleVectorLow
  bcc rle_expand_end_end
  inc rleVectorHigh
rle_expand_end_end:  
  ;retreive x value for each line
  pla
  tax 
  rts  

rle_print_char:
  pha
  tya
  pha 
  txa
  pha 
  ldx #$0
rle_print_char_loop:
  cpx rleTimes
  beq rle_print_char_end
  txa
  pha 
  lda rleChar
  jsr send_rs232_char   
  pla
  tax
  inx
  jmp rle_print_char_loop
rle_print_char_end:
  pla
  tax
  pla
  tay
  pla
  rts


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------RLE------------------------------------------------
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
;--------------------------------SCREEN MANAGEMENT----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

; Positions of LCD characters
; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 1	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 2	94	95	96	97	98	99	9a	9b	9c	9d	9e	9f	a0	a1	a2	a3	a4	a5	a6	a7
; 3	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7


; Posible ordinal positions

; 01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  A,  B,  C,  D,  E,  F,  10, 11, 12, 13
; 14, 15, 16, 17, 18, 19, 1A, 1B, 1C, 1D, 1E, 1F, 20, 21, 22, 23, 24, 25, 26, 27
; 28, 29, 2A, 2B, 2C, 2D, 2E, 2F, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 3A, 3B
; 3C, 3D, 3E, 3F, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 4A, 4B, 4C, 4D, 4E, 4F

screenInit:
  jsr initilize_display
  jsr clear_display
  jsr loadCursorPositions
  jsr loadScreen
  jsr drawScreen
  jsr DELAY_SEC   
  jsr clearScreenBuffer
  jsr drawScreen 
  rts

; create a matrix of cursor positions in memory 4x20
loadCursorPositions:
  ;load vectors
  lda #lcdCharPositionsLow
  sta lcdCharPositionsLowZeroPage ; to use indirect addressing with y
  lda #lcdCharPositionsHigh
  sta lcdCharPositionsHighZeroPage
  lda #<lcd_positions
  sta lcdROMPositionsLowZeroPage
  lda #>lcd_positions
  sta lcdROMPositionsHighZeroPage
  ldy #$ff
loadCursorPositionsLoop:
  iny
  cpy #totalScreenLenght4Lines 
  ;cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq loadCursorPositionsEnd
  ; copy from ROM to RAM the LCD positions
  lda (lcdROMPositionsLowZeroPage),Y
  sta (lcdCharPositionsLowZeroPage),Y
  jmp loadCursorPositionsLoop
loadCursorPositionsEnd:
  rts

loadScreen:
  ;load vectors
  lda #screenBufferLow
  sta screenMemoryLow ; to use indirect addressing with y
  lda #screenBufferHigh
  sta screenMemoryHigh
  lda #<initialScreen
  sta initialScreenZeroPageLow
  lda #>initialScreen
  sta initialScreenZeroPageHigh
  ldy #$ff
loadScreenLoop:
  iny
  cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq loadCursorPositionsEnd
  ; copy from ROM to RAM the LCD positions
  lda (initialScreenZeroPageLow),Y
  sta (screenMemoryLow),Y
  jmp loadScreenLoop
loadScreenEnd:
  rts

drawScreen:
  ldy #$ff
drawScreenLoop:
  iny
  cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq drawScreenEnd
  ;position cursor
  lda (lcdCharPositionsLowZeroPage),Y ;load cursor position
  jsr lcd_send_instruction ; position cursor
  ;write screen character
  lda (screenMemoryLow),Y ;load character
  jsr print_char 
  jmp drawScreenLoop
drawScreenEnd:
  rts


print_screen:  
  ;BEGIN Write all the letters 
  ldy #$00 ;first byte is the position of the line
print_screen_load_position:
  lda (charDataVectorLow),y
  cmp #end_char;compare to ending character
  beq print_screen_end ;jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr lcd_send_instruction 
  ldx #$00
print_screen_eeprom:  
  iny
  inx
  cpx record_lenght ; record lenght is a memory position now
  beq print_screen_load_position
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  jsr print_char 
  jmp print_screen_eeprom
print_screen_end:
  rts   

print_message:  
  ;BEGIN Write all the letters
  ldy #$00 ;start on FF so when i add one it will be 0

print_message_eeprom:  
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  beq print_message_end ; jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr print_char 
  iny
  jmp print_message_eeprom
print_message_end:
  rts 
  ;END Write all the letters  

clearScreenBuffer: 
  ldy #$FF 
clearScreenBufferLoop:
  iny      
  cpy #$50
  beq clearScreenBufferEnd
  lda #cblank ;load ship form
  sta (screenMemoryLow),y ;at the alien position en Y draw the alien ship on the accumulator
  jmp clearScreenBufferLoop 
clearScreenBufferEnd: 
  rts    


;END--------------------------------------------------------------------------------  
;-----------------------------------------------------------------------------------
;--------------------------------SCREEN MANAGEMENT----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LCD COMMANDS---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

clear_display:
; BEGIN clear display instruction  on port B
  lda #%00000001 ;the instruction itself is 00000001
  jsr lcd_send_instruction
  ; END clear display instruction on port B 


initilize_display:
; BEGIN clear display instruction  on port B
  lda #%00000001 ;the instruction itself is 00000001
  jsr lcd_send_instruction
  ; END clear display instruction on port B  

  ; BEGIN send the instruction function set on port B
  lda #%00111000 ;the instruction itself is 001, data lenght 8bits(1), Number Display lines 2 (1)
            ;and Character Font 5x8 (0), last two bits are unused
  jsr lcd_send_instruction 
  ; END send the instruction function set on port B

  ;BEGIN Turn on Display instruction
  lda #%00001100 ;the instruction itself is 0001, Display On(1), Cursor Off (0)
            ;and Cursor Blinking Off (0)
  jsr lcd_send_instruction 
  ; END Turn on Display instruction

   ;BEGIN Entry Mode Set instruction
  lda #%00000110 ;the instruction itself is 00001, Put next character to the right (1)
            ;and Scroll Display Off (0)
  jsr lcd_send_instruction
  ; END Entry Mode Set instruction
  rts

lcd_wait:
  pha ; push to preserve the contents of the acummulator register
  ;set LCD_PORTB to all inputs so we can read the busy flag
  lda #$00000000 ;port b ins input
  sta LCD_DDRB 
lcd_busy:
  ;set register select to 0 and RW to 1 to read the busy flag
  lda #RW ;set RW RW = %01000000 ; Read/Write Signal
  sta LCD_PORTA
  lda #(RW | E) ;do the enable and do not era the RW bit
  sta LCD_PORTA
  ;this will give us the info from the busy flags and the counter 01 BF AC AC AC AC AC AC AC
  ;on port B so we read it
  lda LCD_PORTB
  and #%10000000 ;and the accumulator to loose all bits but the 7 bit (from 7 to 0)
                ; on the acummulator I will now have only the Busy Flag result
  bne lcd_busy ; branch if the zero flag is not set
  ;turn off the enable bit
  lda #RW ;set RW RW = %01000000 ; Read/Write Signal
  sta LCD_PORTA
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF to make it output
  sta LCD_DDRB ;store the accumulator in the data direction register for Port B
  pla ; pull to restablish the contents of the acummulator register
  rts


lcd_send_instruction:
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta LCD_PORTB
            
  lda #%0  ;Clear RS,RW and E bit on Port A  
  sta LCD_PORTA ;     

  ;togle the enable bit in order to send the instruction
  ;RS is zero so we are sending instructions
  ;RW is zero so we are writing
  lda #E ;enable bit is 1 , so we turn on the chip and execute the instruction.
  sta LCD_PORTA ; 

  lda #%0  ;Clear RS,RW and E bit on Port A  
  sta LCD_PORTA ;  
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts ; return from the subroutine

print_char:
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta LCD_PORTB

  ;RS is one so we are sending data
  ;RW is zero so we are writing
  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta LCD_PORTA ;     

  ;togle the enable bit in order to send the instruction
  lda #(RS | E );RS and enable bit are 1 , we OR them and send the data
  sta LCD_PORTA ; 

  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta LCD_PORTA ; 
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LCD COMMANDS---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

delay_1_sec:
  jsr DELAY_SEC
  rts

; delay_2_sec:
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   rts

delay_3_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

; delay_4_sec:
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; rts 

; delay_5_sec:
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   rts

; DELAY_onetenth_SEC:
;   lda #$10
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN

; DELAY_two_tenth_SEC:
;   lda #$10
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN   

DELAY_SEC:
  lda #$FF
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

; DELAY_HALF_SEC:
;   lda #$50
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN

DELAY_MAIN:
    LDX delay_COUNT_A     ; Load outer loop count
OUTER_LOOP:
    LDY delay_COUNT_B     ; Load inner loop count
INNER_LOOP:
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    DEY               ; Decrement inner loop counter
    BNE INNER_LOOP    ; Branch if not zero
    DEX               ; Decrement outer loop counter
    BNE OUTER_LOOP    ; Branch if not zero
    RTS               ; Return from subroutine

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------                                      

clearRS232Screen:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e" 

screen1_demo:
  .asciiz "     Adventure      "
  .asciiz "       Game         "  
  .asciiz "        RLE         "
  .asciiz "                    "


  

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------PRINTER-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

initializePrinter:
  jsr printerReset
  rts

printerWelcomeMessage:
  lda #$1
  sta rs232Printer  
  lda #<msj_bienvenida
  sta serialDataVectorLow  
  lda #>msj_bienvenida
  sta serialDataVectorHigh
  ;lets print on the printer
  jsr initializePrinter
  jsr printAsciiDrawing 
  lda #$0
  sta rs232Printer  
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
;----------------------------------UTILITY------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

bin_2_ascii_simulationTime:
  lda #0 ;this signals the empty string
  sta message ;initialize the string we will use for the results
  ;BEGIN Initialization of the 4 bytes
  ; initializae value to be the counter to ccount interrupts 
  sei ;disable interrupts so as to update properly the counter
  lda simulationTimePassedLowDigits
  sta value 
  lda simulationTimePassedHighDigits
  sta value + 1
  ;cli ; reenable interrupts after updating
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message
  rts

bin_2_ascii_random:
  lda #$0
  sta message ;string with nul character
  sei
  lda randomNumber
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts

bin_2_ascii_enemyProbActionCostCummulative:
  lda #$0
  sta message ;string with nul character
  sei
  lda enemyProbActionCostCummulative
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts 

bin_2_ascii_enemyActionProb:
  lda #$0
  sta message ;string with nul character
  sei
  lda enemyProbActionCost
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts 

bin_2_ascii_enemyProbFlashlight:  
  lda #$0
  sta message ;string with nul character
  sei
  lda enemyProbFlashlight
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts 


bin_2_ascii_Action_Plus_Flashlight:
  lda #$0
  sta message ;string with nul character
  sei
  lda enemyProbActionCummPlusFlashlight
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts  

bin_2_ascii_currentScreen:
  lda #$0
  sta message ;string with nul character
  sei
  lda enemyProbCurrentScreen
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts  

bin_2_ascii_enemy:
  lda #$0
  sta message ;string with nul character
  sei
  lda enemyProbabilityTotal
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts  

bin_2_ascii_multiply:
  lda #$0
  sta message ;string with nul character
  sei
  lda multiResultLow
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts

bin_2_ascii_waterLevel:
  lda #$0
  sta message ;string with nul character
  sei
  lda waterLevel
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts 

bin_2_ascii_actionFailedProbWaterPerLevel:
  lda #$0
  sta message ;string with nul character
  sei
  lda actionFailedProbWaterPerLevel
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts 

bin_2_ascii_actionFailedProbFlashlight:
  lda #$0
  sta message ;string with nul character
  sei
  lda actionFailedProbFlashlight
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts 

bin_2_ascii_actionFailedProbHeartRate:
  lda #$0
  sta message ;string with nul character
  sei
  lda actionFailedProbHeartRate
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts 

bin_2_ascii_actionFailedWaterFlashLightHeartRate:
  lda #$0
  sta message ;string with nul character
  sei
  lda actionFailedWaterFlashLightHeartRate
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts   

bin_2_ascii_actionFailedProb:
  lda #$0
  sta message ;string with nul character
  sei
  lda actionFailedProb
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts   

bin_2_ascii_actionFailedProbabilityTotal:
  lda #$0
  sta message ;string with nul character
  sei
  lda actionFailedProbabilityTotal
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts     

bin_2_ascii_secrets:
  lda #$0
  sta message ;string with nul character
  sei
  lda secretsFound
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts 

bin_2_ascii_secrets_printer:
  lda #$0
  sta message ;string with nul character
  sei
  lda secretsFound
  sta value
  lda #$0
  sta value + 1
  jsr bin_2_ascii
  lda #$1
  sta rs232Printer  
  jsr initializePrinter
  jsr bin_2_ascii_print_message  
  lda #$0
  sta rs232Printer
  rts 

bin_2_ascii_print_message
  ldx #$0
bin_2_ascii_printMessageLoop:
  lda message,x  
  beq bin_2_ascii_printMessageLoopEnd ;on null character stop printing
  jsr send_rs232_char
  inx
  jmp bin_2_ascii_printMessageLoop
bin_2_ascii_printMessageLoopEnd:  
  jsr send_rs232_CRLF
  rts

bin_2_ascii_segmentBarSizeLow:
  lda #$0
  sta message ;string with nul character
  sei
  lda segmentBarSizeLow
  sta value
  lda segmentBarSizeHigh
  sta value + 1
  jsr bin_2_ascii
  jsr bin_2_ascii_print_message  
  rts   

bin_2_ascii:
divide:
  ;initialize the remainder to be 0
  lda #0
  sta mod10
  sta mod10 + 1
  clc ; we will clear the carry bit
  ;END Initialization of the 4 bytes

  ldx #16
divloop:
  ;rotate the quotient and the remainder
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ;substract 1010, we will do it 8 bits at a time
  sec ; set the carry bit
  lda mod10
  sbc #10 ;substract with carry from 10
  tay ; save the low part of the 16 bits of the remainder to register y
  lda mod10 + 1
  sbc #0 ;substract with carry zero as the 8 high bits are all zeroes from 10 division
  ; the answer is on the combination of the a register and the y register
  ; a,y = dividend - divisor
  ; if the carry is clear for a then the dividend was less that the divisor and we will
  ; discard the result and do a shift left
  bcc ignore_result ; we will branch if the carry bit is clear (the carry of the last operation)
  ; if we do not ignore the result we want to store the intermediate result a,y
  ; in mod10+1 for a register and mod10 for the y register
  sty mod10
  sta mod10 + 1

  ; and then we will keep with the division if we did less than 16 left shifts

ignore_result:
  dex ; decrement the X time that we shifted left
    ; dex affects the Z flag if the content of the x register is zero
  bne divloop ;if what is on the X register
  ;we will rotate the carry bit inside value to have the result of the division
  rol value
  rol value + 1

  ;now we have to store the remainder
  lda mod10
  clc
  adc #"0" ;by adding zero to the a register we will have the ascii number of its value
  jsr push_char ;and now we store our character in the string
  ; we will be done dividen whne the result of the division is a zero
  ; we will check value and value + 1 and if any bit is one we are not done
  lda value
  ora value + 1 ; combine all ones from the 16 bits of value
  bne divide ; if a is not zero keep dividing
  rts
;add the content of the a register to a null terminated string message
push_char:
  pha ;push new character into the stack first 
  ldy #0
char_loop:
  lda message,y ;get char on string and put into x
  tax
  pla
  sta message,y ; we replaced the old first character with the new one
  iny ; lets go to the next character
  txa
  pha ; we have the character that used to be on the beginning of the message on the stack
  ;if a is zero we are at the end of the string
  bne char_loop
  pla
  sta message,y ; store the null terminator again
  rts

multiplyTest:
  lda #2
  sta multiFactor1
  lda #125
  sta multiFactor2
  jsr multiplyTwoNumbers8bitnumbers
  jsr bin_2_ascii_multiply
  rts 

multiplyTwoNumbers8bitnumbers:
  lda #$0
  sta multiResultLow
  sta multiResultHigh; Clear the 16-bit result 
  ldx #$8 ; Loop counter (8 bits to process)
multiplyTwoNumbers8bitnumbers_loop:
  lsr multiFactor1 ; Shift the multiplier right, putting LSB into Carry
  bcc multiplyTwoNumbers8bitnumbers_no_add ; If Carry is clear (bit was 0), skip addition
  ; Add multiplicand to the high/low result pair  
  clc
  lda multiResultLow
  adc multiFactor2
  sta multiResultLow
  lda multiResultHigh
  adc #$00 ; add any carry for low byte addition
  sta multiResultHigh
multiplyTwoNumbers8bitnumbers_no_add:
  asl multiFactor2
  ; Rotate a zero-page address (example placeholder, replace with ROL of a second byte if multiplicand were 16-bit)
  ;rol #$00
  dex 
  bne multiplyTwoNumbers8bitnumbers_loop
  rts
;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------UTILITY------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LED_ASCII------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

set_position_lcd_line0:
  lda #pos_lcd_initial_line0
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line1:
  lda #pos_lcd_initial_line1
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line2:
  lda #pos_lcd_initial_line2
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line3:
  lda #pos_lcd_initial_line3
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
reset_screen_position:
  lda #pos_lcd_initial_line0
  jsr lcd_send_instruction 
  jmp print_ascii_screen_end

print_ascii_screen:  
  ;BEGIN print_ascii_screen
  jsr clear_display
  ldx #$ff ; start as ff so when i add 1 it goes to zero
  ldy #$ff ; jsut at the begginning so it would got all the 80 characters of the screen
print_ascii_screen_line:  
  inx
  cpx #$00
  beq set_position_lcd_line0
  cpx #$01
  beq set_position_lcd_line1
  cpx #$02
  beq set_position_lcd_line2
  cpx #$03
  beq set_position_lcd_line3
  cpx #$04
  beq reset_screen_position ; to reset the screen to initial position
print_ascii_screen_eeprom:
  iny ;so it would go out of a last byte equal 0 loop
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  beq print_ascii_screen_line ; jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr print_char 
  jmp print_ascii_screen_eeprom
print_ascii_screen_end:
  rts 
  ;END print_ascii_screen

lcdDemoMessage:
  ;Draw Screen 1 Final Demo
  lda #<screen1_demo
  sta charDataVectorLow
  lda #>screen1_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec
  rts 
;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LED_ASCII------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIALCDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaLcdInit:

  ;BEGIN enable interrupts LCD VIA
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  ;sets interrupts for timer 1 and CA1 #%11000010
  ;sets interrupts for CA1 #%10000010

  lda #%10000010
  sta LCD_IER 
  ;enable negative edge transition ca1 LCD_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta LCD_PCR 
  ;bit 7,6 00 timer 1 one shot mode without pb7
  ;bit 5 in 0 timer 2 one shot mode
  ;bit 4,3,2 in 0 disable shift register
  ;bit 1 in zero portB latch disable
  ;bit 0 in 0 portA larch disable
  ;lda #%00000000      ; clear bits 7 and 6
  lda #%01000000      ; set bit 6 to make it freen running load and continue
  sta LCD_ACR
  ;counter in zero bit 6 of IFR is set

  ;END enable interrupts

  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta LCD_DDRB ;store the accumulator in the data direction register for Port B

  lda #%11100000  ;set the last 3 pins as output PA7, PA6, PA5 and as input PA4,PA3,PA2,PA1,PA0
  sta LCD_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIALCDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIARSINIT------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaRsInit:
  ;BEGIN enable interrupts RS VIA
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  lda #%10000010
  sta RS_IER 
  ;enable negative edge transition ca1 RS_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta RS_PCR 
  ;END enable interrupts

  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta RS_DDRB ;store the accumulator in the data direction register for Port B
  
  ;set all port A pins as Inputs
  ;lda #%00000000  ;set as input PA7, PA6, PA5, PA4,PA3,PA2,PA1,PA0
  ;set all port A pins as output
  lda #%11111111  ;load all ones equivalent to $FF  
  sta RS_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B
  ;Use PA0 connecting PA0 to EEPROM0 and the inverted PA0 to EEPROM1
  lda #$00
  sta RS_PORTA
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIALCDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


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

setSimulationTimerBars:
  lda simulationSegments
  sta barSegmentNumbers
  lda maxSimulationTimeLowByte
  sta barMaximumTimerLow
  lda maxSimulationTimeHighByte
  sta barMaximumTimerHigh
  jsr setBarSegmentSize
  ;jsr bin_2_ascii_segmentBarSizeLow
  rts

printSimulationTimerBars:
  lda simulationSegments
  sta barSegmentNumbers
  lda simulationTimePassedLowDigits
  sta currentTimeBarLow
  lda simulationTimePassedHighDigits
  sta currentTimeBarHigh
  jsr printSegments
  rts

setFlashlightTimerBars:
  lda flashlightSegments
  sta barSegmentNumbers
  lda maxFlashlightTimeLowByte
  sta barMaximumTimerLow
  lda maxFlashlightTimeHighByte
  sta barMaximumTimerHigh
  jsr setBarSegmentSize
  rts

printFlashlightTimerBars:
  lda flashlightSegments
  sta barSegmentNumbers
  lda flashlightSecondsUsedLowByte
  sta currentTimeBarLow
  lda flashlightSecondsUsedHighByte
  sta currentTimeBarHigh
  jsr printSegments
  rts  

printFlashlightTimerBars_Reverse:
  lda #$4
  sta barSegmentNumbers
  sec 
  lda maxFlashlightTimeLowByte
  sbc flashlightSecondsUsedLowByte
  sta currentTimeBarLow
  lda maxFlashlightTimeHighByte
  sbc flashlightSecondsUsedHighByte
  sta currentTimeBarHigh
  jsr printSegments
  rts   

printFlashlight:
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-------------------------------------BARRA-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

lcd_positions:
lcd_positions_line0:
  .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F,$90,$91,$92,$93
lcd_positions_line1:
  .byte $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF,$D0,$D1,$D2,$D3
lcd_positions_line2:
  .byte $94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F,$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
lcd_positions_line3:
  .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7


; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 1	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 2	94	95	96	97	98	99	9a	9b	9c	9d	9e	9f	a0	a1	a2	a3	a4	a5	a6	a7
; 3	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7
initialScreen:
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill

; left_cursor_endings:
;  ; .byte  $80,$c0,$94,$d4
;   .byte  $88,$c8,$9c,$dc  

; right_cursor_endings:
;   .byte  $93,$d3,$a7,$e7

; ; up_cursor_endings:
; ;   .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8F,$8E,$90,$91,$92,$93
; up_cursor_endings: ;so it is all in one line
;   .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
  
; down_cursor_endings:
;   .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
actions_index=$c300  ;the same as   .include "acs_actions_bank0.asm" on bank0 file
  .org $a100
  .include "acs_screens_bank1.asm"  
  .org $f500
  .include "acs_actions_headers_bank1.asm"
;   .org $d300  
;   .include "acs_actions.asm"
  .org $f900
  .include "acs_sensors.asm"
  .org $fc00
  .include "acs_dashboard.asm"
;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------INTERRUPT MANAGEMENT-------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

nmi:

irq:
  sei ; disable interrupts
  ;preserve Accumulator, X and Y so we can use them here
  pha ; store accumulator in the stack
  txa ; transfer X to Accumulator
  pha ; store the X register in the stack
  tya ; transfer Y to Accumulator
  pha ; store the Y register in the stack
  ;bit command read the memory and compares just used to read the register
  ;bit PORTA ; clear the interrupt flag I am doing it with an LDA on test_buttons
  
  ;check that the input is enabled first (so the program is waiting for user input)
  ;or we can disable interruptions and only enable them before accepting input from the user;
;   lda LCD_IFR
;   and #%01000000;#LCD_T1_FLAG
;   beq irqNextInterruptSource
  ;jsr timerCheckSecondElapsed
;   lda #$61
;   jsr send_rs232_char
  ;jsr timerCheck10SecondElapsed
  ;jsr timerCheckMinuteElapsed
  ;jsr timerCheckTimeIdleElapsed
irqNextInterruptSource:
;   lda #$62
;   jsr send_rs232_char
  jsr test_buttons ;test_buttons loads the message
exit_irq:  
  ;reserve order of stacking to restore values
  pla ; retrieve the Y register from the stack
  tay ; transfer accumulator to Y register
  pla ; retrieve the X register from the stack
  tax ; transfer accumulator to X register
  pla ; restore the accumulator value
  cli ;re enable interrupts
  rti 



;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



