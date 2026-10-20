#!/usr/bin/env python3
"""
pantalla20c.py - Arma pantallas de texto grande para la 20c (estilo AMIGOS.BIN).

Letras de 5x7 píxeles dibujadas con medio bloque (▀ ▄ █), hasta 4 renglones de
13 letras, centradas, con un pie de texto chico. Genera el .BIN en el formato
de la 20c (25 líneas separadas por 00, termina en ESC[0m 00, <= 12288 bytes),
y si están instaladas las librerías, también el .LZ4 y una vista previa .PNG.

Uso:
  python3 pantalla20c.py ASISI "A SISI" "TENEMOS" "MÚSICA CON" "TREMENDO SID"
  python3 pantalla20c.py GRACIAS "¡GRACIAS!" --fondo 22 --letra 226
  python3 pantalla20c.py FIN "FIN" --pie ""          (sin pie)
  python3 pantalla20c.py --letras                     (muestra todas las letras)

Opciones:
  --pie TEXTO      texto chico del renglón 23 (por defecto el de la FlashParty)
  --fondo N        color de fondo, 16-255 (por defecto 27, azul)
  --letra N        color de las letras grandes (por defecto 231, blanco)
  --color-pie N    color del pie (por defecto 153, celeste claro)
  --sin-lz4        no genera el .LZ4
  --sin-png        no genera la vista previa

Colores útiles (256 colores, evitar 0-15):
  16 negro · 231 blanco · 27 azul · 33/39 celeste · 117 celeste claro · 22/28 verde
  46 verde Matrix · 196 rojo · 88 bordó · 226 amarillo · 214 naranja · 201 magenta
  93 violeta · 232-255 grises (de oscuro a claro)

Para el .LZ4 hace falta:  pip install lz4      Para el PNG:  pip install pillow
"""
import argparse
import sys

# ---------------------------------------------------------------- fuente 5x7
# Las letras de AMIGOS.BIN (A C D E G I L M N O R S T U Y) y el resto dibujado
# en el mismo estilo. 7 renglones de 5 columnas, '#' = píxel prendido.
FONT = {
 'A': ".###. #...# #...# ##### #...# #...# #...#",
 'B': "####. #...# #...# ####. #...# #...# ####.",
 'C': ".###. #...# #.... #.... #.... #...# .###.",
 'D': "####. #...# #...# #...# #...# #...# ####.",
 'E': "##### #.... #.... ####. #.... #.... #####",
 'F': "##### #.... #.... ####. #.... #.... #....",
 'G': ".###. #...# #.... #.### #...# #...# .###.",
 'H': "#...# #...# #...# ##### #...# #...# #...#",
 'I': ".###. ..#.. ..#.. ..#.. ..#.. ..#.. .###.",
 'J': "..### ...#. ...#. ...#. ...#. #..#. .##..",
 'K': "#...# #..#. #.#.. ##... #.#.. #..#. #...#",
 'L': "#.... #.... #.... #.... #.... #.... #####",
 'M': "#...# ##.## #.#.# #...# #...# #...# #...#",
 'N': "#...# ##..# #.#.# #..## #...# #...# #...#",
 'O': ".###. #...# #...# #...# #...# #...# .###.",
 'P': "####. #...# #...# ####. #.... #.... #....",
 'Q': ".###. #...# #...# #...# #.#.# #..#. .##.#",
 'R': "####. #...# #...# ####. #.#.. #..#. #...#",
 'S': "##### #.... #.... .#### ....# ....# #####",
 'T': "##### ..#.. ..#.. ..#.. ..#.. ..#.. ..#..",
 'U': "#...# #...# #...# #...# #...# #...# .###.",
 'V': "#...# #...# #...# #...# #...# .#.#. ..#..",
 'W': "#...# #...# #...# #...# #.#.# ##.## #...#",
 'X': "#...# #...# .#.#. ..#.. .#.#. #...# #...#",
 'Y': "#...# #...# .#.#. ..#.. ..#.. ..#.. ..#..",
 'Z': "##### ....# ...#. ..#.. .#... #.... #####",
 '0': ".###. #...# #..## #.#.# ##..# #...# .###.",
 '1': "..#.. .##.. ..#.. ..#.. ..#.. ..#.. .###.",
 '2': ".###. #...# ....# ...#. ..#.. .#... #####",
 '3': "##### ...#. ..#.. ...#. ....# #...# .###.",
 '4': "...#. ..##. .#.#. #..#. ##### ...#. ...#.",
 '5': "##### #.... ####. ....# ....# #...# .###.",
 '6': "..##. .#... #.... ####. #...# #...# .###.",
 '7': "##### ....# ...#. ..#.. .#... .#... .#...",
 '8': ".###. #...# #...# .###. #...# #...# .###.",
 '9': ".###. #...# #...# .#### ....# ...#. .##..",
 ' ': "..... ..... ..... ..... ..... ..... .....",
 '!': "..#.. ..#.. ..#.. ..#.. ..#.. ..... ..#..",
 '¡': "..#.. ..... ..#.. ..#.. ..#.. ..#.. ..#..",
 '?': ".###. #...# ....# ...#. ..#.. ..... ..#..",
 '¿': "..#.. ..... ..#.. .#... #.... #...# .###.",
 '.': "..... ..... ..... ..... ..... ..... ..#..",
 ',': "..... ..... ..... ..... ..... ..#.. .#...",
 ':': "..... ..#.. ..... ..... ..... ..#.. .....",
 ';': "..... ..#.. ..... ..... ..... ..#.. .#...",
 '-': "..... ..... ..... ##### ..... ..... .....",
 '+': "..... ..#.. ..#.. ##### ..#.. ..#.. .....",
 '=': "..... ..... ##### ..... ##### ..... .....",
 '/': "....# ....# ...#. ..#.. .#... #.... #....",
 "'": "..#.. ..#.. .#... ..... ..... ..... .....",
 '"': ".#.#. .#.#. ..... ..... ..... ..... .....",
 '(': "...#. ..#.. .#... .#... .#... ..#.. ...#.",
 ')': ".#... ..#.. ...#. ...#. ...#. ..#.. .#...",
 '#': ".#.#. .#.#. ##### .#.#. ##### .#.#. .#.#.",
 '$': "..#.. .#### #.#.. .###. ..#.# ####. ..#..",
 '%': "##..# ##..# ...#. ..#.. .#... #..## #..##",
 '&': ".##.. #..#. #.#.. .#... #.#.# #..#. .##.#",
 '*': "..... #.#.# .###. ##### .###. #.#.# .....",
 '<': "...#. ..#.. .#... #.... .#... ..#.. ...#.",
 '>': ".#... ..#.. ...#. ....# ...#. ..#.. .#...",
 '_': "..... ..... ..... ..... ..... ..... #####",
 '@': ".###. #...# #.### #.#.# #.### #.... .####",
 '♥': "..... .#.#. ##### ##### .###. ..#.. .....",
 '★': "..#.. ..#.. ##### .###. .#.#. #...# .....",
 '♪': "..##. ..#.# ..#.. ..#.. ###.. ###.. .....",
}
# Acentos: van en el renglón vacío de arriba de la letra (2 píxeles más arriba),
# así no se pegan a la letra. La U con diéresis lleva dos puntos.
ACCENTS = {'Á': ('A', "...#."), 'É': ('E', "...#."), 'Í': ('I', "...#."),
           'Ó': ('O', "...#."), 'Ú': ('U', "...#."), 'Ü': ('U', ".#.#."),
           'Ñ': ('N', ".####")}

