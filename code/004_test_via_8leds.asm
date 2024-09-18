;CIA Ports and Constants
;PORTB = $6001
;PORTA = $6000
;DDRB = $6003
;DDRA = $6002

;VIA Ports and Constants
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003


  .org $8000


  .org $8000

RESET:
  ;put all bits of the 6522 as output, lets load 1111 1111
  lda #$ff  ;load all ones
  sta DDRA ;store the accumulator in the data direction register for Port A

  lda #$50 ;load value 00000101
  sta PORTA ;store the accumulator in the output register for Port A

LOOP:
  ror ;shift values one bit to the right using the carry 00000101 => 00001010
  sta PORTA ;store the accumulator in the output register for Port A

  jmp LOOP
  
;complete the file
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .word $0000 ;finish completing the values of the eeprom $fffe $ffff with values 00 00
