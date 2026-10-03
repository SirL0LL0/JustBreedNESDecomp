#!/usr/bin/env python3
"""
auto_disasm.py v3 — MMC5-aware automatic disassembler for Just Breed (NES)

Usage (dalla cartella JB_VIBE):
    py JustBreedNESDecomp\\tools\\auto_disasm.py baserom_jp.nes JustBreedNESDecomp\\asm\\banks\\auto\\

MMC5 bank model (8K slots):
  $5114 -> $8000-$9FFF   $5115 -> $A000-$BFFF
  $5116 -> $C000-$DFFF   $5117 -> $E000-$FFFF (fixed, last 8K)
  Slot values are 8K bank numbers. For this 512KB ROM:
  $FC = bank $1E first half    $FD = bank $1E second half
  $FE = bank $1F first half    $FF = bank $1F second half (vectors)

Bank-call convention (discovered in bank $1F trampolines):
  JSR $EB9C  -> window $8000 = bank in A (shadowed to RAM $BC)
  JSR $EB96  -> window $A000 = bank in A (shadowed to RAM $BD)
  LDA #$xx / STA $5116 -> window $C000 = bank $xx

The walker follows same-bank calls, records cross-bank refs, and iterates
to a fixpoint so banks $1E/$1F get fully explored from real entry points.
Everything unreached is emitted as .byte -> byte-perfect coverage.
"""
import sys, os, pathlib

