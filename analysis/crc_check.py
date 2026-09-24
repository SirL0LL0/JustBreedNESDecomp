import zlib, os
here = os.path.dirname(os.path.abspath(__file__))
cdl = open(os.path.join(here, "justbreed.cdl"), "rb").read()
print("cdl crc field", cdl[5:9].hex(), "LE int %08x" % int.from_bytes(cdl[5:9], "little"))
for name in ("baserom.nes", "baserom_jp.nes"):
    r = open(os.path.join(here, "..", name), "rb").read()
    prg = r[16:16 + r[4] * 16384]
    chr_ = r[16 + r[4] * 16384:]
    print(name, "file %08x" % zlib.crc32(r), "prg+chr %08x" % zlib.crc32(r[16:]), "prg %08x" % zlib.crc32(prg), "chr %08x" % zlib.crc32(chr_))
