# Editor offline e VWF

## Uso
```
python tools/editor.py
```
Serve Python 3 con Tkinter (incluso nell'installer ufficiale per Windows). I sorgenti della traduzione sono in `text/`
(`it.tsv`, `ui_it.tsv`, `tables_it.tsv`, `narrow_glyphs.json`), esclusi da git perche' derivati dal testo originale.
`baserom_jp.nes` deve stare nella cartella del progetto.

- **Costruisci ROM**: salva, riflusso automatico (`text_wrap.py`), `build_it.py` -> `build_rom/jb_it_preview.nes`.
- **Avvia nel launcher**: costruisce e apre la ROM nel runner (`build_ui/JustBreedRecomp.exe`, con `JB_ANY_ROM=1`).
- **Esporta ROM (hardware)**: copia la ROM iNES (mapper 5, 768 KB, stessa dimensione dell'originale). Su hardware reale
  serve una cartuccia/flash cart con MMC5 e 8 KB di WRAM con batteria (es. EverDrive N8 Pro).
- **Esporta patch IPS**: differenza rispetto alla ROM giapponese, per distribuire la traduzione senza ROM
  (`python tools/ips.py baserom_jp.nes build_rom/jb_it_preview.nes out.ips` da riga di comando).

## VWF statico (`tools/vwf.py`)
Il CHR e' ROM, quindi il testo non si compone a runtime. Il build fonde i caratteri stretti consecutivi
(spazio, `i l t r f j . , ' : ; !`, glifi da 4 px) in un unico tile 8x16 ("coppia"); ogni coppia usata prende un ID libero
(kana giapponesi non piu' usati, `FREE_IDS`) e viene disegnata nei banchi CHR 60/61. Nessuna modifica al codice del gioco.
Le coppie sono scelte per frequenza dal testo di `it.tsv` (max 91). Il riflusso e il controllo delle colonne contano
le celle, non i caratteri. Le stringhe dei menu e le tabelle NON usano VWF (hanno layout a colonne fisse).
Risparmio misurato sui primi 64 messaggi: ~10% di colonne.
