#!/usr/bin/env python3
"""Elenca le stringhe inline (dopo JSR $97CF, la routine di stampa che legge la stringa dal punto di ritorno).

  python tools/inline_strings.py baserom_jp.nes [out.tsv]
Ogni riga: offset ROM della stringa, banco, byte, testo decodificato. La stringa termina con 00; i byte 01 kk = kanji,
02/03/04 + parametro sono comandi (vedi docs/script_codes.md).
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from charmap_jp import decode_line
from dialog_decode import render

UNIT = 8192
rom = open(sys.argv[1], "rb").read()[16:16 + 512 * 1024]
out = open(sys.argv[2], "w", encoding="utf-8") if len(sys.argv) > 2 else None
found = []
i = 0
while i < len(rom) - 3:
    if rom[i] == 0x20 and rom[i + 1] == 0xCF and rom[i + 2] == 0x97:
        p = i + 3
        q = p
        while q < len(rom) and rom[q] != 0 and q - p < 80:
            if rom[q] == 0x01 or rom[q] in (0x02, 0x03, 0x04):
                q += 2
            else:
                q += 1
        if q < len(rom) and rom[q] == 0 and q > p:
            found.append((p, rom[p:q]))
        i = q
    i += 1
print("stringhe inline dopo JSR $97CF:", len(found))
by = {}
for off, raw in found:
    by.setdefault(off // UNIT, []).append((off, raw))
for u in sorted(by):
    print("  unit %2d: %d" % (u, len(by[u])))
if out:
    out.write("offset\tunit\tlen\ttext\n")
    for off, raw in found:
        out.write("%05X\t%d\t%d\t%s\n" % (off, off // UNIT, len(raw), render(raw).replace("\t", " ")))
    print("scritto", sys.argv[2])
