#!/usr/bin/env python3
"""Patch delle stringhe inline dell'interfaccia (banco 58): le stringhe italiane vanno nell'unita' 47 (libera) e ogni
chiamata  JSR $97CF + stringa + 00  viene sostituita da  JSR PrintFar + idx + skip.

PrintFar (nel banco fisso 63, area libera $FEAF): legge idx/skip inline, mappa l'unita' 47 a $A000, stampa la stringa
con la routine originale $97EA, ripristina il banco di $A000 e ritorna oltre i byte inline + skip.
Le stringhe sono in unita' 47 a partire da offset 0x100; la tabella (2 byte per idx, indirizzo CPU) a offset 0.
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import charmap_it

UNIT = 8192
STUB_UNIT, STUB_OFF = 63, 0x1EAF
STUB_ADDR = 0xE000 + STUB_OFF
STR_UNIT, STR_BANK, STR_BASE, STR_START = 47, 0xAF, 0xA000, 0x100

STUB = bytes([
    0x68, 0x85, 0xBE, 0x68, 0x85, 0xBF,          # PLA STA $BE PLA STA $BF   (ritorno = ultimo byte del JSR)
    0xA0, 0x01, 0xB1, 0xBE, 0x0A, 0xAA,          # LDY #1 LDA ($BE),Y ASL TAX  (X = idx*2)
    0xA0, 0x02, 0xB1, 0xBE, 0x18, 0x69, 0x02,    # LDY #2 LDA ($BE),Y CLC ADC #2   (skip + 2)
    0x18, 0x65, 0xBE, 0x85, 0xBE, 0x90, 0x02, 0xE6, 0xBF,   # CLC ADC $BE STA $BE BCC +2 INC $BF
    0xA5, 0xBF, 0x48, 0xA5, 0xBE, 0x48,          # push nuovo ritorno (hi, lo)
    0xA5, 0xBD, 0x48,                            # LDA $BD PHA  (salva banco di $A000)
    0xA9, STR_BANK, 0x85, 0xBD, 0x8D, 0x15, 0x51,   # LDA #bank STA $BD STA $5115
    0xBD, 0x00, 0xA0, 0x85, 0xBE, 0xBD, 0x01, 0xA0, 0x85, 0xBF,   # ($BE) = tabella[idx]
    0x20, 0xEA, 0x97,                            # JSR $97EA (stampa)
    0x68, 0x85, 0xBD, 0x8D, 0x15, 0x51,          # PLA STA $BD STA $5115 (ripristina)
    0x60,                                        # RTS
])


def inline_extent(prg, off):
    """(fine_esclusa, terminatore) della stringa inline che inizia a off (regola identica a inline_strings.py)."""
    q = off
    while q < len(prg) and prg[q] != 0 and q - off < 80:
        q += 2 if prg[q] in (0x01, 0x02, 0x03, 0x04) else 1
    return q


def param_seq(raw):
    out, i = [], 0
    while i < len(raw):
        if raw[i] in (0x02, 0x03, 0x04):
            out.append((raw[i], raw[i + 1])); i += 2
        elif raw[i] == 0x01:
            i += 2
        else:
            i += 1
    return out


def apply_ui(data, ui_tsv):
    """data: ROM completa con header (bytearray). Ritorna (n_stringhe, byte_usati)."""
    prg0 = 16
    def unit_slice(u, a, b):
        return prg0 + u * UNIT + a, prg0 + u * UNIT + b

    a, b = unit_slice(STUB_UNIT, STUB_OFF, STUB_OFF + len(STUB))
    assert all(x in (0, 0xFF) for x in data[a:b]), "area libera del banco 63 occupata"
    data[a:b] = STUB

    strings, entries = bytearray(), []
    rows = []
    for l in open(ui_tsv, encoding="utf-8"):
        p = l.rstrip("\n").split("\t")
        if len(p) >= 2 and p[0] != "offset":
            rows.append((int(p[0], 16), p[1]))
    for off, text in rows:
        pos = prg0 + off
        assert data[pos - 3:pos] == bytes([0x20, 0xCF, 0x97]), "%05X: non c'e' JSR $97CF" % off
        end = inline_extent(data, pos)
        jp = bytes(data[pos:end])
        total = 3 + len(jp) + 1
        new = charmap_it.encode_text(text)
        if param_seq(new) != param_seq(jp):
            raise ValueError("%05X: parametri {cc:pp} diversi da quelli originali %s" % (off, param_seq(jp)))
        idx = len(entries)
        entries.append(STR_START + len(strings))
        strings += new + b"\x00"
        skip = total - 5
        assert skip >= 0
        data[pos - 3:pos - 3 + total] = bytes([0x20, STUB_ADDR & 0xFF, STUB_ADDR >> 8, idx, skip]) + bytes([0xEA]) * skip
    assert STR_START + len(strings) <= UNIT, "stringhe troppo grandi per l'unita' 47"
    t0, _ = unit_slice(STR_UNIT, 0, 0)
    for i, o in enumerate(entries):
        v = STR_BASE + o
        data[t0 + 2 * i:t0 + 2 * i + 2] = bytes([v & 0xFF, v >> 8])
    data[t0 + STR_START:t0 + STR_START + len(strings)] = strings
    return len(rows), len(strings)
