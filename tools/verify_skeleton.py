#!/usr/bin/env python3
"""
verify_skeleton.py â€” byte-perfect validation of the skeleton (v2).
Accetta label con nomi arbitrari (post annotate.py).
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

def layout_of(idx):
    return "fixed" if idx == 0x1F else "window"

def assemble_line(mn, operand, pc_addr):
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
        if mn in ("BPL", "BMI", "BVC", "BVS", "BCC", "BCS", "BNE", "BEQ"):
            rel = (w - ((pc_addr + 2) & 0xFFFF)) & 0xFF
            return bytes([ENC[(mn, "rel")], rel])
        return bytes([ENC[(mn, "abs")], w & 0xFF, (w >> 8) & 0xFF])
    # label con nome simbolico (post annotate.py)
    if re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", operand):
        return None  # il chiamante segnala l'errore (serve la tabella label)
    return None

def verify_bank(idx, spath, bank, out, label_vals):
    layout = layout_of(idx)
    lines = pathlib.Path(spath).read_text(encoding="utf-8").splitlines()
    # primo passaggio: raccoglie gli indirizzi delle label simboliche
    labels = {}
    for line in lines:
        s = line.strip()
        m = LABEL_RE.match(s)
        if m:
            labels[m.group(1)] = None
    # le label simboliche non hanno indirizzi numerici: serve la posizione.
    # Ricostruiamo la posizione coi byte cumulati durante il parse.
    buf = bytearray(16384)
    pos = 0
    errors = 0
    label_addr = {}
    for line in lines:
        s = line.strip()
        if not s or s.startswith(";") or s.startswith(".segment"):
            continue
        m = LABEL_RE.match(s)
        if m:
            label_addr[m.group(1)] = cpu_addr(pos, layout)
            continue
        if s.startswith(".byte"):
            for tok in s[5:].split(","):
                buf[pos] = int(tok.strip().replace("$", "0x"), 16)
                pos += 1
            continue
        parts = s.split(" ", 1)
        mn = parts[0]
        operand = parts[1].strip() if len(parts) > 1 else ""
        pc = cpu_addr(pos, layout)
        # risolvi label simboliche
        if operand in label_addr and not operand.startswith(("L_", "sub_")):
            target = label_addr[operand]
            if mn in ("BPL", "BMI", "BVC", "BVS", "BCC", "BCS", "BNE", "BEQ"):
                rel = (target - ((pc + 2) & 0xFFFF)) & 0xFF
                enc = bytes([ENC[(mn, "rel")], rel])
            else:
                enc = bytes([ENC[(mn, "abs")], target & 0xFF, (target >> 8) & 0xFF])
        else:
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
                out.append(f"  bank ${idx:02X} offset ${off:04X}: expected ${bank[off]:02X}, got ${buf[off]:02X}")
    good = (mism == 0 and errors == 0)
    out.append(f"bank ${idx:02X}: " +
               ("PERFECT - byte-identical" if good else f"{mism} mismatch, {errors} asm errors"))
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
        if verify_bank(idx, p, banks[idx], out, {}):
            perfect += 1
    print("\n".join(out))
    print(f"\n{perfect}/32 banks byte-perfect")

if __name__ == "__main__":
    main()
