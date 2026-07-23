
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
