import re, sys, collections
p = sys.argv[1]
rx = re.compile(r'^([0-9A-F]{4})\s+(\S+)\s*(.*?)\s+A:([0-9A-F]{2}) X:([0-9A-F]{2}) Y:([0-9A-F]{2}) S:([0-9A-F]{2}) P:(\S+)\s+V:(\d+)\s+H:(\d+)')
pcs = collections.Counter(); regions = collections.Counter(); mmc5 = collections.Counter()
mn = collections.Counter(); n = 0; bad = 0; frames = set(); ram_exec = collections.Counter()
first = None; last = None
for line in open(p, encoding="latin-1"):
    m = rx.match(line)
    if not m:
        bad += 1; continue
    n += 1
    pc = int(m.group(1), 16); op = m.group(2); rest = m.group(3)
    pcs[pc] += 1; mn[op] += 1
    r = "RAM<2000" if pc < 0x2000 else "IO/EXRAM 2000-5FFF" if pc < 0x6000 else "WRAM 6000-7FFF" if pc < 0x8000 else "8000-9FFF" if pc < 0xA000 else "A000-BFFF" if pc < 0xC000 else "C000-DFFF" if pc < 0xE000 else "E000-FFFF"
    regions[r] += 1
    if pc < 0x8000: ram_exec[pc] += 1
    t = re.search(r'\$(5[0-9A-F]{3})', rest)
    if t and op in ("STA", "STX", "STY", "LDA", "LDX", "LDY", "BIT", "CMP"):
        mmc5[(t.group(1), op)] += 1
    if first is None: first = line.strip()[:60]
    last = line.strip()[:110]
print("lines", n, "unparsed", bad)
print("first:", first); print("last:", last)
print("unique PCs:", len(pcs))
print("exec by region:"); [print("  %-22s %d" % kv) for kv in regions.most_common()]
print("top PCs:"); [print("  %04X %d" % kv) for kv in pcs.most_common(12)]
print("$5xxx accesses:"); [print("  $%s %s %d" % (a, o, c)) for (a, o), c in sorted(mmc5.items())]
print("RAM/WRAM exec PCs (%d unique):" % len(ram_exec))
for pc, c in sorted(ram_exec.items())[:40]: print("  %04X %d" % (pc, c))
