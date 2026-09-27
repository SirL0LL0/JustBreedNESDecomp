# JustBreedRecomp

Porting nativo per PC di Just Breed (NES, giapponese), con una traduzione italiana completa applicata alla ROM
in fase di build. Gira sul **backend cycle-accurate di nesrecomp** (upstream, `runner/cyc`): ogni istruzione
della ROM e' ricompilata in C ciclo per ciclo su una macchina NES cycle-accurate (CPU, PPU, APU, MMC5 con
ExRAM, moltiplicatore, IRQ a scanline). Il codice non ancora incontrato gira sull'interprete della stessa
macchina (identico ciclo per ciclo, solo piu' lento): non e' un'emulazione approssimata.

Sopra c'e' il livello applicazione del fork (`nesrecomp/runner/cyc/app`, branch `cycle-app`): launcher
grafico, menu di gioco, mod (cheat), salvataggi di stato. Di questo repository restano solo l'identita' del
gioco (`game.c`), i cheat (`cheats.c`) e **tutto il lavoro di traduzione** (`text/`, `tools/`, `assets/`,
`docs/`).

## Compilare e giocare

```
git clone --recurse-submodules <url di questo repo>
python tools/build_it.py baserom_jp.nes text/it_wrapped.tsv build_rom/jb_it_preview.nes
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
build\JustBreedRecomp.exe                              # launcher (recomp-ui): scegli la ROM, Mod, Gioca
build\JustBreedRecomp.exe build_rom\jb_it_preview.nes   # senza launcher
```

`baserom_jp.nes` (Just Breed, Giappone) non e' incluso: procurati la tua copia legale. CMake cerca
`./nesrecomp` e `./recomp-ui` (submodule); in alternativa `-DNESRECOMP_ROOT=...` e `-DRECOMP_UI_ROOT=...`.
Serve Python 3.11+ (la generazione del codice avviene durante la configurazione).

Il riconoscimento della ROM (launcher e mod) non usa il CRC32 dell'intero file, perche' cambia a ogni build
della traduzione: usa il CRC32 del banco fisso 62, mai toccato dalla patch italiana (vedi `cheats.c`).

## Controlli, cheat, salvataggi di stato

Uguali a Castlevania3Recomp (stesso livello applicazione): Esc apre il menu di gioco (schermo, grafica, audio,
salva/carica stato), F1-F12 carica lo slot, Maiusc+F1-F12 salva lo slot (`savestates/`, accanto all'exe), Tab
avanti veloce, Ctrl+F11 overlay con le statistiche (nativo/interprete), Ctrl+F12 screenshot.

I cheat sono in `mods/packages/justbreed.cheats` (18 codici RAM: vite/PM/oro/esperienza dei 6 personaggi,
nemici senza salute) e si attivano dalla pagina **Mod** del launcher.

## Il lavoro di traduzione

| Cartella | Contenuto |
|----------|-----------|
| `text/` | **la traduzione stessa.** `dialog_jp.tsv`/`inline_jp.tsv` (testo giapponese estratto), `it.tsv` (la nostra traduzione, id -> italiano), `it_wrapped.tsv` (impaginata, quella che legge `build_it.py`), `tables_it.tsv`/`monsters_it.tsv`/`ui_it.tsv`/`intro_it.tsv` (nomi, interfaccia, intro) |
| `tools/` | pipeline di estrazione/traduzione/verifica (vedi sotto) e il disassemblatore/decompilatore usati per trovare nuovo testo |
| `assets/` | font Unscii (pubblico dominio) patchato nella ROM al posto dei kana |
| `docs/` | `script_codes.md` (i comandi inline del testo), `REVERSE_ENGINEERING.md`, `editor.md` |
| `analysis/all.bin` (+ `.ram`/`.win`/`.wramw`) | copertura del codice unita da tutte le sessioni di gioco/esplorazione: dice quali indirizzi sono codice eseguito, base per trovare nuovo testo e per `cycle_seeds.txt` |

Pipeline principale (vedi i docstring dei singoli script per i dettagli):

```
tools/dialog_decode.py       decodifica i messaggi di dialogo (l'interprete Huffman del gioco, via py65)
tools/text_wrap.py           impagina text/it.tsv -> text/it_wrapped.tsv (26 colonne, 4 righe, interruzioni pagina)
tools/text_check.py          verifica lunghezze/token prima di costruire la ROM
tools/build_it.py            costruisce la ROM: font, tabelle nomi, dialoghi, interfaccia (vedi sopra)
tools/disasm.py              disassembla la ROM usando analysis/all.bin come copertura (trova funzioni/tabelle)
tools/inline_strings.py      trova stringhe non ancora catalogate (pattern: dopo una routine di stampa nota)
tools/coverage.py            merge/report della copertura (CDL Mesen + jb_exec.bin -> analysis/all.bin)
```

**Stato (verificato di persona, non dalla memoria di sessioni precedenti):** dialoghi 1816/1994 messaggi
tradotti (i restanti 178 sono solo comandi, senza testo); le 83 stringhe di interfaccia del banco 58 sono
tutte gestite (43 tradotte, le altre 40 sono formattazione pura o sigle gia' latine tipo `HP`/`MP`/`LV`);
tabelle nomi (298 righe: oggetti/magie/luoghi/personaggi) e nomi mostri (80 righe) presenti. Il codice
disassemblato copre il 15.7% della ROM: schermate mai visitate (risultati di battaglia, negozio) potrebbero
avere testo non ancora trovato. Il font a larghezza variabile (`tools/vwf.py`) e' ancora abbozzato.

## Copertura del codice nativo (opzionale)

`cycle_seeds.txt` elenca gli indirizzi da compilare in codice nativo (18379, dalla vecchia copertura). Il
resto funziona lo stesso, sull'interprete, solo piu' lento. Per ampliarla giocando: crea un file vuoto
`miss.on` accanto all'exe; all'uscita scrive `cycle_seeds_played.txt` (si accumula tra le sessioni).
