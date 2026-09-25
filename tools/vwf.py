#!/usr/bin/env python3
"""Larghezza variabile "statica" (VWF) per i dialoghi: celle precomposte da due mezze-celle da 4 px.

Il gioco stampa un tile 8x16 per carattere e il CHR e' ROM, quindi non si puo' comporre a runtime. Qui l'impaginazione
si fa in fase di build: i caratteri "stretti" (NARROW, glifo da 4 px) consecutivi si fondono in UN tile che contiene
entrambi (coppia). Ogni coppia usata ha un ID tile proprio, preso da FREE_IDS (glifi kana non piu' usati) e disegnato
nei banchi CHR 60/61. Niente cambia nel codice del gioco: e' solo un'altra codifica del testo.

* build_alloc(righe) sceglie le coppie piu' frequenti (al massimo len(FREE_IDS)), in modo deterministico;
* cells(riga, alloc) = codifica a numero minimo di celle (programmazione dinamica);
* le coppie non toccano gli spazi iniziali di una riga (colonna del cursore nei menu) e mai i token di comando.
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

TOKEN = re.compile(r"\{[0-9A-F]{2}:[0-9A-F]{2}\}|<[0-9A-F]{2}>|\$\d|#!?\d+|\*\.?\d+|[+\-%&]\d+|\.\d+")

# ID tile liberi (glifi kana giapponesi: dakuten hiragana/katakana, kana piccoli, punteggiatura 'A0-AF', 'DE/DF').
# Non devono coincidere con nessun ID di charmap_it.IT (controllato in build_alloc).
FREE_IDS = (list(range(0x06, 0x1F)) + list(range(0x66, 0x70)) + list(range(0xA4, 0xB0))
            + list(range(0xCB, 0xDE)) + list(range(0xE6, 0xFF)))

# Glifi stretti: 16 righe da 4 pixel ('#' = pixel), come lo Unscii ma senza grazie; ink a x=1..2 (bordo sinistro 1 px).
def _rows(spec):
    """spec: dict riga -> stringa di 4 caratteri; le righe non citate sono vuote."""
    return [int(spec.get(r, "....").replace("#", "1").replace(".", "0"), 2) for r in range(16)]

NARROW = {
    " ": _rows({}),
    "i": _rows({2: ".##.", 3: ".##.", **{r: ".##." for r in range(6, 13)}}),
    "l": _rows({r: ".##." for r in range(2, 13)}),
    "j": _rows({2: ".##.", 3: ".##.", **{r: ".##." for r in range(6, 15)}, 15: "##.."}),
    "t": _rows({3: ".##.", 4: ".##.", 5: ".##.", 6: "####", **{r: ".##." for r in range(7, 12)}, 12: ".###"}),
    "f": _rows({2: ".###", 3: ".##.", 4: ".##.", 5: ".##.", 6: "####", **{r: ".##." for r in range(7, 13)}}),
    "r": _rows({6: ".###", **{r: ".##." for r in range(7, 13)}}),
    ".": _rows({10: ".##.", 11: ".##.", 12: ".##."}),
    ",": _rows({10: "###.", 11: ".##.", 12: ".##.", 13: "##..", 14: "#..."}),
    "'": _rows({1: ".##.", 2: ".##.", 3: ".##.", 4: "##.."}),
    ":": _rows({3: ".##.", 4: ".##.", 5: ".##.", 10: ".##.", 11: ".##.", 12: ".##."}),
    ";": _rows({3: ".##.", 4: ".##.", 5: ".##.", 10: "###.", 11: ".##.", 12: ".##.", 13: "##..", 14: "#..."}),
    "!": _rows({**{r: ".##." for r in range(1, 9)}, 11: ".##.", 12: ".##."}),
}


def load_overrides():
    """text/narrow_glyphs.json (scritto dall'editor): {carattere: [16 interi da 4 bit]} sostituisce i glifi di base."""
    import json
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "text", "narrow_glyphs.json")
    if os.path.exists(p):
        for k, v in json.load(open(p, encoding="utf-8")).items():
            if k in NARROW and len(v) == 16:
                NARROW[k] = [int(x) & 15 for x in v]


load_overrides()


def pair_glyph(a, b):
    """16 byte (una per riga) del tile 8x16 con a nella meta' sinistra e b in quella destra."""
    return bytes((NARROW[a][r] << 4) | NARROW[b][r] for r in range(16))


def _runs(s):
    """[(True, testo) | (False, token)]: i token di comando non entrano mai nelle coppie."""
    out, pos = [], 0
    for m in TOKEN.finditer(s):
        if m.start() > pos:
            out.append((True, s[pos:m.start()]))
        out.append((False, m.group(0)))
        pos = m.end()
    if pos < len(s):
        out.append((True, s[pos:]))
    return out


