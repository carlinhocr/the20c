; ============================================================
;  ACS Dashboard — auto-generated
; ============================================================

dashboard_index:
  .word dashboard_pointer_0  ; dashBoardTest
dashboard_index_record_length:
  .byte 2

dashboard_pointers:
dashboard_pointer_0:
  .word dashboard_0_id ; dashBoardTest id [0,1]
  .word dashboard_0_name ; dashBoardTest name [2,3]
  .word dashboard_0_start_screen ; dashBoardTest start_screen [4,5]
  .word dashboard_0_high_water_level ; dashBoardTest high_water_level [6,7]
  .word dashboard_0_high_heart_level ; dashBoardTest high_heart_level [8,9]
  .word dashboard_0_total_sim_time ; dashBoardTest total_sim_time [10,11]
  .word dashboard_0_total_flash_time ; dashBoardTest total_flash_time [12,13]
  .word dashboard_0_water_level0 ; dashBoardTest water_level0 [14,15]
  .word dashboard_0_water_level1 ; dashBoardTest water_level1 [16,17]
  .word dashboard_0_water_level2 ; dashBoardTest water_level2 [18,19]
  .word dashboard_0_water_level3 ; dashBoardTest water_level3 [20,21]
  .word dashboard_0_water_level4 ; dashBoardTest water_level4 [22,23]
  .word dashboard_0_water_level5 ; dashBoardTest water_level5 [24,25]
  .word dashboard_0_water_level6 ; dashBoardTest water_level6 [26,27]
  .word dashboard_0_water_level7 ; dashBoardTest water_level7 [28,29]
  .word dashboard_0_water_level8 ; dashBoardTest water_level8 [30,31]
  .word dashboard_0_water_level9 ; dashBoardTest water_level9 [32,33]
  .word dashboard_0_extra_water ; dashBoardTest extra_water [34,35]
  .word dashboard_0_extra_heartrate ; dashBoardTest extra_heartrate [36,37]
  .word dashboard_0_extra_flashlight ; dashBoardTest extra_flashlight [38,39]
  .word dashboard_0_death_water ; dashBoardTest death_water [40,41]
  .word dashboard_0_death_heartrate ; dashBoardTest death_heartrate [42,43]
  .word dashboard_0_death_flashlight ; dashBoardTest death_flashlight [44,45]
  .word dashboard_0_enemy_flash_on ; dashBoardTest enemy_flash_on [46,47]
  .word dashboard_0_end_screen_default ; dashBoardTest end_screen_default [48,49]
  .word dashboard_0_end_screen_enemy ; dashBoardTest end_screen_enemy [50,51]
  .word dashboard_0_end_screen_timeup ; dashBoardTest end_screen_timeup [52,53]
  .word dashboard_0_end_screen_enemy_af ; dashBoardTest end_screen_enemy_af [54,55]
dashboard_name_offset:
  .byte 2
dashboard_start_screen_offset:
  .byte 4
dashboard_high_water_level_offset:
  .byte 6
dashboard_high_heart_level_offset:
  .byte 8
dashboard_total_sim_time_offset:
  .byte 10
dashboard_total_flash_time_offset:
  .byte 12
dashboard_water_level0_offset:
  .byte 14
dashboard_water_level1_offset:
  .byte 16
dashboard_water_level2_offset:
  .byte 18
dashboard_water_level3_offset:
  .byte 20
dashboard_water_level4_offset:
  .byte 22
dashboard_water_level5_offset:
  .byte 24
dashboard_water_level6_offset:
  .byte 26
dashboard_water_level7_offset:
  .byte 28
dashboard_water_level8_offset:
  .byte 30
dashboard_water_level9_offset:
  .byte 32
dashboard_extra_water_offset:
  .byte 34
dashboard_extra_heartrate_offset:
  .byte 36
dashboard_extra_flashlight_offset:
  .byte 38
dashboard_death_water_offset:
  .byte 40
dashboard_death_heartrate_offset:
  .byte 42
dashboard_death_flashlight_offset:
  .byte 44
dashboard_enemy_flash_on_offset:
  .byte 46
dashboard_end_screen_default_offset:
  .byte 48
dashboard_end_screen_enemy_offset:
  .byte 50
dashboard_end_screen_timeup_offset:
  .byte 52
dashboard_end_screen_enemy_af_offset:
  .byte 54
dashboard_record_length:
  .byte 56

; ── Dashboard 0: dashBoardTest ──────────────────────────
dashboard_0_id:
  .byte 0

dashboard_0_name:
  .ascii "dashBoardTest"
  .ascii "e"

dashboard_0_start_screen:
  .byte 0

dashboard_0_high_water_level:
  .byte 9

dashboard_0_high_heart_level:
  .byte 1

dashboard_0_total_sim_time:
  .byte $02  ; high byte (decimal 600)
  .byte $58  ; low byte

dashboard_0_total_flash_time:
  .byte $02  ; high byte (decimal 600)
  .byte $58  ; low byte

dashboard_0_water_level0:
  .byte $00  ; high byte (decimal 0)
  .byte $00  ; low byte

dashboard_0_water_level1:
  .byte $00  ; high byte (decimal 74)
  .byte $4A  ; low byte

dashboard_0_water_level2:
  .byte $00  ; high byte (decimal 75)
  .byte $4B  ; low byte

dashboard_0_water_level3:
  .byte $00  ; high byte (decimal 150)
  .byte $96  ; low byte

dashboard_0_water_level4:
  .byte $00  ; high byte (decimal 225)
  .byte $E1  ; low byte

dashboard_0_water_level5:
  .byte $01  ; high byte (decimal 300)
  .byte $2C  ; low byte

dashboard_0_water_level6:
  .byte $01  ; high byte (decimal 375)
  .byte $77  ; low byte

dashboard_0_water_level7:
  .byte $01  ; high byte (decimal 450)
  .byte $C2  ; low byte

dashboard_0_water_level8:
  .byte $02  ; high byte (decimal 525)
  .byte $0D  ; low byte

dashboard_0_water_level9:
  .byte $02  ; high byte (decimal 600)
  .byte $58  ; low byte

dashboard_0_extra_water:
  .byte $00  ; high byte (decimal 1)
  .byte $01  ; low byte

dashboard_0_extra_heartrate:
  .byte $00  ; high byte (decimal 2)
  .byte $02  ; low byte

dashboard_0_extra_flashlight:
  .byte $00  ; high byte (decimal 2)
  .byte $02  ; low byte

dashboard_0_death_water:
  .byte 1

dashboard_0_death_heartrate:
  .byte 1

dashboard_0_death_flashlight:
  .byte 1

dashboard_0_enemy_flash_on:
  .byte 1

dashboard_0_end_screen_default:
  .byte 255  ; screen id

dashboard_0_end_screen_enemy:
  .byte 40  ; screen id

dashboard_0_end_screen_timeup:
  .byte 39  ; screen id

dashboard_0_end_screen_enemy_af:
  .byte 41  ; screen id

dashboard_count:
  .byte 1
