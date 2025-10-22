note_names = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#']
print("SID values con 1Mhz")
print("Nota, Frecuencia (Hz), Valor Extra, Hexadecimal, High Byte, Low Byte")

for key_number in range(1, 89):  # Teclas 1 a 88
    note_index = (key_number - 1) % 12
    note_name = note_names[note_index]

    octave = ((key_number + 8) // 12)
    full_note = f"{note_name}{octave}"

    # Calcular frecuencia
    frequency = 440 * (2 ** ((key_number - 49) / 12))

    # Valor extra
    #extra_value = int(frequency / 0.059604645)
    extra_value = int(frequency / (1000000/16777216))


    # Valor hexadecimal completo
    hex_value = f"0x{extra_value:04X}"

    # Obtener high y low bytes
    high_byte = (extra_value >> 8) & 0xFF
    low_byte = extra_value & 0xFF

    high_byte_str = f"${high_byte:02X}"
    low_byte_str = f"${low_byte:02X}"
    directive_byte="  .byte"



    #print(f"{full_note}, {frequency:.2f}, {extra_value}, {hex_value}, {high_byte_str}, {low_byte_str}")

    print(f"  .byte {high_byte_str}, {low_byte_str} ;{full_note}")
 