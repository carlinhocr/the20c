;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2

;SOUND VIA

SOUND_PORTB = $4000
SOUND_PORTA = $4001
SOUND_DDRB = $4002 
SOUND_DDRA = $4003
SOUND_T1CL = $4004
SOUND_T1CH = $4005
SOUND_SR = $400a
SOUND_ACR = $400b
SOUND_PCR = $400c
SOUND_IFR = $400d
SOUND_IER = $400e
SOUND_PORTANH = $400f ;port A no handshake

;ACIA/UART ports
ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003

;VIA Ports and Constant ds
LCD_PORTB = $6000
LCD_PORTA = $6001
LCD_DDRB = $6002 
LCD_DDRA = $6003
LCD_PCR = $600c
LCD_IFR = $600d
LCD_IER = $600e

; RS_PORTB = $7000
; RS_PORTA = $7001
; RS_DDRB = $7002
; RS_DDRA = $7003
; RS_PCR = $700c
; RS_IFR = $700d
; RS_IER = $700e

;CIA Ports and Constants
; RS_PORTB = $7001
; RS_PORTA = $7000
; RS_DDRB = $7003
; RS_DDRA = $7002

;zero page memory positions for Vectors and Data


charDataVectorLow = $30
charDataVectorHigh = $31
delay_COUNT_A = $32        
delay_COUNT_B = $33
screenMemoryLow=$34 ;80 bytes
screenMemoryHigh=$35 
lcdCharPositionsLowZeroPage =$36 
lcdCharPositionsHighZeroPage =$37
lcdROMPositionsLowZeroPage =$38 
lcdROMPositionsHighZeroPage =$39
initialScreenZeroPageLow=$3a
initialScreenZeroPageHigh=$3b
;record_lenght=$3c ;it is a memory position
serialDataVectorLow = $3d
serialDataVectorHigh = $3e
serialCharperLines = $3f
serialTotalLinesAscii =$40
serialDrawindEndChar=$41

soundLowByte=$50
soundHighByte=$51
soundDelay=$52
;Vectors RLE
rleVectorLow=$a0
rleVectorHigh=$a1

;Zero Page Vectors Screen
screenCurrentASCII_Low=$b0
screenCurrentASCII_High=$b1

screenCurrentDescription_Low=$b2
screenCurrentDescription_High=$b3

screenCurrentObjects_Low=$b4
screenCurrentObjects_High=$b5

objectDataVectorLow=$b6
objectDataVectorHigh=$b7

pivotZpLow=$fe
pivotZpHigh=$ff

;Memory locations RLE
rleChar=$0200
rleTimes=$0201
rleScreenLines=$0202

screenCurrentID=$0210
screenMultiple=$0211
screenRecordSize=$0212
screenCurrentBaseAddressLow=$0213
screenCurrentBaseAddressHigh=$0214

objectCurrentID=$0215
objectMultiple=$0216
objectRecordSize=$0217
object1Offset=$0218
currentObjectOffset=$0219

puzzleCurrentID=$021a
puzzleMultiple=$021b
puzzleRecordSize=$021c
puzzle1Offset=$021d
puzzleObjectOffset=$021e


objectsRAM=$0300
puzzlesRAM=$0400

;constants
fill=$43 ;letter C
totalScreenLenght4Lines=$50
totalScreenLenght=$3c ;make it only 3 lines long 3c = 60 decimal
totalLineLenght=$13 ;20 positions in hexadecimal is 13
end_char=$ff
cblank=$20

pos_line1=$8B
pos_line2=$CB
pos_line3=$9F
pos_line4=$DF

record_lenght=$09

lenght_screen_lines=$04; 0 to 3
lenght_ascii_line_characters=$20
lenght_screen_characters=$50 ;80 in decimal
pos_lcd_initial_line0=$80
pos_lcd_initial_line1=$C0
pos_lcd_initial_line2=$94
pos_lcd_initial_line3=$D4

;Memory Mappings
;these are constants where we reflect the number of the memory position

screenBufferLow =$00 ;goes to $50 which is 80 decimal
screenBufferHigh =$30

lcdCharPositionsLow =$00 ;goes to $50 which is 80 decimal
lcdCharPositionsHigh =$31

romNarcoPoliceLow=$00
romNarcoPoliceHigh=$70

romFreddyLow=$80
romFreddyHigh=$70

;bin 2 ascii values
; value =$0200 ;2 bytes, Low 16 bit half
; mod10 =$0202 ;2 bytes, high 16 bit half and as it has the remainder of dividing by 10
;              ;it is the mod 10 of the division (the remainder)
; message = $0204 ; the result up to 6 bytes
; counter = $020a ; 2 bytes

;define LCD signals
E = %10000000 ;Enable Signal
RW = %01000000 ; Read/Write Signal
RS = %00100000 ; Register Select

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
  jsr viaLcdInit
  ;jsr viaSoundInit
  jsr uartSerialInit
  jsr screenInit
  jsr lcdDemoMessage
  jsr mainProgram
  jmp listeningMode

lcdDemoMessage:

  ;Draw Screen 1 Final Demo
  lda #<screen1_demo
  sta charDataVectorLow
  lda #>screen1_demo
  sta charDataVectorHigh
  jsr print_ascii_screen
  jsr delay_3_sec

  rts 


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------ASCII----------------------------------------------
;-----------------------------------------------------------------------------------

set_position_lcd_line0:
  lda #pos_lcd_initial_line0
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line1:
  lda #pos_lcd_initial_line1
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line2:
  lda #pos_lcd_initial_line2
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
set_position_lcd_line3:
  lda #pos_lcd_initial_line3
  jsr lcd_send_instruction 
  jmp print_ascii_screen_eeprom
reset_screen_position:
  lda #pos_lcd_initial_line0
  jsr lcd_send_instruction 
  jmp print_ascii_screen_end

print_ascii_screen:  
  ;BEGIN print_ascii_screen
  jsr clear_display
  ldx #$ff ; start as ff so when i add 1 it goes to zero
  ldy #$ff ; jsut at the begginning so it would got all the 80 characters of the screen
print_ascii_screen_line:  
  inx
  cpx #$00
  beq set_position_lcd_line0
  cpx #$01
  beq set_position_lcd_line1
  cpx #$02
  beq set_position_lcd_line2
  cpx #$03
  beq set_position_lcd_line3
  cpx #$04
  beq reset_screen_position ; to reset the screen to initial position
print_ascii_screen_eeprom:
  iny ;so it would go out of a last byte equal 0 loop
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  beq print_ascii_screen_line ; jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr print_char 
  jmp print_ascii_screen_eeprom
print_ascii_screen_end:
  rts 
  ;END print_ascii_screen


;END---------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------ASCII----------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIALCDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaLcdInit:

  ;BEGIN enable interrupts LCD VIA
  ;enable CA1 for interrupts
  ;bits set/clear,timer1,timer2,CB1,CB2,ShiftReg,CA1,CA2
  lda #%10000010
  sta LCD_IER 
  ;enable negative edge transition ca1 LCD_PCR register
  ;bits 7,6,5(cb2 control),4 cb1 control,3,2,1(ca2 control),0 ca1 control
  lda #%00000000
  sta LCD_PCR 
  ;END enable interrupts

  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta LCD_DDRB ;store the accumulator in the data direction register for Port B

  lda #%11100000  ;set the last 3 pins as output PA7, PA6, PA5 and as input PA4,PA3,PA2,PA1,PA0
  sta LCD_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIALCDINIT-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASOUNDINIT---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

viaSoundInit:

  ;Enable timer 1 to square wave output on pin PB7
  ;lda #%11000000 ;$c0
  ;sta SOUND_ACR 
  ;BEGIN Configure Ports A & B
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF
  sta SOUND_DDRB ;store the accumulator in the data direction register for Port B

  lda #%11111111  ;set the last 3 pins as output PA7, PA6, PA5 and as input PA4,PA3,PA2,PA1,PA0
  sta SOUND_DDRA ;store the accumulator in the data direction register for Port A
  ;END Configure Ports A & B

  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASOUNDINIT---------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASERIALINIT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

; viaSerialInit:

;   ;set all port A pins as output but bit 6
;   ;bit 6 is the input from the serial protocol
;   lda #%10111111  ;load all ones equivalent to $FF but bit 6
;   sta RS_DDRA ;store the accumulator in the data direction register for Port A

;   ;set all port B pins as output
;   lda #%11111111  ;load all ones equivalent to $FF
;   sta RS_DDRB ;store the accumulator in the data direction register for Port B

;   lda #1
;   sta RS_PORTA
;   rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------VIASERIALINIT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------UARTSERIALINIT-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

uartSerialInit:

  ;reset UART 6551 by writting to thestatus register
  lda #$00
  sta ACIA_STATUS

  ;configure the control register
  ;bit 7 = 0 -> 1 Stop Bit
  ;bit 6 =0 and bit 5=0 -> 8 bits word lenght
  ;bit 4 = 1 -> receiver clock source is baud rate
  ;bit 3 =1 bit 2=1 bit 1=1 bit 0=0 -> 9600 baudios as a baud rate
  ;bit 3 =1 bit 2=1 bit 1=1 bit 0=1 -> 19200 baudios as a baud rate
  ;lda #%00011110 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 9600 baudios
  lda #%00011111 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 19200 baudios
  sta ACIA_CTRL

  ;configure the command register
  ;bit 7 = 0 and bit 6 =0 -> odd parity but we will not be using parity
  ;bit 5=0 -> disable parity
  ;bit 4 = 0 -> disable ECHO
  ;bit 3 =1 bit 2=0 -> RTSB Active Low and Interrupts Disable
  ;bit 1 =1 -> Receiver interrupt request disable
  ;bit 0 =1 -> Data terminal Ready (DTRB Low)
  lda #%00001011 ;N-8-1 = No parity, 8 bits, 1 Stop Bit, 9600 baudios
  sta ACIA_CMD

  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------UARTSERIALINIT-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN PROGRAM---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
