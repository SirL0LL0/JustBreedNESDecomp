#!/usr/bin/env python3
"""Rende il font di Just Breed dal CHR in un PNG (nessuna dipendenza esterna).

  python tools/font_sheet.py baserom_jp.nes out.png TOP_BANK BOTTOM_BANK
Ogni carattere kana e' 8x16: meta' alta = tile N del banco 4KB TOP_BANK, meta' bassa = tile N del banco BOTTOM_BANK
(nel gioco: ExRAM 0x3C / 0x3D = banchi 60 / 61). La tabella e' 16x16 caratteri, codice = riga*16+colonna,
con una griglia di etichette esadecimali nei bordi.
"""
import struct, sys, zlib

rom = open(sys.argv[1], "rb").read()
prg = rom[4] * 16384
chr_ = rom[16 + prg:16 + prg + rom[5] * 8192]
out, top, bot = sys.argv[2], int(sys.argv[3]), int(sys.argv[4])

FONT5x7 = {c: g for c, g in zip("0123456789ABCDEF", [
    "01110100011000110001100011000101110", "00100011000010000100001000010001110", "01110100010000101110100001000011111",
    "11110000010000101110000010000111110", "00010001100101011111000100001000010", "11111100001111000001000011000101110",
    "01110100001000011110100011000101110", "11111000010001000100010000100001000", "01110100011000101110100011000101110",
    "01110100011000101111000010000101110", "01110100011000111111100011000110001", "11110100011000111110100011000111110",
    "01110100011000010000100001000101110", "11110100011000110001100011000111110", "11111100001000011110100001000011111",
    "11111100001000011110100001000010000"])}


def tile(bank, n):
    o = bank * 4096 + n * 16
    rows = []
    for y in range(8):
        lo, hi = chr_[o + y], chr_[o + y + 8]
        rows.append([((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1) for x in range(8)])
    return rows


CELL_W, CELL_H, PAD = 10, 18, 16
W, H = PAD + 16 * CELL_W, PAD + 16 * CELL_H
img = [[0] * W for _ in range(H)]
PAL = [255, 40, 150, 90]      # sfondo chiaro, glifo scuro
for n in range(256):
    cx, cy = PAD + (n % 16) * CELL_W, PAD + (n // 16) * CELL_H
    t, b = tile(top, n), tile(bot, n)
    for y in range(8):
        for x in range(8):
            img[cy + y][cx + x] = PAL[t[y][x]]
            img[cy + 8 + y][cx + x] = PAL[b[y][x]]
for i in range(16):        # etichette (una cifra hex ciascuna)
    for (bx, by, ch) in ((PAD + i * CELL_W + 1, 4, "0123456789ABCDEF"[i]), (4, PAD + i * CELL_H + 6, "0123456789ABCDEF"[i])):
        g = FONT5x7[ch]
        for k, c in enumerate(g):
            if c == "1":
                y, x = by + k // 5, bx + k % 5
                if 0 <= y < H and 0 <= x < W:
                    img[y][x] = 0


def png(pix):
    raw = b"".join(b"\x00" + bytes(r) for r in pix)
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", len(pix[0]), len(pix), 8, 0, 0, 0, 0)) + \
        chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


# ingrandisce 3x per leggibilita'
S = 3
big = [[p for p in row for _ in range(S)] for row in img for _ in range(S)]
open(out, "wb").write(png(big))
print("scritto", out, len(big[0]), "x", len(big))
