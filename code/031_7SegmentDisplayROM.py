rom = bytearray([0b11111111] *2048) # create an array of 32768 ea

rom[0] = 0b01110111 #number 0 in the 7 digit display
rom[1] = 0b00010100 #number 1 in the 7 digit display
rom[2] = 0b10110011 #number 2 in the 7 digit display
rom[3] = 0b10110110 #number 3 in the 7 digit display
rom[4] = 0b11010100 #number 4 in the 7 digit display
rom[5] = 0b11100110 #number 5 in the 7 digit display
rom[6] = 0b11100111 #number 6 in the 7 digit display
rom[7] = 0b00110100 #number 7 in the 7 digit display
rom[8] = 0b11110111 #number 8 in the 7 digit display
rom[9] = 0b11110110 #number 9 in the 7 digit display
rom[10] = 0b11110101 #number 10 in the 7 digit display
rom[11] = 0b11000111 #number 11 in the 7 digit display
rom[12] = 0b01100011 #number 12 in the 7 digit display
rom[13] = 0b10010111 #number 13 in the 7 digit display
rom[14] = 0b11100011 #number 14 in the 7 digit display
rom[15] = 0b11100001 #number 15 in the 7 digit display

with open("031_7SegmentDisplayROM.bin","wb") as out_file:
    out_file.write(rom)