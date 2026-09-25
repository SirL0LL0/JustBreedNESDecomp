#!/usr/bin/env python3
"""Crea una patch IPS (originale -> modificata), per distribuire la traduzione senza la ROM.

  python tools/ips.py baserom_jp.nes build_rom/jb_it_preview.nes just_breed_ita.ips

Le due ROM devono avere la stessa dimensione (la traduzione non espande la ROM). Applicabile con qualsiasi patcher IPS
(Lunar IPS, Floating IPS, ...) alla ROM giapponese originale, per giocare su hardware reale (cartuccia flash MMC5).
"""
import sys


def make_ips(a, b):
    assert len(a) == len(b), "le ROM devono avere la stessa dimensione"
    out = bytearray(b"PATCH")
    i, n = 0, len(a)
    while i < n:
        if a[i] == b[i]:
            i += 1
            continue
        j = i
        while j < n and (a[j] != b[j] or (j + 1 < n and a[j + 1] != b[j + 1] and j - i < 0xFFFF)):
            j += 1
            if j - i >= 0xFFFF:
                break
        start = i
        if start == 0x454F46:                      # evita che l'offset sembri "EOF": si parte un byte prima
            start -= 1
        chunk = b[start:j]
        out += start.to_bytes(3, "big") + len(chunk).to_bytes(2, "big") + chunk
        i = j
    out += b"EOF"
    return bytes(out)


def apply_ips(rom, patch):
    rom = bytearray(rom)
    assert patch[:5] == b"PATCH"
    p = 5
    while patch[p:p + 3] != b"EOF":
        off = int.from_bytes(patch[p:p + 3], "big"); size = int.from_bytes(patch[p + 3:p + 5], "big"); p += 5
        if size == 0:
            run = int.from_bytes(patch[p:p + 2], "big"); val = patch[p + 2]; p += 3
            rom[off:off + run] = bytes([val]) * run
        else:
            rom[off:off + size] = patch[p:p + size]; p += size
    return bytes(rom)


if __name__ == "__main__":
    a, b = open(sys.argv[1], "rb").read(), open(sys.argv[2], "rb").read()
    ips = make_ips(a, b)
    assert apply_ips(a, ips) == b, "verifica IPS fallita"
    open(sys.argv[3], "wb").write(ips)
    print("patch IPS: %d byte, verificata" % len(ips))
