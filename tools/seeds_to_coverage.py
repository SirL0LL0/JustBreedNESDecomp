#!/usr/bin/env python3
"""Converte cycle_seeds.txt (righe `4k:BB:AAAA`, banco PRG da 4KB + indirizzo CPU, dal backend a cicli, sempre
esatto sul banco perche' scritto dal mapper vero a runtime) nel formato di copertura del vecchio disassemblatore
(1 byte per byte di PRG; bit0 = inizio di istruzione). A differenza della vecchia copertura CDL/Mesen, qui non
c'e' ambiguita' possibile sul banco: ogni riga e' gia' l'offset esatto nella PRG.

  python tools/seeds_to_coverage.py cycle_seeds.txt cycle_seeds_played.txt ... -o analysis/all.bin

Unisce con la copertura esistente al percorso -o, se presente (OR bit a bit), non la sovrascrive da zero.
"""
import argparse, os, re

PRG_SIZE = 512 * 1024


def load_seeds(path):
    out = set()
    if not os.path.exists(path):
        print("(manca, salto) %s" % path)
        return out
    for line in open(path, encoding="utf-8", errors="replace"):
        m = re.match(r"4k:([0-9A-Fa-f]+):([0-9A-Fa-f]+)", line)
        if not m:
            continue
        bank4k = int(m.group(1), 16)
        addr = int(m.group(2), 16)
        off = bank4k * 4096 + (addr & 0xFFF)
        if 0 <= off < PRG_SIZE:
            out.add(off)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("seeds", nargs="+")
    ap.add_argument("-o", "--out", required=True)
    args = ap.parse_args()

    cov = bytearray(PRG_SIZE)
    if os.path.exists(args.out):
        old = open(args.out, "rb").read()
        cov[:len(old)] = old
        print("copertura esistente: %d byte di codice" % sum(1 for b in cov if b & 1))

    new = 0
    for p in args.seeds:
        offs = load_seeds(p)
        added = sum(1 for o in offs if not cov[o] & 1)
        for o in offs:
            cov[o] |= 1
        new += added
        print("%-40s semi %6d, nuovi byte di codice %6d" % (os.path.basename(p), len(offs), added))

    open(args.out, "wb").write(cov)
    total = sum(1 for b in cov if b & 1)
    print("scritto %s: %d/%d byte di codice (%.1f%%), %d nuovi in questa esecuzione" %
          (args.out, total, PRG_SIZE, 100.0 * total / PRG_SIZE, new))


if __name__ == "__main__":
    main()
