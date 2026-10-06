
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
  jsr sidInit
  ;set attacj/decay for Voice 1
  ;bits 7-4 attack bits 3-0 decay
  ;9 is 0001 0001
  ;8ms of attack and 24ms of decay
  ;measured on a 1Mhz clock
  ;for other frecuency multiple 1Mhz/other freq
  lda #9;0001 0001
  sta SID_V1AD
  ;set sustain/release for Voice 1
  ;bits 7-4 sustain bits 3-0 release
  ;6 is 0000 0110
  ;sustain at zero amplitud
  ;decay identical to release scale
  ;6 is 204ms
  lda #6
  sta SID_V1SR
  ;set Volume to maximum
  lda #15
  sta SID_FILTER_MV
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
  ;sta SID_V1CTRL
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  lda #$03
  sta SID_BASE + 2
  lda #$FF
  sta SID_BASE + 3
  lda #%01000001 ;
  sta SID_V1CTRL
  jmp sidTest

testSidLoop:
  jmp testSidLoop

sidTestMultiNotes:
  jsr sidInit
  ;store contro byte wave form for each voice
  lda #%00010001 ; triangle 17 set the code bit and start
  sta waveFormV1
  lda #%01000001 ; square 65 set the code bit and start
  sta waveFormV2
  lda #%00100001 ; sawtooth 17 set the code bit and start
  sta waveFormV3
  ldy #$FF
sidTestMultiNotesDecodeNotes:
  iny 
  rts


sidNotesExamplePlay:
  ;load note address
  lda #<sidNotesExample
  sta sidNotesLowV1
  lda #>sidNotesExample
  sta sidNotesHighV1
  jsr soundSid
  lda #<sidScale
  sta sidNotesLowV1
  lda #>sidScale
  sta sidNotesHighV1
  jsr soundSid
  lda #<sidScale
  sta sidNotesLowV1
  lda #>sidScale
  sta sidNotesHighV1
  lda #<sidScale
  sta sidNotesLowV2
  lda #>sidScale
  sta sidNotesHighV2
  lda #<sidScale
  sta sidNotesLowV3
  lda #>sidScale
  sta sidNotesHighV3
  jsr soundSid3VoicesExample
  rts

soundSid3VoicesExample:
  jsr sidInit
  ;set attacj/decay for Voice 1,2,3
  ;bits 7-4 attack bits 3-0 decay
  ;9 is 0001 0001
  ;8ms of attack and 24ms of decay
  ;measured on a 1Mhz clock
  ;for other frecuency multiple 1Mhz/other freq  
  ;
  lda #9;0001 0001
  sta SID_V1AD
  ;organ for voice 2
  lda #0;0000 0000 
  sta SID_V2AD
  ;violin for voice 3
  lda #$A8;1010 1000 
  sta SID_V3AD
  ;set sustain/release for Voice 1,2,3
  ;bits 7-4 sustain bits 3-0 release
  ;6 is 0000 0110
  ;sustain at zero amplitud
  ;decay identical to release scale
  ;6 is 204ms
  lda #6
  sta SID_V1SR
    ;organ for voice 2
  lda #15;0000 1111 
  sta SID_V2SR
  ;violin for voice 3
  lda #$A9;1010 1001 
  sta SID_V3SR

  ;set Volume to maximum
  lda #15
  sta SID_FILTER_MV
playSidNotes3Voices:  
  ;play notes
  ldy #$FF
playSidNotesLoop3Voices:
  iny 
  lda (sidNotesLowV1),y 
  cmp #$FF
  beq playSidNotesEnd3Voices 
  ;store high frequency for Voice 1,2,3
  sta SID_V1FH
  lda (sidNotesLowV2),y 
  sta SID_V2FH
  lda (sidNotesLowV3),y 
  sta SID_V3FH
  ;load and store low frequency for Voice 1,2,3
  iny
  lda (sidNotesLowV1),y 
  sta SID_V1FL
  lda (sidNotesLowV2),y 
  sta SID_V2FL
  lda (sidNotesLowV3),y 
  sta SID_V3FL
  ;load and wait duration for Voice 1 for the 3 voices
  iny
  lda (sidNotesLowV1),y 
  sta soundDelay
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  lda #33 ; sawtooth ;0010000
  sta SID_V1CTRL
  lda #%01000001 ;square
  sta SID_V2CTRL
  lda #%00010001 ;triangle
  sta SID_V3CTRL
  ;wait soundDelay time
  jsr sidSoundDelay
  ;00100001 
  ;bit 5 selects sawtooth
  ;the last bit turns off starts the Release Phase
  lda #32 ;0010000
  sta SID_V1CTRL
  lda #%01000000 ;square
  sta SID_V2CTRL
  lda #%00010000 ;triangle
  sta SID_V3CTRL
  ;wait 50 for the duration of the release before next note
  lda #50
  sta soundDelay
  jsr sidSoundDelay
  ;play next note
  jmp playSidNotesLoop3Voices

