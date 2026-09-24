;define ports and constansts VIA1 (6000) VIA2 (7000)
;define LCD primitives for showing one message VIA1 or VIA2
;define RS232 primitives for showing lights on KB_PORTA and KB_PORTB VIA1 or VIA2


;ACIA/UART ports
ACIA_DATA = $7000
ACIA_STATUS = $7001
ACIA_CMD = $7002
ACIA_CTRL = $7003

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

;bin 2 ascii values
value =$0200 ;2 bytes, Low 16 bit half
mod10 =$0202 ;2 bytes, high 16 bit half and as it has the remainder of dividing by 10
             ;it is the mod 10 of the division (the remainder)
message = $0204 ; the result up to 6 bytes
counter = $020a ; 2 bytes

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
  jsr uartSerialInit
  jsr mainProgram


;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN-----------------------------------------------
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
  jsr printClearRS232Screen
  jsr printMessage01
  jsr delay_3_sec
  jsr printMessage02
  jsr delay_3_sec
  jsr printMessage03
  jsr delay_3_sec
  jsr printthe20cAscii
  jsr delay_3_sec
  jsr printMessage04
  jsr delay_3_sec  
  jsr printMessage05
  jsr delayClear 
  jsr printTrucoAscii
  jsr delayClear 
  jsr printMessage06
  jsr delayClear   
  jsr printCiberCirujas  
  jsr delayClear   
  jsr printArcadeAscii
  jsr delayClear   
  jsr printModoHistoriaAscii
  jsr delayClear   
  jsr printVentilastationAscii
  jsr delayClear  
  jsr printReplay
  jsr delayClear    
  jsr printMessage07
  jsr delayClear   
  jsr printCommodoreAscii
  jsr delayClear 
  jsr printMarioAscii
  jsr delayClear
  jsr printMessage08
  jsr delayClear    
  jsr printMessage09
  jsr delayClear  
  jsr print20cAscii
  jmp mainProgram
  rts

delayClear:
  jsr delay_5_sec  
  jsr printClearRS232Screen
  rts

printthe20cAscii:
  lda #< the20cAscii
  sta serialDataVectorLow
  lda #> the20cAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

printMarioAscii:
  lda #< marioReverseAscii
  sta serialDataVectorLow
  lda #> marioReverseAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts

printCiberCirujas:
  lda #< cyberCirujasAscii
  sta serialDataVectorLow
  lda #> cyberCirujasAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts  

printReplay:
  lda #< replayAscii
  sta serialDataVectorLow
  lda #> replayAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printTrucoAscii:
  lda #< trucoAscii
  sta serialDataVectorLow
  lda #> trucoAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts    

printArcadeAscii:
  lda #< arcadeAscii
  sta serialDataVectorLow
  lda #> arcadeAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts   

printModoHistoriaAscii:
  lda #< modoHistoriaAscii
  sta serialDataVectorLow
  lda #> modoHistoriaAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
  rts    

printCommodoreAscii:
  lda #< commodoreAscii
  sta serialDataVectorLow
  lda #> commodoreAscii 
  sta serialDataVectorHigh
  jsr printAsciiDrawing
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
  rts

;END--------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------MAIN PROGRAM-------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

;BEGIN------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;--------------------------------SERIALUART-----------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
serialUART:

  ldx #0
send_rs232_message:
  ;lets send a message
  lda rs232_message,x ;test for the NULL char that ends all ASCII strings
  beq send_rs232_message_end
  jsr send_rs232_char
  inx
  jmp send_rs232_message  

send_rs232_message_end:
  ;print cr
  lda #$0d
  jsr send_rs232_char
  lda #$0a
  jsr send_rs232_char 
  rts

rs232_message: .asciiz "RS-232 Terminal for 20c" ;\r carriage return \n line feed 

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
  ;jsr print_char ;print the char on the local lcd of the 20 c
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
;--------------------------------TIME MANAGEMENT------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

delay_1_sec:
  jsr DELAY_SEC
  rts

delay_2_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

delay_3_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

delay_4_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts 

delay_5_sec:
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  jsr DELAY_SEC
  rts

DELAY_onetenth_SEC:
  lda #$10
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

DELAY_two_tenth_SEC:
  lda #$10
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN   

