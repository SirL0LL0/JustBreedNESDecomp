#!/usr/bin/env python3
"""
verify_skeleton.py â€” byte-perfect validation of the auto-generated skeleton.

Usage:
    py tools/verify_skeleton.py <rom.nes> <skeleton_dir>

Per ogni banco: rilegge bank_XX.s, ri-assembla le istruzioni (tabelle
inverse di auto_disasm), ricompone i 16384 byte e li confronta con il
banco originale della ROM. Report: PERFECT o lista di mismatch.

Nota: le JSR/JMP cross-bank verso label non definite nel file usano
l'indirizzo incorporato nel nome della label (L_A757 -> $A757), quindi
ricostruiscono comunque i byte corretti.
"""
import sys, os, re, pathlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from auto_disasm import OPS, load_prg, cpu_addr

# inverse table: (mnemonic, mode) -> opcode
ENC = {}
for op, (mn, md) in OPS.items():
    ENC.setdefault((mn, md), op)

LABEL_RE = re.compile(r"^(L_[0-9A-F]{4}|sub_[0-9A-F]{4}):$")

def layout_of(idx):
    return "fixed" if idx == 0x1F else "window"

def assemble_line(mn, operand, pc_addr):
    """Ri-assembla una riga di istruzione -> bytes o None."""
    if operand == "":
        if (mn, "acc") in ENC:
            return bytes([ENC[(mn, "acc")]])
        return bytes([ENC[(mn, "imp")]])
    if operand.startswith("#$"):
        return bytes([ENC[(mn, "imm")], int(operand[2:], 16)])
    if re.match(r"^\(\$[0-9A-F]{2},X\)$", operand):
        return bytes([ENC[(mn, "izx")], int(operand[3:5], 16)])
    if re.match(r"^\(\$[0-9A-F]{2}\),Y$", operand):
        return bytes([ENC[(mn, "izy")], int(operand[2:4], 16)])
    if re.match(r"^\(\$[0-9A-F]{4}\)$", operand):
        w = int(operand[2:6], 16)
        return bytes([ENC[(mn, "ind")], w & 0xFF, (w >> 8) & 0xFF])
    if re.match(r"^\$[0-9A-F]{2}$", operand):
        return bytes([ENC[(mn, "zp")], int(operand[1:], 16)])
    if re.match(r"^\$[0-9A-F]{2},X$", operand):
        return bytes([ENC[(mn, "zpx")], int(operand[1:3], 16)])
    if re.match(r"^\$[0-9A-F]{2},Y$", operand):
        return bytes([ENC[(mn, "zpy")], int(operand[1:3], 16)])
    if re.match(r"^\$[0-9A-F]{4},X$", operand):
        w = int(operand[1:5], 16)
        return bytes([ENC[(mn, "abx")], w & 0xFF, (w >> 8) & 0xFF])
    if re.match(r"^\$[0-9A-F]{4},Y$", operand):
        w = int(operand[1:5], 16)
        return bytes([ENC[(mn, "aby")], w & 0xFF, (w >> 8) & 0xFF])
    if re.match(r"^\$[0-9A-F]{4}$", operand):
        w = int(operand[1:], 16)
        return bytes([ENC[(mn, "abs")], w & 0xFF, (w >> 8) & 0xFF])
    if operand.startswith("sub_"):
        w = int(operand[4:], 16) & 0xFFFF
        return bytes([ENC[(mn, "abs")], w & 0xFF, (w >> 8) & 0xFF])
    if operand.startswith("L_"):
        w = int(operand[2:], 16) & 0xFFFF
        if mn in ("BPL", "BMI", "BVC", "BVS", "BCC", "BCS", "BNE", "BEQ"):
            rel = (w - ((pc_addr + 2) & 0xFFFF)) & 0xFF
            return bytes([ENC[(mn, "rel")], rel])
        return bytes([ENC[(mn, "abs")], w & 0xFF, (w >> 8) & 0xFF])
    return None

def verify_bank(idx, spath, bank, out):
    layout = layout_of(idx)
    lines = pathlib.Path(spath).read_text(encoding="utf-8").splitlines()
    buf = bytearray(16384)
    pos = 0
    errors = 0
    for line in lines:
        s = line.strip()
        if not s or s.startswith(";") or s.startswith(".segment"):
            continue
        if LABEL_RE.match(s):
            continue
        if s.startswith(".byte"):
            for tok in s[5:].split(","):
                buf[pos] = int(tok.strip().replace("$", "0x"), 16)
                pos += 1
            continue
        # istruzione
        parts = s.split(" ", 1)
        mn = parts[0]
        operand = parts[1].strip() if len(parts) > 1 else ""
        pc = cpu_addr(pos, layout)
        enc = assemble_line(mn, operand, pc)
        if enc is None:
            if errors < 8:
                out.append(f"  bank ${idx:02X} offset ${pos:04X}: CANNOT ASSEMBLE: {s}")
            errors += 1
            pos += 1
            continue
        for b in enc:
            buf[pos] = b
            pos += 1
    mism = 0
    for off in range(16384):
        if buf[off] != bank[off]:
            mism += 1
            if mism <= 8:
                out.append(f"  bank ${idx:02X} offset ${off:04X}: "
                           f"expected ${bank[off]:02X}, got ${buf[off]:02X}")
    good = (mism == 0 and errors == 0)
    out.append(f"bank ${idx:02X}: " +
               ("PERFECT - byte-identical" if good else
                f"{mism} mismatch, {errors} asm errors"))
    return good

def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    banks = load_prg(sys.argv[1])
    skeldir = sys.argv[2]
    out = ["; ==== verify_skeleton report ===="]
    perfect = 0
    for idx in range(32):
        p = pathlib.Path(skeldir) / f"bank_{idx:02x}.s"
        if not p.exists():
            out.append(f"bank ${idx:02X}: skeleton file missing")
            continue
        if verify_bank(idx, p, banks[idx], out):
            perfect += 1
    print("\n".join(out))
    print(f"\n{perfect}/32 banks byte-perfect")

if __name__ == "__main__":
    main()
