;needs the utility library for bin_2_ascii
;lib_utils_code.asm
;lib_utils_constants.asm
;lib_utils_memory.asm


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