MAX_COLS = 13      # 13 letras * 6 columnas - 1 = 77 <= 80
MAX_LINES = 4      # 4 renglones de 4 filas + 1 fila de separación
ROW_PIE = 22       # renglón del pie (0 = primera fila de la pantalla)
DEFAULT_PIE = 'OSO labs · the 20c · FlashParty 2026'


def glyph(ch):
    """Devuelve (filas de la letra, fila del acento o None)."""
    accent = None
    if ch in ACCENTS:
        ch, accent = ACCENTS[ch]
    if ch not in FONT:
        raise KeyError(ch)
    rows = [[c == '#' for c in r] for r in FONT[ch].split()]
    return rows, ([c == '#' for c in accent] if accent else None)


def build(name, lines, pie, fondo, letra, color_pie):
    lines = [l.upper() for l in lines]
    if not 1 <= len(lines) <= MAX_LINES:
        sys.exit(f'Error: tiene que haber entre 1 y {MAX_LINES} renglones.')
    for l in lines:
        if len(l) > MAX_COLS:
            sys.exit(f'Error: "{l}" tiene {len(l)} letras y entran {MAX_COLS} por renglón.')
        for ch in l:
            try:
                glyph(ch)
            except KeyError:
                sys.exit(f'Error: la letra "{ch}" no está en la fuente (mirá --letras).')
    if len(pie) > 80:
        sys.exit('Error: el pie tiene más de 80 caracteres.')

    # 80x48 píxeles: cada fila de la terminal tiene 2 (arriba = ▀, abajo = ▄)
    px = [[False] * 80 for _ in range(48)]
    first = 1 + (MAX_LINES - len(lines)) * 5 // 2      # centrado vertical
    for k, text in enumerate(lines):
        y0 = 2 * (first + 5 * k)                        # píxel de arriba de la letra
        x0 = (80 - (6 * len(text) - 1)) // 2            # centrado horizontal
        for i, ch in enumerate(text):
            rows, accent = glyph(ch)
            x = x0 + 6 * i
            for gy, r in enumerate(rows):
                for gx, on in enumerate(r):
                    px[y0 + gy][x + gx] = on
            if accent:
                for gx, on in enumerate(accent):
                    px[y0 - 2][x + gx] = on

    blocks = {(False, False): ' ', (True, False): '▀', (False, True): '▄', (True, True): '█'}
    out = []
    for r in range(24):
        if r == ROW_PIE and pie:
            s, col = pie.center(80), color_pie
        else:
            s = ''.join(blocks[(px[2*r][x], px[2*r+1][x])] for x in range(80))
            col = letra
        out.append(f'\x1b[{r+1};1H\x1b[38;5;{col};48;5;{fondo}m{s}\x1b[0m'.encode('utf-8'))
    data = b'\x1b[2J\x1b[?25l' + b'\x00' + b'\x00'.join(out) + b'\x00'

    assert data.count(0) == 25 and data.endswith(b'\x1b[0m\x00')
    if len(data) > 12288:
        sys.exit(f'Error: la pantalla mide {len(data)} bytes y el buffer es de 12288.')
    open(f'{name}.BIN', 'wb').write(data)
    print(f'{name}.BIN  {len(data)} bytes')
    return data, px