playSidNotesEnd3Voices:  
  ;jmp playSidNotes ;keep playing in loop
  ;it reaches here when the hight byte for
  ;the ound note is $FF
  rts

soundSid:
  jsr sidInit
  ;set attacj/decay for Voice 1
  ;bits 7-4 attack bits 3-0 decay
  ;9 is 0001 0001
  ;8ms of attack and 24ms of decay
  ;measured on a 1Mhz clock
  ;for other frecuency multiple 1Mhz/other freq  
  lda #9;0001 0001
  sta SID_V1AD
  ;set sustain/release for Voice 1
  ;bits 7-4 sustain bits 3-0 release
  ;6 is 0000 0110
  ;sustain at zero amplitud
  ;decay identical to release scale
  ;6 is 204ms
  lda #6
  sta SID_V1SR
  ;set Volume to maximum
  lda #15
  sta SID_FILTER_MV
playSidNotes:  
  ;play notes
  ldy #$FF
playSidNotesLoop:
  iny 
  lda (sidNotesLowV1),y 
  cmp #$FF
  beq playSidNotesEnd 
  ;store high frequency for Voice 1
  sta SID_V1FH
  ;load and store low frequency for Voice 1
  iny
  lda (sidNotesLowV1),y 
  sta SID_V1FL
  ;load and wait duration for Voice 1
  iny
  lda (sidNotesLowV1),y 
  sta soundDelay
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  lda #33 ;
  sta SID_V1CTRL
  ;wait soundDelay time
  jsr sidSoundDelay
  ;00100001 
  ;bit 5 selects sawtooth
  ;the last bit turns off starts the Release Phase
  lda #32 ;0010000
  sta SID_V1CTRL
  ;wait 50 for the duration of the release before next note
  lda #50
  sta soundDelay
  jsr sidSoundDelay
  ;play next note
  jmp playSidNotesLoop

playSidNotesEnd:  
  ;jmp playSidNotes ;keep playing in loop
  ;it reaches here when the hight byte for
  ;the ound note is $FF
  rts
  
sidSoundDelay:
  ;save state to the stack
  pha ;store accumulator
  txa ;store x
  pha ;store x
  tya ;store y
  pha ;store y
  lda soundDelay
  tax
  cpx #$0
  beq sidSoundDelayDone
sidSoundDelayLoop:
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

parseNotes:
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SOUND SID -----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


parseSong:
  jsr songSIDInit
  jsr parserNotes
  rts

songSIDInit:
  jsr sidInit
  ;set attacj/decay for Voice 1
  ;bits 7-4 attack bits 3-0 decay
  ;9 is 0001 0001
  ;8ms of attack and 24ms of decay
  ;measured on a 1Mhz clock
  ;for other frecuency multiple 1Mhz/other freq  
  lda #9;0001 0001
  sta SID_V1AD
  ;set sustain/release for Voice 1
  ;bits 7-4 sustain bits 3-0 release
  ;6 is 0000 0110
  ;sustain at zero amplitud
  ;decay identical to release scale
  ;6 is 204ms
  lda #6
  sta SID_V1SR
  ;set Volume to maximum
  lda #15
  sta SID_FILTER_MV
  rts

parserNotes:
  pha ;save accumulator
  txa
  pha
  tya
  pha
  ldy #$FF
parserNotesLoop:
  iny
  ;lda songExampleNotes,x ;here I load note
  lda (musicalNotesLow),y 
  cmp #$7a;"z"
  beq parserNotesEnd
  sec
  sbc #$61
  sta musicNote ;0=a,1=b,etc ...8=b#7 9=b#7
  inx  ;the X is for the octave or #
  ;lda songExampleNotes,x ;here i load octave or #
  lda (musicalNotesLow),y 
  cmp #$23;"#"
  bne parseOctave ;jumping with the octave on the accumulator and x index
  lda #$7
  clc
  adc musicNote
  ;if musicNote was a then its value was 0
  ;if I find de # the value is 0+7
  ;finding its place in frequenciesSid_1Mhz_alphabetic
  inx ; get X index to the octave after #
