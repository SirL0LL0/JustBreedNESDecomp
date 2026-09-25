#!/usr/bin/env python3
"""Disassemblatore per Just Breed (MMC5): analisi ricorsiva per banco da 8K + copertura registrata.

  python tools/disasm.py baserom_jp.nes OUTDIR [cov1.bin cov2.bin ...]

Per ogni banco 8K scrive OUTDIR/unitNN.asm (sorgente in stile ca65 con etichette) e OUTDIR/summary.txt.
  * base della finestra CPU di ogni banco: da <cov>.win (finestra in cui il banco ha eseguito) oppure stimata
    dagli operandi JSR/JMP; i banchi 61/62 stanno a $C000 e 63 a $E000 (fissi).
  * semi: vettori RESET/NMI/IRQ, ingressi (bit1) e opcode (bit0) della copertura, tabelle di puntatori
    note dal file 'seeds.txt' (una riga "unit addr" esadecimale).
  * routine con dati inline (iniziano con PLA/STA...): dopo la JSR i byte sono dati (stringa fino a 00).
  * il resto e' emesso come .byte; il testo giapponese noto e' annotato in commento.
"""
import os, sys, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from py65.devices.mpu6502 import MPU
from charmap_jp import decode_line

UNIT = 8192
LEN = {"imp": 1, "acc": 1, "imm": 2, "zpg": 2, "zpx": 2, "zpy": 2, "rel": 2, "inx": 2, "iny": 2, "abs": 3, "abx": 3, "aby": 3, "ind": 3}
OPS = MPU().disassemble
HW = {0x2000: "PPUCTRL", 0x2001: "PPUMASK", 0x2002: "PPUSTATUS", 0x2003: "OAMADDR", 0x2004: "OAMDATA", 0x2005: "PPUSCROLL",
      0x2006: "PPUADDR", 0x2007: "PPUDATA", 0x4014: "OAMDMA", 0x4015: "APUSTATUS", 0x4016: "JOY1", 0x4017: "JOY2",
      0x5100: "MMC5_PRGMODE", 0x5101: "MMC5_CHRMODE", 0x5102: "MMC5_RAMPROT1", 0x5103: "MMC5_RAMPROT2", 0x5104: "MMC5_EXRAMMODE",
      0x5105: "MMC5_NTMAP", 0x5106: "MMC5_FILLTILE", 0x5107: "MMC5_FILLATTR", 0x5113: "MMC5_WRAMBANK", 0x5114: "MMC5_PRG8000",
      0x5115: "MMC5_PRGA000", 0x5116: "MMC5_PRGC000", 0x5117: "MMC5_PRGE000", 0x5130: "MMC5_CHRUPPER", 0x5200: "MMC5_SPLITMODE",
      0x5201: "MMC5_SPLITSCROLL", 0x5202: "MMC5_SPLITBANK", 0x5203: "MMC5_IRQCMP", 0x5204: "MMC5_IRQSTATUS",
      0x5205: "MMC5_MULA", 0x5206: "MMC5_MULB", 0x5015: "MMC5_AUDIOSTATUS", 0x5010: "MMC5_PCM"}
for i in range(8):
    HW[0x5120 + i] = "MMC5_CHR_A%d" % i
for i in range(4):
    HW[0x5128 + i] = "MMC5_CHR_B%d" % i


