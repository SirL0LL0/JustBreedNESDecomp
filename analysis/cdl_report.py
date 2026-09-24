import struct, sys, collections, os, zlib
here = os.path.dirname(os.path.abspath(__file__))
cdl = open(os.path.join(here, "justbreed.cdl"), "rb").read()
rom = open(os.path.join(here, "..", "baserom.nes"), "rb").read()
prg = rom[16:16 + rom[4] * 16384]
print("cdl size", len(cdl), "header", cdl[:5], "crc", cdl[5:9].hex(), "rom crc(prg+chr)", "%08x" % zlib.crc32(rom[16:]), "prg crc", "%08x" % zlib.crc32(prg))
d = cdl[9:]
print("data bytes", len(d), "prg", len(prg), "chr", len(rom) - 16 - len(prg))
c = collections.Counter(d)
for k, v in c.most_common(16):
    print("flag 0x%02X: %d" % (k, v))
pd = d[:len(prg)]
code = sum(1 for b in pd if b & 1)
data = sum(1 for b in pd if b & 2)
print("PRG code bytes %d (%.1f%%), data bytes %d (%.1f%%)" % (code, 100 * code / len(prg), data, 100 * data / len(prg)))
print("per 8KB bank: code%")
for i in range(len(prg) // 8192):
    seg = pd[i * 8192:(i + 1) * 8192]
    print("  8K bank %2d: code %5d  data %5d" % (i, sum(1 for b in seg if b & 1), sum(1 for b in seg if b & 2)))