parseOctave:
  ;lda songExampleNotes,x
  lda (musicalNotesLow),y 
  sec ;lets substract 30 to obtain the number instead of ascii code
  sbc #$30
  sta musicOctave
  ;now we can get the frequency of the note
  jsr noteToFrequency
  ;now we have the right frequency note and octave on the variables noteFreqHigh and noteFreqLow
  ;load duration of the note
  ; function to load duration
  tya ;store x index
  pha 
  lda noteIndex
  tay 
  ;lda songExampleDuration,x
  lda (musicalDurationLow),y 
  sta noteDuration
  inc noteIndex
  pla
  tax ;return old x index
  ;ready to play at the SID
  ; lets play the note at the SID
  jsr playOneNote
  ;keep reading
  iny
  ;lda songExampleNotes,x
  lda (musicalNotesLow),y 
  cmp #$2C ;" ,  "
  beq parserNotesLoop
  
parserNotesEnd:
  pla
  tay 
  pla
  tax
  pla ;retreive accumulator
  rts

noteToFrequency:
  pha ;save accumulator
  txa
  pha
  tya
  pha
  lda musicNote
  cmp #0 ;it is the note a
  beq calculateNote ;calculating the case it was a
  ;multiply by 2 musicNote to position the byte offset
  ;for all othe notes
  clc
  rol musicNote
calculateNote:  
  ;load high byte and save it
  ldx musicNote
  lda frequenciesSid_1Mhz_alphabetic,x
  sta noteFreqHigh
  ;load low byte and save it
  inx
  lda frequenciesSid_1Mhz_alphabetic,x
  sta noteFreqLow
  ;calculate octave offset
  lda #7 ;highest octave
  sec
  sbc musicOctave
  sta octaveOffset
  ;rol according to octave
  lda musicNote ;already multiplied if 2 it is note B
  cmp #2
  bne calculateOctave
  ;calculate firt ocurrence for note B
  ldy octaveOffset
  cpy #$0 ;if zero it is done but not reproduceable for the sid b7 note
  beq noteToFrequencyDone 
  sec ;set the carry for notB at the 7 octave
  ror noteFreqHigh ;keep the carry for the low byte
  ror noteFreqLow
  ;save the correct note for b6
  ; lda #$81
  ; sta noteFreqHigh
  ; lda #$77
  ; sta noteFreqLow
  dey
  ;now keep going on the calculate octave loop
  jmp calculateOctaveLoop
calculateOctave:
  ldy octaveOffset
calculateOctaveLoop:  
  cpy #$0
  beq noteToFrequencyDone
  clc ;clear carry for rol
  ror noteFreqHigh ;keep the carry for the low byte
  ror noteFreqLow
  dey ;decrease y and keep going
  jmp calculateOctaveLoop
noteToFrequencyDone:
  ;now we have the right frequency note and octave on the variables noteFreqHigh and noteFreqLow
  ;ready to play at the SID
  pla
  tay
  pla
  tax
  pla
  rts

playOneNote:
  pha ;save accumulator
  txa
  pha
  tya
  pha
  ;load and store High frequency for Voice 1  
  lda noteFreqHigh 
  sta SID_V1FH
  ;load and store low frequency for Voice 1
  lda noteFreqLow 
  sta SID_V1FL
  ;load and wait duration for Voice 1
  ;sound delay already loaded before playinf the note
  ;lda #60 
  ;sta soundDelay
  lda noteDuration
  sta soundDelay
  ;bit 5 selects sawtooth
  ;00100001 
  ;the third bit turn on sawtooth
  ;the last bit turns on the Attack Delay Sustain cycle
  ;this starts playing the note
  lda #33 ;
  sta SID_V1CTRL
  ;wait soundDelay time
  jsr sidSoundDelay
  ;00100001 
  ;bit 5 selects sawtooth
  ;the last bit turns off starts the Release Phase
  lda #32 ;0010000
  sta SID_V1CTRL
  ;wait 50 for the duration of the release before next note
  lda #50
  sta soundDelay
  jsr sidSoundDelay
  pla
  tay
  pla
  tax
  pla
  rts


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------PARSER NOTES --------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