class Rom:
    def __init__(self, path, covs):
        d = open(path, "rb").read()
        self.prg = d[16:16 + d[4] * 16384]
        self.nunits = len(self.prg) // UNIT
        n = len(self.prg)
        self.op = bytearray(n)       # bit0 opcode visto (copertura)
        self.ent = bytearray(n)      # bit0 entry visto
        self.win = [0] * 256         # maschera finestre
        for c in covs:
            b = open(c, "rb").read()
            if len(b) == n:
                for i, v in enumerate(b):
                    if v & 1: self.op[i] = 1
                    if v & 2: self.ent[i] = 1
            w = c + ".win"
            if os.path.exists(w):
                for i, v in enumerate(open(w, "rb").read()):
                    self.win[i] |= v
        self.base = {}
        for u in range(self.nunits):
            self.base[u] = self.guess_base(u)

    def guess_base(self, u):
        if u == 63: return 0xE000
        if u in (61, 62): return 0xC000
        m = self.win[u] & 7
        if m:
            for w in range(3):
                if m & (1 << w):
                    return 0x8000 + 0x2000 * w
        # stima: conta JSR/JMP abs i cui operandi cadono nella finestra candidata ($C000 e' solo dei banchi 61/62)
        d = self.prg[u * UNIT:(u + 1) * UNIT]
        best, bw = -1, 0x8000
        for cand in (0x8000, 0xA000):
            n = 0
            for i in range(len(d) - 2):
                if d[i] in (0x20, 0x4C):
                    t = d[i + 1] | (d[i + 2] << 8)
                    if cand <= t < cand + UNIT:
                        n += 1
            if n > best:
                best, bw = n, cand
        return bw

    def unit_of(self, addr, cur):
        """unita' che contiene un indirizzo CPU, dato il contesto (unita' corrente)."""
        if addr >= 0xE000: return 63, addr - 0xE000
        if 0xC000 <= addr < 0xE000 and cur not in (61, 62) and self.base[cur] != 0xC000:
            return 62, addr - 0xC000
        if self.base[cur] <= addr < self.base[cur] + UNIT:
            return cur, addr - self.base[cur]
        return None, None


def inline_routines(rom):
    """Routine che estraggono l'indirizzo di ritorno (PLA...STA nei primi passi): (unit,addr) -> True."""
    out = set()
    for u in range(rom.nunits):
        d = rom.prg[u * UNIT:(u + 1) * UNIT]
        for i in range(len(d) - 8):
            if d[i] == 0x68 and d[i + 1] in (0x85, 0x8D) or (d[i] == 0x68 and d[i + 1] == 0x68):
                out.add((u, i))
    return out


def plausible_code(rom, u, off, min_insns=3, max_insns=80):
    """True se da off si decodifica una sequenza sensata che termina con RTS/RTI/JMP entro max_insns."""
    d = rom.prg[u * UNIT:(u + 1) * UNIT]
    n = 0
    while off < UNIT and n < max_insns:
        name, mode = OPS[d[off]]
        if name == "???" or name == "BRK":
            return False
        ln = LEN[mode]
        if off + ln > UNIT:
            return False
        if mode == "rel":
            t = off + 2 + (d[off + 1] - 256 if d[off + 1] > 127 else d[off + 1])
            if not 0 <= t < UNIT:
                return False
        if mode in ("abs", "abx", "aby", "ind") and name in ("JSR", "JMP"):
            a = d[off + 1] | (d[off + 2] << 8)
            if a < 0x8000:
                return False
        n += 1
        if name in ("RTS", "RTI") or (name == "JMP"):
            return n >= min_insns
        off += ln
    return False


def pointer_table_seeds(rom, code):
    """Tabelle di parole a 16 bit consecutive (>=4) che puntano nella finestra del banco (o +1: dispatch RTS)."""
    seeds = set()
    for u in range(rom.nunits):
        base = rom.base[u]
        d = rom.prg[u * UNIT:(u + 1) * UNIT]
        i = 0
        while i < UNIT - 8:
            run = []
            j = i
            while j + 1 < UNIT:
                w = d[j] | (d[j + 1] << 8)
                for delta in (0, 1):
                    t = w + delta
                    if base <= t < base + UNIT:
                        run.append((j, t - base)); break
                else:
                    break
                j += 2
            if len(run) >= 4:
                for _, t in run:
                    if plausible_code(rom, u, t):
                        seeds.add((u, t))
                i = j
            else:
                i += 2
    return seeds


