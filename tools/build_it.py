#!/usr/bin/env python3
"""Costruisce la ROM di prova in italiano a partire dalla ROM giapponese.

  python tools/build_it.py baserom_jp.nes text/it_wrapped.tsv out.nes

* sostituisce albero, tabella puntatori e blob dei dialoghi (banchi 46 e 16-26) con quelli italiani;
  i messaggi non ancora tradotti diventano un segnaposto "Msg NNNN" per non mescolare l'alfabeto giapponese;
* ridisegna nel CHR (banchi 60/61) i glifi latini dal font Unscii (pubblico dominio, assets/unscii-16.hex).
Poi verifica che la routine originale del gioco (py65) decodifichi tutti i messaggi come atteso.
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import hufpack, charmap_it
from dialog_decode import Game

UNIT = 8192
here = os.path.dirname(os.path.abspath(__file__))


def load_unscii():
    d = {}
    for l in open(os.path.join(here, "..", "assets", "unscii-16.hex")):
        if ":" in l:
            a, b = l.strip().split(":")
            if len(b) == 32:
                d[int(a, 16)] = bytes.fromhex(b)
    return d


def patch_font(data, prg_size):
    uns = load_unscii()
    chr0 = 16 + prg_size
    n = 0
    for tile_id, ch in charmap_it.DRAW.items():
        g = uns.get(ord(ch))
        if g is None:
            raise ValueError("Unscii non ha il glifo %r" % ch)
        for half, bank in ((0, 60), (1, 61)):
            rows = g[half * 8:half * 8 + 8]
            o = chr0 + bank * 4096 + tile_id * 16
            for y, byte in enumerate(rows):
                data[o + y] = byte           # piano 0
                data[o + 8 + y] = byte       # piano 1 -> colore 3
        n += 1
    return n


# Tabelle di nomi a record fissi: nome -> (offset PRG, larghezza record in byte, numero record)
# Il record e' 'testo + spazi' fino a larghezza-1 colonne, poi 00 (kanji = 2 colonne, come nell'originale).
TABLES = {"items": (0x4C000, 8, 154), "spells": (0x4C4D0, 8, 74), "places": (0x4D2B4, 10, 29), "chars": (0x72000, 6, 37)}


def patch_tables(data, tsv_path):
    n = 0
    for l in open(tsv_path, encoding="utf-8"):
        p = l.rstrip("\n").split("\t")
        if len(p) < 3 or p[0] == "table":
            continue
        tab, idx, text = p[0], int(p[1]), p[2]
        base, width, count = TABLES[tab]
        if not 0 <= idx < count:
            raise ValueError("%s: id %d fuori tabella" % (tab, idx))
        raw = charmap_it.encode_text(text)
        if len(raw) > width - 1:
            raise ValueError("%s[%d] %r: %d colonne (max %d)" % (tab, idx, text, len(raw), width - 1))
        rec = raw + b"\x20" * (width - 1 - len(raw)) + b"\x00"
        off = 16 + base + idx * width
        data[off:off + width] = rec
        n += 1
    return n


def main():
    rom_path, tsv, out = sys.argv[1], sys.argv[2], sys.argv[3]
    data = bytearray(open(rom_path, "rb").read())
    prg_size = data[4] * 16384
    jp = [l.rstrip("\n").split("\t") for l in open(os.path.join(here, "..", "text", "dialog_jp.tsv"), encoding="utf-8")][1:]
    ids = [int(r[0], 16) for r in jp]
    it = {}
    for l in open(tsv, encoding="utf-8"):
        p = l.rstrip("\n").split("\t")
        if len(p) >= 2 and p[0] != "id":
            it[int(p[0], 16)] = p[1]
    msgs, done = [], 0
    for mid in ids:
        if mid in it:
            msgs.append(charmap_it.encode_text(it[mid])); done += 1
        else:
            msgs.append(charmap_it.encode_text("“Msg %04X”<05>" % mid))
    print("messaggi: %d (tradotti %d)" % (len(ids), done))

    tree, blobs, codes = hufpack.encode_messages(msgs)
    assert len(tree) <= 512, "albero troppo grande: %d" % len(tree)
    pos, used = hufpack.layout(blobs)
    print("albero %d byte, %d simboli; blob %d byte (%.1f unita', max 11.0)" % (len(tree), len(codes), used, used / UNIT))
    assert used <= 11 * UNIT, "blob non entrano nelle unita' 16-26"
    assert max(len(b) for b in blobs) <= 256, "blob > 256 byte: id %04X (%d)" % (
        ids[max(range(len(blobs)), key=lambda i: len(blobs[i]))], max(len(b) for b in blobs))

    def wr(unit, off, b):
        data[16 + unit * UNIT + off:16 + unit * UNIT + off + len(b)] = b

    wr(46, 0, tree + bytes(512 - len(tree)))
    for i, mid in enumerate(ids):
        wr(46, 0x200 + mid, hufpack.pointer_entry(pos[i]))
    for i, b in enumerate(blobs):
        for k, byte in enumerate(b):
            p = pos[i] + k
            data[16 + (16 + p // UNIT) * UNIT + p % UNIT] = byte
    print("glifi latini ridisegnati:", patch_font(data, prg_size))
    up = os.path.join(here, "..", "text", "ui_it.tsv")
    if os.path.exists(up):
        import ui_patch
        n, nb = ui_patch.apply_ui(data, up)
        print("stringhe di interfaccia tradotte: %d (%d byte in unita' 47)" % (n, nb))
    tp = os.path.join(here, "..", "text", "tables_it.tsv")
    if os.path.exists(tp):
        print("voci di tabella tradotte:", patch_tables(data, tp))
    open(out, "wb").write(data)
    print("scritta", out)

    g = Game(out)
    bad = 0
    for mid, m in zip(ids, msgs):
        got = g.message(mid)
        if got != m:
            bad += 1
            if bad <= 3:
                print("  diverso %04X: atteso %s ottenuto %s" % (mid, m.hex(), got.hex()))
    print("verifica decodifica con la routine del gioco: %d messaggi, diversi: %d" % (len(ids), bad))


if __name__ == "__main__":
    main()