mainProgram:
  jsr loadObjectsRAM
  jsr loadPuzzlesRAM
  jsr select_screen
  ;jsr draw_current_screen
  ;jsr draw_current_screen_table
  ;jsr rle_screen
  ;jsr rle_init
  ;jsr rle_expand
  ; jsr printMessage01
  ; jsr delay_3_sec
  ; jsr printMessage02
  ; jsr delay_3_sec
  ; jsr printMessage03
  ; jsr delay_3_sec
  ; jsr printthe20cAscii
  ; jsr delay_3_sec
  ; jsr printMessage04
  ; jsr delay_3_sec  
  ; jsr printMessage05
  ; jsr delay_3_sec
  ; jsr delayClear 
  ; jsr printTrucoAscii
  ; jsr delayClear 
  ; jsr printMessage06
  ; jsr delay_3_sec
  ; jsr delayClear   
  ; jsr printCiberCirujas  
  ; jsr delayClear   
  ; jsr printArcadeAscii
  ; jsr delayClear   
  ;jsr printextraRomNarcoPoliceAscii
  ;jsr delayClear  
  ;jsr printextraRomFreddyAscii 
  ;jsr delayClear  
  ; jsr printModoHistoriaAscii
  ; jsr delayClear   
  ; jsr printVentilastationAscii
  ; jsr delayClear
  ; jsr printInformaticaClasica  
  ; jsr delayClear
  ; jsr printAlfaAscii  
  ; jsr delayClear
  ; jsr printReplay
  ; jsr delayClear    
  ; jsr printMessage07
  ; jsr delay_3_sec
  ; jsr delayClear   
  ; jsr printCommodoreAscii
  ; jsr delayClear 
  ; jsr printMarioAscii
  ; jsr playMario
  ; jsr playMario
  ; jsr delayClear
  ; jsr printMessage08
  ; jsr delay_3_sec
  ; jsr delayClear    
  ; jsr printMessage09
  ; jsr delay_3_sec
  ; jsr delayClear  
  ; jsr print20cAscii
  rts

delayClear:
  jsr delay_3_sec  
  jsr printClearRS232Screen
  rts

printVentilastationAscii:
  lda #< ventilastationAscii
  sta serialDataVectorLow
  lda #> ventilastationAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

print20cAscii:
  lda #< la20cAscii
  sta serialDataVectorLow
  lda #> la20cAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

printInformaticaClasica:
  lda #< informaticaClasicaAscii
  sta serialDataVectorLow
  lda #> informaticaClasicaAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts     

printAlfaAscii:
  lda #< alfaAscii
  sta serialDataVectorLow
  lda #> alfaAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts      

printClearRS232Screen:
  lda #< clearRS232Screen
  sta serialDataVectorLow
  lda #> clearRS232Screen 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

printMessage01:
  lda #< message01
  sta serialDataVectorLow
  lda #> message01 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printMessage02:
  lda #< message02
  sta serialDataVectorLow
  lda #> message02 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts 

printMessage03:
  lda #< message03
  sta serialDataVectorLow
  lda #> message03 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts     

printMessage04:
  lda #< message04
  sta serialDataVectorLow
  lda #> message04 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts    

printMessage05:
  lda #< message05
  sta serialDataVectorLow
  lda #> message05 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts      

printMessage06:
  lda #< message06
  sta serialDataVectorLow
  lda #> message06 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printMessage07:
  lda #< message07
  sta serialDataVectorLow
  lda #> message07 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts    

printMessage08:
  lda #< message08
  sta serialDataVectorLow
  lda #> message08 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printMessage09:
  lda #< message09
  sta serialDataVectorLow
  lda #> message09 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts       

printAsciiDrawing:
  ;save accumulator x and y registers
  pha
  txa
  pha
  tya
  pha
  ;here print first line
  jsr send_rs232_line
  ldx #$0 ;the first line 0 we aleready printed
printAsciiDrawing_lenghts_loop:
  inx ;now going to line 1
  ;here increment on additional lines
  clc
  lda serialDataVectorLow ;load marioascii low
  adc serialCharperLines ; add the number of records of the last send_rs232_line
  sta serialDataVectorLow ; store the new value
  bcc printAsciiDrawing_lenghts_no_carry ;branch on carry clear or no carry
  ;if there is a carry it is in the carry flag
  ; clear the carry and add one to the high order byte
  clc
  lda serialDataVectorHigh
  adc #1; adds the carry if there is one
  sta serialDataVectorHigh
printAsciiDrawing_lenghts_no_carry  
  ;here printing the new mario line
  ldy #0
  lda (serialDataVectorLow),y 
  cmp #$65;"e"
  beq printAsciiDrawing_end
  jsr send_rs232_line
  jmp printAsciiDrawing_lenghts_loop
  ;cpx serialTotalLinesAscii ;check to see if 27 lines where printed from 1 to 26
  ;bne printAsciiDrawing_lenghts_loop
  ;return and increment according to the lenght of the mario screen
  ;end by jumping to listening mode
printAsciiDrawing_end:
  ;save accumulator x and y registers
  pla
  tay
  pla
  tax
  pla
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN PROGRAM-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

loadObjectsRAM:
  lda #$a ;10 bytes
  sta objectRecordSize
  lda #< object_0_visible
  sta pivotZpLow
  lda #> object_0_visible 
  sta pivotZpHigh
  ldx #$00
  ldy #$00
loadObjectsRAM_loop:
  lda (pivotZpLow),Y 
  sta objectsRAM,X
  tya
  clc
  adc objectRecordSize
  tay
  inx 
  cpx object_count
  bne loadObjectsRAM_loop
  rts

loadPuzzlesRAM:
  lda #$f ;16 bytes
  sta puzzleRecordSize
  lda #< puzzle_0_solved
  sta pivotZpLow
  lda #> puzzle_0_solved 
  sta pivotZpHigh
  ldx #$00
  ldy #$00
loadPuzzlesRAM_loop:
  lda (pivotZpLow),Y 
  sta puzzlesRAM,X
  tya
  clc
  adc puzzleRecordSize
  tay
  inx 
  cpx puzzle_count
  bne loadPuzzlesRAM_loop
  rts

    

select_screen:
  lda #$0
  sta screenCurrentID
  jsr screen_multiple_calculate
  jsr draw_current_screen_table
  lda #$1
  sta screenCurrentID
  jsr screen_multiple_calculate
  jsr draw_current_screen_table
  rts


screen_multiple_calculate:
  ;screen table record size
  ;8 bytes
  lda #$0
  sta screenMultiple
  lda #$8
  sta screenRecordSize
  ldx #$ff
screen_multiple_loop:
  inx
  cpx screenCurrentID
  beq screen_multiple_end
  lda screenRecordSize
  clc
  adc screenMultiple
  sta screenMultiple
  jmp screen_multiple_loop 
screen_multiple_end:
  rts

draw_current_screen_table:
;  lda #$0
;  sta screenCurrentID
;  sta screenMultiple  
  ;print ascii
  lda screenMultiple
  clc
  adc #$4 ;ascii
  tax 
  lda screen_pointers,x 
  sta serialDataVectorLow  
  inx 
  lda screen_pointers,x
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  ;print description
  lda screenMultiple
  clc
  adc #$6  ;description
  tax
  lda screen_pointers,x 
  sta serialDataVectorLow  
  inx 
  lda screen_pointers,x
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  jsr selectObject
  rts

selectObject:
  ldy #$ff
selectObject_loop:
  ;Print Object 1
  lda screenMultiple
  clc
  adc #$2  ;fist object byte
  tax
  lda screen_pointers,x 
  sta objectDataVectorLow  
  inx 
  lda screen_pointers,x
  sta objectDataVectorHigh
  ldy #$0
  lda (objectDataVectorLow),y
  sta objectCurrentID
  jsr processObject
  ldy #$1
  lda (objectDataVectorLow),y
  sta objectCurrentID
  jsr processObject
  ldy #$2
  lda (objectDataVectorLow),y
  sta objectCurrentID
  jsr processObject
  rts

processObject:
  lda objectCurrentID
  cmp #$ff ;invalid object so that slot is empty do not process
  beq end_processObject
  jsr object_multiple_calculate
  ;check visibility do not print invisible objects
  ldx objectCurrentID
  lda objectsRAM,x
  cmp #$1
  bne end_processObject
  jsr print_current_object_name
  jsr print_current_object_description
end_processObject:  
  rts

object_multiple_calculate:
  ;screen table record size
  ;8 bytes
  lda #$0
  sta objectMultiple
  lda #$a ;10 bytes
  sta objectRecordSize
  ldx #$ff
object_multiple_loop:
  inx
  cpx objectCurrentID
  beq object_multiple_end
  lda objectRecordSize
  clc
  adc objectMultiple
  sta objectMultiple
  jmp object_multiple_loop 
object_multiple_end:
  rts  

print_current_object_name:
  lda objectMultiple
  clc
  adc #$6 ;ascii
  tax 
  lda objects_pointers,x 
  sta serialDataVectorLow  
  inx 
  lda objects_pointers,x
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

print_current_object_description:
  lda objectMultiple
  clc
  adc #$8 ;ascii
  tax 
  lda objects_pointers,x 
  sta serialDataVectorLow  
  inx 
  lda objects_pointers,x
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  


  byte 00,00,00,00,00,00,00,00,00,00

