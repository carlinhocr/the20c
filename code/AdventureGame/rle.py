def read_screen(filename: str):
    # Open the file and read all lines into a list
    with open(filename, "r") as file:
        lines = file.read().splitlines()
    return lines

def comprimir_ascii(cadena: str) -> str:
    if not cadena:
        return ""

    resultado = []
    actual = cadena[0]
    contador = 1

    for c in cadena[1:]:
        if c == actual:
            contador += 1
        else:
            resultado.append(f"{ord(actual)},{contador}")
            actual = c
            contador = 1

    # último grupo
    resultado.append(f"{ord(actual)},{contador}")

    return ",".join(resultado)

def comprimir_ascii_5chars(cadena: str) -> str:
    if not cadena:
        return ""

    resultado = []
    i = 0
    n = len(cadena)

    while i < n:
        # contar repeticiones del carácter actual
        j = i
        while j < n and cadena[j] == cadena[i]:
            j += 1

        repeticiones = j - i

        if repeticiones > 1:
            # carácter repetido
            resultado.append(f"{ord(cadena[i])},{repeticiones}")
            i = j
        else:
            # caracteres únicos consecutivos (hasta 5)
            grupo = []

            while i < n:
                # si empieza una repetición, cortamos
                if i + 1 < n and cadena[i] == cadena[i + 1]:
                    break

                grupo.append(str(ord(cadena[i])))
                i += 1

                if len(grupo) == 5:
                    break

            resultado.append(",".join(grupo) + ",1")

    return ",".join(resultado)

def comprimir_ascii_limit31(cadena: str) -> str:
    if not cadena:
        return ""

    resultado = []
    i = 0
    n = len(cadena)

    while i < n:
        actual = cadena[i]
        contador = 0

        # contar hasta un máximo de 31
        while i < n and cadena[i] == actual and contador < 31:
            contador += 1
            i += 1

        resultado.append(f"{ord(actual)},{contador}")

    return ",".join(resultado)


def comprimir_ascii_rle3chars(cadena: str) -> str:
    if not cadena:
        return ""

    resultado = []
    i = 0
    n = len(cadena)

    while i < n:
        actual = cadena[i]
        contador = 0

        # contar hasta 31 repeticiones
        while i < n and cadena[i] == actual and contador < 31:
            contador += 1
            i += 1

        if contador >= 3:
            # 3 o más repeticiones
            resultado.append(f"{ord(actual)},{contador}")
        else:
            # 1 o 2 repeticiones → escribir ASCII por separado
            for _ in range(contador):
                resultado.append(str(ord(actual)))
    resultado.append("255") #add line termination character for asm processing
    return ",".join(resultado)

def compress_screen(filename):
    screen = read_screen(filename)
    screen_compressed = []
    for line_uncompress in screen: 
        screen_compressed.append(comprimir_ascii_rle3chars(line_uncompress))    
    return screen_compressed  

def format_screen(screen):  
    screen_format = []
    for line in screen: 
        line_formatted = "  .byte "+line
        screen_format.append(line_formatted)
    return screen_format    

def process_screen():
    filename= "screen_la20c.txt"
    screen_compressed = compress_screen(filename)
    screen_format = format_screen(screen_compressed)
    for line in screen_format:
        print(line)

process_screen()
# Ejemplo de uso
#texto = "aaabbc"
# texto = "aaabb                                        cecaffbb hola como estas"
# comprimido = comprimir_ascii(texto)
# comprimido2 = comprimir_ascii_5chars(texto)
# comprimido3 = comprimir_ascii_limit31(texto)
# comprimido4 =  comprimir_ascii_rle3chars(texto)
# print(texto)
# print(len(texto))
# print(comprimido)
# print (comprimido.count(",")+1)
# print (comprimido2)
# print (comprimido2.count(",")+1)
# print (comprimido3)
# print (comprimido3.count(",")+1)
# print (comprimido4)
# print (comprimido4.count(",")+1)
