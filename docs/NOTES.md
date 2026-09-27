# Working notes â€” Just Breed

## ROM di riferimento
- baserom_jp.nes â€” SHA-1 516264328536F3D21594A0EC761A7EAA54CDD0DB
- Header: 4E 45 53 1A 20 20 52 08 (iNES 2.0, mapper 5)
- Vettori: NMI=$E143, RESET=$E000, IRQ=$E2C4

## Architettura scoperta (banco $1F)

### RESET ($E000)
- Init standard NES + MMC5: PRG mode 3, CHR mode 3, EXATTR ON ($5104=$01)
- Mirroring verticale, WRAM protect unlock, bank $C000=$FE, $E000=$FF
- EXATTR = attributi estesi per-tile MMC5, usato da pochissimi giochi

### NMI ($E143-$E202) â€” frame heartbeat
- INC $52: frame counter
- CHR banking dinamico: flag $E5 -> JSR $A757/$AFCD (banco $1E) calcolano
  i banchi CHR e li caricano da RAM $83-$8A nei registri $5120-$5127
  ogni frame -> tile animati (acqua, fuoco, nidi mostri)
- HUD update condizionale: flag $53 -> JSR $E25D
- CLI dentro NMI: interrupt riattivati nel vblank (timing tecnica)
- OAM DMA: JSR $E908
- Joypad: JSR $E205
- Main logic hook: JSR $A22E (banco $1E, mappato a $8000)
- Attesa IRQ scanline MMC5: BIT $5204 / BVC loop
- Split screen verticale: flag $62 -> JSR $E7A0 (registro $5200-$5203)
- Battery save: JSR $EBE8 se flag $69 e non $0402
- RE-BANKING: LDA #$FE / STA $5116 -> banco $C000 diventa $1E,
  poi JSR $D1BE e dispatcher JSR $C1C5 con X=$10
- Music tick: JSR $EACE (driver APU + 2 canali extra MMC5)

### Pattern chiave
- Il banco $1E e' il "game logic bank": mappato a $C000 dal NMI
- Flag RAM: $52 frame, $53 HUD, $62 split, $63 ?, $69 save, $E5 CHR,
  $83-$8A CHR bank numbers, $BC/$BD puntatori (NPC/oggetti?)
- Stack helpers: $EB9C/$EB96 (push/pop frame bank?)

### Curiosita'
- Firma "JUSTBREED" ASCII + metadati a fine banco $1F (offset $3FF0)
- Nel banco $1E (extraction by mistake): dispatcher a jump table a $C153,
  loop su 6 unita' (Team Spirits: 6 comandanti x 6 soldati = 36 unita')

## Prossimi estratti
- $E203-$E2C3 (utility NMI area)
- IRQ $E2C4-$E3xx (scanline split HUD)
- Banco $1E: main loop, dispatcher $C1C5, jump table $C153
