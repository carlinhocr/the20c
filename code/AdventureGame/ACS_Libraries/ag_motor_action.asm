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

