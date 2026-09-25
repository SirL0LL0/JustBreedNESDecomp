#!/usr/bin/env python3
"""Controlla le traduzioni: token identici a quelli giapponesi e righe non piu' lunghe della finestra.

  python tools/text_check.py [text/dialog_jp.tsv] [text/it.tsv]
it.tsv: una riga per messaggio  ID<TAB>testo italiano  (stessa sintassi di dialog_jp.tsv: <XX> = byte grezzo,
{cc:pp} = comando con parametro, $n = nome, #!nn / *.nnn / +n / -n / %n = comandi in ASCII; <05> = a capo).
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

MAXLINE = 26
TOKEN = re.compile(r"\{[0-9A-F]{2}:[0-9A-F]{2}\}|<[0-9A-F]{2}>|\$\d|#!?\d+|\*\.?\d+|[+\-%&]\d+|\.\d+")
JPCHAR = re.compile(r"[　-鿿＀-￯…・]")


def tokens(s):
    return TOKEN.findall(s)


def visible_lines(s):
    out = []
    for seg in s.split("<05>"):
        seg = TOKEN.sub(lambda m: "xxxx" if m.group(0).startswith("$") else "", seg)
        out.append(len(seg))
    return out


def load(path, cols):
    d = {}
    for l in open(path, encoding="utf-8"):
        p = l.rstrip("\n").split("\t")
        if len(p) >= cols and p[0] != "id":
            d[p[0]] = p
    return d


if __name__ == "__main__":
    jp = load(sys.argv[1] if len(sys.argv) > 1 else "text/dialog_jp.tsv", 3)
    it = load(sys.argv[2] if len(sys.argv) > 2 else "text/it.tsv", 2)
    bad = 0
    for k, row in it.items():
        if k not in jp:
            print(k, "id inesistente"); bad += 1; continue
        # a capo e pause di pagina possono cambiare col riflusso: si confrontano solo i token "veri"
        drop = ("<05>", "<5E>")
        a = [t for t in tokens(jp[k][2]) if t not in drop]
        b = [t for t in tokens(row[1]) if t not in drop]
        if a != b:
            print(k, "TOKEN diversi\n   JP:", a, "\n   IT:", b); bad += 1
        if JPCHAR.search(row[1]):
            print(k, "contiene caratteri giapponesi"); bad += 1
        try:
            import charmap_it
            n_raw = len(charmap_it.encode_text(row[1]))
            if n_raw > 254:
                print(k, "messaggio troppo lungo: %d byte (max 254, buffer del gioco)" % n_raw); bad += 1
        except ValueError as e:
            print(k, "errore:", e); bad += 1
        for n in visible_lines(row[1]):
            if n > MAXLINE:
                print(k, "riga di %d caratteri (max %d): %s" % (n, MAXLINE, row[1][:70])); bad += 1; break
    print("messaggi tradotti: %d / %d, problemi: %d" % (len(it), len(jp), bad))
