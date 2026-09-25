#!/usr/bin/env python3
"""Flusso di lavoro per tradurre i dialoghi a lotti (senza editor grafico).

  python tools/batch.py show N [DIM]     # mostra il lotto N (DIM messaggi da tradurre, default 40) con il giapponese
  python tools/batch.py add FILE         # aggiunge a text/it.tsv le righe "ID<TAB>italiano" di FILE (controlla i token)
  python tools/batch.py status           # quanti messaggi tradotti / da tradurre / senza testo

Un messaggio "senza testo" contiene solo comandi del motore (nessun kana/kanji): non va tradotto, la build li lascia
com'e'. I token (<XX>, {cc:pp}, $n, #!nn, *nnn, +n, -n, %n, &n, .n) devono restare identici al giapponese.
"""
import os, re, sys
here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import text_check, charmap_it

TEXT = os.path.join(here, "..", "text")
JPCH = re.compile(r"[぀-ヿ一-鿿]")


def load_jp():
    rows = [l.rstrip("\n").split("\t") for l in open(os.path.join(TEXT, "dialog_jp.tsv"), encoding="utf-8-sig")][1:]
    return {r[0]: r[2] for r in rows}, [r[0] for r in rows]


def load_it():
    d = {}
    p = os.path.join(TEXT, "it.tsv")
    if os.path.exists(p):
        for l in open(p, encoding="utf-8-sig"):
            q = l.rstrip("\n").split("\t")
            if len(q) >= 2 and q[0] != "id":
                d[q[0]] = q[1]
    return d


def needs_text(jp):
    return bool(JPCH.search(text_check.TOKEN.sub("", jp)))


def cmd_status():
    jp, order = load_jp(); it = load_it()
    todo = [m for m in order if m not in it and needs_text(jp[m])]
    empty = [m for m in order if not needs_text(jp[m])]
    print("totale %d | tradotti %d | da tradurre %d | senza testo %d" % (len(order), len(it), len(todo), len(empty)))


def cmd_show(n, size):
    jp, order = load_jp(); it = load_it()
    todo = [m for m in order if m not in it and needs_text(jp[m])]
    for m in todo[n * size:(n + 1) * size]:
        print("%s\t%s" % (m, jp[m]))
    print("# lotto %d: %d..%d di %d da tradurre" % (n, n * size, min((n + 1) * size, len(todo)), len(todo)), file=sys.stderr)


def cmd_add(path):
    jp, order = load_jp(); it = load_it()
    added, bad = 0, 0
    for l in open(path, encoding="utf-8-sig"):
        l = l.rstrip("\n")
        if not l.strip() or l.startswith("#"):
            continue
        mid, _, text = l.partition("\t")
        text = text.replace("…", "...")
        if mid not in jp:
            print(mid, "id inesistente"); bad += 1; continue
        drop = ("<05>", "<5E>")
        a = [t for t in text_check.tokens(jp[mid]) if t not in drop]
        b = [t for t in text_check.tokens(text) if t not in drop]
        if a != b:
            print(mid, "TOKEN diversi\n   JP:", a, "\n   IT:", b); bad += 1; continue
        if text_check.JPCHAR.search(text):
            print(mid, "contiene giapponese"); bad += 1; continue
        try:
            charmap_it.encode_text(text)
        except ValueError as e:
            print(mid, "errore:", e); bad += 1; continue
        it[mid] = text; added += 1
    with open(os.path.join(TEXT, "it.tsv"), "w", encoding="utf-8", newline="\n") as f:
        f.write("id\tit\n")
        for m in order:
            if m in it:
                f.write("%s\t%s\n" % (m, it[m]))
    print("aggiunti %d, scartati %d, totale tradotti %d" % (added, bad, len(it)))


if __name__ == "__main__":
    c = sys.argv[1] if len(sys.argv) > 1 else "status"
    if c == "status":
        cmd_status()
    elif c == "show":
        cmd_show(int(sys.argv[2]), int(sys.argv[3]) if len(sys.argv) > 3 else 40)
    elif c == "add":
        cmd_add(sys.argv[2])
