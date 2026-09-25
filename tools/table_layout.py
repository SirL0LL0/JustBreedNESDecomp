"""Mostra la larghezza dei record delle tabelle di nomi (distanza tra i terminatori 00) e il testo decodificato."""
import os, sys, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from charmap_jp import decode_line

rom = open(sys.argv[1] if len(sys.argv) > 1 else "baserom_jp.nes", "rb").read()[16:]
TABLES = {  # nome: (inizio, fine)
    "consumabili?": (0x4C000, 0x4C0F0),
    "accessori/oggetti": (0x4C0F0, 0x4C190),
    "equip 1": (0x4C190, 0x4C290),
    "archi": (0x4C290, 0x4C3E8),
    "armature": (0x4C3E8, 0x4C4D0),
    "incantesimi/nomi": (0x4C4D0, 0x4D000),
    "luoghi": (0x4D2B4, 0x4D400),
    "personaggi": (0x72000, 0x720ED),
    "mostri A": (0x720ED, 0x7212F),
    "mostri B": (0x7212F, 0x72231),
    "boss": (0x72231, 0x72300),
}
for name, (a, b) in TABLES.items():
    seg = rom[a:b]
    zeros = [i for i, x in enumerate(seg) if x == 0]
    dist = collections.Counter(z2 - z1 for z1, z2 in zip(zeros, zeros[1:]))
    top = dist.most_common(3)
    print("%-18s %05X-%05X  record: %s  n00=%d" % (name, a, b, top, len(zeros)))
    if len(sys.argv) > 2:
        p = 0
        for z in zeros[:60]:
            print("   %05X %s" % (a + p, decode_line(seg[p:z])))
            p = z + 1
