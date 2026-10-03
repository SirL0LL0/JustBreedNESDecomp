#!/usr/bin/env python3
"""
classify_banks.py â€” classificazione statistica delle banche dati.

Usage:
    py tools/classify_banks.py <rom.nes>

Per ogni banco PRG calcola:
  - filler: frazione di $00 e $FF
  - ASCII: frazione di byte stampabili (testo)
  - PTR: frazione di coppie LE nel range $8000-$FFFF (tabelle puntatori)
  - RLE: frazione di byte uguali al precedente (dati ripetitivi/compressi)
  - ENT: entropia di Shannon (banchi "random" = packed/CHR)
  - top-4 byte piu' frequenti
E propone una classificazione. Salva banks_report.txt.
"""
import sys, os, math, collections, pathlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from auto_disasm import load_prg

def analyze(bank):
    n = len(bank)
    c = collections.Counter(bank)
    zeros = c[0] / n
    ffs = c[0xFF] / n
    ascii_frac = sum(v for k, v in c.items() if 32 <= k < 127) / n
    ptr = 0
    for i in range(0, n - 1, 2):
        w = bank[i] | (bank[i + 1] << 8)
        if 0x8000 <= w <= 0xFFFF:
            ptr += 1
    ptr /= (n / 2)
    rep = sum(1 for i in range(1, n) if bank[i] == bank[i - 1]) / n
    ent = 0.0
    for v in c.values():
        p = v / n
        ent -= p * math.log2(p)
    top = ", ".join(f"${k:02X}x{v}" for k, v in c.most_common(4))
    return zeros, ffs, ascii_frac, ptr, rep, ent, top

def classify(zeros, ffs, ascii_frac, ptr, rep, ent):
    if zeros + ffs > 0.90:
        return "FILLER (padding)"
    if ascii_frac > 0.50:
        return "TESTO (charset/dialoghi)"
    if ptr > 0.30 and rep < 0.4:
        return "TABELLE/PUNTATORI"
    if rep > 0.55:
        return "RLE/RIPETITIVO (tilemap/compresso)"
    if ent > 7.3:
        return "ALTA ENTROPIA (packed/CHR/cripto?)"
    return "DATI STRUTTURATI (tabelle/mappa)"

def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    banks = load_prg(sys.argv[1])
    out = ["; ==== banks_report â€” classificazione banche PRG ====",
           "; bank  %00    %FF   ASCII  PTR    RLE   ENT   TOP BYTES            CLASSIFICAZIONE"]
    for i, b in enumerate(banks):
        zeros, ffs, asc, ptr, rep, ent, top = analyze(b)
        cls = classify(zeros, ffs, asc, ptr, rep, ent)
        out.append(f";  ${i:02X}  {zeros:5.1%} {ffs:5.1%} {asc:6.1%} {ptr:5.1%} {rep:5.1%} {ent:5.2f}  {top:24s} {cls}")
    report = "\n".join(out)
    print(report)
    pathlib.Path("docs/banks_report.txt").write_text(report + "\n", encoding="utf-8")
    print("\nSalvato -> docs/banks_report.txt")

if __name__ == "__main__":
    main()
