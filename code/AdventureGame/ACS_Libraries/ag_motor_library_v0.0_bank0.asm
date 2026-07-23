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
flashLightSensor=                 $0277

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
  .include "ag_motor_sensors.asm"
  .include "ag_motor_enemy.asm"
  .include "ag_motor_action.asm"
  .include "ag_motor_screen.asm"
  .include "ag_motor_dashboard.asm"
  .include "ag_motor_init.asm"

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



