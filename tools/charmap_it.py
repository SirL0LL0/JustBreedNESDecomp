"""Mappa dei caratteri italiani di Just Breed: carattere -> ID tile (il byte che finisce nel testo).

Il font dei dialoghi sta nei banchi CHR 60 (meta' alta) e 61 (meta' bassa): tile N = glifo 8x16 del codice N.
Le lettere latine sostituiscono i glifi kana (ID 0x71-0x9F, 0xB1-0xCA); i codici che il decoder o il motore usano
come comandi (00-04, 60-63, 59, 5A, 5B, 5E, 49, 4C ...) non vengono mai usati come lettere, e le icone del gioco
(HP, G, L, X a 0x27/0x2C/0x3B/0x3D/0x1F) restano dove sono.
"""

IT = {}


def _put(start, chars):
    for i, c in enumerate(chars):
        IT[c] = start + i


_put(0x71, "abcdefghijklmnopqrstuvwxyz")
_put(0x8B, "àèéìòù")
_put(0x91, "ÈÉÀÌÒÙ")
IT[","] = 0x97
IT["'"] = 0x98
IT[";"] = 0x9A
IT["“"] = 0xA2          # “  (sostituisce il glifo 「)
IT["”"] = 0xA3          # ”  (sostituisce il glifo 」)
_put(0xB1, "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

# caratteri con glifo gia' presente e ID = ASCII (non si ridisegnano)
for c in " !\"#$%&()*+-./0123456789:<>?":
    IT[c] = ord(c)

# glifi da (ri)disegnare dal font Unscii: ID -> carattere Unicode
DRAW = {v: k for k, v in IT.items() if v not in range(0x20, 0x40)}
# cifre e punteggiatura gia' presenti nel font originale: ridisegnate in Unscii per uniformare lo stile
# (esclusi 0x27/0x2C/0x3B/0x3D = icone HP/G/L/X e gli ID usati come comandi)
for _c in "0123456789!?.:-()*+/%&":
    DRAW[ord(_c)] = _c


def encode_text(s, alloc=None):
    """Stringa italiana (con token <XX>, {cc:pp}) -> byte grezzi del messaggio.
    alloc = {(a,b): id_tile}: attiva le celle a larghezza variabile (vedi vwf.py); solo per i dialoghi."""
    import re
    if alloc:
        import vwf
        out = bytearray()
        for n, line in enumerate(s.split("<05>")):
            if n:
                out.append(0x05)
            for c in vwf.cells(line, alloc):
                if c[0] == "c":
                    out.append(IT[c[1]])
                elif c[0] == "p":
                    out.append(alloc[(c[1], c[2])])
                else:
                    out += encode_text(c[1])
        return bytes(out)
    out, i = bytearray(), 0
    tok = re.compile(r"<([0-9A-F]{2})>|\{([0-9A-F]{2}):([0-9A-F]{2})\}")
    while i < len(s):
        m = tok.match(s, i)
        if m:
            if m.group(1):
                out.append(int(m.group(1), 16))
            else:
                out += bytes([int(m.group(2), 16), int(m.group(3), 16)])
            i = m.end()
            continue
        c = s[i]
        if c not in IT:
            raise ValueError("carattere non mappato %r in %r" % (c, s[:60]))
        out.append(IT[c])
        i += 1
    return bytes(out)          # il terminatore 00 lo aggiunge il codificatore (hufpack.tokenize)
