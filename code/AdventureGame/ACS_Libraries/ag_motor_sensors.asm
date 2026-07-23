

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
;-----------------------------------HEARTRATE---------------------------------------
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