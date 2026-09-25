#!/usr/bin/env python3
"""Confronta due registri di istruzioni (NESRECOMP_BOUNDARY_LOG) e mostra la prima divergenza.

  python tools/seqdiff.py a.log b.log [--ctx 6]

Record da 8 byte: pc(2) A X Y S lo-ritorno hi-ritorno. Se lo stato (A,X,Y,S) diverge prima del pc, l'istruzione PRECEDENTE e' quella sbagliata.
"""
import sys


def main():
    a = open(sys.argv[1], "rb").read()
    b = open(sys.argv[2], "rb").read()
    ctx = int(sys.argv[sys.argv.index("--ctx") + 1]) if "--ctx" in sys.argv else 6
    n = min(len(a), len(b)) // 8
    i = 0
    # confronto veloce a blocchi
    step = 8 * 4096
    off = 0
    while off < min(len(a), len(b)) and a[off:off + step] == b[off:off + step]:
        off += step
    i = off // 8
    while i < n and a[i * 8:i * 8 + 8] == b[i * 8:i * 8 + 8]:
        i += 1
    print("record: A=%d B=%d, identici per i primi %d" % (len(a) // 8, len(b) // 8, i))
    if i >= n:
        print("nessuna divergenza nel tratto comune")
        return 0
    for k in range(max(0, i - ctx), min(n, i + 3)):
        ra, rb = a[k * 8:k * 8 + 8], b[k * 8:k * 8 + 8]
        fmt = lambda r: "pc=%04X A=%02X X=%02X Y=%02X S=%02X top=%02X%02X" % (r[0] | r[1] << 8, r[2], r[3], r[4], r[5], r[7], r[6])
        print("%s #%d  A: %s   B: %s" % (">>" if k == i else "  ", k, fmt(ra), fmt(rb)))
    return 1


if __name__ == "__main__":
    sys.exit(main())