DELAY_SEC:
  lda #$FF
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

DELAY_HALF_SEC:
  lda #$50
  sta delay_COUNT_A
  lda #$FF
  sta delay_COUNT_B
  jmp DELAY_MAIN

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



startMessage1:
  .ascii "    RS-232 TERMINAL    "   

the20cAscii:
  .ascii "  _  _     _                            "
  .ascii " | || |___| |__ _                       "
  .ascii " | __ / _ \ / _` |                      "
  .ascii " |_||_\___/_\__,_|_        ___ __       "
  .ascii " / __| ___ _  _  | |__ _  |_  )  \ __   "
  .ascii " \__ \/ _ \ || | | / _` |  / / () / _|_ "
  .ascii " |___/\___/\_, | |_\__,_| /___\__/\__( )"
  .ascii "  __| |___ |__/_ _  _ _____ _____    |/ "
  .ascii " / _` / -_) | ' \ || / -_) V / _ \      "
  .ascii " \__,_\___| |_||_\_,_\___|\_/\___/      "
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

replayAscii:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                                                  q6g"
  .ascii "                                                 ewrf"
  .ascii "         eweewefd                               fyu9     q66qo      q6q    q6."
  .ascii "      ewesadd  bttf     .(oog.   gg  g66g      345    gfhvvsas0   wqe.   ssf."
  .ascii "    6esadsd4   ndsg    6rjh43g  455v9. 4ng    s5    gsaw   sag   345   qsrv9"
  .ascii "  6we  xcvs   65ng   689(  .9)  wte   asbg   re    gsd    df9   fsv  .vcvxz"
  .ascii "  6g  qefuvmv52g   6hn1  .zg   45w   sfv6   aw    sfw   sfsd  sagv vs.vrg9"
  .ascii "     6bsd$w#6     6wefgfhg)  dfhn   sfxg  sde   nnmbb v1sav as dssdv dds."
  .ascii "    6pf   szp   63$32      6ssxc   asad sg saxvg vsxc97 sadxv  ogo  dwr"
  .ascii "   6fv    qwg dfg  fvbaxve5wsfgdggggi9)v   oggo   ogo   ogo        ddf"
  .ascii "   sd      dqs+     6vb9)  afs                                66.fdf9"
  .ascii "   o                      sas                                  669."
  .ascii "                          oo"
  .ascii ""
  .ascii "                              . . . . . . . . ."
  .ascii "                              | | | | | | | | |"
  .ascii "                             @@@@@@@@@@@@@@@@@@@"
  .ascii "                             (                 )"
  .ascii "                             )    F E L I Z    ("
  .ascii "                             (                 )"
  .ascii "                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  .ascii "                        (                           )"
  .ascii "                        )   A N I V E R S A R I O   ("
  .ascii "                        (                           )"
  .ascii "                        @@@@@@@@@@@@berdyx@@@@@@@@@@@"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

trucoAscii:

  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "         ┌─────┐┌────────────────┐"
  .ascii "      ┌──┘     └┘              ┌─┘"
  .ascii "      └──┐     │ ┌───────────┬─┘        ┌───┬───┬───┐"
  .ascii "         └┬────┘ │         ■┌┘          │7  │1  │1  │"
  .ascii "         ┌┘      │     ■    └──────┐    │ ¥ │ ! │ ¥ │"
  .ascii "         │      ┌┴┐└         ┌───┐ │    │   │   │   │"
  .ascii "         │      │ └┐         └──┐└─┘    └┬─┬┴───┴─┬─┘       ┐"
  .ascii "         └─┐ ┌──┘  └──┐   └─    │        │        │"
  .ascii "           └─┘     ┌──┴──┐   ┌┐ ├┐       └┬─────┬─┘            ┐"
  .ascii "              ┌────┘     └── └└┐┘└───┐    │     │"
  .ascii "           ┌──┘               └└┐    └────┘   ┌─┘                 ┐"
  .ascii "           │      ┌           ┌┴┴────┐        │"
  .ascii "           │      └────┐  ┌───┴─┐    │ ───────┘     ┌  ─  ─  ─  ─  ─  ─  ┐"
  .ascii "           │           └─┬┘    ─┴─┐  │"
  .ascii "           └─┐berdyx     │    ─┬──┘  │              │  T R U C O         │"
  .ascii "             └───────────┴┐  ─┬┴┐   ┌┘"
  .ascii "                          └───┘ └───┘               │    A R B I S E R   │"
  .ascii ""
  .ascii "                                                    └  ─  ─  (c) 1982-86 ┘"
  .ascii "                     DONDE TODO COMENZO..."
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

