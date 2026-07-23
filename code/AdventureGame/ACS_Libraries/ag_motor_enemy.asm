
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
;------------------------------------ENEMY------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
