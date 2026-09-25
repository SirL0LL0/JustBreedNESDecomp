# Just Breed (NES, MMC5) - reverse engineering e ricompilazione

Stato del lavoro e strada verso un sorgente completo, compilabile in autonomia.
Nessun dato della ROM e' in questo repository: tutto il codice derivato si rigenera con `python tools/regen.py`.

## Pipeline

| Passo | Strumento | Prodotto | Verifica |
|---|---|---|---|
| Copertura | runner (`NESRECOMP_COV_FILE`), `tools/explore.py`, `tools/coverage.py`, `tools/cov_merge.py` | `analysis/all.bin` | - |
| Disassemblaggio | `tools/disasm.py` (analisi a livelli, argomenti inline, far call, tabelle, emulazione dei siti) | `disasm/unitNN.asm` | `tools/asm_verify.py`: si riassembla identico alla ROM |
| Blocchi tradotti | `tools/mmc5_blocks.py` | `generated/blocks` | stessa esecuzione dell'interprete; hash dei byte per ROM patchate |
| Decompilazione | `tools/decompile.py` + `decomp_emit.py` + `decomp_names.py` | `generated/decomp` (eseguibile), `generated/decomp_r` (leggibile) | `tools/decomp_check.py`, `NESRECOMP_BOUNDARY_LOG` + `tools/seqdiff.py` |
| Nomi | `analysis/symbols.tsv` (a mano) + euristiche | nomi di variabili/funzioni | - |

## Dove gira il codice (sessione di prova, ROM italiana)

`[where]` a fine esecuzione: circa 64% in funzioni C decompilate, 26% in blocchi tradotti, 10% nell'interprete
(quasi tutto controllo di flusso dentro le "isole": routine con argomenti inline, tabelle di salto, indirizzi di ritorno
manipolati). `NESRECOMP_INTERP_HIST=N` elenca le istruzioni interpretate piu' frequenti.

## Cosa manca per l'autonomia (nessun interprete, nessuna decodifica a run time)

1. **Isole -> C.** Le routine che leggono byte dopo la JSR (`far_call`, `read_inline_byte`, `print_inline_string`, le
   tabelle di salto inline) e le ~127 routine "hard" (TSX/TXS, RTS come salto) vanno tradotte in C con la pila
   modellata a parte: l'indirizzo di ritorno come variabile, non come dato sulla pila 6502. Con la firma dei registri
   (`tools/decompile.py` la calcola) `far_call(unit, funzione)` diventa una vera funzione.
2. **Copertura completa.** Il codice mai eseguito ne' raggiunto dall'analisi statica (stima: ~5% del codice giocato,
   piu' le zone mai giocate) e' l'unica cosa che l'interprete copre oggi. Serve: piu' esplorazione (`tools/explore.py`),
   piu' scoperte statiche, e una modalita' "strict" che segnala ogni salto verso codice non tradotto.
3. **Dati.** Tabelle (mappe, testi, grafica, musica) restano nella ROM dell'utente; vanno descritte con formato e
   puntatori (le tabelle di testo e i nomi sono gia' estratti da `tools/build_it.py`).
4. **Timing.** Oggi ogni istruzione chiama `NB_STEP` (NMI/IRQ esatti). Il sorgente leggibile non lo fa: per compilarlo
   direttamente servono punti di campionamento espliciti (cicli, attese del vblank) e collaudo a livello di comportamento.
5. **Leggibilita'.** Parametri/ritorni per registro (fatto come commento e argomenti nominati), propagazione delle
   copie, nomi per le variabili (da `analysis/symbols.tsv`).

## Strumenti di collaudo

* `python tools/decomp_check.py build_x <rom> --frames 3000 --seeds 3`: stato finale identico all'interprete.
* `NESRECOMP_BOUNDARY_LOG=file,N` + `python tools/seqdiff.py a b [--notop]`: prima istruzione che diverge.
* `NESRECOMP_DECOMP_VERIFY=N`: confronto per chiamata (C contro interprete) dallo stesso stato.
* `NESRECOMP_DECOMP=0`, `NESRECOMP_BLOCKS=0`: escludono decompilato / blocchi.