arcadeAscii:
  .ascii "                                                                           "
  .ascii "                             jugar NO es opcional                          "
  .ascii "                                                                           "
  .ascii "                                ╔═══════════╗                              "
  .ascii "                                ║  N A V E  ║                              "
  .ascii "                                ╠═══════════╣                              "
  .ascii "                                ║           ║                              "
  .ascii "                                ║   never   ║                              "
  .ascii "                                ║  give up  ║                              "
  .ascii "                                ║           ║                              "
  .ascii "                               ╔╩═══════════╩╗                             "
  .ascii "                               ║     ! o     ║                             "
  .ascii "                               ╚╦═══════════╦╝                             "
  .ascii "                                ║     ▄     ║                              "
  .ascii "                                ║    ▄█▄    ║                              "
  .ascii "                                ║   █▀ ▀█   ║                              "
  .ascii "                                ║  ███████  ║                              "
  .ascii "                                ║   ▀   ▀   ║                              "
  .ascii "                                ║           ║                              "
  .ascii "                                ║   berdyx  ║                              "
  .ascii "                                ╚═══════════╝                              "
  .ascii " ┌─────┐ ┌─┐    ┌─┐ ┌─┐ ┌────┐                                             "
  .ascii " │ ┌───┘ │ │    │ │ │ │ │ ┌┐ │                                             "
  .ascii " │ │     │ │    │ │ │ │ │    └┐                █████      ████       ████  "
  .ascii " │ └───┐ │ └──┐ │ └─┘ │ │ └┘  │               ██   ██    ██  ██     ██  ██ "
  .ascii " └─────┘ └────┘ └─────┘ └─────┘              ██         ██    ██   ██    ██"
  .ascii "                                             ██         ████████   ████████"
  .ascii "    ┌─┐ ┌─┐  ┌─────┐ ┌─┐ ┌─┐                  ██   ██   ██    ██   ██    ██"
  .ascii "    │ │ │ │  │ ┌─  │ │ │ │ │                   █████    ██    ██   ██    ██"
  .ascii "    │ └─┘ └┐ │ │ │ │ │ └─┘ └┐                                              "
  .ascii "    └───┐ ┌┘ │  ─┘ │ └───┐ ┌┘                                              "
  .ascii "        └─┘  └─────┘     └─┘                                               "
  .ascii "e" 

