import re, sys
lines = open(sys.argv[1], encoding="latin-1").read().splitlines()
def show(pat, ctx=0, maxn=6):
    n = 0
    for i, l in enumerate(lines):
        if re.search(pat, l):
            for j in range(max(0, i - ctx), min(len(lines), i + ctx + 1)):
                print(("> " if j == i else "  ") + lines[j][:118])
            print("--"); n += 1
            if n >= maxn: break
print("### $5800 context"); show(r'\$5800', ctx=3, maxn=2)
print("### bank register writes (A = value)")
for l in lines:
    m = re.search(r'STA \$(511[4-7]).*A:([0-9A-F]{2})', l)
    if m: print(l[:8].strip(), "STA $" + m.group(1), "<- $" + m.group(2))
print("### IRQ writes")
show(r'STX \$5203|STA \$5204', ctx=1, maxn=4)