screen_pointers:
  .word screen_0  ; 0,1
  .word screen_0_object ;2,3
  .word screen_0_ASCII ;4,5
  .word screen_0_description ;6,7
  .word screen_1  ; 0,1
  .word screen_1_object ;2,3
  .word screen_1_ASCII ;4,5
  .word screen_1_description ;6,7


screen_0:
screen_0_id:
  .byte 0 ;id
screen_0_object:
  .byte 0,$ff,2
screen_0_description:
  .ascii "Te encuentras a los pies de una montaña, puedes ver a lo lejos una cueva"
  .ascii "a tus pies encuentras"
  .ascii "e"
screen_0_ASCII:
  .ascii "................................................................................"
  .ascii "......................................./ \......................................"
  .ascii "....................................../   \....................................."
  .ascii "...................................../     \...................................."
  .ascii "..................................../         \................................."
  .ascii "................................./             \................................"
  .ascii "................................/                 \............................."
  .ascii "............................./        ########        \........................."
  .ascii "............................/         ##########         \......................"
  .ascii "........................./           ############           \..................."
  .ascii "....................../                ############                \............"
  .ascii "................./                     ##########                     \........."
  .ascii "............../                         ########                         \......"
  .ascii "........./                                                              \......."
  .ascii "....../                                                                    \...."
  .ascii "................................................................................"
  .ascii "................................................................................"
  .ascii ""
  .ascii "e" 

screen_1:
screen_1_id:
  .byte 1 ;id
screen_1_object:
  .byte 0,1,$ff
screen_1_description:
  .ascii "La entrada de la cueva esta colapsada, no puedes salir por ahí"
  .ascii "a tus pies encuentras"
  .ascii "e"
screen_1_ASCII:
  .ascii "#################################################################################"
  .ascii "###########################^^^^^#^^^##^^^^^^^####################################"
  .ascii "######################^^^^^########################^^^^^^########################"
  .ascii "##################^^^^^^###############################^^^^^#####################"
  .ascii "###############^^^^^#########################################^^^^^###############"
  .ascii "###########^^^^^##########################%%%%#####################^^^^^#########"
  .ascii "########^^^^^######################%%%%%%%@@@@@@%%%%%%%################^^^#######"
  .ascii "#####^^^^^###################%%%%%%%@@@@@@@@@@@@@@@@%%%%%%%################^^^^##"
  .ascii "###^^^^^##################%%%%%%%@@@@@@@@@@@######@@@@@@@@@@@%%%%%%%########^^^^#"
  .ascii "##^^^^^#################%%%%%%%@@@@@@@@######################@@@@@@@@%%%%%%%^^^^#"
  .ascii "##^^^^^###############%%%%%%%@@@@@@@@############################@@@@@@@@%%%%%%%#"
  .ascii "###^^^^^###############%%%%%%%@@@@@@################################@@@@@@%%%%%%#"
  .ascii "#####^^^^^###############%%%%%%%@@@@####################################%%%%%%%##"
  .ascii "########^^^^^##########################^^^^^^^^^^^^^^^^################^^^#######"
  .ascii "############^^^^^##########################################^^^^^#################"
  .ascii "################^^^^^######################################^^^^^#################"
  .ascii "######################^^^^^############################^^^^^#####################"
  .ascii "###############################^^^^^#^^^##^^^^^^^################################"
  .ascii "#################################################################################"
  .ascii "#################################################################################"
  .ascii ""
  .ascii "e"

; ============================================================
;  ACS Objects — auto-generated by acs_objects_to_asm.py
; ============================================================

objects_pointers:
  .word object_0_id        ; rama id          [0,1]
  .word object_0_takeable  ; rama takeable    [2,3]
  .word object_0_visible   ; rama visible     [4,5]
  .word object_0_name      ; rama name        [6,7]
  .word object_0_description ; rama description [8,9]
  .word object_1_id        ; encendedor id          [10,11]
  .word object_1_takeable  ; encendedor takeable    [12,13]
  .word object_1_visible   ; encendedor visible     [14,15]
  .word object_1_name      ; encendedor name        [16,17]
  .word object_1_description ; encendedor description [18,19]
  .word object_2_id        ; unguento id          [20,21]
  .word object_2_takeable  ; unguento takeable    [22,23]
  .word object_2_visible   ; unguento visible     [24,25]
  .word object_2_name      ; unguento name        [26,27]
  .word object_2_description ; unguento description [28,29]
  .word object_3_id        ; vela id          [30,31]
  .word object_3_takeable  ; vela takeable    [32,33]
  .word object_3_visible   ; vela visible     [34,35]
  .word object_3_name      ; vela name        [36,37]
  .word object_3_description ; vela description [38,39]

; ── Object 0: rama ──────────────────────────
object_0_id:
  .byte 0

object_0_takeable:
  .byte 1

object_0_visible:
  .byte 1

object_0_name:
  .ascii "rama"
  .ascii "e"

object_0_description:
  .ascii "es uan rama de arbol muy sólida"
  .ascii "e"

; ── Object 1: encendedor ──────────────────────────
object_1_id:
  .byte 1

object_1_takeable:
  .byte 1

object_1_visible:
  .byte 1

object_1_name:
  .ascii "encendedor"
  .ascii "e"

object_1_description:
  .ascii "es un encendedor sirve para prender cosas"
  .ascii "e"

; ── Object 2: unguento ──────────────────────────
object_2_id:
  .byte 2

object_2_takeable:
  .byte 1

object_2_visible:
  .byte 1

object_2_name:
  .ascii "unguento"
  .ascii "e"

object_2_description:
  .ascii "es una crema para curar heridas"
  .ascii "e"

; ── Object 3: vela ──────────────────────────
object_3_id:
  .byte 3

object_3_takeable:
  .byte 1

object_3_visible:
  .byte 0

object_3_name:
  .ascii "vela"
  .ascii "e"

object_3_description:
  .ascii "sirve para iluminar"
  .ascii "e"

; ── Total object count ──────────────────────────────────────
object_count:
  .byte 4


  puzzles_pointers:
  .word puzzle_0_id                   ; prender_vela id                   [0,1]
  .word puzzle_0_name                 ; prender_vela name                 [2,3]
  .word puzzle_0_action               ; prender_vela action               [4,5]
  .word puzzle_0_object1              ; prender_vela object1              [6,7]
  .word puzzle_0_object2              ; prender_vela object2              [8,9]
  .word puzzle_0_solved               ; prender_vela solved               [10,11]
  .word puzzle_0_description_solved   ; prender_vela description_solved   [12,13]
  .word puzzle_0_description_notsolved; prender_vela description_notsolved[14,15]
  .word puzzle_1_id                   ; abrir_puerta_llave id                   [16,17]
  .word puzzle_1_name                 ; abrir_puerta_llave name                 [18,19]
  .word puzzle_1_action               ; abrir_puerta_llave action               [20,21]
  .word puzzle_1_object1              ; abrir_puerta_llave object1              [22,23]
  .word puzzle_1_object2              ; abrir_puerta_llave object2              [24,25]
  .word puzzle_1_solved               ; abrir_puerta_llave solved               [26,27]
  .word puzzle_1_description_solved   ; abrir_puerta_llave description_solved   [28,29]
  .word puzzle_1_description_notsolved; abrir_puerta_llave description_notsolved[30,31]

; ── Puzzle 0: prender_vela ──────────────────────────
puzzle_0_id:
  .byte 0

puzzle_0_name:
  .ascii "prender_vela"
  .ascii "e"

puzzle_0_action:
  .byte 2  ; usar

puzzle_0_object1:
  .byte 1  ; encendedor

puzzle_0_object2:
  .byte 3  ; vela

puzzle_0_solved:
  .byte 0

puzzle_0_description_solved:
  .ascii "Ahora si puedes ver claramente, en el piso notas una llave"
  .ascii "e"

puzzle_0_description_notsolved:
  .ascii "La cueva esta muy oscura, no puedes ver casi nada"
  .ascii "e"

; ── Puzzle 1: abrir_puerta_llave ──────────────────────────
puzzle_1_id:
  .byte 1

puzzle_1_name:
  .ascii "abrir_puerta_llave"
  .ascii "e"

puzzle_1_action:
  .byte 2  ; usar

puzzle_1_object1:
  .byte 3  ; llave

puzzle_1_object2:
  .byte 4  ; puerta

puzzle_1_solved:
  .byte 0

puzzle_1_description_solved:
  .ascii "Abres la puerta y puedes pasar a otra sección de la cueva"
  .ascii "e"

puzzle_1_description_notsolved:
  .ascii "Puedes ver una puerta cerrada al final de la cueva."
  .ascii "e"

; ── Total puzzle count ──────────────────────────────────────
puzzle_count:
  .byte 2


; objects_pointers:
;   .word object_0 ; Screen zero 0,1
;   .word object_0_takable ;2,3
;   .word object_0_visible ;4,5
;   .word object_0_name ;6,7
;   .word object_0_description ;8,9
;   .word object_1 ; Screen zero
;   .word object_1_takable
;   .word object_1_visible
;   .word object_1_name
;   .word object_1_description
;   .word object_2 ; Screen zero
;   .word object_2_takable
;   .word object_2_visible
;   .word object_2_name
;   .word object_2_description

; object_0:
; object_0_id:
;   .byte 0
; object_0_takable:
;   .byte 1
; object_0_visible:
;   .byte 1  
; object_0_name:
;   .ascii "rama"
;   .ascii "e"  
; object_0_description:
;   .ascii "Es una rama de un arbol, parece muy resistente"
;   .ascii "e" 
  
