import re, sys, collections
regs = {0x5114: None, 0x5115: None, 0x5116: None, 0x5117: None}
execs = collections.defaultdict(set)
ram_win = collections.Counter()
rx = re.compile(r'^([0-9A-F]{4})\s+(\S+)\s.*?A:([0-9A-F]{2})')
for l in open(sys.argv[1], encoding="latin-1"):
    m = rx.match(l)
    if not m: continue
    pc = int(m.group(1), 16); op = m.group(2); a = int(m.group(3), 16)
    if op == "STA":
        t = re.search(r'STA \$(511[4-7])', l)
        if t: regs[int(t.group(1), 16)] = a; continue
    if pc >= 0x8000:
        w = 0x5114 + ((pc - 0x8000) >> 13)
        v = regs[w]
        if v is None: key = (w, "unknown")
        elif v & 0x80: key = (w, "ROM 8K bank %d" % ((v & 0x7F) % 64))
        else: key = (w, "WRAM bank %d" % (v & 7)); ram_win[key] += 1
        execs[key].add(pc)
for (w, b), pcs in sorted(execs.items(), key=lambda kv: (kv[0][0], kv[0][1])):
    print("window $%04X %-16s %4d distinct PCs  range %04X-%04X" % ((w - 0x5114) * 0x2000 + 0x8000, b, len(pcs), min(pcs), max(pcs)))
print("executed from WRAM-mapped windows:", dict(ram_win))
