#!/usr/bin/env python3
"""
extract_rom.py â€” split a Just Breed .nes ROM into PRG/CHR banks.

Usage:  python3 tools/extract_rom.py <input.nes> <outdir>

Validates the iNES header (mapper 5, 512 KB PRG, 256 KB CHR) and writes:
    <outdir>/prg_bank_XX.bin   16 KB each (32 banks)
    <outdir>/chr_bank_XX.bin    8 KB each (32 banks)
    <outdir>/header.bin         16-byte iNES header
"""
import sys, pathlib

EXPECTED = {"prg_banks": 32, "chr_banks": 32, "mapper": 5}  # MMC5

def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    rom = pathlib.Path(sys.argv[1])
    out = pathlib.Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)

    data = rom.read_bytes()
    if data[:4] != b"NES\x1a":
        sys.exit("ERROR: not an iNES file")

    prg_n, chr_n = data[4], data[5]
    mapper = (data[6] >> 4) | (data[7] & 0xF0)
    print(f"Header: PRG={prg_n}x16KB  CHR={chr_n}x8KB  mapper={mapper}")

    if prg_n != EXPECTED["prg_banks"] or chr_n != EXPECTED["chr_banks"]:
        sys.exit(f"ERROR: unexpected sizes (expected {EXPECTED})")
    if mapper != EXPECTED["mapper"]:
        sys.exit(f"ERROR: expected mapper 5 (MMC5), got {mapper}")

    (out / "header.bin").write_bytes(data[:16])
    off = 16
    for i in range(prg_n):
        (out / f"prg_bank_{i:02d}.bin").write_bytes(data[off:off+16384]); off += 16384
    for i in range(chr_n):
        (out / f"chr_bank_{i:02d}.bin").write_bytes(data[off:off+8192]); off += 8192

    print(f"OK: wrote {prg_n} PRG banks + {chr_n} CHR banks to {out}")
    print(f"ROM size: {len(data)} bytes (6 Mbit cartridge)")

if __name__ == "__main__":
    main()