# ---------------------------------------------------------------- opcodes
OPS = {}
def s(op, mn, md): OPS[op] = (mn, md)
s(0x00,"BRK","imp"); s(0x01,"ORA","izx"); s(0x05,"ORA","zp"); s(0x06,"ASL","zp")
s(0x08,"PHP","imp"); s(0x09,"ORA","imm"); s(0x0A,"ASL","acc"); s(0x0D,"ORA","abs"); s(0x0E,"ASL","abs")
s(0x10,"BPL","rel"); s(0x11,"ORA","izy"); s(0x15,"ORA","zpx"); s(0x16,"ASL","zpx")
s(0x18,"CLC","imp"); s(0x19,"ORA","aby"); s(0x1D,"ORA","abx"); s(0x1E,"ASL","abx")
s(0x20,"JSR","abs"); s(0x21,"AND","izx"); s(0x24,"BIT","zp"); s(0x25,"AND","zp"); s(0x26,"ROL","zp")
s(0x28,"PLP","imp"); s(0x29,"AND","imm"); s(0x2A,"ROL","acc"); s(0x2C,"BIT","abs"); s(0x2D,"AND","abs"); s(0x2E,"ROL","abs")
s(0x30,"BMI","rel"); s(0x31,"AND","izy"); s(0x35,"AND","zpx"); s(0x36,"ROL","zpx")
s(0x38,"SEC","imp"); s(0x39,"AND","aby"); s(0x3D,"AND","abx"); s(0x3E,"ROL","abx")
s(0x40,"RTI","imp"); s(0x41,"EOR","izx"); s(0x45,"EOR","zp"); s(0x46,"LSR","zp")
s(0x48,"PHA","imp"); s(0x49,"EOR","imm"); s(0x4A,"LSR","acc"); s(0x4C,"JMP","abs"); s(0x4D,"EOR","abs"); s(0x4E,"LSR","abs")
s(0x50,"BVC","rel"); s(0x51,"EOR","izy"); s(0x55,"EOR","zpx"); s(0x56,"LSR","zpx")
s(0x58,"CLI","imp"); s(0x59,"EOR","aby"); s(0x5D,"EOR","abx"); s(0x5E,"LSR","abx")
s(0x60,"RTS","imp"); s(0x61,"ADC","izx"); s(0x65,"ADC","zp"); s(0x66,"ROR","zp")
s(0x68,"PLA","imp"); s(0x69,"ADC","imm"); s(0x6A,"ROR","acc"); s(0x6C,"JMP","ind"); s(0x6D,"ADC","abs"); s(0x6E,"ROR","abs")
s(0x70,"BVS","rel"); s(0x71,"ADC","izy"); s(0x75,"ADC","zpx"); s(0x76,"ROR","zpx")
s(0x78,"SEI","imp"); s(0x79,"ADC","aby"); s(0x7D,"ADC","abx"); s(0x7E,"ROR","abx")
s(0x81,"STA","izx"); s(0x84,"STY","zp"); s(0x85,"STA","zp"); s(0x86,"STX","zp")
s(0x88,"DEY","imp"); s(0x8A,"TXA","imp"); s(0x8C,"STY","abs"); s(0x8D,"STA","abs"); s(0x8E,"STX","abs")
s(0x90,"BCC","rel"); s(0x91,"STA","izy"); s(0x94,"STY","zpx"); s(0x95,"STA","zpx")
s(0x96,"STX","zpy"); s(0x98,"TYA","imp"); s(0x99,"STA","aby"); s(0x9A,"TXS","imp"); s(0x9D,"STA","abx")
s(0xA0,"LDY","imm"); s(0xA1,"LDA","izx"); s(0xA2,"LDX","imm"); s(0xA4,"LDY","zp")
s(0xA5,"LDA","zp"); s(0xA6,"LDX","zp"); s(0xA8,"TAY","imp"); s(0xA9,"LDA","imm"); s(0xAA,"TAX","imp")
s(0xAC,"LDY","abs"); s(0xAD,"LDA","abs"); s(0xAE,"LDX","abs")
s(0xB0,"BCS","rel"); s(0xB1,"LDA","izy"); s(0xB4,"LDY","zpx"); s(0xB5,"LDA","zpx")
s(0xB6,"LDX","zpy"); s(0xB8,"CLV","imp"); s(0xB9,"LDA","aby"); s(0xBA,"TSX","imp")
s(0xBC,"LDY","abx"); s(0xBD,"LDA","abx"); s(0xBE,"LDX","aby")
s(0xC0,"CPY","imm"); s(0xC1,"CMP","izx"); s(0xC4,"CPY","zp"); s(0xC5,"CMP","zp"); s(0xC6,"DEC","zp")
s(0xC8,"INY","imp"); s(0xC9,"CMP","imm"); s(0xCA,"DEX","imp"); s(0xCC,"CPY","abs"); s(0xCD,"CMP","abs"); s(0xCE,"DEC","abs")
s(0xD0,"BNE","rel"); s(0xD1,"CMP","izy"); s(0xD5,"CMP","zpx"); s(0xD6,"DEC","zpx")
s(0xD8,"CLD","imp"); s(0xD9,"CMP","aby"); s(0xDD,"CMP","abx"); s(0xDE,"DEC","abx")
s(0xE0,"CPX","imm"); s(0xE1,"SBC","izx"); s(0xE4,"CPX","zp"); s(0xE5,"SBC","zp"); s(0xE6,"INC","zp")
s(0xE8,"INX","imp"); s(0xE9,"SBC","imm"); s(0xEA,"NOP","imp"); s(0xEC,"CPX","abs"); s(0xED,"SBC","abs"); s(0xEE,"INC","abs")
s(0xF0,"BEQ","rel"); s(0xF1,"SBC","izy"); s(0xF5,"SBC","zpx"); s(0xF6,"INC","zpx")
s(0xF8,"SED","imp"); s(0xF9,"SBC","aby"); s(0xFD,"SBC","abx"); s(0xFE,"INC","abx")

SIZE = {"imp":1,"acc":1,"imm":2,"zp":2,"zpx":2,"zpy":2,"izx":2,"izy":2,"rel":2,
        "abs":3,"abx":3,"aby":3,"ind":3}

# ---------------------------------------------------------------- ROM
def load_prg(path):
    data = pathlib.Path(path).read_bytes()
    # 'NES' + 0x1A (iNES magic) — written as bytes() to avoid escape issues
    if data[:4] != bytes([0x4E, 0x45, 0x53, 0x1A]):
        sys.exit("ERROR: not an iNES file")
    if data[4] != 32 or data[5] != 32:
        sys.exit(f"ERROR: expected 32/32 banks, got {data[4]}/{data[5]}")
    off = 16
    banks = []
    for i in range(32):
        banks.append(data[off:off+16384]); off += 16384
    return banks

