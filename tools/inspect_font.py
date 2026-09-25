"""Ispeziona la convenzione dei pixel dei glifi kana e la copertura del font Unscii."""
import collections, os
here = os.path.dirname(os.path.abspath(__file__))
rom = open(os.path.join(here, "..", "baserom_jp.nes"), "rb").read()
prg = rom[4] * 16384
chr_ = rom[16 + prg:]


def tile(bank, n):
    o = bank * 4096 + n * 16
    return [[((chr_[o + y] >> (7 - x)) & 1) | (((chr_[o + y + 8] >> (7 - x)) & 1) << 1) for x in range(8)] for y in range(8)]


for name, bank, n in (("あ top", 60, 0x71), ("あ bottom", 61, 0x71), ("ア top", 60, 0xB1), ("space", 60, 0x20), ("cifra 5 top", 60, 0x35)):
    print(name)
    for r in tile(bank, n):
        print("  " + "".join(".123"[v] for v in r))
c = collections.Counter(v for b in (60, 61) for n in range(0x66, 0xE0) for r in tile(b, n) for v in r)
print("valori pixel nei kana:", dict(c))
d = {}
for l in open(os.path.join(here, "..", "assets", "unscii-16.hex")):
    if ":" in l:
        a, b = l.strip().split(":")
        d[int(a, 16)] = b
for ch in "aàèéìòùÈÉ,;'\"“”":
    b = d.get(ord(ch))
    print(repr(ch), "ok %d byte" % (len(b) // 2) if b else "MANCA")
