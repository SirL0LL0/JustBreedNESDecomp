#!/usr/bin/env python3
"""Estrae dalla ROM giapponese i blocchi che sembrano testo (kana + 01 xx kanji, righe chiuse da 00).

  python tools/text_extract.py baserom_jp.nes [out.tsv]
Ogni blocco: offset ROM, banco 8K, numero righe, testo decodificato. Euristica: righe di >= MINCH caratteri
composte solo da byte di testo, con almeno una frazione minima di kana; i blocchi finiscono con 00 00 o con un
byte non di testo. Il risultato va validato contro il testo visto a schermo (text_locate.py).
"""
import sys
sys.path.insert(0, __file__.rsplit("tools", 1)[0] + "tools")
from charmap_jp import KANA, KANJI, decode_line

rom = open(sys.argv[1], "rb").read()[16:16 + 512 * 1024]
out = sys.argv[2] if len(sys.argv) > 2 else None

TEXT = set(KANA) - set(range(0x20, 0x40)) | {0x20} | set(range(0x30, 0x3B))
KANA_ONLY = {c for c in KANA if c >= 0x06 and not (0x20 <= c < 0x40)}
MINCH = 4


HIRA = set(range(0x06, 0x1F)) | set(range(0x66, 0x70)) | set(range(0x71, 0x9E))
KATA = set(range(0xA6, 0xE0)) | set(range(0xE6, 0xFF))
SMALL_H = {0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E}    # ぁぃぅぇぉ ゃゅょ
SMALL_K = {0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE}    # ァィゥェォ ャュョ


def plausible(raw):
    """Filtro linguistico: pochi cambi di sillabario, piccoli kana solo dopo il proprio sillabario."""
    kinds, i = [], 0
    while i < len(raw):
        if raw[i] == 0x01:
            kinds.append("J"); i += 2; continue
        c = raw[i]
        kinds.append("H" if c in HIRA else "K" if c in KATA else "S")
        i += 1
    kana = [k for k in kinds if k in "HK"]
    if len(kana) < 2:
        return False
    nz = [k for k in kinds if k not in "SJ"]
    switches = sum(1 for a, b in zip(nz, nz[1:]) if a != b)
    if switches > 1 + len(kinds) // 7:
        return False
    prev, j = None, 0
    while j < len(raw):
        c = raw[j]
        if c == 0x01:
            prev = "J"; j += 2; continue
        if c in SMALL_H and prev != "H":
            return False
        if c in SMALL_K and prev != "K":
            return False
        prev = "H" if c in HIRA else "K" if c in KATA else "S"
        j += 1
    return True


def parse_line(p):
    """Legge una riga da p fino a 00; ritorna (fine, byte) o None se non e' testo."""
    i, n_kana, n = p, 0, 0
    while i < len(rom):
        c = rom[i]
        if c == 0x00:
            break
        if c == 0x01:
            if i + 1 >= len(rom) or rom[i + 1] not in KANJI:
                return None
            i += 2; n += 1; continue
        if c not in TEXT:
            return None
        if c in KANA_ONLY:
            n_kana += 1
        n += 1; i += 1
    else:
        return None
    if n < MINCH or n_kana + 0 < max(1, n // 4):
        return None
    if not plausible(rom[p:i]):
        return None
    return i, rom[p:i]


blocks = []
p = 0
while p < len(rom) - 8:
    lines, q = [], p
    while True:
        # salta spazi iniziali di riga: fanno parte del testo
        r = parse_line(q)
        if not r:
            break
        end, raw = r
        lines.append(raw)
        q = end + 1                 # dopo il terminatore 00
        if q < len(rom) and rom[q] == 0x00:      # 00 00 = fine testo
            q += 1
            break
    if lines:
        blocks.append((p, lines, q))
        p = q
    else:
        p += 1

tot_lines = sum(len(b[1]) for b in blocks)
print("blocchi:", len(blocks), "righe:", tot_lines)
per_unit = {}
for off, lines, _ in blocks:
    per_unit.setdefault(off // 8192, []).append((off, lines))
for u in sorted(per_unit):
    print("  unit %2d: %4d blocchi, %5d righe" % (u, len(per_unit[u]), sum(len(l) for _, l in per_unit[u])))

if out:
    with open(out, "w", encoding="utf-8") as f:
        f.write("offset\tunit\tlines\ttext\n")
        for off, lines, _ in blocks:
            f.write("%05X\t%d\t%d\t%s\n" % (off, off // 8192, len(lines), " | ".join(decode_line(l) for l in lines)))
    print("scritto", out)
