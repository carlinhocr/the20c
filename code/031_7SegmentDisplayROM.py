rom = bytearray([0xFF] *2048) # create an array of 32768 ea

rom[0] = 0b01110111 #number 0 in the 7 digit display
rom[1] = 0b00010001 #number 1 in the 7 digit display

with open("031_7SegmentDisplayROM.bin","wb") as out_file:
    out_file.write(rom)