# ---------------------------------------------------------------- layout
# layout "fixed"  : bank $1F (offsets 0x0000-0x1FFF @ $C000-$DFFF via $5116=$FE,
#                              offsets 0x2000-0x3FFF @ $E000-$FFFF fixed)
# layout "window" : switchable banks (0x0000-0x1FFF @ $8000-$9FFF,
#                                    0x2000-0x3FFF @ $A000-$BFFF)
def cpu_addr(off, layout):
    if layout == "fixed":
        return (0xC000 + off) if off < 0x2000 else (0xE000 + (off - 0x2000))
    return (0x8000 + off) if off < 0x2000 else (0xA000 + (off - 0x2000))

def bank_off(addr, layout):
    if layout == "fixed":
        if 0xC000 <= addr < 0xE000: return addr - 0xC000
        if 0xE000 <= addr <= 0xFFFF: return 0x2000 + (addr - 0xE000)
    else:
        if 0x8000 <= addr < 0xA000: return addr - 0x8000
        if 0xA000 <= addr < 0xC000: return 0x2000 + (addr - 0xA000)
    return None

def slot_of(t):
    """(slot_register, slot_base) for a call target, or None."""
    if 0x8000 <= t < 0xA000: return (0x5114, 0x8000)
    if 0xA000 <= t < 0xC000: return (0x5115, 0xA000)
    if 0xC000 <= t < 0xE000: return (0x5116, 0xC000)
    return None

def decode(bank, off, layout):
    """Decode one instruction -> (text, size) or None."""
    if off >= 16384: return None
    op = bank[off]
    e = OPS.get(op)
    if e is None: return None
    mn, md = e
    sz = SIZE[md]
    if off + sz > 16384: return None
    pc = cpu_addr(off, layout)
    if md in ("imp", "acc"): txt = mn
    elif md == "imm": txt = f"{mn} #${bank[off+1]:02X}"
    elif md == "zp":  txt = f"{mn} ${bank[off+1]:02X}"
    elif md == "zpx": txt = f"{mn} ${bank[off+1]:02X},X"
    elif md == "zpy": txt = f"{mn} ${bank[off+1]:02X},Y"
    elif md == "izx": txt = f"{mn} (${bank[off+1]:02X},X)"
    elif md == "izy": txt = f"{mn} (${bank[off+1]:02X}),Y"
    elif md == "rel":
        t = (pc + 2 + ((bank[off+1] ^ 0x80) - 0x80)) & 0xFFFF
        txt = f"{mn} L_{t:04X}"
    elif md == "ind":
        w = bank[off+1] | (bank[off+2] << 8)
        txt = f"{mn} (${w:04X})"
    else:
        w = bank[off+1] | (bank[off+2] << 8)
        suffix = {"abs": "", "abx": ",X", "aby": ",Y"}[md]
        if md == "abs" and mn in ("JSR", "JMP"):
            txt = f"{mn} {'sub_' if mn == 'JSR' else 'L_'}{w:04X}"
        else:
            txt = f"{mn} ${w:04X}{suffix}"
    return txt, sz

