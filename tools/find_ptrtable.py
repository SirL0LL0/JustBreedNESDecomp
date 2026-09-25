"""Cerca tabelle di puntatori (word LE) che puntano agli inizi delle stringhe di una regione.
   python find_ptrtable.py baserom_jp.nes UNIT START_OFF END_OFF BASE   (offset nell'unita', BASE = indirizzo CPU dell'unita')"""
import sys
rom = open(sys.argv[1], "rb").read()[16:]
unit, a, b, base = int(sys.argv[2]), int(sys.argv[3], 16), int(sys.argv[4], 16), int(sys.argv[5], 16)
seg = rom[unit * 8192 + a:unit * 8192 + b]
starts, p = [0], 0
for i, x in enumerate(seg):
    if x == 0 and i + 1 < len(seg):
        starts.append(i + 1)
addrs = [base + a + s for s in starts]
print("stringhe:", len(starts), "prime:", ["%04X" % x for x in addrs[:6]])
want = set(addrs)
# cerca in tutta la ROM parole LE che coincidono con gli indirizzi cercati, raggruppando per vicinanza
hits = {}
for off in range(0, len(rom) - 1):
    w = rom[off] | (rom[off + 1] << 8)
    if w in want:
        hits.setdefault(off // 8192, []).append((off % 8192, w))
for u, l in sorted(hits.items()):
    if len(l) >= 6:
        print("unit %d: %d parole coincidenti, es. offset %s" % (u, len(l), ["%04X" % o for o, _ in l[:8]]))