; object_1:  
; object_1_id:
;   .byte 1
; object_1_takable:
;   .byte 1
; object_1_visible:
;   .byte 1    
; object_1_name:
;   .ascii "unguento"
;   .ascii "e"  
; object_1_description:
;   .ascii "Es como si fuera una crema"
;   .ascii "e"

; object_2:
; object_2_id:
;   .byte 2
; object_2_takable:
;   .byte 0
; object_2_visible:
;   .byte 0    
; object_2_name:
;   .ascii "cueva"
;   .ascii "e"  
; object_2_description:
;   .ascii "Parece muy oscura, algo te lleva a querer acercarte a ella"
;   .ascii "e"  


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------SCREEN------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------RLE------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;one line for RLE
rle_data:
  .byte 97,3,98,98,32,31,32,9,99,101,99,97,102,102,98,98,32,104,111,108,97
  .byte 32,99,111,109,111,32,101,115,116,97,115,255 ;255 is the end character
  .ascii "aaabb                                        cecaffbb hola como estas"

;algoritm
;read first char and read second char
;if first char is 255 end
;if second char <32 print first char second char times
;if second char = 255 print first char one time and end
;else all conditions print first char one time
rle_init:
  lda #< rle_data
  sta rleVectorLow
  lda #> rle_data 
  sta rleVectorHigh
  rts

rle_screen:
  lda #< screen_20c_compressed
  sta rleVectorLow
  lda #> screen_20c_compressed
  sta rleVectorHigh
  ;first byte is size
  ldy #$00
  lda (rleVectorLow),y 
  sta rleScreenLines 
rle_screen_cont:  
  ldx #$ff
rle_screen_process_line:
  inx
  cpx rleScreenLines
  beq rle_screen_end
  jsr rle_expand
  jmp rle_screen_process_line
rle_screen_end:
  rts



rle_expand:
  txa 
  pha
  ldy #$00 ;to bypass the first byte of number of lines
rle_expand_loop:
  iny
rle_expand_loop_cont1:  
  lda (rleVectorLow),y  
  cmp #$ff
  beq rle_expand_end
  sta rleChar
  iny
rle_expand_loop_cont2:   
  lda (rleVectorLow),y 
  cmp #$ff
  beq rle_expand_print_one_and_end
  lda (rleVectorLow),y   
  cmp #32
  ;when accumulator is minor that data (do not use bmi)
  bcc rle_expand_several_times
  ;if we are here is just print one time and continue
  lda #$1
  sta rleTimes
  ;print the char
  jsr rle_print_char
  dey ;decrement y as it was a new character there and not times Byte
  jmp rle_expand_loop

rle_expand_several_times:
  sta rleTimes
  ;print the char
  jsr rle_print_char
  jmp rle_expand_loop 
rle_expand_print_one_and_end:
  lda #1
  sta rleTimes
  ;print the char
  jsr rle_print_char
rle_expand_end:
  ;print line feed and carriege return
  jsr send_rs232_CRLF
  tya
  clc
  adc rleVectorLow
  sta rleVectorLow
  bcc rle_expand_end_end
  inc rleVectorHigh
rle_expand_end_end:  
  ;retreive x value for each line
  pla
  tax 
  rts  

rle_print_char:
  pha
  tya
  pha 
  txa
  pha 
  ldx #$0
rle_print_char_loop:
  cpx rleTimes
  beq rle_print_char_end
  txa
  pha 
  lda rleChar
  jsr send_rs232_char   
  pla
  tax
  inx
  jmp rle_print_char_loop
rle_print_char_end:
  pla
  tax
  pla
  tay
  pla
  rts


; rle_expand:
;   txa 
;   pha
;   ldy #$00 ;to bypass the first byte of number of lines
; rle_expand_loop:
;   iny
;   cpy #$0
;   bne rle_expand_loop_cont1
;   inc rleVectorHigh
; rle_expand_loop_cont1:  
;   lda (rleVectorLow),y  
;   cmp #$ff
;   beq rle_expand_end
;   sta rleChar
;   iny
;   cpy #$0
;   bne rle_expand_loop_cont2
;   inc rleVectorHigh
; rle_expand_loop_cont2:   
;   lda (rleVectorLow),y 
;   cmp #$ff
;   beq rle_expand_print_one_and_end
;   lda (rleVectorLow),y   
;   cmp #32
;   ;when accumulator is minor that data (do not use bmi)
;   bcc rle_expand_several_times
;   ;if we are here is just print one time and continue
;   lda #$1
;   sta rleTimes
;   ;print the char
;   jsr rle_print_char
;   dey ;decrement y as it was a new character there and not times Byte
;   jmp rle_expand_loop

; rle_expand_several_times:
;   sta rleTimes
;   ;print the char
;   jsr rle_print_char
;   jmp rle_expand_loop 
; rle_expand_print_one_and_end:
;   lda #1
;   sta rleTimes
;   ;print the char
;   jsr rle_print_char
; rle_expand_end:
;   ;print line feed and carriege return
;   jsr send_rs232_CRLF
;   tya
;   clc
;   adc rleVectorLow
;   sta rleVectorLow
;   bcc rle_expand_end_end
;   inc rleVectorHigh
; rle_expand_end_end:  
;   ;retreive x value for each line
;   pla
;   tax 
;   rts  

; rle_print_char:
;   pha
;   tya
;   pha 
;   txa
;   pha 
;   ldx #$0
; rle_print_char_loop:
;   cpx rleTimes
;   beq rle_print_char_end
;   txa
;   pha 
;   lda rleChar
;   jsr send_rs232_char   
;   pla
;   tax
;   inx
;   jmp rle_print_char_loop
; rle_print_char_end:
;   pla
;   tax
;   pla
;   tay
;   pla
;   rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------RLE------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALUART-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
serialUART:

send_rs232_line:
  ldy #$0
send_rs232_line_loop:
  lda (serialDataVectorLow),y 
  ;test for the NULL char that ends all ASCII strings
  beq send_rs232_line_end
  jsr send_rs232_char
  iny
  jmp send_rs232_line_loop 
send_rs232_line_end:
  ;add the number of characters printed + 1 for the null char
  ;store in serialCharperLines
  clc
  tya
  adc #1
  sta serialCharperLines
  jsr send_rs232_CRLF
  rts  

send_rs232_CRLF:
  lda #$0d
  jsr send_rs232_char
  lda #$0a
  jsr send_rs232_char 
  rts   

listeningMode: 
  jmp loopReceiveData ;go to listening mode
  
  
  ;wait until the status register bit 3 receive data register is full =1, then 
  ;read the data register
loopReceiveData:
   
  lda ACIA_STATUS
  and #%00001000; and it to see if bit 3 is one, delete all the other bits
  beq loopReceiveData ; if zero we have not received anythinßg
  ;if we are here we have a byte to read
  lda ACIA_DATA ;read character
  jsr print_char ;print the char on the local lcd of the 20 c
  jsr send_rs232_char ;echo the character typed
  jmp loopReceiveData ;go to wait for next character
  rts

send_rs232_char:
  sta ACIA_DATA ;wrie whatever is on the accumulator to the transmit register
  ; preserve accumulator
  pha 
  ; preserve Y register
  tya  
  pha
  ; preserve X register
  txa  
  pha  

  ;check to see if the transmit data register is empty bit 4 of the status register
tx_wait:  
  lda ACIA_STATUS
  and #%00010000 ;leave vae only bit 4 on the accumulator
  beq tx_wait ;if zero the transmit buffer is full so we wait
  jsr tx_delay ; solve bit 4 hardware issue on the wdc issue
  ;recover X register
  pla
  tax
  ;recover y register
  pla
  tay
  ; recover accumulator
  pla 
  rts

tx_delay:
  ;at 19200 bauds it is 1 bit every 52 clock cycles
  ;so 8 bits + start and stop bit it is 10 bits or 520 cycles
  ldy #102
tx_delay_loop:  
  dey ;2 cycles
  bne tx_delay_loop ; 3 cycles
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALUART-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SCREEN MANAGEMENT----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

; Positions of LCD characters
; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 1	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 2	94	95	96	97	98	99	9a	9b	9c	9d	9e	9f	a0	a1	a2	a3	a4	a5	a6	a7
; 3	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7


; Posible ordinal positions

; 01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  A,  B,  C,  D,  E,  F,  10, 11, 12, 13
; 14, 15, 16, 17, 18, 19, 1A, 1B, 1C, 1D, 1E, 1F, 20, 21, 22, 23, 24, 25, 26, 27
; 28, 29, 2A, 2B, 2C, 2D, 2E, 2F, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 3A, 3B
; 3C, 3D, 3E, 3F, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 4A, 4B, 4C, 4D, 4E, 4F

screenInit:
  jsr initilize_display
  jsr clear_display
  jsr loadCursorPositions
  jsr loadScreen
  jsr drawScreen
  jsr DELAY_SEC   
  jsr clearScreenBuffer
  jsr drawScreen 
  rts

; create a matrix of cursor positions in memory 4x20
loadCursorPositions:
  ;load vectors
  lda #lcdCharPositionsLow
  sta lcdCharPositionsLowZeroPage ; to use indirect addressing with y
  lda #lcdCharPositionsHigh
  sta lcdCharPositionsHighZeroPage
  lda #<lcd_positions
  sta lcdROMPositionsLowZeroPage
  lda #>lcd_positions
  sta lcdROMPositionsHighZeroPage
  ldy #$ff
loadCursorPositionsLoop:
  iny
  cpy #totalScreenLenght4Lines 
  ;cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq loadCursorPositionsEnd
  ; copy from ROM to RAM the LCD positions
  lda (lcdROMPositionsLowZeroPage),Y
  sta (lcdCharPositionsLowZeroPage),Y
  jmp loadCursorPositionsLoop
