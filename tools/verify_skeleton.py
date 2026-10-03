#!/usr/bin/env python3
"""
verify_skeleton.py v3 â€” byte-perfect validation (two-pass).

Pass 1: calcola l'offset di OGNI label del file (anche quelle simboliche,
definite dopo il riferimento), stimando le dimensioni delle istruzioni.
Pass 2: assembla con la tabella label completa e confronta i 16384 byte.

Usage:
    py tools/verify_skeleton.py <rom.nes> <skeleton_dir>
"""
import sys, os, re, pathlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from auto_disasm import OPS, load_prg, cpu_addr

ENC = {}
for op, (mn, md) in OPS.items():
    ENC.setdefault((mn, md), op)

LABEL_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):$")
BRANCHES = ("BPL", "BMI", "BVC", "BVS", "BCC", "BCS", "BNE", "BEQ")

def layout_of(idx):
    return "fixed" if idx == 0x1F else "window"

def parse_items(lines):
    """-> lista di ("label", nome) | ("data", bytes) | ("inst", mn, operand)"""
    items = []
    for line in lines:
        s = line.strip()
        if not s or s.startswith(";") or s.startswith(".segment"):
            continue
        m = LABEL_RE.match(s)
        if m:
            items.append(("label", m.group(1)))
            continue
        if s.startswith(".byte"):
            vals = [int(t.strip().replace("$", "0x"), 16)
                    for t in s[5:].split(",")]
            items.append(("data", bytes(vals)))
            continue
        parts = s.split(" ", 1)
        mn = parts[0]
        operand = parts[1].strip() if len(parts) > 1 else ""
        items.append(("inst", mn, operand))
    return items

def encode(mn, operand, pc_addr, labels):
    """Assembla una istruzione. labels: nome -> indirizzo CPU (o assente)."""
    if operand == "":
        if (mn, "acc") in ENC:
            return bytes([ENC[(mn, "acc")]])
        return bytes([ENC[(mn, "imp")]])
    if operand.startswith("#$"):
        return bytes([ENC[(mn, "imm")], int(operand[2:], 16)])
    if re.match(r"^\(\$[0-9A-F]{2},X\)$", operand):
        return bytes([ENC[(mn, "izx")], int(operand[2:4], 16)])
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
        if mn in BRANCHES:
            rel = (w - ((pc_addr + 2) & 0xFFFF)) & 0xFF
            return bytes([ENC[(mn, "rel")], rel])
        return bytes([ENC[(mn, "abs")], w & 0xFF, (w >> 8) & 0xFF])
    # label simbolica (post annotate.py)
    if re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", operand):
        if operand in labels:
            w = labels[operand]
            if mn in BRANCHES:
                rel = (w - ((pc_addr + 2) & 0xFFFF)) & 0xFF
                return bytes([ENC[(mn, "rel")], rel])
            return bytes([ENC[(mn, "abs")], w & 0xFF, (w >> 8) & 0xFF])
        return None
    return None

def verify_bank(idx, spath, bank, out):
    layout = layout_of(idx)
    items = parse_items(pathlib.Path(spath).read_text(encoding="utf-8").splitlines())

    # ---- pass 1: offset di ogni label (stima dimensioni per i fwd-ref)
    labels = {}
    pos = 0
    for it in items:
        if it[0] == "label":
            labels[it[1]] = cpu_addr(pos, layout)
        elif it[0] == "data":
            pos += len(it[1])
        else:
            mn, operand = it[1], it[2]
            pc = cpu_addr(pos, layout)
            enc = encode(mn, operand, pc, labels)
            if enc is not None:
                sz = len(enc)
            elif mn in BRANCHES:
                sz = 2
            elif mn in ("JSR", "JMP"):
                sz = 3
            else:
                sz = 1
            pos += sz

    # ---- pass 2: assembla con la tabella label completa
    buf = bytearray(16384)
    pos = 0
    errors = 0
    for it in items:
        if it[0] == "label":
            continue
        if it[0] == "data":
            for b in it[1]:
                if pos < 16384:
                    buf[pos] = b
                pos += 1
            continue
        mn, operand = it[1], it[2]
        pc = cpu_addr(pos, layout)
        enc = encode(mn, operand, pc, labels)
        if enc is None:
            if errors < 8:
                out.append(f"  bank ${idx:02X} offset ${pos:04X}: CANNOT ASSEMBLE: {mn} {operand}")
            errors += 1
            pos += 3 if mn in ("JSR", "JMP") else (2 if mn in BRANCHES else 1)
            continue
        for b in enc:
            if pos < 16384:
                buf[pos] = b
            pos += 1

    mism = 0
    for off in range(16384):
        if buf[off] != bank[off]:
            mism += 1
            if mism <= 8:
                out.append(f"  bank ${idx:02X} offset ${off:04X}: expected ${bank[off]:02X}, got ${buf[off]:02X}")
    good = (mism == 0 and errors == 0)
    out.append(f"bank ${idx:02X}: " +
               ("PERFECT - byte-identical" if good else f"{mism} mismatch, {errors} asm errors"))
    return good

def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    banks = load_prg(sys.argv[1])
    out = ["; ==== verify_skeleton report (v3) ===="]
    perfect = 0
    for idx in range(32):
        p = pathlib.Path(sys.argv[2]) / f"bank_{idx:02x}.s"
        if not p.exists():
            out.append(f"bank ${idx:02X}: skeleton file missing")
            continue
        if verify_bank(idx, p, banks[idx], out):
            perfect += 1
    print("\n".join(out))
    print(f"\n{perfect}/32 banks byte-perfect")

if __name__ == "__main__":
    main()