# ---------------------------------------------------------------- walker
def walk(bank, entries, layout, xrefs, unresolved, winvals):
    """Recursive descent with window tracking.
    Updates: xrefs (set of (bank16, off)), unresolved (set of (slot_base, target)),
    winvals (dict slot -> set of values seen). Returns (seen, code)."""
    seen = set(); code = set()
    stack = [e for e in entries if 0 <= e < 16384]
    while stack:
        off = stack.pop()
        # per-path window state; fixed bank starts with $5116=$FE (set by RESET)
        win = {0x5114: None, 0x5115: None,
               0x5116: (0xFE if layout == "fixed" else None)}
        last_imm = None
        while 0 <= off < 16384 and off not in seen:
            op = bank[off]
            e = OPS.get(op)
            if e is None: break
            mn, md = e
            sz = SIZE[md]
            if off + sz > 16384: break
            seen.add(off)
            for k in range(sz): code.add(off + k)
            follow = []
            if mn == "LDA" and md == "imm":
                last_imm = bank[off+1]
                follow = [off + sz]
            elif mn == "STA" and md == "abs":
                w = bank[off+1] | (bank[off+2] << 8)
                if w in (0x5114, 0x5115, 0x5116):
                    win[w] = last_imm
                    if last_imm is not None: winvals[w].add(last_imm)
                follow = [off + sz]
            elif mn == "JSR" and md == "abs":
                t = bank[off+1] | (bank[off+2] << 8)
                if t == 0xEB9C:
                    win[0x5114] = last_imm
                    if last_imm is not None: winvals[0x5114].add(last_imm)
                elif t == 0xEB96:
                    win[0x5115] = last_imm
                    if last_imm is not None: winvals[0x5115].add(last_imm)
                else:
                    res = resolve_call(t, win, layout)
                    if res is not None:
                        kind = res[0]
                        if kind == "self":
                            stack.append(res[1])
                        else:
                            xrefs.add((res[1], res[2]))
                    else:
                        sl = slot_of(t)
                        if sl: unresolved.add((sl[1], t))
                    # $Exxx-$FFFF calls from window banks -> fixed bank
                    if 0xE000 <= t <= 0xFFFF and layout != "fixed":
                        xrefs.add((0x1F, 0x2000 + (t - 0xE000)))
                follow = [off + sz]          # return address
            elif mn == "JMP" and md == "abs":
                t = bank[off+1] | (bank[off+2] << 8)
                res = resolve_call(t, win, layout)
                if res is not None:
                    if res[0] == "self": stack.append(res[1])
                    else: xrefs.add((res[1], res[2]))
                else:
                    sl = slot_of(t)
                    if sl: unresolved.add((sl[1], t))
                if 0xE000 <= t <= 0xFFFF and layout != "fixed":
                    xrefs.add((0x1F, 0x2000 + (t - 0xE000)))
                follow = []                    # no fall-through
            elif md == "rel":
                pc = cpu_addr(off, layout)
                t = (pc + 2 + ((bank[off+1] ^ 0x80) - 0x80)) & 0xFFFF
                o = bank_off(t, layout)
                if o is not None: follow.append(o)
                follow.append(off + sz)
            elif mn in ("RTS", "RTI"):
                follow = []
            elif mn == "JMP" and md in ("ind", "abx"):
                follow = []                    # computed target
            else:
                follow = [off + sz]
            if not follow: break
            off = follow[0]
            stack.extend(follow[1:])
    return seen, code

def resolve_call(t, win, layout):
    """Resolve a JSR/JMP target under current window state.
    Returns ('self', off) | ('xref', bank16, off) | None."""
    # fixed region $E000-$FFFF
    if 0xE000 <= t <= 0xFFFF:
        if layout == "fixed":
            return ("self", 0x2000 + (t - 0xE000))
        return ("xref", 0x1F, 0x2000 + (t - 0xE000))
    sl = slot_of(t)
    if sl is None: return None
    slot, base = sl
    v = win.get(slot)
    # fixed-bank code calling into $C000-$DFFF with $5116=$FE: same bank, first half
    if slot == 0x5116 and layout == "fixed" and v == 0xFE:
        return ("self", t - 0xC000)
    if v is None: return None
    v8 = v & 0x3F
    return ("xref", v8 >> 1, (v8 & 1) * 0x2000 + (t - base))

