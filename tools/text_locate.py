#!/usr/bin/env python3
"""Individua dove sta il testo nella ROM: cerca le righe di tile-id viste a schermo (jb_nt_all.bin, prodotto
da JB_DUMP_EVERY) come sottosequenze di byte nella ROM. Riporta i punti di ROM con corrispondenze lunghe.

  python tools/text_locate.py baserom_jp.nes C:/temp/jb_nt_all.bin [lunghezza_minima=6]
"""
import collections, struct, sys

rom = open(sys.argv[1], "rb").read()[16:16 + 512 * 1024]
snap = open(sys.argv[2], "rb").read()
minlen = int(sys.argv[3]) if len(sys.argv) > 3 else 6

idx = collections.defaultdict(list)
for i in range(len(rom) - 3):
    idx[rom[i:i + 4]].append(i)

rows = set()
for p in range(0, len(snap), 4100):
    nt = snap[p + 4:p + 4100]
    blank = collections.Counter(nt[:0x3C0]).most_common(1)[0][0]
    for r in range(30):
        row = nt[r * 32:(r + 1) * 32]
        if sum(1 for b in row if b != blank) >= 4:
            rows.add(bytes(row))
print("righe distinte:", len(rows))

hits = collections.defaultdict(int)          # inizio in ROM -> lunghezza massima
for row in rows:
    for i in range(len(row) - 3):
        cands = idx.get(row[i:i + 4])
        if not cands or len(cands) > 300:
            continue
        for c in cands:
            n = 4
            while i + n < len(row) and c + n < len(rom) and rom[c + n] == row[i + n]:
                n += 1
            if n >= minlen:
                hits[c] = max(hits[c], n)

if len(sys.argv) > 4:
    with open(sys.argv[4], "w") as f:
        for off in sorted(hits):
            f.write("%d\t%d\n" % (off, hits[off]))

per_unit = collections.Counter()
for off, n in hits.items():
    per_unit[off // 8192] += 1
print("corrispondenze (>=%d byte) per banco 8K:" % minlen)
for u, n in sorted(per_unit.items()):
    lo = min(o for o in hits if o // 8192 == u)
    hi = max(o for o in hits if o // 8192 == u)
    print("  unit %2d: %4d  (0x%05X-0x%05X)" % (u, n, lo, hi))
