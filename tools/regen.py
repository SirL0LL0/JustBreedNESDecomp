#!/usr/bin/env python3
"""Rigenera tutto il codice derivato dalla ROM (backend MMC5 di nesrecomp) e, se richiesto, compila.

  python tools/regen.py [--rom baserom_jp.nes] [--build build_x] [--no-build]
"""
import argparse, os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ap = argparse.ArgumentParser()
ap.add_argument("--rom", default="baserom_jp.nes")
ap.add_argument("--build", default="build_x")
ap.add_argument("--no-build", action="store_true")
a = ap.parse_args()
os.chdir(ROOT)
r = subprocess.run([sys.executable, os.path.join("nesrecomp", "tools", "mmc5", "mmc5_regen.py"), "--rom", a.rom, "--out", "generated/mmc5"])
if r.returncode or a.no_build:
    sys.exit(r.returncode)
if not os.path.exists(os.path.join(a.build, "build.ninja")):
    subprocess.run(["cmake", "-S", ".", "-B", a.build, "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release"], check=True)
sys.exit(subprocess.run(["cmake", "--build", a.build]).returncode)
