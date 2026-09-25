#!/usr/bin/env python3
"""Rigenera TUTTO il codice derivato dalla ROM e compila il gioco, con un solo comando.

  python tools/regen.py [--rom baserom_jp.nes] [--cov analysis/all.bin] [--build build_x] [--no-build]

Passi (ognuno usa i file sorgente del repository, niente e' scritto a mano in generated/):
  1. tools/disasm.py       -> disasm/unitNN.asm  (+ tools/asm_verify.py: il sorgente si riassembla identico alla ROM)
  2. tools/mmc5_blocks.py  -> generated/blocks   (blocchi base tradotti in C)
  3. tools/decompile.py    -> generated/decomp   (funzioni C eseguibili) e generated/decomp_r (sorgente leggibile)
  4. cmake + ninja         -> build/JustBreedRecomp.exe

I file generati derivano dalla ROM: non vanno pubblicati (sono in .gitignore). Cosi' chiunque abbia la propria ROM
ricostruisce il gioco da questo repository.
"""
import argparse, os, subprocess, sys, time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def run(title, cmd, cwd=ROOT):
    t = time.time()
    print("== %s" % title, flush=True)
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    out = (r.stdout + r.stderr).strip().splitlines()
    for l in out[-6:]:
        print("   " + l)
    if r.returncode not in (0,):
        print("   ERRORE (codice %d)" % r.returncode)
        sys.exit(r.returncode)
    print("   ok (%.0fs)" % (time.time() - t), flush=True)
    return r


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", default="baserom_jp.nes")
    ap.add_argument("--cov", default="analysis/all.bin")
    ap.add_argument("--build", default="build_x")
    ap.add_argument("--no-build", action="store_true")
    ap.add_argument("--no-readable", action="store_true")
    a = ap.parse_args()
    py = sys.executable
    run("disassemblaggio", [py, "tools/disasm.py", a.rom, "disasm", a.cov])
    run("verifica riassemblaggio (ROM identica)", [py, "tools/asm_verify.py", a.rom, "disasm"])
    run("blocchi tradotti", [py, "tools/mmc5_blocks.py", a.rom, "generated/blocks", a.cov])
    run("decompilazione (eseguibile)", [py, "tools/decompile.py", a.rom, "generated/decomp", a.cov])
    if not a.no_readable:
        run("decompilazione (leggibile)", [py, "tools/decompile.py", a.rom, "generated/decomp_r", a.cov, "--readable", "--closed"])
    if not a.no_build:
        if not os.path.exists(os.path.join(ROOT, a.build, "build.ninja")):
            run("cmake (configurazione)", ["cmake", "-S", ".", "-B", a.build, "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release",
                                            "-DJB_INTERP_ONLY=ON"])
        run("compilazione", ["cmake", "--build", a.build])
        print("\nFatto: %s/JustBreedRecomp.exe <rom>" % a.build)


if __name__ == "__main__":
    main()