def chain_seeds(rom, min_chain=10, min_share=0.25):
    """Semi euristici: catene di >= min_chain istruzioni valide che finiscono con RTS/RTI (solo nei banchi 'da codice')."""
    seeds = []
    for u in range(rom.nunits):
        d = rom.prg[u * UNIT:(u + 1) * UNIT]
        chains, i, good = [], 0, 0
        while i < UNIT:
            j, c = i, 0
            while j < UNIT:
                name, mode = OPS[d[j]]
                if name in ("???", "BRK"):
                    break
                ln = LEN[mode]
                if j + ln > UNIT:
                    break
                if mode == "rel":
                    t = j + 2 + (d[j + 1] - 256 if d[j + 1] > 127 else d[j + 1])
                    if not 0 <= t < UNIT:
                        break
                j += ln; c += 1
                if name in ("RTS", "RTI"):
                    break
            if c >= min_chain:
                chains.append(i); good += j - i; i = j
            else:
                i += 1
        if good / UNIT >= min_share:
            seeds += [(u, s) for s in chains]
    return seeds


def analyze(rom, seeds_extra):
    seeds_extra = list(seeds_extra) + chain_seeds(rom)
    code, targets, ext = analyze_pass(rom, seeds_extra)
    for _ in range(6):
        extra = set(seeds_extra)
        for (u, off) in pointer_table_seeds(rom, code):
            if off not in code[u]:
                extra.add((u, off))
        # funzioni subito dopo un terminatore
        for u in range(rom.nunits):
            cs = code[u]
            d = rom.prg[u * UNIT:(u + 1) * UNIT]
            for off, ln in list(cs.items()):
                if OPS[d[off]][0] in ("RTS", "RTI", "JMP"):
                    nxt = off + ln
                    if nxt < UNIT and nxt not in cs and plausible_code(rom, u, nxt):
                        extra.add((u, nxt))
        new = [s for s in extra if s[1] not in code[s[0]]]
        if not new:
            break
        code, targets, ext = analyze_pass(rom, list(extra) + list(seeds_extra))
    return code, targets, ext


