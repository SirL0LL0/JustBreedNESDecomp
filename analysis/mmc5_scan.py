"""Decodifica i run di codice del CDL e cerca gli accessi ai registri MMC5 ($5000-$5FFF)."""
import os, collections
here = os.path.dirname(os.path.abspath(__file__))
cdl = open(os.path.join(here, "justbreed.cdl"), "rb").read()[9:]
rom = open(os.path.join(here, "..", "baserom.nes"), "rb").read()
prg = rom[16:16 + rom[4] * 16384]
pd = cdl[:len(prg)]

# lunghezza istruzione per opcode (solo quelli ufficiali che ci servono; il resto = 1)
ABS = {0xAD: "LDA", 0x8D: "STA", 0xAE: "LDX", 0x8E: "STX", 0xAC: "LDY", 0x8C: "STY",
       0xEE: "INC", 0xCE: "DEC", 0x2C: "BIT", 0xCD: "CMP", 0x0D: "ORA", 0x2D: "AND", 0x4C: "JMP", 0x20: "JSR"}
ABSX = {0xBD: "LDA,X", 0x9D: "STA,X", 0xB9: "LDA,Y", 0x99: "STA,Y", 0xBE: "LDX,Y", 0xBC: "LDY,X"}
LEN2 = {0xA9, 0xA2, 0xA0, 0x09, 0x29, 0x49, 0x69, 0xE9, 0xC9, 0xE0, 0xC0, 0xA5, 0x85, 0xA6, 0x86, 0xA4, 0x84,
        0xB5, 0x95, 0xA1, 0x81, 0xB1, 0x91, 0xC5, 0xE5, 0x65, 0x25, 0x05, 0x45, 0xE6, 0xC6, 0xB6, 0x96, 0xB4, 0x94,
        0x10, 0x30, 0x50, 0x70, 0x90, 0xB0, 0xD0, 0xF0, 0x06, 0x26, 0x46, 0x66, 0x24, 0xE4, 0xC4, 0x15, 0x35, 0x55,
        0x75, 0xD5, 0xF5, 0xD1, 0x11, 0x31, 0x51, 0x71, 0xF1, 0xC1, 0x01, 0x21, 0x41, 0x61, 0xE1, 0x16, 0x36, 0x56,
        0x76, 0xD6, 0xF6}
LEN3 = set(ABS) | set(ABSX) | {0x6C, 0x0E, 0x2E, 0x4E, 0x6E, 0x1E, 0x3E, 0x5E, 0x7E, 0xDE, 0xFE, 0x1D, 0x3D, 0x5D,
                                0x7D, 0xDD, 0xFD, 0x19, 0x39, 0x59, 0x79, 0xD9, 0xF9, 0xEC, 0xCC, 0x0D, 0x6D, 0xED, 0xAD}
def ilen(op):
    if op in LEN3: return 3
    if op in LEN2: return 2
    return 1

CODE = 0x01
mmc5 = collections.defaultdict(list)   # reg -> [(off, kind, lastimm)]
i, n = 0, len(pd)
runs = 0
while i < n:
    if pd[i] & CODE:
        j = i
        while j < n and pd[j] & CODE: j += 1
        runs += 1
        p, last = i, None
        while p < j:
            op = prg[p]; l = ilen(op)
            if l == 3 and p + 2 < n:
                addr = prg[p + 1] | prg[p + 2] << 8
                if 0x5000 <= addr <= 0x5FFF:
                    kind = ABS.get(op) or ABSX.get(op) or "op%02X" % op
                    mmc5[addr].append((p, kind, last))
            if op == 0xA9 and p + 1 < n: last = prg[p + 1]
            elif op in (0xA2, 0xA0): pass
            elif op not in (0x8D, 0x8E, 0x8C): last = None if op in LEN3 and op != 0x8D else last
            p += l
        i = j
    else:
        i += 1
print("code runs:", runs)
NAMES = {0x5000: "MMC5 pulse1 vol", 0x5100: "PRG mode", 0x5101: "CHR mode", 0x5102: "PRG-RAM protect1", 0x5103: "PRG-RAM protect2",
         0x5104: "ExRAM mode", 0x5105: "Nametable map", 0x5106: "Fill tile", 0x5107: "Fill colour", 0x5113: "PRG-RAM bank $6000",
         0x5114: "PRG bank $8000", 0x5115: "PRG bank $A000", 0x5116: "PRG bank $C000", 0x5117: "PRG bank $E000",
         0x5200: "Split mode", 0x5201: "Split scroll", 0x5202: "Split bank", 0x5203: "IRQ scanline cmp", 0x5204: "IRQ status/enable",
         0x5205: "Mult A / lo", 0x5206: "Mult B / hi", 0x5015: "MMC5 audio status", 0x5010: "MMC5 PCM mode", 0x5011: "MMC5 PCM"}
for k in range(0x5120, 0x512C): NAMES[k] = "CHR bank sprite %d" % (k - 0x5120)
for k in range(0x5128, 0x512C): NAMES[k] = "CHR bank BG %d" % (k - 0x5128)
for reg in sorted(mmc5):
    ev = mmc5[reg]
    kinds = collections.Counter(k for _, k, _ in ev)
    vals = sorted({v for _, k, v in ev if v is not None and k.startswith("ST")})
    print("$%04X %-22s %3d sites %s  imm-vals=%s" % (reg, NAMES.get(reg, "?"), len(ev), dict(kinds), ["%02X" % v for v in vals][:12]))
    for p, k, v in ev[:3]:
        print("        rom_off 0x%05X (8K bank %d, cpu-off $%04X) %s" % (p, p // 8192, p % 8192, k))
