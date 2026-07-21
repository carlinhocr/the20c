;define LCD signals
E = %10000000 ;Enable Signal
RW = %01000000 ; Read/Write Signal
RS = %00100000 ; Register Select

pos_lcd_initial_line0=$80
pos_lcd_initial_line1=$C0
pos_lcd_initial_line2=$94
pos_lcd_initial_line3=$D4

lenght_screen_lines=$04; 0 to 3
lenght_ascii_line_characters=$20
lenght_screen_characters=$50 ;80 in decimal

pos_line1=$8B
pos_line2=$CB
pos_line3=$9F
pos_line4=$DF

fill=$43 ;letter C
totalScreenLenght4Lines=$50
totalScreenLenght=$3c ;make it only 3 lines long 3c = 60 decimal
totalLineLenght=$13 ;20 positions in hexadecimal is 13
end_char=$ff
cblank=$20

screen1_demo:
  .asciiz "     Adventure      "
  .asciiz "       Game         "  
  .asciiz "        RLE         "
  .asciiz "                    "