#!/usr/bin/env python3
"""Anteprima dei dialoghi con lo STESSO font che finira' nella ROM (tile 8x16 di build_it.patch_font + coppie VWF).

  python tools/preview.py ID [text/it.tsv] [out.png]      # disegna il messaggio ID (wrappato) in un PNG

Serve anche all'editor (editor.py): load_font() -> {id: 16 byte}, render_message() -> pagine di righe di ID tile,
tile_pixels() -> matrice di pixel.
"""
import os, re, sys, struct, zlib
here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import charmap_it, vwf, build_it

COLS, ROWS = 26, 4
TOKEN = vwf.TOKEN
NAME_PREVIEW = "Eroe"          # $n
_NUM = "999"                   # {02:xx}


def load_font(jp_rom_path, alloc):
    """Font finale: parte dal CHR giapponese, applica lettere latine e coppie; ritorna {id: 16 byte} e i tile HP/MP ecc."""
    data = bytearray(open(jp_rom_path, "rb").read())
    prg = data[4] * 16384
    build_it.patch_font(data, prg)
    if alloc:
        vwf.patch_pair_glyphs(data, prg, alloc)
    chr0 = 16 + prg
    font = {}
    for tid in range(256):
        top = data[chr0 + 60 * 4096 + tid * 16: chr0 + 60 * 4096 + tid * 16 + 8]
        bot = data[chr0 + 61 * 4096 + tid * 16: chr0 + 61 * 4096 + tid * 16 + 8]
        font[tid] = bytes(top) + bytes(bot)
    return font


def is_command_line(line):
    """Riga di comandi del motore (solo token/cifre/segni, senza lettere): non viene mostrata."""
    rest = TOKEN.sub("", line)
    return not re.search(r"[A-Za-zàèéìòùÀÈÉÌÒÙ“”]", rest) and not re.search(r"<[0-9A-F]{2}>", line) and rest.strip() == "" or \
        re.fullmatch(r"\s*[%#*+\-&]\S*\s*", line) is not None


def line_tiles(line, alloc):
    """Riga -> lista di ID tile da stampare (i token diventano segnaposto)."""
    out = []
    for c in vwf.cells(line, alloc):
        if c[0] == "c":
            out.append(charmap_it.IT[c[1]])
        elif c[0] == "p":
            out.append(alloc[(c[1], c[2])])
        else:
            t = c[1]
            if t.startswith("$"):
                out += [charmap_it.IT[ch] for ch in NAME_PREVIEW]
            elif t.startswith("{"):
                out += [charmap_it.IT[ch] for ch in _NUM]
            elif re.fullmatch(r"<[0-9A-F]{2}>", t) and t not in ("<05>", "<5E>"):
                out.append(int(t[1:3], 16))
    return out


def render_message(text, alloc):
    """text: messaggio (con <05>). Ritorna lista di pagine; ogni pagina = lista di righe (liste di ID tile)."""
    pages, cur = [], []
    for line in text.split("<05>"):
        if line.strip() == "<5E>":
            pages.append(cur); cur = []; continue
        if is_command_line(line) or line == "":
            continue
        cur.append(line_tiles(line, alloc))
        if len(cur) == ROWS:
            pages.append(cur); cur = []
    if cur:
        pages.append(cur)
    return pages


def tile_pixels(pages, font, gap=1):
    """Immagine 'a finestre' impilate: lista di righe di pixel (0/1), larghezza 26 celle = 208 px, righe da 16 px."""
    W = COLS * 8
    img = []
    for pi, page in enumerate(pages):
        for r in range(ROWS):
            tiles = page[r] if r < len(page) else []
            rows = [[0] * W for _ in range(16)]
            for x, tid in enumerate(tiles[:COLS + 8]):
                g = font[tid]
                for y in range(16):
                    for b in range(8):
                        if x * 8 + b < W and (g[y] >> (7 - b)) & 1:
                            rows[y][x * 8 + b] = 1
            img += rows
        img += [[0] * W for _ in range(gap * 4)]
    return img


def write_png(path, pix, scale=3, fg=(240, 240, 240), bg=(16, 16, 32)):
    h, w = len(pix) * scale, len(pix[0]) * scale
    raw = bytearray()
    for row in pix:
        line = bytearray([0])
        for v in row:
            line += bytes(fg if v else bg) * scale
        raw += bytes(line) * scale
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + \
          chunk(b"IDAT", zlib.compress(bytes(raw), 6)) + chunk(b"IEND", b"")
    open(path, "wb").write(png)


if __name__ == "__main__":
    mid = sys.argv[1].upper().zfill(4)
    tsv = sys.argv[2] if len(sys.argv) > 2 else os.path.join(here, "..", "text", "it_wrapped.tsv")
    out = sys.argv[3] if len(sys.argv) > 3 else os.path.join(here, "..", "scratch", "preview_%s.png" % mid)
    alloc = vwf.alloc_from_dialog(os.path.join(here, "..", "text", "it.tsv"))
    font = load_font(os.path.join(here, "..", "baserom_jp.nes"), alloc)
    text = next(l.rstrip("\n").split("\t")[1] for l in open(tsv, encoding="utf-8") if l.startswith(mid + "\t"))
    write_png(out, tile_pixels(render_message(text, alloc), font))
    print("scritto", out)
