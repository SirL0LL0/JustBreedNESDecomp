#!/usr/bin/env python3
"""Cerca stringhe di testo giapponese incorporate direttamente nel codice (non nel sistema Huffman dei 1994
dialoghi) rimaste NON tradotte nella nostra ROM: byte identici tra baserom_jp.nes e la nostra ROM, in un tratto
che sembra testo (lettere kana/kanji, comandi $n/#!/*./+/-/%, terminato da <05> o <00>).

  python tools/find_untranslated.py baserom_jp.nes build_rom/jb_it_preview.nes [unita...]

Senza unita': scansiona tutta la PRG. Righe gia' individuate (dialoghi Huffman uniti 16-26, tabelle nomi note)
si possono escludere passando le unita' da controllare esplicitamente.
"""
import os, sys, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import charmap_jp

PRG = 512 * 1024
UNIT = 8192


def bank_addr(off):
    unit = off // UNIT
    o = off % UNIT
    base = {0xE000: 0xE000}.get(None)
    # base per unita' pari/dispari secondo lo schema noto (8000/A000 alternati) salvo il banco fisso
    if unit >= 62:
        base = 0xC000 if unit == 62 else 0xE000
    else:
        base = 0x8000 if unit % 2 == 0 else 0xA000
    return unit, base + o


def looks_like_text(b):
    """1 byte 'di testo': token noto, kana/kanji (charmap_jp lo riconosce), spazio, punteggiatura, fine riga."""
    if b in (0x00, 0x05):
        return True
    if b == 0x24 or b in (0x23, 0x2A, 0x2B, 0x2D, 0x25, 0x21, 0x2E, 0x2C):
        return True
    if 0x20 <= b <= 0x3F:
        return True
    if b == 0x01:  # prefisso kanji (2 byte)
        return True
    try:
        ch = charmap_jp.decode_line(bytes([b]))
        return len(ch) == 1 and ch != "?"
    except Exception:
        return False


def main():
    jp_path, it_path = sys.argv[1], sys.argv[2]
    units = [int(u) for u in sys.argv[3:]] if len(sys.argv) > 3 else None
    jp = open(jp_path, "rb").read()[16:16 + PRG]
    it = open(it_path, "rb").read()[16:16 + PRG]

    found = []
    off = 0
    while off < PRG:
        if units is not None and off // UNIT not in units:
            off += UNIT - (off % UNIT)
            continue
        b = jp[off]
        if b in (0x24,) and looks_like_text(b):
            # possibile inizio stringa: raccoglie finche' resta "testo" e finisce con 00 (dopo un 05, o subito)
            j = off
            n = 0
            last_nl = -1
            while j < PRG and n < 400 and looks_like_text(jp[j]):
                if jp[j] == 0x01:
                    j += 2; n += 2; continue
                if jp[j] == 0x05:
                    last_nl = j
                if jp[j] == 0x00 and j > off + 3:
                    break
                j += 1; n += 1
            if j < PRG and jp[j] == 0x00 and (j - off) >= 6:
                raw = jp[off:j + 1]
                same = it[off:j + 1] == raw
                if same:
                    unit, addr = bank_addr(off)
                    try:
                        txt = charmap_jp.decode_line(raw)
                    except Exception:
                        txt = "(errore decodifica)"
                    found.append((unit, addr, off, raw, txt))
                off = j + 1
                continue
        off += 1

    print("%d candidati non tradotti" % len(found))
    for unit, addr, off, raw, txt in found:
        print("unit %2d  $%04X  off=0x%06X  %s" % (unit, addr, off, raw.hex(" ")))
        print("           %s" % txt)


if __name__ == "__main__":
    main()
