#!/usr/bin/env python3
"""Recall dell'estrattore: quante corrispondenze 'viste a schermo' (hits.tsv di text_locate) cadono in un blocco estratto."""
import csv, sys

hits = [tuple(map(int, l.split())) for l in open(sys.argv[1])]
blocks = []
for r in list(csv.reader(open(sys.argv[2], encoding="utf-8"), delimiter="\t"))[1:]:
    off = int(r[0], 16)
    blocks.append(off)
# ogni blocco: da off a off + lunghezza; il tsv non ha la lunghezza, quindi la ricostruiamo dal testo (>= n righe)
covered = 0
missed = []
import bisect
starts = sorted(blocks)
for off, n in hits:
    i = bisect.bisect_right(starts, off) - 1
    if i >= 0 and off - starts[i] < 4000:      # blocco che inizia poco prima
        covered += 1
    else:
        missed.append(off)
print("hit a schermo: %d, coperti da un blocco: %d (%.0f%%)" % (len(hits), covered, 100 * covered / max(1, len(hits))))
print("non coperti (primi 25):", ["%05X" % m for m in missed[:25]])