# ---------------------------------------------------------------- emit
def emit_bank(idx, bank, seen, code, outdir):
    layout = "fixed" if idx == 0x1F else "window"
    hdr = ("$C000-$DFFF (via $5116=$FE) + $E000-$FFFF (fixed)" if idx == 0x1F
           else "$8000-$9FFF / $A000-$BFFF (via $5114/$5115)")
    lines = [
        "; =============================================================",
        f"; PRG bank ${idx:02X} — auto-disassembled skeleton (v3)",
        f"; CPU mapping: {hdr}",
        f"; code bytes: {len(code)} / 16384",
        "; NOTE: auto-generated. Refine labels & data tables by hand.",
        "; =============================================================",
        f'.segment "CODE{idx}"',
        "",
    ]
    off = 0
    while off < 16384:
        if off in seen:
            lines.append(f"L_{cpu_addr(off, layout):04X}:")
            d = decode(bank, off, layout)
            txt, sz = d
            lines.append("    " + txt)
            off += sz
        else:
            run = []
            while off < 16384 and off not in seen and len(run) < 16:
                run.append(bank[off]); off += 1
            lines.append("    .byte " + ", ".join(f"${x:02X}" for x in run))
            if off < 16384 and off in seen:
                lines.append("")
    if idx == 0x1F:
        lines += [
            "",
            "; Real vectors ($FFFA): NMI=$E143 RESET=$E000 IRQ=$E2C4",
            "; (emitted by the linker config, see config/nes.cfg)",
        ]
    p = pathlib.Path(outdir) / f"bank_{idx:02x}.s"
    p.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return p

# ---------------------------------------------------------------- main
def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    rom, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    banks = load_prg(rom)

    entries = {0x1F: {0x2000, 0x2143, 0x22C4}}   # RESET, NMI, IRQ (2nd half)
    xrefs = set()
    unresolved = set()
    winvals = {0x5114: {0xFC}, 0x5115: {0xFC, 0xFD}, 0x5116: {0xFE, 0xFD}}

    # ---- fixpoint iterations
    for it in range(10):
        changed = False
        for bidx in sorted(entries):
            layout = "fixed" if bidx == 0x1F else "window"
            walk(banks[bidx], sorted(entries[bidx]), layout,
                 xrefs, unresolved, winvals)
        # add resolved xrefs as new entries
        for (b2, o2) in xrefs:
            if 0 <= b2 < 32 and 0 <= o2 < 16384:
                if b2 not in entries or o2 not in entries[b2]:
                    entries.setdefault(b2, set()).add(o2)
                    changed = True
        # expand unresolved targets with all known values for that slot
        for (base, t) in list(unresolved):
            slot = slot_of(t)[0]
            for v in winvals[slot]:
                v8 = v & 0x3F
                b2 = v8 >> 1
                o2 = (v8 & 1) * 0x2000 + (t - base)
                if 0 <= b2 < 32 and 0 <= o2 < 16384:
                    if b2 not in entries or o2 not in entries[b2]:
                        entries.setdefault(b2, set()).add(o2)
                        changed = True
        print(f"iter {it}: {sum(len(v) for v in entries.values())} entries, "
              f"{len(xrefs)} xrefs, {len(unresolved)} unresolved"
              + (" (changed)" if changed else " (stable)"))
        if not changed:
            break

    # ---- final pass: walk & emit every bank
    total_code = 0
    for idx in range(32):
        layout = "fixed" if idx == 0x1F else "window"
        ent = entries.get(idx)
        if not ent:
            ent = {0x0000, 0x2000}   # fallback: linear probes on data banks
        seen, code = walk(banks[idx], sorted(ent), layout,
                          xrefs, unresolved, winvals)
        p = emit_bank(idx, banks[idx], seen, code, outdir)
        total_code += len(code)
        print(f"bank ${idx:02X}: {len(code):6d} code bytes / 16384  -> {p.name}")

    # ---- save the cross-bank map
    mp = ["; ==== cross-bank map (call site resolution) ===="]
    for (b2, o2) in sorted(xrefs):
        lay2 = "fixed" if b2 == 0x1F else "window"
        mp.append(f"  -> bank ${b2:02X} offset ${o2:04X} (CPU ${cpu_addr(o2, lay2):04X})")
    for (base, t) in sorted(unresolved):
        mp.append(f"  ?? window ${base:04X} target ${t:04X} (dynamic bank)")
    pathlib.Path(outdir, "bankmap.txt").write_text("\n".join(mp) + "\n", encoding="utf-8")

    print(f"\nTotal code bytes: {total_code} / 524288 ({100*total_code/524288:.1f}%)")
    print("Skeleton ready in asm/banks/auto/.")

if __name__ == "__main__":
    main()