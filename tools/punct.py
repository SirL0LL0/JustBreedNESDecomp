#!/usr/bin/env python3
"""Aggiunge i punti fermi mancanti nelle traduzioni (il giapponese separa le frasi con spazi e a capo, l'italiano no).

  python tools/punct.py [text/it.tsv]        # riscrive il file (idempotente)

Regole (solo dentro il testo, mai sui comandi del motore):
  * "lettera <05> [<5E><05>] Maiuscola"  -> punto dopo la lettera, se la parola maiuscola NON e' un nome proprio noto;
  * "lettera <05><5E>"  (fine pagina)     -> punto;
  * "lettera”"                            -> nessuna modifica (le virgolette chiudono da sole).
"""
import re, sys, os

PROPER = set("""Astholm Shoros Segaltea Filis Elen Karen Loran Orlov Hans Duval Lidia Isaac Tifa Cosette Cecil Lina Jisfandel
Fillossera Gel Marle Penta Scapan Borne Rutom Irondel Albani Grachesca Milton Dalbia Bajad Esencia Sequet Barn Tsungal
Rambulvil Winga Susandna Muraglia Banyuls Messalia Cassalia Mare Keafner Jarmy Pierre Sekol Zaffiro Smeraldo Cristallo
Ametista Gigante Saggi Saggio Harem Boss Kurnas Hausen Henyamul Sandworm Capo Marei Gilan Elk Lenny Mori Jumbo Max Ka
Rubino Lapislazzuli Kyaa Ehi Oh Ah Eh Uh Ihih Mmm Mmh Uffa Wow Su Ecco Bene Allora Certo Ma Se Non Sì Sono Che Quel Quella
Quello Ora Sarà Come Perché Poi Dove Chi Cosa Cosa? Quando Sei Hai Ho Ha Siamo Vi Ti Mi Ci Lo La Le Li Il I Un Una""".split())
# le parole "normali" sopra (Ma, Se, Non, ...) NON devono ricevere il punto prima di se' solo quando iniziano una frase nuova:
# per questo nella regola sotto si escludono soltanto i nomi propri veri (tutti quelli fino a Ka, piu' Rubino/Lapislazzuli).
NAMES = set("""Astholm Shoros Segaltea Filis Elen Karen Loran Orlov Hans Duval Lidia Isaac Tifa Cosette Cecil Lina Jisfandel
Fillossera Gel Marle Penta Scapan Borne Rutom Irondel Albani Grachesca Milton Dalbia Bajad Esencia Sequet Barn Tsungal
Rambulvil Winga Susandna Muraglia Banyuls Messalia Cassalia Mare Keafner Jarmy Pierre Sekol Zaffiro Smeraldo Cristallo
Ametista Gigante Saggi Saggio Harem Boss Kurnas Hausen Henyamul Sandworm Capo Marei Gilan Elk Lenny Mori Jumbo Max
Rubino Lapislazzuli""".split())

PAT = re.compile(r"([a-zàèéìòù])(<05>(?:<5E><05>)?)( ?)([A-ZÈÉÀÌÒÙ][a-zàèéìòùA-Z']*)")


def fix(s):
    m0 = re.search(r"%\d+<05>", s)          # dopo "%n" iniziano le voci di una scelta: non sono frasi
    if m0:
        return fix(s[:m0.start()]) + s[m0.start():]

    def rep(m):
        prev, nl, sp, word = m.groups()
        if word in NAMES:
            return m.group(0)
        return prev + "." + nl + sp + word
    out = PAT.sub(rep, s)
    # fine pagina dopo lettera: "<5E>" preceduto da lettera e <05>
    out = re.sub(r"([a-zàèéìòù])(<05><5E>)", r"\1.\2", out)
    return out


if __name__ == "__main__":
    p = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "text", "it.tsv")
    lines = open(p, encoding="utf-8-sig").read().split("\n")
    n = 0
    for i, l in enumerate(lines):
        parts = l.split("\t")
        if len(parts) >= 2 and parts[0] != "id":
            new = fix(parts[1])
            if new != parts[1]:
                n += 1
                parts[1] = new
                lines[i] = "\t".join(parts)
    open(p, "w", encoding="utf-8", newline="\n").write("\n".join(lines))
    print("messaggi modificati:", n)
