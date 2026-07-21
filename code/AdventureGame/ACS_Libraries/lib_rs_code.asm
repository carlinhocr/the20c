

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIARSINIT------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaRsInit:
  ;BEGIN enable interrupts RS VIA
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  lda #%10000010
  sta RS_IER 
  ;enable negative edge transition ca1 RS_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta RS_PCR 
  ;END enable interrupts

  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta RS_DDRB ;store the accumulator in the data direction register for Port B
  
  ;set all port A pins as Inputs
  ;lda #%00000000  ;set as input PA7, PA6, PA5, PA4,PA3,PA2,PA1,PA0
  ;set all port A pins as output
  lda #%11111111  ;load all ones equivalent to $FF  
  sta RS_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B
  ;Use PA0 connecting PA0 to EEPROM0 and the inverted PA0 to EEPROM1
  lda #$00
  sta RS_PORTA
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIARSINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

