;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2



;SOUND SID 6581

SID_V1FL = $4000
SID_V1FH = $4001
SID_V1PWL = $4002
SID_V1PWLH = $4003
SID_V1CTRL = $4004
SID_V1AD = $4005
SID_V1SR = $4006

SID_V2FL = $4007
SID_V2FH = $4008
SID_V2PWL = $4009
SID_V2PWLH = $400A
SID_V2CTRL = $400B
SID_V2AD = $400C
SID_V2SR = $400D

SID_V3FL = $400E
SID_V3FH = $400F
SID_V3PWL = $4010
SID_V3PWLH = $4011
SID_V3CTRL = $4012
SID_V3AD = $4013
SID_V3SR = $4014

SID_FILTER_FCL = $4015
SID_FILTER_FCH = $4016
SID_FILTER_RF = $4017
SID_FILTER_MV = $4018

SID_POTX = $4019
SID_POTY = $401A
SID_OSC3_RANDOM = $401B
SID_ENV3 = $401C

sidLocationLow=$58
sidLocationHigh=$59

  .org $8000


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------STACK, INTERRUPTs----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

RESET:
  ;initialize stack
  ldx #$ff
  txs ;transfer x index register to stack register
  ;clear interrupt disable bit
  cli ;sets at zero the interrupt disable bit 
      ;N Z C I D V
      ;- - - 0 - -


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------STACK, INTERRUPTs----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


programStart:
  ;initialize variables, vectors, memory mappings and constans
  ;configure stack and enable interrupts
  jsr sidInit
  jsr sidTest
  jmp sidTest
loop:
  jmp loop


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SIDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;clear sid register
sidInit:
  ;SID_V1FL is where all sid registers start
  lda #< SID_V1FL
  sta sidLocationLow
  lda #> SID_V1FL
  sta sidLocationHigh
  ldy #$FF
  lda #$0
sidInitLoop:
  iny 
  sta (sidLocationLow),y 
  cpy #$28
  bne sidInitLoop
  rts


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SIDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SOUND SID -----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

sidTest:
  ;set Volume to maximum
  lda #15 
  sta SID_FILTER_MV ;$4018


  ;set attacj/decay for Voice 1
  ;bits 7-4 attack bits 3-0 decay
  ;9 is 0000 1001
  ;8ms of attack and 24ms of decay
  ;measured on a 1Mhz clock
  ;for other frecuency multiple 1Mhz/other freq
  lda #9;0000 1001
  sta SID_V1AD ;$4005
  ;set sustain/release for Voice 1
  ;bits 7-4 sustain bits 3-0 release
  ;6 is 0000 0110
  ;sustain at zero amplitud
  ;decay identical to release scale
  ;6 is 204ms
  lda #6
  sta SID_V1SR ;$4006
sidTestLoop:
  lda #$1C ;a4 high byte
  sta SID_V1FH
  lda #$D5; a4 low byte
  sta SID_V1FL
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  ;lda #33 ;
  ;lda #%00100001
  lda #33 ;triangle wave form
  sta SID_V1CTRL;$4004
  jsr sidSoundDelay ;wait
  lda #32
  ;start release
  ;lda #%00100000
  sta SID_V1CTRL;$4004
  jsr sidSoundDelay ;wait
  ;loop again
  jmp sidTestLoop

  
sidSoundDelay:
  ;save state to the stack
  pha ;store accumulator
  txa ;store x
  pha ;store x
  tya ;store y
  pha ;store y
  ;lda soundDelay
  lda #$20
  tax
sidSoundDelayLoop:
  cpx #$0
  beq sidSoundDelayDone
  ldy #$FF
sidSoundDelayInnerLoop:
  nop
  nop  
  dey
  bne sidSoundDelayInnerLoop
  dex
  bne sidSoundDelayLoop
sidSoundDelayDone:  
  pla ;recover y
  tay ;recover y
  pla ;recover x
  tax ;recover x
  pla ;recover accummulator
  rts

;----------------------------------------------------
nmi:
irq:
    rti

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



