#!/usr/bin/env python3
"""lz4asm.py - arma las constantes y los cargadores en assembler para pantallas .LZ4 de la 20c

Uso:
  python3 lz4asm.py BERDYX.LZ4 OSO.LZ4 ...          (nombres como argumentos)
  ls *.LZ4 | python3 lz4asm.py                      (o la salida de ls por la entrada)
  python3 lz4asm.py -o pantallas.txt *.LZ4          (otro archivo de salida)
  python3 lz4asm.py --split *.LZ4                   (dos archivos: _constants.asm y _code.asm)

Por cada archivo NOMBRE.LZ4 genera:

  fileNOMBRE_lz:
      .byte "0:NOMBRE.LZ4,P,R", $00

  loadAndPrintNOMBRE_lz:
    lda #<fileNOMBRE_lz
    sta ZP_PTR_LO
    lda #>fileNOMBRE_lz
    sta ZP_PTR_HI
    jsr loadRetryAndPrintLZ
    rts

Solo toma los archivos que terminan en .LZ4 (sin importar mayúsculas), ignora
rutas y repetidos, y avisa si un nombre no es 8.3 (el sd2iec lo busca así).
"""
import argparse, os, re, sys

def label_for(base):
    lab = re.sub(r'[^A-Za-z0-9_]', '_', base.upper())   # vasm: letras, números y _
    if lab[0].isdigit():
        lab = 'F' + lab                                  # una etiqueta no puede empezar con número
    return lab

def main():
    ap = argparse.ArgumentParser(description='Constantes y cargadores .LZ4 para la 20c')
    ap.add_argument('files', nargs='*', help='archivos .LZ4 (si no hay, se leen de la entrada estándar)')
    ap.add_argument('-o', '--output', default='lz4_files.txt', help='archivo de salida (default: lz4_files.txt)')
    ap.add_argument('--split', action='store_true', help='escribir dos archivos: <salida>_constants.asm y <salida>_code.asm')
    a = ap.parse_args()

    names = a.files
    if not names:
        if sys.stdin.isatty():
            ap.print_help(); sys.exit(1)
        names = sys.stdin.read().split()          # salida de ls: uno o varios por línea

    seen, entries = set(), []
    for n in names:
        fname = os.path.basename(n.strip())
        if not fname.upper().endswith('.LZ4'):
            continue
        base = fname[:-4]
        lab = label_for(base)
        if lab in seen:
            continue
        seen.add(lab)
        if len(base) > 8 or not re.fullmatch(r'[A-Za-z0-9_\-]+', base):
            print(f'aviso: "{fname}" no es un nombre 8.3 simple; revisá que el sd2iec lo encuentre así', file=sys.stderr)
        if fname != fname.upper():
            print(f'aviso: "{fname}" tiene minúsculas; conviene renombrarlo en mayúsculas como los demás', file=sys.stderr)
        entries.append((lab, fname))           # el nombre va tal cual está en la tarjeta

    if not entries:
        print('No encontré archivos .LZ4 en la lista.', file=sys.stderr); sys.exit(1)

    consts = ['; ---- nombres de las pantallas .LZ4 (generado por lz4asm.py) ----']
    for lab, fname in entries:
        consts.append(f'file{lab}_lz:')
        consts.append(f'    .byte "0:{fname},P,R", $00')
        consts.append('')
    code = ['; ---- cargadores de las pantallas .LZ4 (generado por lz4asm.py) ----']
    for lab, fname in entries:
        code += [f'loadAndPrint{lab}_lz:',
                 f'  lda #<file{lab}_lz',
                 '  sta ZP_PTR_LO',
                 f'  lda #>file{lab}_lz',
                 '  sta ZP_PTR_HI',
                 '  jsr loadRetryAndPrintLZ',
                 '  rts',
                 '']

    if a.split:
        root = os.path.splitext(a.output)[0]
        open(root + '_constants.asm', 'w').write('\n'.join(consts) + '\n')
        open(root + '_code.asm', 'w').write('\n'.join(code) + '\n')
        print(f'{len(entries)} archivos -> {root}_constants.asm y {root}_code.asm')
    else:
        txt = ['; ===== CONSTANTES (van con las *_constants, fuera del camino del código) =====', ''] + consts + \
              ['', '; ===== CÓDIGO (va con las rutinas del programa) =====', ''] + code
        open(a.output, 'w').write('\n'.join(txt) + '\n')
        print(f'{len(entries)} archivos -> {a.output}')

if __name__ == '__main__':
    main()
