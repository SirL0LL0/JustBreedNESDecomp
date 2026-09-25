#!/usr/bin/env python3
"""Prova di andata e ritorno: ricodifica tutti i messaggi giapponesi con il nostro codificatore, scrive una ROM
modificata e li ridecodifica con la routine ORIGINALE del gioco (py65). Deve coincidere byte per byte.

  python tools/pack_test.py baserom_jp.nes text/dialog_jp.tsv [out.nes]
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import hufpack
from dialog_decode import Game

UNIT = 8192
rom_path, tsv = sys.argv[1], sys.argv[2]
out = sys.argv[3] if len(sys.argv) > 3 else None
data = bytearray(open(rom_path, "rb").read())
rows = [l.rstrip("\n").split("\t") for l in open(tsv, encoding="utf-8")][1:]
ids = [int(r[0], 16) for r in rows]
msgs = [bytes.fromhex(r[1]) for r in rows]

tree, blobs, codes = hufpack.encode_messages(msgs)
print("simboli:", len(codes), " albero: %d byte (max 512)" % len(tree))
assert len(tree) <= 512
pos, used = hufpack.layout(blobs)
print("blob: %d byte in %d messaggi (%.1f unita', originale: unita' 16-26)" % (used, len(blobs), used / UNIT))
assert max(len(b) for b in blobs) <= 256, "blob > 256 byte: %d" % max(len(b) for b in blobs)

PRG0 = 16
def wr(unit, off, b):
    data[PRG0 + unit * UNIT + off:PRG0 + unit * UNIT + off + len(b)] = b

wr(46, 0, tree + bytes(512 - len(tree)))
for i, mid in enumerate(ids):
    wr(46, 0x200 + mid, hufpack.pointer_entry(pos[i]))
for i, b in enumerate(blobs):
    lin = pos[i]
    u, off = 16 + lin // UNIT, lin % UNIT
    # scrittura lineare attraverso le unita' consecutive
    for k, byte in enumerate(b):
        p = lin + k
        data[PRG0 + (16 + p // UNIT) * UNIT + p % UNIT] = byte
if out:
    open(out, "wb").write(data)
    print("scritta", out)

open("C:/temp/_pack_rom.nes", "wb").write(data)
g = Game("C:/temp/_pack_rom.nes")
bad = 0
for mid, m in zip(ids, msgs):
    got = g.message(mid)
    if got != m:
        bad += 1
        if bad <= 5:
            print("DIVERSO %04X\n  atteso %s\n  ottenuto %s" % (mid, m.hex(), got.hex()))
print("messaggi verificati: %d, diversi: %d" % (len(ids), bad))