loadCursorPositionsEnd:
  rts

loadScreen:
  ;load vectors
  lda #screenBufferLow
  sta screenMemoryLow ; to use indirect addressing with y
  lda #screenBufferHigh
  sta screenMemoryHigh
  lda #<initialScreen
  sta initialScreenZeroPageLow
  lda #>initialScreen
  sta initialScreenZeroPageHigh
  ldy #$ff
loadScreenLoop:
  iny
  cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq loadCursorPositionsEnd
  ; copy from ROM to RAM the LCD positions
  lda (initialScreenZeroPageLow),Y
  sta (screenMemoryLow),Y
  jmp loadScreenLoop
loadScreenEnd:
  rts

drawScreen:
  ldy #$ff
drawScreenLoop:
  iny
  cpy #totalScreenLenght ;80 decimal it counts from 0 to 49 and then at 50 is the 81 number quit
  beq drawScreenEnd
  ;position cursor
  lda (lcdCharPositionsLowZeroPage),Y ;load cursor position
  jsr lcd_send_instruction ; position cursor
  ;write screen character
  lda (screenMemoryLow),Y ;load character
  jsr print_char 
  jmp drawScreenLoop
drawScreenEnd:
  rts


print_screen:  
  ;BEGIN Write all the letters 
  ldy #$00 ;first byte is the position of the line
print_screen_load_position:
  lda (charDataVectorLow),y
  cmp #end_char;compare to ending character
  beq print_screen_end ;jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr lcd_send_instruction 
  ldx #$00
print_screen_eeprom:  
  iny
  inx
  cpx record_lenght ; record lenght is a memory position now
  beq print_screen_load_position
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  jsr print_char 
  jmp print_screen_eeprom
print_screen_end:
  rts   

print_message:  
  ;BEGIN Write all the letters
  ldy #$00 ;start on FF so when i add one it will be 0

print_message_eeprom:  
  lda (charDataVectorLow),y ;load letter from eeprom position indirect in the memory position charDataVector and indexed by Y
  beq print_message_end ; jump to loop if I load a 0 on lda a zero means the end  of a n .asciiz string
  jsr print_char 
  iny
  jmp print_message_eeprom
print_message_end:
  rts 
  ;END Write all the letters  

clearScreenBuffer: 
  ldy #$FF 
clearScreenBufferLoop:
  iny      
  cpy #$50
  beq clearScreenBufferEnd
  lda #cblank ;load ship form
  sta (screenMemoryLow),y ;at the alien position en Y draw the alien ship on the accumulator
  jmp clearScreenBufferLoop 
clearScreenBufferEnd: 
  rts    


;END--------------------------------------------------------------------------------  
;-----------------------------------------------------------------------------------
;--------------------------------SCREEN MANAGEMENT----------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------



;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LCD COMMANDS---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

clear_display:
; BEGIN clear display instruction  on port B
  lda #%00000001 ;the instruction itself is 00000001
  jsr lcd_send_instruction
  ; END clear display instruction on port B 


initilize_display:
; BEGIN clear display instruction  on port B
  lda #%00000001 ;the instruction itself is 00000001
  jsr lcd_send_instruction
  ; END clear display instruction on port B  

  ; BEGIN send the instruction function set on port B
  lda #%00111000 ;the instruction itself is 001, data lenght 8bits(1), Number Display lines 2 (1)
            ;and Character Font 5x8 (0), last two bits are unused
  jsr lcd_send_instruction 
  ; END send the instruction function set on port B

  ;BEGIN Turn on Display instruction
  lda #%00001100 ;the instruction itself is 0001, Display On(1), Cursor Off (0)
            ;and Cursor Blinking Off (0)
  jsr lcd_send_instruction 
  ; END Turn on Display instruction

   ;BEGIN Entry Mode Set instruction
  lda #%00000110 ;the instruction itself is 00001, Put next character to the right (1)
            ;and Scroll Display Off (0)
  jsr lcd_send_instruction
  ; END Entry Mode Set instruction
  rts

lcd_wait:
  pha ; push to preserve the contents of the acummulator register
  ;set LCD_PORTB to all inputs so we can read the busy flag
  lda #$00000000 ;port b ins input
  sta LCD_DDRB 
lcd_busy:
  ;set register select to 0 and RW to 1 to read the busy flag
  lda #RW ;set RW RW = %01000000 ; Read/Write Signal
  sta LCD_PORTA
  lda #(RW | E) ;do the enable and do not era the RW bit
  sta LCD_PORTA
  ;this will give us the info from the busy flags and the counter 01 BF AC AC AC AC AC AC AC
  ;on port B so we read it
  lda LCD_PORTB
  and #%10000000 ;and the accumulator to loose all bits but the 7 bit (from 7 to 0)
                ; on the acummulator I will now have only the Busy Flag result
  bne lcd_busy ; branch if the zero flag is not set
  ;turn off the enable bit
  lda #RW ;set RW RW = %01000000 ; Read/Write Signal
  sta LCD_PORTA
  ;set all port B pins as output
  lda #%11111111  ;load all ones equivalent to $FF to make it output
  sta LCD_DDRB ;store the accumulator in the data direction register for Port B
  pla ; pull to restablish the contents of the acummulator register
  rts


lcd_send_instruction:
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta LCD_PORTB
            
  lda #%0  ;Clear RS,RW and E bit on Port A  
  sta LCD_PORTA ;     

  ;togle the enable bit in order to send the instruction
  ;RS is zero so we are sending instructions
  ;RW is zero so we are writing
  lda #E ;enable bit is 1 , so we turn on the chip and execute the instruction.
  sta LCD_PORTA ; 

  lda #%0  ;Clear RS,RW and E bit on Port A  
  sta LCD_PORTA ;  
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts ; return from the subroutine

print_char:
  pha ;push the accumulator value to the stack so we can have it back a the end of the subroutine
  jsr lcd_wait
  sta LCD_PORTB

  ;RS is one so we are sending data
  ;RW is zero so we are writing
  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta LCD_PORTA ;     

  ;togle the enable bit in order to send the instruction
  lda #(RS | E );RS and enable bit are 1 , we OR them and send the data
  sta LCD_PORTA ; 

  lda #RS  ;Set RS, and clear RW and E bit on Port A  
  sta LCD_PORTA ; 
  pla ;pull the accumulator value to the stack so we can have it back a the end of the subroutine
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------LCD COMMANDS---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------


;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

; delay_1_sec:
;   jsr DELAY_SEC
;   rts

; delay_2_sec:
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   rts

delay_3_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

; delay_4_sec:
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; jsr DELAY_SEC
;   ; rts 

; delay_5_sec:
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   jsr DELAY_SEC
;   rts

; DELAY_onetenth_SEC:
;   lda #$10
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN

; DELAY_two_tenth_SEC:
;   lda #$10
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN   

DELAY_SEC:
  lda #$FF
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

; DELAY_HALF_SEC:
;   lda #$50
;   sta delay_COUNT_A
;   lda #$FF
;   sta delay_COUNT_B
;   jmp DELAY_MAIN

DELAY_MAIN:
    LDX delay_COUNT_A     ; Load outer loop count
OUTER_LOOP:
    LDY delay_COUNT_B     ; Load inner loop count
INNER_LOOP:
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    NOP               ; No operation (takes 2 cycles)
    DEY               ; Decrement inner loop counter
    BNE INNER_LOOP    ; Branch if not zero
    DEX               ; Decrement outer loop counter
    BNE OUTER_LOOP    ; Branch if not zero
    RTS               ; Return from subroutine

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

nmi:
irq:
    rti

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------  

the20cAscii:
  .ascii "  _  _     _ "
  .ascii " | || |___| |__ _"
  .ascii " | __ / _ \ / _` |"
  .ascii " |_||_\___/_\__,_|_        ___ __"
  .ascii " / __| ___ _  _  | |__ _  |_  )  \ __"
  .ascii " \__ \/ _ \ || | | / _` |  / / () / _|_"
  .ascii " |___/\___/\_, | |_\__,_| /___\__/\__( )"
  .ascii "  __| |___ |__/_ _  _ _____ _____    |/"
  .ascii " / _` / -_) | ' \ || / -_) V / _ \"
  .ascii " \__,_\___| |_||_\_,_\___|\_/\___/"
  .ascii ""
  .ascii ""
  .ascii ""    
  .ascii "e"                                       

marioReverseAscii:
  .ascii "     y puedo hacer un mario"
  .ascii "██████████████████████████████████"
  .ascii "███████████████        ██      ███"
  .ascii "███████████    ░░░░░░    ▓▓▓▓▓▓ ██"
  .ascii "█████████  ░░░░░░░░░░░░  ▓▓▓▓▓▓ ██"
  .ascii "███████  ░░░░░░            ▓▓▓▓ ██"
  .ascii "█████  ░░░░░░                ▓▓ ██"
  .ascii "█████  ░░    ▓▓▓▓▓▓▓▓▓▓▓▓       ██"
  .ascii "███        ▓▓▓▓▓▓  ▓▓  ▓▓  ░░░░ ██"
  .ascii "███  ▓▓    ▓▓▓▓▓▓  ▓▓  ▓▓  ░░░░ ██"
  .ascii "█  ▓▓▓▓      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ░░ ██"
  .ascii "█  ▓▓▓▓▓▓  ▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓  ░░ ██"
  .ascii "█  ▓▓▓▓▓▓  ▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓  ░░ ██"
  .ascii "███  ▓▓▓▓▓▓▓▓        ▓▓▓▓       ██"
  .ascii "█████    ▓▓▓▓▓▓▓▓          ░░  ███"
  .ascii "███████      ▓▓▓▓▓▓▓▓▓▓  ░░░░  ███"
  .ascii "███▓▓  ░░░░              ░░  █████"
  .ascii "███  ░░░░░░░░    ▓▓▓▓▓▓    ███████"
  .ascii "█    ░░░░░░░░  ▓▓▓▓▓▓▓▓▓▓  ███████"
  .ascii "█    ░░░░░░░░  ▓▓▓▓▓▓▓▓▓▓  ███████"
  .ascii "█      ░░░░░░░░  ▓▓▓▓▓▓        ███"
  .ascii "███      ░░░░░░                ███"
  .ascii "█████                      ░░░░  █"
  .ascii "███  ░░░░                 ░░░░░░ █"
  .ascii "█    ░░                   ░░░░░░ █"
  .ascii "█  ░░░░                   ░░░░░░ █"
  .ascii "█  ░░░░           ██████  ░░░░   █"
  .ascii "█  ░░░░   ███████████████       ██"
  .ascii "███    ███████████████████████████"
  .ascii "██████████████████████████████████"
  .ascii "        y esa musiquita????     "
  .ascii "e"