def write_lz4(name, raw):
    try:
        import lz4.block
    except ImportError:
        print('(no se generó el .LZ4: falta "pip install lz4")')
        return
    blk = lz4.block.compress(raw, mode='high_compression', compression=12, store_size=False)
    out = len(raw).to_bytes(2, 'little') + len(blk).to_bytes(2, 'little') + blk
    assert len(raw) < 0x3000 and len(out) <= 0x3000
    assert lz4.block.decompress(blk, uncompressed_size=len(raw)) == raw
    open(f'{name}.LZ4', 'wb').write(out)
    print(f'{name}.LZ4  {len(out)} bytes ({100 * len(out) // len(raw)} %)')


def rgb(n):
    if n >= 232:
        v = 8 + 10 * (n - 232)
        return (v, v, v)
    n -= 16
    l = [0, 95, 135, 175, 215, 255]
    return (l[n // 36], l[(n // 6) % 6], l[n % 6])


def write_png(name, px, pie, fondo, letra, color_pie):
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print('(no se generó la vista previa: falta "pip install pillow")')
        return
    S = 12
    im = Image.new('RGB', (80 * S, 48 * S), rgb(fondo))
    d = ImageDraw.Draw(im)
    for y in range(48):
        for x in range(80):
            if px[y][x]:
                d.rectangle([x*S, y*S, x*S + S - 1, y*S + S - 1], fill=rgb(letra))
    if pie:
        try:
            f = ImageFont.truetype('DejaVuSansMono-Bold.ttf', 20)
        except OSError:
            f = ImageFont.load_default()
        x0 = (80 - len(pie)) // 2
        for i, ch in enumerate(pie):
            d.text(((x0 + i) * S, ROW_PIE * 2 * S), ch, font=f, fill=rgb(color_pie))
    im.save(f'{name}_preview.png')
    print(f'{name}_preview.png')


def show_letters():
    chars = list(FONT) + list(ACCENTS)
    for i in range(0, len(chars), 12):
        group = chars[i:i + 12]
        print('  '.join(f'{c:^5}' for c in group))
        for gy in range(-2, 7):
            line = []
            for c in group:
                rows, acc = glyph(c)
                r = acc if gy == -2 else ([False] * 5 if gy == -1 else rows[gy])
                line.append(''.join('█' if v else ' ' for v in (r or [False] * 5)))
            print('  '.join(line))
        print()


def color(s):
    n = int(s)
    if not 16 <= n <= 255:
        raise argparse.ArgumentTypeError('usá colores de 16 a 255 (0-15 cambian según el tema de la VTE)')
    return n


def main():
    p = argparse.ArgumentParser(description='Pantallas de texto grande para la 20c.')
    p.add_argument('nombre', nargs='?', help='nombre del archivo, 8 letras como máximo (ej. ASISI)')
    p.add_argument('renglones', nargs='*', help=f'hasta {MAX_LINES} renglones de {MAX_COLS} letras')
    p.add_argument('--pie', default=DEFAULT_PIE)
    p.add_argument('--fondo', type=color, default=27)
    p.add_argument('--letra', type=color, default=231)
    p.add_argument('--color-pie', type=color, default=153)
    p.add_argument('--sin-lz4', action='store_true')
    p.add_argument('--sin-png', action='store_true')
    p.add_argument('--letras', action='store_true', help='muestra todas las letras de la fuente')
    a = p.parse_args()

    if a.letras:
        show_letters()
        return
    if not a.nombre or not a.renglones:
        p.error('falta el nombre y al menos un renglón (ej: ASISI "A SISI" "TENEMOS")')
    name = a.nombre.upper()
    if len(name) > 8 or not name.replace('_', '').isalnum() or not name.isascii():
        sys.exit('Error: el nombre tiene que tener hasta 8 letras o números (formato 8.3 del sd2iec).')

    data, px = build(name, a.renglones, a.pie, a.fondo, a.letra, a.color_pie)
    if not a.sin_lz4:
        write_lz4(name, data)
    if not a.sin_png:
        write_png(name, px, a.pie, a.fondo, a.letra, a.color_pie)
    print(f'\nfile{name}:    .byte "0:{name}.BIN,P,R", $00')
    if not a.sin_lz4:
        print(f'file{name}_LZ: .byte "0:{name}.LZ4,P,R", $00')


if __name__ == '__main__':
    main()
