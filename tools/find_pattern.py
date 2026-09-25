"""Cerca nel disassemblato (OUTDIR/unitNN.asm) sequenze di istruzioni: python find_pattern.py OUTDIR "asl a" "asl a" "asl a" [ctx]"""
import glob, os, re, sys

outdir = sys.argv[1]
pat = [p.lower() for p in sys.argv[2:5]]
ctx = int(sys.argv[5]) if len(sys.argv) > 5 else 6
for f in sorted(glob.glob(os.path.join(outdir, "unit*.asm"))):
    lines = open(f, encoding="utf-8").read().split("\n")
    ins = [(i, re.sub(r"\s+", " ", l.split(";")[0]).strip().lower()) for i, l in enumerate(lines) if l.startswith("    ") and not l.strip().startswith(".byte")]
    for k in range(len(ins) - len(pat)):
        if all(ins[k + j][1] == pat[j] for j in range(len(pat))):
            a = ins[k][0]
            print("=== %s:%d" % (os.path.basename(f), a))
            for l in lines[max(0, a - ctx):a + ctx + 4]:
                print("  " + re.sub(r"\s{2,}", " ", l))
