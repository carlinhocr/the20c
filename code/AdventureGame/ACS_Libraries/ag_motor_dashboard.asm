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