cyberCirujasAscii:
  .ascii ""
  .ascii ""
  .ascii "                         █████ █   █ ████  █████ ████            n"
  .ascii "                         █   █ █   █ █  █  █     █  █            i"
  .ascii "              n          █     █████ █████ ███   █████"
  .ascii "              i          █         █ █   █ █     █   █           o"
  .ascii "                         █████ █████ █████ █████ █   █           c"
  .ascii "              h                                                  i"
  .ascii "              a                  ▓▓▓ ▓▓▓ ▓▓▓                     s"
  .ascii "              r                 ▓   ▓   ▓   ▓▓▓▓                 x"
  .ascii "              d                 ▓   ▓   ▓   ▓   ▓                s"
  .ascii "              w       ▒▒▒▒▒▒▒▒▒▒▓▓▓▓ ▓▓▓▓   ▓   ▓▒▒▒▒▒▒▒▒"
  .ascii "              a       ▒▒  ▒▒  ▒▓         ▓▓▓    ▓▒  ▒  ▒▒        c"
  .ascii "              r       ▒▒▒▒▒▒▒▒▒▓       ▓▓▒▒▒▒▓▓▓▒▒▒▒▒▒▒▒▒        o"
  .ascii "              e       ░░░░░░░░░▓   ▓▓▓▓░░░░░░░░░░░░░░░░░░        n"
  .ascii "                                ▓               ▓"
  .ascii "              o                  ▓             ▓                 h"
  .ascii "              c                   ▓▓▓▓▓▓▓▓▓▓▓▓▓                  a"
  .ascii "              i                                                  r"
  .ascii "              o      █████ ███ ████  █   █     █ █████ █████     d"
  .ascii "              s      █   █  █  █  █  █   █     █ █   █ █         w"
  .ascii "              o      █      █  █████ █   █     █ █████ █████     a"
  .ascii "                     █      █  █   █ █   █ █   █ █   █     █     r"
  .ascii "                     █████ ███ █   █ █████ █████ █   █ █████     e"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

arcadeAscii:
  .ascii ""
  .ascii "                             jugar NO es opcional"
  .ascii ""
  .ascii "                                ╔═══════════╗"
  .ascii "                                ║  N A V E  ║"
  .ascii "                                ╠═══════════╣"
  .ascii "                                ║           ║"
  .ascii "                                ║   never   ║"
  .ascii "                                ║  give up  ║"
  .ascii "                                ║           ║"
  .ascii "                               ╔╩═══════════╩╗"
  .ascii "                               ║     ! o     ║"
  .ascii "                               ╚╦═══════════╦╝"
  .ascii "                                ║     ▄     ║"
  .ascii "                                ║    ▄█▄    ║"
  .ascii "                                ║   █▀ ▀█   ║"
  .ascii "                                ║  ███████  ║"
  .ascii "                                ║   ▀   ▀   ║"
  .ascii "                                ║           ║"
  .ascii "                                ║   berdyx  ║"
  .ascii "                                ╚═══════════╝"
  .ascii " ┌─────┐ ┌─┐    ┌─┐ ┌─┐ ┌────┐"
  .ascii " │ ┌───┘ │ │    │ │ │ │ │ ┌┐ │"
  .ascii " │ │     │ │    │ │ │ │ │    └┐                █████      ████       ████  "
  .ascii " │ └───┐ │ └──┐ │ └─┘ │ │ └┘  │               ██   ██    ██  ██     ██  ██ "
  .ascii " └─────┘ └────┘ └─────┘ └─────┘              ██         ██    ██   ██    ██"
  .ascii "                                             ██         ████████   ████████"
  .ascii "    ┌─┐ ┌─┐  ┌─────┐ ┌─┐ ┌─┐                  ██   ██   ██    ██   ██    ██"
  .ascii "    │ │ │ │  │ ┌─  │ │ │ │ │                   █████    ██    ██   ██    ██"
  .ascii "    │ └─┘ └┐ │ │ │ │ │ └─┘ └┐"
  .ascii "    └───┐ ┌┘ │  ─┘ │ └───┐ ┌┘"
  .ascii "        └─┘  └─────┘     └─┘"
  .ascii "e" 

modoHistoriaAscii:

  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                                                 █"
  .ascii "                                               ███"
  .ascii "                                                ██"
  .ascii "                   █ ███  ██       ████       ████      ████"
  .ascii "                 █████ ███  ██   ██    ██   ██  ██    ██    ██"
  .ascii "                  ██   ██   ██   ██    ██  ██   ██    ██    ██"
  .ascii "                  ██   ██   ██   ██    ██  ██   ██ █  ██    ██"
  .ascii "                  ██   ██   ███   ██   █    ██  ███    ██   █"
  .ascii "                  █    █    █      ████      ███  █     ████"
  .ascii ""
  .ascii "           ██       █               █                       █"
  .ascii "          ███                     ███"
  .ascii "           ██  █     █      ███    ████    ████     ██ ██    █     ████"
  .ascii "           ██████  ███    ███  █   ██    ██    ██  ██████  ███    █   ██"
  .ascii "           ██  ██   ██   ███       ██    ██    ██  ██   █   ██   ██   ██"
  .ascii "           ██  ██   ██     ████    ██    ██    ██  ██       ██   ██   ██"
  .ascii "           ██  ██   ███  █    ██   ██ █   ██   █   ██       ███   ██ ██"
  .ascii "           █   █    ██    ████      ██     ████    █        ██     ███ ██"
  .ascii "              █"
  .ascii ""
  .ascii ""
  .ascii "                             videojuegos en contexto"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                          (N. del A.: hablen del X-COM)"
  .ascii ""
  .ascii "                          (N. del OSO: y del Defender of the Crown)"
  .ascii "e"

narcoPoliceAscii:
  .ascii "e"


commodoreAscii: 
  .ascii ""
  .ascii ""
  .ascii "              DREAN COMMODORE 64, desde San Luis a Villa Martelli"
  .ascii ""
  .ascii "   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░"
  .ascii "   ▓▓▓▓▓▓Drean Commodore ≡ 64▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓Enc ☻▓▓▓▓▓▓▓▓▓▓▓▓░b"
  .ascii "   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░e"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░r"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░d"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒┌──┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬────┬────┐▒▒▒▒▒▒▒▒▒▒┌───┐▒▒▒▒▒▒▒▒▒░y"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒│<-│1│2│3│4│5│6│7│8│9│0│+│-│£│CLR │INST│▒▒▒▒▒▒▒▒▒▒│f 1│▒▒▒▒▒▒▒▒▒░x"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒├──┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┤HOME│ DEL│▒▒▒▒▒▒▒▒▒▒└───┘▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒├────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──┴────┤▒▒▒▒▒▒▒▒▒▒┌───┐▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒│CTRL│Q│W│E│R│T│Y│U│I│O│P│@│*│↑│RESTORE│▒▒▒▒▒▒▒▒▒▒│f 3│▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒┌─┴──┬─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴───────┤▒▒▒▒▒▒▒▒▒▒└───┘▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒│RUN │SHIFT├─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──────┬┘▒▒▒▒▒▒▒▒▒▒┌───┐▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒│STOP│ LOCK│A│S│D│F│G│H│J│K│L│:│;│RETURN│▒▒▒▒▒▒▒▒▒▒▒│f 5│▒▒▒▒▒▒▒▒▒░░" 
  .ascii "   ▒▒▒▒▒▒▒▒├────┴─────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴┬──┬──┤▒▒▒▒▒▒▒▒▒▒▒└───┘▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒├─┬─────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─────┤CR│CR│▒▒▒▒▒▒▒▒▒▒▒┌───┐▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒│Ç│SHIFT│Z│X│C│V│B│N│M│,│.│/│SHIFT│SR│SR│▒▒▒▒▒▒▒▒▒▒▒│f 7│▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒└─┴─────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─────┴──┴──┘▒▒▒▒▒▒▒▒▒▒▒└───┘▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┌─────────────────┐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒└─────────────────┘▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░"
  .ascii "   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e" 

