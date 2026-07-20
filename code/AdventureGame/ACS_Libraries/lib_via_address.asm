
;VIA Ports and Constant ds
LCD_VIA_BASE  = $6000

LCD_PORTB = LCD_VIA_BASE + $00
LCD_PORTA = LCD_VIA_BASE + $01
LCD_DDRB =  LCD_VIA_BASE + $02 
LCD_DDRA =  LCD_VIA_BASE + $03
LCD_T1CL =  LCD_VIA_BASE + $04   ; Timer 1 counter low   (R: clears T1 IFR bit)
LCD_T1CH =  LCD_VIA_BASE + $05   ; Timer 1 counter high  (W: starts timer)
LCD_T1LL =  LCD_VIA_BASE + $06   ; Timer 1 latch low
LCD_T1LH =  LCD_VIA_BASE + $07   ; Timer 1 latch high
LCD_T2CL =  LCD_VIA_BASE + $08   ; Timer 1 counter low   (R: clears T1 IFR bit)
LCD_T2CH =  LCD_VIA_BASE + $09   ; Timer 1 counter high  (W: starts timer)
LCD_ACR  =  LCD_VIA_BASE + $0B   ; Auxiliary Control Register
LCD_PCR  =  LCD_VIA_BASE + $0C
LCD_IFR  =  LCD_VIA_BASE + $0D   ; Interrupt Flag Register
LCD_IER  =  LCD_VIA_BASE + $0E   ; Interrupt Enable Register

; ── Timer 1 IFR bit mask ──────────────────────────────────
LCD_T1_FLAG   = %01000000         ; bit 6

;------------------------------------------------------------

RS_VIA_BASE  = $7000
RS_PORTB = RS_VIA_BASE + $00
RS_PORTA = RS_VIA_BASE + $01
RS_DDRB =  RS_VIA_BASE + $02
RS_DDRA =  RS_VIA_BASE + $03
RS_PCR =   RS_VIA_BASE + $04
RS_IFR =   RS_VIA_BASE + $05
RS_IER =   RS_VIA_BASE + $06
