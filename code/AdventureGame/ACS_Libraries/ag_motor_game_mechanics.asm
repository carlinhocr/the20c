
mainProgram:
  jsr lcdDemoMessage
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