ventilastationAscii:
  .ascii ""
  .ascii "                           V E N T I L A S T A T I O N"
  .ascii ""
  .ascii "              La primer consola del mundo corriendo en un ventilador"
  .ascii ""
  .ascii "                       Y, obviamente, creada en Argentina"
  .ascii ""
  .ascii ""
  .ascii "                                 ░░░░░░░▓▓▓▓▓▓▓"
  .ascii "                             ░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓"
  .ascii "                          ░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
  .ascii "                        ░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
  .ascii "                      ▓░░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░"
  .ascii "                     ▓▓▓▓░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░"
  .ascii "                    ▓▓▓▓▓▓▓░░░░░░░░░░░░░███▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░"
  .ascii "                   ▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░██████▓▓▓▓▓▓▓░░░░░░░░░"
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░☻░░░████████▓▓▓░░░░░░░░░░░░"
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░☻▒▒▒▒███████░░░░░░░░░░░░░░"
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓███░░░░▒████▒███████░░░░░░░░░░░░░░"
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓▓▒█  █▒███████░░░░░░░░░░░░░░"
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓▓▒█  █▒░██████░░░░░░░░░░░░░░"
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓░▒████▒░██████░░░░░░░░░░░░░░"
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓▓████░░░▒▒▒▒░░█████░░░░░░░░░░░░░░"
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓░░█████░░░░░░█████▓▓▓░░░░░░░░░░░░"
  .ascii "                   ▓▓▓▓▓▓▓▓▓░░░░░░████████████▓▓▓▓▓▓▓░░░░░░░░░"
  .ascii "                    ▓▓▓▓▓▓░░░░░░░░░░░██████▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░"
  .ascii "                     ▓▓▓░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░"
  .ascii "                      ▓░░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░"
  .ascii "                        ░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
  .ascii "                          ░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
  .ascii "                             ░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓"
  .ascii "                                 ░░░░berdyx▓▓▓▓"
  .ascii "                                       ║║"
  .ascii "e" 

la20cAscii:
  .ascii "                                    LA 20c"
  .ascii ""  
  .ascii "                                 OSOLABS.TECH"
  .ascii ""  
  .ascii "                    ┌─┴─┴─┴─┴─┴─┬─┴─┴─┴─┴─┴─┬─┴─┴─┴─┴─┴─┐"
  .ascii "                    │  4F53 4F  │    RAM    │    RAM    ├"
  .ascii "                    │  ■■■■ ■■  │           │           ├"
  .ascii "                    │  Address  │    ▐░▌    │    ▐▒▌    ├"
  .ascii "                    │   Data    │           │           ├"
  .ascii "                    │  Display  │    ROM    │    ROM    ├"
  .ascii "                    ├───────────├───────────├───────────┤───────┐"
  .ascii "                    │    BUS    ▌    BUS    ▌    BUS    │ D P A │"
  .ascii "                    │           ▌           ▌           │ U R N │"
  .ascii "                    │  Address  ▌  Address  ▌  Address  │ I O L │"
  .ascii "                    │   Data    ▌   Data    ▌   Data    │ N T Y │"
  .ascii "                    │ Expansion ▌ Expansion ▌ Expansion │ O . Z │"
  .ascii "                    ├───────────┬───────────┬───────────┤───────┘"
  .ascii "                    │ VIA 6522  │   GLUE    │  CPU 6502 ├"
  .ascii "                    │           │   LOGIC   │   .....   ├"
  .ascii "                    │   ....    │....  .... │   ▓▓▓▓▓   ├"
  .ascii "                    │   ░░░░    │))))  (((( │   ·····   ├"
  .ascii "                    │   ····    │····  ···· │           ├"
  .ascii "                    ├───────────┬───────────┬───────────┤"
  .ascii "                    │  I/0 LCD  │   POWER   │   CLOCK   ├"
  .ascii "                    │           │   module  │    OSO    ├"
  .ascii "                    │ ▄▄▄▄▄▄▄▄  │  5v  ♥    │           ├"
  .ascii "                    │ █berdyx█  │  9v  ♦    │           ├"
  .ascii "                    │ ▀▀▀▀▀▀▀▀  │ 12v  ♣    │        ☻  ├"
  .ascii "                    └───────────┴───────────┴───────────┘"
  .ascii ""
  .ascii "e" 

informaticaClasicaAscii:
  .ascii "INFORMATICA CLASICA - URUGUAY               ............               ANTONIO"
  .ascii "                                          ....             ..:::.::^   SOVIET"
  .ascii "        ..............................   :.             ...::^^^^^^^   MARIO"
  .ascii "       .^^^^:::::::::::::::^^^^^^^^^^^. :.       ...::^^^^^^^^^^^^^^   TACHA"
  .ascii "       .^^:^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒.^^^^^^^^^^::.  ..::^^^^^^^^^^^^^^^^^^^^:   SANTIAGO"
  .ascii "       .^^:^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒.^^^^^^^^^^^:  :^^^^^^^^^::::::::::::::^^   PAUL"
  .ascii "       .^^^:::::::::::::::::^^^^^^^^^^^.  :^^^^:^^^^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒.  LOTHAR"
  .ascii "       .^^::░░░░░░░░░░░░░░░::^^^^^^^^^:   :^^^:.▒▒▒▒░░░░░░░░░░░░░░▒▒   MEGASHOCK"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░░░░░░░░░░░░▒▒   RANGERS"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒   CARLOS"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.^^^^^^^^^^^   GALUCCI"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.:^^^^^^^^^:   RICHARD"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.^^^^^^^^^^^   VELAZCO"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.^^^^^^^^^^^   SARTOR"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.^^^^^^^^^^^"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.^^^^^^^^^^^   Y A TODOS"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.^^^^^^^^^^^   LOS QUE"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.^^^^^^^^^^^   COMPARTEN"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.^^^^^^^^^^^   ESTAS"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░▒.:::::::::::   JORNADAS"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░░░░░░░░░░░░░▒   HISTORIA"
  .ascii "       .^^.^▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒::^^^^^^^^^.   :^^^:.▒░░░░░░░░░░░░░░░░░░▒   PRESERVAR"
  .ascii "       .^^:^░░░░░░░░░░░░░░░::^^^^^^^^^.   :^^^^:▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒.  APREMDER"
  .ascii "kr4k4t04^^::!~~~~~~~~~~~~~!:^^^^^^^^^^.   :^^^^^::::::::::^^^~~~!777      @2025"
  .ascii "e"

alfaAscii:  
  .ascii ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::kr4k4::"
  .ascii ":::::::::~~~~~~~^:::^~~^:::::::::::::^~~~~~~~~~~~~~::::::^~~~~~~::::::::::::::::"
  .ascii "::::::^░░░░░░░░B?::░░▒░░::::::::::::░░░░░░░░░░░░▒▒P:::░░░░░░░░░:^^^^^^^^::::::::"
  .ascii "::::^░░░GP777░░░::?░░░░::::::::::::░░░░▒^~~~~▒~~~!::░░░░░░░░░░░░^^^^^^^^^^::::::"
  .ascii ":::^?░░BJ:.?░░░!.~░░░░~:::::::::::░░░░░!:::::::::::░░░░░Y:.:░░░░^^^^^^^^^^^:::::"
  .ascii ":::?░5░░░░░░░░░::░░░░░::::::::::::▓▓░░░░▒░░░▒:::::░░░░░P5Y5:░░░:^^^^^^^^^^^:::::"
  .ascii "::~░░░Y!77?░░░~.!░░░░^:::::::::::░░░░░░░░░▒░~::::░░░░░░░░░░░░░░:^^^^^^^^^^^:::::"
  .ascii "::░░░B7::7░░░░::░░░░?.:::::^7?!::░░░░!.:::::::::░░░░░B?:::░░░░::^^^^^^^^^^^:::::"
  .ascii ":░░░░5::^J░▒░░:░░░░░░░░░░░░░░░?:░░░░5::::::::::░░░░░BG:::░░░░~:^^^^^^^^^^^::::::"
  .ascii "░░░░░~::7░░░░::▒▒▒░░░░░░░░▒▓▒J:░░░░░~:::::::::░░░░░GG!::░░░░J:~COMPUTERS URUGUAY"
  .ascii ":~~!::::^~~^:::^~^~~^^^^^^^~^:::~~!::::::::::::::^~!^:::^~~^:^~~^^^:^::^::::::::"
  .ascii "RICHARD & ALFA COMPUTERS - URUGUAY"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

clearRS232Screen:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e" 

screen1_demo:
  .asciiz "     Adventure      "
  .asciiz "       Game         "  
  .asciiz "        RLE         "
  .asciiz "                    "


screen2_demo:
  .asciiz "                    "
  .asciiz "    Ahora tengo     "
  .asciiz "      RS-232        "
  .asciiz "                    "  


message01:
  .ascii "Ahora si! tengo RS-232"
  .ascii "e" 

message02:
  .ascii ""

  .ascii "pero bueno muestro texto"
  .ascii "e" 

message03:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "a ver....hagamos fuerza"
  .ascii ""
  .ascii "mmmmmmffff"
  .ascii "mmmpppppfffffff"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"   

message04:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "vaaaaamoooos"
  .ascii "puedo hacer ascii ART"
  .ascii ""
  .ascii ""
  .ascii "e"    

message05:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "        Pero mejor traigo a un par de artistas"
  .ascii ""  
  .ascii ""  
  .ascii "                    Berdyx y kr4k4t04"
  .ascii ""
  .ascii "e" 

message06:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                 Tenemos muchos Amigos"
  .ascii ""  
  .ascii "        A los que les queremos Agradecer y Nombrar"
  .ascii ""  
  .ascii "                todos de la scene Retro "
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""  
  .ascii "e"   


message07:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                aaaaa mira quien volvio ....."
  .ascii ""  
  .ascii "                    volvio COMMODORE!!!"
  .ascii ""
  .ascii "                Pero nada como una DREAN"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"    

