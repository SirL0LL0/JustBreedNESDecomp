#!/usr/bin/env python3
"""Fogli dei glifi di Just Breed, ingranditi e con etichette, per leggerli a occhio.

  python tools/glyph_sheet.py baserom_jp.nes OUTDIR
Scrive: kana_00-7f.png, kana_80-ff.png (banchi 60/61, 8x16, codice = ID tile) e kanji.png (banchi 62/63,
16x16 = tile 2n e 2n+1; l'etichetta e' l'ID della tile sinistra, cioe' il byte dopo 01 nel testo).
"""
import struct, sys, zlib, os

rom = open(sys.argv[1], "rb").read()
prg = rom[4] * 16384
chr_ = rom[16 + prg:16 + prg + rom[5] * 8192]
outdir = sys.argv[2]
os.makedirs(outdir, exist_ok=True)
S = 4

F = {c: g for c, g in zip("0123456789ABCDEF", [
    "01110100011000110001100011000101110", "00100011000010000100001000010001110", "01110100010000101110100001000011111",
    "11110000010000101110000010000111110", "00010001100101011111000100001000010", "11111100001111000001000011000101110",
    "01110100001000011110100011000101110", "11111000010001000100010000100001000", "01110100011000101110100011000101110",
    "01110100011000101111000010000101110", "01110100011000111111100011000110001", "11110100011000111110100011000111110",
    "01110100011000010000100001000101110", "11110100011000110001100011000111110", "11111100001000011110100001000011111",
    "11111100001000011110100001000010000"])}


def tile_px(bank, n):
    o = bank * 4096 + n * 16
    return [[(((chr_[o + y] >> (7 - x)) & 1) | (((chr_[o + y + 8] >> (7 - x)) & 1) << 1)) for x in range(8)] for y in range(8)]


def blit(img, x0, y0, px):
    for y, row in enumerate(px):
        for x, v in enumerate(row):
            img[y0 + y][x0 + x] = 255 if v == 0 else 0


def label(img, x0, y0, text):
    for ci, ch in enumerate(text):
        for k, c in enumerate(F[ch]):
            if c == "1":
                y, x = y0 + k // 5, x0 + ci * 6 + k % 5
                if 0 <= y < len(img) and 0 <= x < len(img[0]):
                    img[y][x] = 0


def png(pix, scale):
    pix = [[p for p in row for _ in range(scale)] for row in pix for _ in range(scale)]
    raw = b"".join(b"\x00" + bytes(r) for r in pix)
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", len(pix[0]), len(pix), 8, 0, 0, 0, 0)) + \
        chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def kana_sheet(lo, hi, name):
    cols, cw, ch, pad = 16, 12, 24, 14
    rows = (hi - lo + 1) // cols
    img = [[200] * (pad + cols * cw) for _ in range(pad + rows * ch)]
    for n in range(lo, hi + 1):
        r, c = (n - lo) // cols, n % cols
        x, y = pad + c * cw + 2, pad + r * ch + 2
        blit(img, x, y, tile_px(60, n)); blit(img, x, y + 8, tile_px(61, n))
    for c in range(cols):
        label(img, pad + c * cw + 4, 4, "0123456789ABCDEF"[c])
    for r in range(rows):
        label(img, 1, pad + r * ch + 8, "0123456789ABCDEF"[(lo >> 4) + r])
    open(os.path.join(outdir, name), "wb").write(png(img, S))


def kanji_sheet():
    cols, cw, ch, pad = 8, 20, 24, 14
    rows = 16
    img = [[200] * (pad + cols * cw) for _ in range(pad + rows * ch)]
    for k in range(128):
        r, c = k // cols, k % cols
        x, y = pad + c * cw + 2, pad + r * ch + 2
        for half in (0, 1):
            t = 2 * k + half
            blit(img, x + 8 * half, y, tile_px(62, t)); blit(img, x + 8 * half, y + 8, tile_px(63, t))
        label(img, x, y + 17, "%02X" % (2 * k))
    open(os.path.join(outdir, "kanji.png"), "wb").write(png(img, 3))


kana_sheet(0x00, 0x7F, "kana_00-7f.png")
kana_sheet(0x80, 0xFF, "kana_80-ff.png")
kanji_sheet()
print("fatto in", outdir)
