

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

select_screen:
  lda screenCurrentID
  jsr load_screen_ram
  jsr load_screen_variables
  rts

load_screen_ram:
  lda screenCurrentID
  ;multiply by 2 the id
  asl ;if not screen zero multiple by 2
  sta current_screen_offset
  ldx current_screen_offset ;byte 6 if it is screen 3
  ;store in sourceScreenVector the address of screen_x_id
  ;use screen zero
  lda screens_index,x
  sta sourceScreenVectorLow
  inx
  lda screens_index,x
  sta sourceScreenVectorHigh
  ;store in ramScreenVectorLow the address of the RAM portin for the screen
  lda #$00
  sta ramScreenVectorLow
  lda #$05
  sta ramScreenVectorHigh
  ldy #$ff
load_screen_ram_loop:
  iny
  cpy screen_record_length
  beq load_screen_ram_end
  lda (sourceScreenVectorLow),Y
  sta (ramScreenVectorLow),Y
  jmp load_screen_ram_loop
load_screen_ram_end:
  rts

load_screen_variables:
  ;end screen variable
  ldx screen_is_end_screen_offset
  lda screenPointersRAM,X
  sta sourceScreenVectorLow
  inx
  lda screenPointersRAM,X
  sta sourceScreenVectorHigh
  ldy #$0
  lda (sourceScreenVectorLow),Y  
  sta isEndScreenVariable
  ;secret screen variable
  ldx screen_is_secret_screen_offset
  lda screenPointersRAM,X
  sta sourceScreenVectorLow
  inx
  lda screenPointersRAM,X
  sta sourceScreenVectorHigh
  ldy #$0
  lda (sourceScreenVectorLow),Y  
  sta isSecretScreenVariable
  ;screen enemy probability
  ldx screen_enemy_probability_offset
  lda screenPointersRAM,X
  sta sourceScreenVectorLow
  inx
  lda screenPointersRAM,X
  sta sourceScreenVectorHigh
  ldy #$0
  lda (sourceScreenVectorLow),Y
  sta enemyProbCurrentScreen
  ;screen actions
  ldx screen_action_offset
  lda screenPointersRAM,X
  sta sourceScreenVectorLow
  inx
  lda screenPointersRAM,X
  sta sourceScreenVectorHigh
  ldy #$0
  ldx #$0
screen_actions_loop:
  lda (sourceScreenVectorLow),Y
  sta currentScreenAllActionsRAM,x ;is goes from 0 to 3 in max aciotns = 4
  iny
  inx
  cpx max_actions_per_screen
  bne screen_actions_loop
  rts

draw_current_screen_table:
  jsr draw_screen_ascii
  jsr draw_screen_description
  jsr draw_screen_description_flashlight
  rts

draw_screen_ascii:
  lda screen_ascii_offset
  sta screenPrintOffset
  jsr draw_screen
  rts  

draw_screen_description:
  lda screen_description_offset
  sta screenPrintOffset
  jsr draw_screen
  rts  

draw_screen_description_flashlight:
  lda flashlightStatus
  ;if it is not zero then it is on
  bne draw_screen_description_flashlight_on
  ;flashlight off, the flashlightStatus was zero
  lda screen_flashlight_off_offset
  sta screenPrintOffset  
  jsr draw_screen
  rts   
draw_screen_description_flashlight_on:  
  lda screen_flashlight_on_offset
  sta screenPrintOffset
  jsr draw_screen
  rts    

draw_screen:  
  ldx screenPrintOffset  ;description offset
  lda screenPointersRAM,x 
  sta serialDataVectorLow  
  inx 
  lda screenPointersRAM,x
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

draw_screen_by_ram_ascii:  
  ldx screen_ascii_offset  ; offset ascii
  lda screenPointersRAM,x
  ;lda $051e ;the 30 offset starting ascii low byte
  sta serialDataVectorLow  
  inx 
  lda screenPointersRAM,x
  ;lda $051f ;the 31 offset starting ascii high byte
  sta serialDataVectorHigh
  jsr printAsciiDrawing

; draw_screen_by_hand:  
;   ldx screenPrintOffset  ;description offset
;   lda #<screen_0_ascii
;   sta serialDataVectorLow  
;   inx 
;   lda #>screen_0_ascii
;   sta serialDataVectorHigh
;   jsr printAsciiDrawing

;   lda #<screen_0_flashlight_on
;   sta serialDataVectorLow  
;   inx 
;   lda #>screen_0_flashlight_on
;   sta serialDataVectorHigh
;   jsr printAsciiDrawing  
  rts    


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
