rom = bytearray([0b11111111] *2048) # create an array of 32768 ea

digits= bytearray=(0b01110111,0b00010100,0b10110011,0b10110110,
                   0b11010100,0b11100110,0b11100111,0b00110100,
                   0b11110111,0b11110110,0b11110101,0b11000111,
                   0b01100011,0b10010111,0b11100011,0b11100001) 

# address that are of the form 0 XXXX0000 will show on the second display
# address that are of the form 1 0000XXXX will show on the first display
for indexRom in range(255):
    indexDigit = indexRom % 16
    rom[indexRom]=indexDigit

with open("032_2x7SD_ROM.bin","wb") as out_file:
    out_file.write(rom)