def analyze_pass(rom, seeds_extra):
    code = {u: {} for u in range(rom.nunits)}      # unit -> {off: length}
    targets = {u: set() for u in range(rom.nunits)}
    ext = collections.defaultdict(set)              # riferimenti fuori unita': (unit, off)
    inline = inline_routines(rom)
    work = []
    # semi: vettori
    fixed = rom.prg[63 * UNIT:]
    for vec in (0x1FFA, 0x1FFC, 0x1FFE):
        a = fixed[vec] | (fixed[vec + 1] << 8)
        work.append((63, a - 0xE000))
    for i, v in enumerate(rom.op):
        if v and rom.ent[i]:
            work.append((i // UNIT, i % UNIT))
    for i, v in enumerate(rom.op):                   # anche gli opcode visti: partono come semi
        if v:
            work.append((i // UNIT, i % UNIT))
    work += seeds_extra
    seen = set()
    while work:
        u, off = work.pop()
        if u is None or not (0 <= off < UNIT) or (u, off) in seen:
            continue
        # decodifica lineare da off finche' non c'e' un terminatore
        while 0 <= off < UNIT:
            if off in code[u]:
                break
            d = rom.prg[u * UNIT + off]
            name, mode = OPS[d]
            if name == "???" or (name == "BRK" and not rom.op[u * UNIT + off]):
                break
            ln = LEN[mode]
            if off + ln > UNIT:
                break
            code[u][off] = ln
            seen.add((u, off))
            ops = rom.prg[u * UNIT + off + 1:u * UNIT + off + ln]
            base = rom.base[u]
            if mode == "rel":
                t = off + 2 + (ops[0] - 256 if ops[0] > 127 else ops[0])
                targets[u].add(t); work.append((u, t))
            elif name in ("JSR", "JMP") and mode == "abs":
                a = ops[0] | (ops[1] << 8)
                tu, to = rom.unit_of(a, u)
                if tu is not None:
                    targets[tu].add(to); work.append((tu, to))
                else:
                    ext[u].add(a)
                if name == "JSR" and tu is not None and (tu, to) in inline:
                    # dati inline: stringa fino a 00; il codice riprende dopo il terminatore
                    p = off + ln
                    while p < UNIT and rom.prg[u * UNIT + p] != 0:
                        p += 1
                    off = p + 1
                    if off < UNIT:
                        targets[u].add(off)
                    continue
                if name == "JMP":
                    break
            elif name == "JMP" or name in ("RTS", "RTI"):
                break
            off += ln
    return code, targets, ext


def operand_text(rom, u, off, name, mode, ops, targets, labels):
    base = rom.base[u]
    def sym(a):
        if a in HW: return HW[a]
        tu, to = rom.unit_of(a, u)
        if tu is not None and a >= 0x8000:
            return labels(tu, to)
        return "$%04X" % a if a > 0xFF else "$%02X" % a
    if mode == "imp": return ""
    if mode == "acc": return "a"
    if mode == "imm": return "#$%02X" % ops[0]
    if mode == "rel":
        t = off + 2 + (ops[0] - 256 if ops[0] > 127 else ops[0])
        return labels(u, t)
    a = ops[0] if len(ops) == 1 else ops[0] | (ops[1] << 8)
    s = sym(a) if mode in ("abs", "abx", "aby", "ind") else ("$%02X" % a)
    return {"abs": s, "abx": s + ",x", "aby": s + ",y", "ind": "(%s)" % s, "zpg": s, "zpx": s + ",x", "zpy": s + ",y",
            "inx": "(%s,x)" % s, "iny": "(%s),y" % s}[mode]


def emit(rom, code, targets, outdir):
    os.makedirs(outdir, exist_ok=True)
    summary = []
    for u in range(rom.nunits):
        base = rom.base[u]
        lab = lambda tu, to: "u%02d_%04X" % (tu, rom.base[tu] + to)
        lines = ["; unita' %d  (ROM 0x%05X-0x%05X)  finestra CPU $%04X" % (u, u * UNIT, u * UNIT + UNIT - 1, base), ""]
        d = rom.prg[u * UNIT:(u + 1) * UNIT]
        off, n_code = 0, 0
        cs = code[u]
        while off < UNIT:
            if off in targets[u] or off in cs and off in targets[u]:
                lines.append("%s:" % lab(u, off))
            if off in cs:
                ln = cs[off]
                name, mode = OPS[d[off]]
                ops = d[off + 1:off + ln]
                op = operand_text(rom, u, off, name, mode, ops, targets[u], lab)
                lines.append("    %-4s %-22s ; %04X  %s" % (name.lower(), op, base + off, " ".join("%02X" % b for b in d[off:off + ln])))
                n_code += ln
                off += ln
                continue
            # dati: fino al prossimo byte di codice o etichetta, a righe da 16
            end = off
            while end < UNIT and end not in cs and (end == off or end not in targets[u]):
                end += 1
            p = off
            while p < end:
                q = min(end, p + 16)
                chunk = d[p:q]
                lines.append("    .byte %-64s ; %04X" % (",".join("$%02X" % b for b in chunk), base + p))
                p = q
            off = end
        open(os.path.join(outdir, "unit%02d.asm" % u), "w", encoding="utf-8").write("\n".join(lines) + "\n")
        summary.append((u, n_code))
    with open(os.path.join(outdir, "summary.txt"), "w") as f:
        tot = 0
        for u, n in summary:
            f.write("unit %2d  base $%04X  codice %5d / %d (%.0f%%)\n" % (u, rom.base[u], n, UNIT, 100 * n / UNIT))
            tot += n
        f.write("TOTALE codice: %d / %d (%.1f%%)\n" % (tot, rom.nunits * UNIT, 100 * tot / (rom.nunits * UNIT)))
    return summary


if __name__ == "__main__":
    rom = Rom(sys.argv[1], sys.argv[3:])
    extra = []
    sp = os.path.join(os.path.dirname(os.path.abspath(__file__)), "seeds.txt")
    if os.path.exists(sp):
        for l in open(sp):
            l = l.split("#")[0].split()
            if len(l) == 2:
                u, a = int(l[0], 16), int(l[1], 16)
                tu, to = rom.unit_of(a, u)
                if tu is not None:
                    extra.append((tu, to))
    code, targets, ext = analyze(rom, extra)
    s = emit(rom, code, targets, sys.argv[2])
    tot = sum(n for _, n in s)
    print("codice disassemblato: %d byte su %d (%.1f%%)" % (tot, rom.nunits * UNIT, 100 * tot / (rom.nunits * UNIT)))
