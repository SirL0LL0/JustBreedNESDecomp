#!/usr/bin/env python3
"""Scansione esplorativa dei caricamenti di puntatore-stringa nella ROM giapponese di Just Breed.

Cerca  LDA #lo / STA $BE / LDA #hi / STA $BF  (e la variante con hi prima) seguito, entro pochi byte,
da JSR abs, e riporta per ogni banco da 8K le chiamate e le subroutine di stampa piu' usate.
"""
import collections, sys

rom = open(sys.argv[1] if len(sys.argv) > 1 else "baserom_jp.nes", "rb").read()[16:16 + 512 * 1024]
UNIT = 8192


def scan_unit(u):
    d = rom[u * UNIT:(u + 1) * UNIT]
    hits = []
    for i in range(len(d) - 12):
        # A9 lo 85 BE A9 hi 85 BF 20 a b   |   A9 hi 85 BF A9 lo 85 BE 20 a b
        if d[i] == 0xA9 and d[i + 2] == 0x85 and d[i + 4] == 0xA9 and d[i + 6] == 0x85:
            if d[i + 3] == 0xBE and d[i + 7] == 0xBF:
                lo, hi = d[i + 1], d[i + 5]
            elif d[i + 3] == 0xBF and d[i + 7] == 0xBE:
                hi, lo = d[i + 1], d[i + 5]
            else:
                continue
            j = i + 8
            if d[j] == 0x20:
                hits.append((i, (hi << 8) | lo, d[j + 1] | (d[j + 2] << 8)))
    return hits


tot = 0
subs = collections.Counter()
for u in range(64):
    h = scan_unit(u)
    if not h:
        continue
    tot += len(h)
    c = collections.Counter(s for _, _, s in h)
    for s, n in c.items():
        subs[(u, s)] += n
    print("unit %2d: %3d caricamenti; sub di stampa: %s" % (u, len(h), ", ".join("$%04X x%d" % (s, n) for s, n in c.most_common(3))))
print("totale caricamenti puntatore+JSR:", tot)
