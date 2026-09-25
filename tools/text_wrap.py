#!/usr/bin/env python3
"""Riflusso automatico delle traduzioni: righe <= WIDTH caratteri, pagine <= PAGE_LINES righe.

  python tools/text_wrap.py text/it.tsv text/it_wrapped.tsv

Il sorgente puo' avere righe (<05>) a piacere. Le righe di *testo* consecutive vengono unite in un paragrafo e
ri-spezzate; NON vengono toccate: righe di comando (solo token/cifre, senza lettere), righe centrate (>= 3 spazi
iniziali), le voci di una scelta (dopo un comando %n) e le pause di pagina (<5E>). Se un paragrafo supera
PAGE_LINES righe, si inserisce <05><5E><05> (attesa tasto e nuova pagina).
Larghezza: $n = 4 colonne, <XX> = 1 colonna, altri token di comando = 0. Le righe successive alla prima hanno
1 spazio di rientro se il paragrafo inizia con virgolette (“) o con <59>, come nel testo originale.
"""
import re, sys

WIDTH, PAGE_LINES = 26, 4
TOKEN = re.compile(r"\{[0-9A-F]{2}:[0-9A-F]{2}\}|<[0-9A-F]{2}>|\$\d|#!?\d+|\*\.?\d+|[+\-%&]\d+|\.\d+")
LETTER = re.compile(r"[A-Za-zàèéìòùÀÈÉÌÒÙ぀-ヿ一-鿿]")


def width(s):
    w = 0
    pos = 0
    for m in TOKEN.finditer(s):
        w += len(s[pos:m.start()])
        t = m.group(0)
        w += 4 if t.startswith("$") else 1 if re.fullmatch(r"<[0-9A-F]{2}>", t) and t not in ("<05>", "<5E>") else 0
        pos = m.end()
    return w + len(s[pos:])


def words(s):
    """Divide in parole senza spezzare i token; gli spazi tra parole diventano separatori."""
    return [w for w in s.split(" ") if w != ""]


def wrap_paragraph(text_lines, in_quote=False):
    joined = " ".join(l.strip() for l in text_lines)
    indent = 1 if (in_quote or joined.startswith(("“", "<59>"))) else 0
    out, cur = [], ""
    first = True
    for w in words(joined):
        cand = (cur + " " + w) if cur else ((" " * indent) + w if in_quote and first else w)
        if width(cand) > WIDTH and cur.strip():
            out.append(cur)
            cur = (" " * indent) + w
        else:
            cur = cand
        first = False
    if cur:
        out.append(cur)
    return out


def wrap_message(s):
    lines = s.split("<05>")
    out, para, after_choice = [], [], False
    quote_open = False                       # un “ e' aperto: le righe successive (anche dopo <5E>) hanno rientro

    def flush():
        nonlocal para, quote_open
        if not para:
            return
        wrapped = wrap_paragraph(para, in_quote=quote_open)
        joined = " ".join(para)
        opens, closes = joined.count("“"), joined.count("”")
        quote_open = quote_open + opens > closes and (opens > closes or quote_open)
        for i in range(0, len(wrapped), PAGE_LINES):
            if i:
                out.extend(["<5E>"])
            out.extend(wrapped[i:i + PAGE_LINES])
        para = []

    for idx, l in enumerate(lines):
        is_last_empty = idx == len(lines) - 1 and l == ""
        if re.fullmatch(r"\s*%\d+\s*", l):
            flush(); out.append(l); after_choice = True
        elif after_choice or l.strip() == "<5E>" or l.startswith("   ") or not LETTER.search(TOKEN.sub("", l)) or is_last_empty:
            flush(); out.append(l)
        else:
            para.append(l)
    flush()
    return "<05>".join(out)


if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    with open(dst, "w", encoding="utf-8") as f:
        for l in open(src, encoding="utf-8"):
            p = l.rstrip("\n").split("\t")
            if len(p) < 2 or p[0] == "id":
                f.write(l)
                continue
            f.write("%s\t%s\n" % (p[0], wrap_message(p[1])))
    print("scritto", dst)
