;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2
  .include "lib_acia_memory.asm" ;define memory address for ACIA
  .include "lib_acia_constants.asm" ;define constansts that are not memory addresses but literals for ACIA  
  .include "lib_sensor_memory.asm" ;define memory address for ACIA
  .include "lib_sensor_constants.asm" ;define constansts that are not memory addresses but literals
  .include "lib_lcd_memory.asm" ;define memory address for ACIA
  .include "lib_lcd_constants.asm" ;define constansts that are not memory addresses but literals
  .include "lib_utils_memory.asm" ;define memory address for Utilities
  .include "lib_utils_constants.asm" ;define constansts that are not memory addresses but literals
; soundLowByte=$50
; soundHighByte=$51
; soundDelay=$52

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

  .org $8000

  .include "lib_init.asm" ;reset vector and stack initialization

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
  jsr viaSensorInit
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
  sta SENSOR_PORTA
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
  sta SENSOR_PORTA
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
  lda #<msj_end_water
  sta serialDataVectorLow  
  lda #>msj_end_water
  sta serialDataVectorHigh  
  jsr printAsciiDrawingPrinter
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
  lda #<msj_end_enemy
  sta serialDataVectorLow  
  lda #>msj_end_enemy
  sta serialDataVectorHigh  
  jsr printAsciiDrawingPrinter
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
  lda #<msj_end_printer
  sta serialDataVectorLow  
  lda #>msj_end_printer
  sta serialDataVectorHigh
  jsr printAsciiDrawingPrinter
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
  lda SENSOR_PORTB ;load what is already on port B
  and #%10111011 ;keep bits 7,5,4,3,2,1 and reset bits 6, 2 of port b
  sta SENSOR_PORTB
  ora flashLightSensor ;set bit 6 for sync and bit 0.
  sta SENSOR_PORTB ;set the new value
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
  lda SENSOR_PORTB ;load what is already on port B
  and #%10111101 ;keep bits 7,5,4,3,2,0 and reset bits 6, 1 of port b
  sta SENSOR_PORTB
  ora waterLevelSensor ;set bit 6 for sync and bit 0.
  sta SENSOR_PORTB ;set the new value
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
  lda SENSOR_PORTB ;load what is already on port B
  and #%10111110 ;keep bits 7,5,4,3,2,1 and reset bits 6, 1 and 0 of port b
  sta SENSOR_PORTB
  ora heartRateSensor ;set bit 6 for sync and bit 0.
  sta SENSOR_PORTB ;set the new value
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
;-----------------------------------HEARTRATE---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------WATERLEVEL--------------------------------------
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
;-----------------------------------WATERLEVEL--------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
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

  .include "lib_lcd_code.asm"
  .include "lib_sensor_code.asm"
  .include "lib_acia_code.asm"
  .include "lib_utils_code.asm"
  .include "ag_motor_debug.asm"

  .include "acs_phrases.asm"
screens_index=$a100  ;  .include "acs_screens_bank1.asm" on bank 1 file
  .org $c000
  .include "acs_screens_headers_bank0.asm"
  .org $c300  
  .include "acs_actions_bank0.asm"
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
  lda pressedButton
  sta userOptionSelection
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