def _pair_candidates(run, lead):
    """Coppie possibili nel testo `run` (lead = numero di caratteri iniziali intoccabili)."""
    for i in range(max(lead, 0), len(run) - 1):
        a, b = run[i], run[i + 1]
        if a in NARROW and b in NARROW and not (a == " " and b == " "):
            yield (a, b)


def _lead(line):
    """Spazi iniziali della riga (nel primo run di testo), da non fondere."""
    runs = _runs(line)
    if runs and runs[0][0]:
        t = runs[0][1]
        return len(t) - len(t.lstrip(" "))
    return 0


def build_alloc(lines, ids=None):
    """lines: righe di testo (messaggi gia' divisi su <05>). Ritorna {(a,b): id_tile}."""
    from charmap_it import IT
    ids = list(FREE_IDS if ids is None else ids)
    used = set(IT.values())
    assert not (set(ids) & used), "FREE_IDS in conflitto con la charmap: %s" % sorted(set(ids) & used)
    freq = {}
    for line in lines:
        first = True
        for is_txt, r in _runs(line):
            if is_txt:
                for p in _pair_candidates(r, _lead(line) if first else 0):
                    freq[p] = freq.get(p, 0) + 1
            first = False
    best = sorted(freq.items(), key=lambda kv: (-kv[1], kv[0]))[:len(ids)]
    return {p: ids[i] for i, (p, _) in enumerate(best)}


def cells(line, alloc):
    """Codifica della riga: lista di celle, ognuna ('c', carattere) oppure ('p', a, b); i token restano ('t', token)."""
    out = []
    first = True
    for is_txt, r in _runs(line):
        if not is_txt:
            out.append(("t", r)); first = False; continue
        lead = _lead(line) if first else 0
        n = len(r)
        INF = 10 ** 9
        best = [INF] * (n + 1); nxt = [None] * (n + 1)
        best[n] = 0
        for i in range(n - 1, -1, -1):
            best[i], nxt[i] = 1 + best[i + 1], 1
            if i >= lead and i + 1 < n and (r[i], r[i + 1]) in alloc and 1 + best[i + 2] < best[i]:
                best[i], nxt[i] = 1 + best[i + 2], 2
        i = 0
        while i < n:
            if nxt[i] == 2:
                out.append(("p", r[i], r[i + 1])); i += 2
            else:
                out.append(("c", r[i])); i += 1
        first = False
    return out


def text_width(line, alloc):
    """Colonne (celle) occupate da `line`: come text_wrap.width ma con le coppie. Token: $n = 4, <XX> = 1."""
    w = 0
    for c in cells(line, alloc):
        if c[0] == "t":
            t = c[1]
            w += 4 if t.startswith("$") else 1 if re.fullmatch(r"<[0-9A-F]{2}>", t) and t not in ("<05>", "<5E>") else 0
        else:
            w += 1
    return w


def alloc_from_dialog(path):
    """Alloca le coppie dal testo dei dialoghi (it.tsv non ancora riflusso)."""
    lines = []
    for l in open(path, encoding="utf-8"):
        p = l.rstrip("\n").split("\t")
        if len(p) >= 2 and p[0] != "id":
            lines += p[1].split("<05>")
    return build_alloc(lines)


def patch_pair_glyphs(data, prg_size, alloc):
    chr0 = 16 + prg_size
    for (a, b), tid in alloc.items():
        g = pair_glyph(a, b)
        for half, bank in ((0, 60), (1, 61)):
            o = chr0 + bank * 4096 + tid * 16
            for y, byte in enumerate(g[half * 8:half * 8 + 8]):
                data[o + y] = byte
                data[o + 8 + y] = byte
    return len(alloc)


if __name__ == "__main__":
    src = sys.argv[1] if len(sys.argv) > 1 else "text/it.tsv"
    al = alloc_from_dialog(src)
    tot = cnt = 0
    for l in open(src, encoding="utf-8"):
        p = l.rstrip("\n").split("\t")
        if len(p) < 2 or p[0] == "id":
            continue
        for line in p[1].split("<05>"):
            tot += text_width(line, {}); cnt += text_width(line, al)
    print("coppie allocate: %d/%d; colonne totali %d -> %d (%.1f%% in meno)" % (len(al), len(FREE_IDS), tot, cnt, 100.0 * (tot - cnt) / max(tot, 1)))
    for p, i in list(al.items())[:12]:
        print("  %r -> %02X" % ("".join(p), i))