message08:
  .ascii "    y también gracias por tanto a...."
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "     ESPACIO TEC (nuetra casa)"
  .ascii ""    
  .ascii "     PVM (si no fuera por haber visto la demo del eternauta, no estariamos aca)"   
  .ascii ""  
  .ascii "     ALECU (siempre coordinando y alentando)"
  .ascii ""  
  .ascii "     Nahuel (que siempre organiza todos los eventos)"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e" 

message09:
  .ascii "     Esta Demo fue traida a ustedes por..."
  .ascii ""
  .ascii ""  
  .ascii ""
  .ascii ""  
  .ascii "     BERDYX (su arte nos honra)"
  .ascii ""    
  .ascii "     KRAKATOA (Arte, espíritu y magia)"   
  .ascii ""  
  .ascii "     CARLINHO (el OSO de OSOLABs,  assembler y hardware)"
  .ascii ""  
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "     y también por la computadora OpenSource que corre todo esto"
  .ascii ""
  .ascii "e"   

screen_20c_compressed:
  .byte 31
  .byte 32,32,34,32,31,32,5,76,65,32
  .byte 50,48,99,34,255
  .byte 32,32,34,34,32,32,255
  .byte 32,32,34,32,31,32,32,79,83,79
  .byte 76,65,66,83,46,84,69,67,72,34
  .byte 255
  .byte 32,32,34,34,32,32,255
  .byte 32,32,34,32,20,226,148,140,226,148
  .byte 128,226,148,180,226,148,128,226,148,180
  .byte 226,148,128,226,148,180,226,148,128,226
  .byte 148,180,226,148,128,226,148,180,226,148
  .byte 128,226,148,172,226,148,128,226,148,180
  .byte 226,148,128,226,148,180,226,148,128,226
  .byte 148,180,226,148,128,226,148,180,226,148
  .byte 128,226,148,180,226,148,128,226,148,172
  .byte 226,148,128,226,148,180,226,148,128,226
  .byte 148,180,226,148,128,226,148,180,226,148
  .byte 128,226,148,180,226,148,128,226,148,180
  .byte 226,148,128,226,148,144,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 52,70,53,51,32,52,70,32,32,226
  .byte 148,130,32,4,82,65,77,32,4,226
  .byte 148,130,32,4,82,65,77,32,4,226
  .byte 148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 226,150,160,226,150,160,226,150,160,226
  .byte 150,160,32,226,150,160,226,150,160,32
  .byte 32,226,148,130,32,11,226,148,130,32
  .byte 11,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 65,100,100,114,101,115,115,32,32,226
  .byte 148,130,32,4,226,150,144,226,150,145
  .byte 226,150,140,32,4,226,148,130,32,4
  .byte 226,150,144,226,150,146,226,150,140,32
  .byte 4,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 68,97,116,97,32,4,226,148,130,32
  .byte 11,226,148,130,32,11,226,148,156,34
  .byte 255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 68,105,115,112,108,97,121,32,32,226
  .byte 148,130,32,4,82,79,77,32,4,226
  .byte 148,130,32,4,82,79,77,32,4,226
  .byte 148,156,34,255
  .byte 32,32,34,32,20,226,148,156,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,156,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,156
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,164,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,144
  .byte 34,255
  .byte 32,32,34,32,20,226,148,130,32,4
  .byte 66,85,83,32,4,226,150,140,32,4
  .byte 66,85,83,32,4,226,150,140,32,4
  .byte 66,85,83,32,4,226,148,130,32,68
  .byte 32,80,32,65,32,226,148,130,34,255
  .byte 32,32,34,32,20,226,148,130,32,11
  .byte 226,150,140,32,11,226,150,140,32,11
  .byte 226,148,130,32,85,32,82,32,78,32
  .byte 226,148,130,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 65,100,100,114,101,115,115,32,32,226
  .byte 150,140,32,32,65,100,100,114,101,115
  .byte 115,32,32,226,150,140,32,32,65,100
  .byte 100,114,101,115,115,32,32,226,148,130
  .byte 32,73,32,79,32,76,32,226,148,130
  .byte 34,255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 68,97,116,97,32,4,226,150,140,32
  .byte 3,68,97,116,97,32,4,226,150,140
  .byte 32,3,68,97,116,97,32,4,226,148
  .byte 130,32,78,32,84,32,89,32,226,148
  .byte 130,34,255
  .byte 32,32,34,32,20,226,148,130,32,69
  .byte 120,112,97,110,115,105,111,110,32,226
  .byte 150,140,32,69,120,112,97,110,115,105
  .byte 111,110,32,226,150,140,32,69,120,112
  .byte 97,110,115,105,111,110,32,226,148,130
  .byte 32,79,32,46,32,90,32,226,148,130
  .byte 34,255
  .byte 32,32,34,32,20,226,148,156,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,172,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,172
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,164,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,152
  .byte 34,255
  .byte 32,32,34,32,20,226,148,130,32,86
  .byte 73,65,32,54,53,50,50,32,32,226
  .byte 148,130,32,3,71,76,85,69,32,4
  .byte 226,148,130,32,32,67,80,85,32,54
  .byte 53,48,50,32,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,11
  .byte 226,148,130,32,3,76,79,71,73,67
  .byte 32,3,226,148,130,32,3,46,5,32
  .byte 3,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 46,4,32,4,226,148,130,46,4,32
  .byte 32,46,4,32,226,148,130,32,3,226
  .byte 150,147,226,150,147,226,150,147,226,150
  .byte 147,226,150,147,32,3,226,148,156,34
  .byte 255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 226,150,145,226,150,145,226,150,145,226
  .byte 150,145,32,4,226,148,130,41,4,32
  .byte 32,40,4,32,226,148,130,32,3,194
  .byte 183,194,183,194,183,194,183,194,183,32
  .byte 3,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,3
  .byte 194,183,194,183,194,183,194,183,32,4
  .byte 226,148,130,194,183,194,183,194,183,194
  .byte 183,32,32,194,183,194,183,194,183,194
  .byte 183,32,226,148,130,32,11,226,148,156
  .byte 34,255
  .byte 32,32,34,32,20,226,148,156,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,172,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,172
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,164,34,255
  .byte 32,32,34,32,20,226,148,130,32,32
  .byte 73,47,48,32,76,67,68,32,32,226
  .byte 148,130,32,3,80,79,87,69,82,32
  .byte 3,226,148,130,32,3,67,76,79,67
  .byte 75,32,3,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,11
  .byte 226,148,130,32,3,109,111,100,117,108
  .byte 101,32,32,226,148,130,32,4,79,83
  .byte 79,32,4,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,226
  .byte 150,132,226,150,132,226,150,132,226,150
  .byte 132,226,150,132,226,150,132,226,150,132
  .byte 226,150,132,32,32,226,148,130,32,32
  .byte 53,118,32,32,226,153,165,32,4,226
  .byte 148,130,32,11,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,226
  .byte 150,136,98,101,114,100,121,120,226,150
  .byte 136,32,32,226,148,130,32,32,57,118
  .byte 32,32,226,153,166,32,4,226,148,130
  .byte 32,11,226,148,156,34,255
  .byte 32,32,34,32,20,226,148,130,32,226
  .byte 150,128,226,150,128,226,150,128,226,150
  .byte 128,226,150,128,226,150,128,226,150,128
  .byte 226,150,128,32,32,226,148,130,32,49
  .byte 50,118,32,32,226,153,163,32,4,226
  .byte 148,130,32,8,226,152,187,32,32,226
  .byte 148,156,34,255
  .byte 32,32,34,32,20,226,148,148,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,180,226,148,128,226,148,128
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,180
  .byte 226,148,128,226,148,128,226,148,128,226
  .byte 148,128,226,148,128,226,148,128,226,148
  .byte 128,226,148,128,226,148,128,226,148,128
  .byte 226,148,128,226,148,152,34,255
  .byte 32,32,34,34,255
  .byte 32,32,34,101,34,32,255


lcd_positions:
lcd_positions_line0:
  .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F,$90,$91,$92,$93
lcd_positions_line1:
  .byte $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF,$D0,$D1,$D2,$D3
lcd_positions_line2:
  .byte $94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F,$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
lcd_positions_line3:
  .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7


; 	01	02	03	04	05	06	07	08	09	10	11	12	13	14	15	16	17	18	19	20
; 0	80	81	82	83	84	85	86	87	88	89	8A	8B	8C	8D	8F	8E	90	91	92	93
; 1	C0	C1	C2	C3	C4	C5	C6	C7	C8	C9	CA	CB	CC	CD	CE	CF	D0	D1	D2	D3
; 2	94	95	96	97	98	99	9a	9b	9c	9d	9e	9f	a0	a1	a2	a3	a4	a5	a6	a7
; 3	D4	D5	D6	D7	D8	D9	DA	DB	DC	DD	DE	DF	E0	E1	E2	E3	E4	E5	E6	E7
initialScreen:
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill
  .byte fill,fill,fill,fill,fill,fill,fill,fill,fill,fill

; left_cursor_endings:
;  ; .byte  $80,$c0,$94,$d4
;   .byte  $88,$c8,$9c,$dc  

; right_cursor_endings:
;   .byte  $93,$d3,$a7,$e7

; ; up_cursor_endings:
; ;   .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8F,$8E,$90,$91,$92,$93
; up_cursor_endings: ;so it is all in one line
;   .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
  
; down_cursor_endings:
;   .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------------------DATA----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
  

;complete the file
  .org $fffa
  .word nmi ;a word is 16 bits or two bytes in this case $fffa and $fffb
  .org $fffc ;go to memory address $fffc of the reset vector
  .word RESET ;store in $FFFC & $FFFD the memory address of the RESET: label  00 80 ($8000 in little endian)
  .org $fffe
  .word irq ;a word is 16 bits or two bytes in this case $fffe and $ffff



