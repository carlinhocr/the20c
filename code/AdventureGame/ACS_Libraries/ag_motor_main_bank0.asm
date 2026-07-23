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
  jsr mainProgram

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
  .include "ag_motor_game_mechanics.asm"
  .include "ag_motor_irq.asm"
  

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

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