modoHistoriaAscii:

  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                 █                              "
  .ascii "                                               ███                              "
  .ascii "                                                ██                              "
  .ascii "                   █ ███  ██       ████       ████      ████                    "
  .ascii "                 █████ ███  ██   ██    ██   ██  ██    ██    ██                  "
  .ascii "                  ██   ██   ██   ██    ██  ██   ██    ██    ██                  "
  .ascii "                  ██   ██   ██   ██    ██  ██   ██ █  ██    ██                  "
  .ascii "                  ██   ██   ███   ██   █    ██  ███    ██   █                   "
  .ascii "                  █    █    █      ████      ███  █     ████                    "
  .ascii "                                                                                "
  .ascii "           ██       █               █                       █                   "
  .ascii "          ███                     ███                                           "
  .ascii "           ██  █     █      ███    ████    ████     ██ ██    █     ████         "
  .ascii "           ██████  ███    ███  █   ██    ██    ██  ██████  ███    █   ██        "
  .ascii "           ██  ██   ██   ███       ██    ██    ██  ██   █   ██   ██   ██        "
  .ascii "           ██  ██   ██     ████    ██    ██    ██  ██       ██   ██   ██        "
  .ascii "           ██  ██   ███  █    ██   ██ █   ██   █   ██       ███   ██ ██         "
  .ascii "           █   █    ██    ████      ██     ████    █        ██     ███ ██       "
  .ascii "              █                                                                 "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                             videojuegos en contexto                            "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                          (N. del A.: hablen del X-COM)                         "
  .ascii "                                                                                "
  .ascii "                                                                                "
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
    .ascii "                                                                                "
  .ascii "                           V E N T I L A S T A T I O N                          "
  .ascii "                                                                                "
  .ascii "              La primer consola del mundo corriendo en un ventilador            "
  .ascii "                                                                                "
  .ascii "                       Y, obviamente, creada en Argentina                       "
  .ascii "                                                                                "
  .ascii "                                                                                "
  .ascii "                                 ░░░░░░░▓▓▓▓▓▓▓                                 "
  .ascii "                             ░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓                             "
  .ascii "                          ░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                         "
  .ascii "                        ░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                       "
  .ascii "                      ▓░░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░                     "
  .ascii "                     ▓▓▓▓░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░                    "
  .ascii "                    ▓▓▓▓▓▓▓░░░░░░░░░░░░░███▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░                   "
  .ascii "                   ▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░██████▓▓▓▓▓▓▓░░░░░░░░░                  "
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░☻░░░████████▓▓▓░░░░░░░░░░░░                 "
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░☻▒▒▒▒███████░░░░░░░░░░░░░░                 "
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓███░░░░▒████▒███████░░░░░░░░░░░░░░                "
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓▓▒█  █▒███████░░░░░░░░░░░░░░                "
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓▓▒█  █▒░██████░░░░░░░░░░░░░░                "
  .ascii "                 ▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓░▒████▒░██████░░░░░░░░░░░░░░                "
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓▓████░░░▒▒▒▒░░█████░░░░░░░░░░░░░░                 "
  .ascii "                  ▓▓▓▓▓▓▓▓▓▓▓▓░░█████░░░░░░█████▓▓▓░░░░░░░░░░░░                 "
  .ascii "                   ▓▓▓▓▓▓▓▓▓░░░░░░████████████▓▓▓▓▓▓▓░░░░░░░░░                  "
  .ascii "                    ▓▓▓▓▓▓░░░░░░░░░░░██████▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░                   "
  .ascii "                     ▓▓▓░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░                    "
  .ascii "                      ▓░░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░                     "
  .ascii "                        ░░░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                       "
  .ascii "                          ░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                         "
  .ascii "                             ░░░░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓                             "
  .ascii "                                 ░░░░berdyx▓▓▓▓                                 "
  .ascii "                                       ║║                                       "
  .ascii "e" 

la20cAscii:
  .ascii "                                    LA 20c               "
  .ascii ""  
  .ascii "                                 OSOLABS.TECH            "
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
  .asciiz "   Hola de nuevo,   "
  .asciiz "                    "  
  .asciiz "   Soy, la  20c.    "
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
  .ascii "        Pero mejor traigo a un artista"
  .ascii ""  
  .ascii "            El Principe de las 286"
  .ascii ""  
  .ascii "                    Berdyx"
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
  .ascii "e"   


message07:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "                aaaaa mira quien volvio ....."
  .ascii ""  
  .ascii "                    volvio COMMODORE!!!      "
  .ascii ""
  .ascii "                Pero nada como una DREAN     "
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
  .ascii "     PVM (si no fuera por haber visto la demo del eternauta, no estariamos aca"   
  .ascii ""  
  .ascii "     ALECU (siempre coordinando y alentando"
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
  .ascii "     Esta Demo fui traida a ustedes por.."
  .ascii ""
  .ascii ""  
  .ascii ""
  .ascii ""  
  .ascii "     BERDYX (su arte nos honra)"
  .ascii ""    
  .ascii "     KRAKATOA (Arte, espíritu y magia)"   
  .ascii ""  
  .ascii "     CARLINHO (el OSO de OSOLABs,  assembler y hardware"
  .ascii ""  
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "     y también por la computadora OpenSource que corre todo esto"
  .ascii ""
  .ascii "e"   

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

left_cursor_endings:
 ; .byte  $80,$c0,$94,$d4
  .byte  $88,$c8,$9c,$dc  

right_cursor_endings:
  .byte  $93,$d3,$a7,$e7

; up_cursor_endings:
;   .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8F,$8E,$90,$91,$92,$93
up_cursor_endings: ;so it is all in one line
  .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
  
down_cursor_endings:
  .byte $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7

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



