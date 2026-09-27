#!/usr/bin/env python3
"""verify_rom.py â€” confirm a rebuilt ROM is byte-identical to the original."""
import sys, filecmp
if len(sys.argv) != 3: sys.exit("usage: verify_rom.py <original.nes> <rebuilt.nes>")
same = filecmp.cmp(sys.argv[1], sys.argv[2], shallow=False)
print("MATCH: byte-identical OK" if same else "MISMATCH: ROMs differ")
sys.exit(0 if same else 1)
