

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASENSORSINIT------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaSensorInit:
  ;BEGIN enable interrupts RS VIA
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  lda #%10000010
  sta SENSOR_IER 
  ;enable negative edge transition ca1 SENSOR_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta SENSOR_PCR 
  ;END enable interrupts

  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta SENSOR_DDRB ;store the accumulator in the data direction register for Port B
  
  ;set all port A pins as Inputs
  ;lda #%00000000  ;set as input PA7, PA6, PA5, PA4,PA3,PA2,PA1,PA0
  ;set all port A pins as output
  lda #%11111111  ;load all ones equivalent to $FF  
  sta SENSOR_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B
  ;Use PA0 connecting PA0 to EEPROM0 and the inverted PA0 to EEPROM1
  lda #$00
  sta SENSOR_PORTA
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASENSORINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------BANKSWITCHING ROUTINES-------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------------------------------------------------------- 

bankswitch0:
  pha
  tya ;save Y because i am going to another process
  pha ;save Y because i am going to another process
  txa ;save X because i am going to another process
  pha ;save X because i am going to another process
  ldx #$1
  lda #$0 ;select bank 1
  sta SENSOR_PORTA
bankswitch0_loop:
  txa
  beq bankswitch0_continue
  inx  
  jmp bankswitch0_loop  
bankswitch0_continue:  
  jsr delay_1_sec
  pla
  tax
  pla
  tay
  pla
  rts  

bankswitch1:
  pha
  tya ;save Y because i am going to another process
  pha ;save Y because i am going to another process
  txa ;save X because i am going to another process
  pha ;save X because i am going to another process
  ldx #$1
  lda #$1 ;select bank 1
  sta SENSOR_PORTA
bankswitch1_loop:
  txa
  beq bankswitch1_continue
  inx  
  jmp bankswitch1_loop  
bankswitch1_continue:  
  jsr delay_1_sec
  pla
  tax
  pla
  tay
  pla
  rts   

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;------------------------------BANKSWITCHING ROUTINES-------------------------------
;-----------------------------------------------------------------------------------
;----------------------------------------------------------------------------------- 
