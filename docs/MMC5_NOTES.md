# MMC5 notes for Just Breed

## Conferme dal disassembly del RESET ($E000)
- PRG mode 3 ($5100=$03): $8000/$A000/$C000 switchable, $E000 fisso = banco $1F
- CHR mode 3 ($5101=$03): 4K+2K+1K switchable
- EXATTR mode ON ($5104=$01): attributi estesi per-tile â€” raro! Usato per colori nel battle HUD
- Mirroring verticale ($5105=$44)
- Banco $C000 = $FE, banco $E000 = $FF
- WRAM protect $5102=$02/$5103=$01 (unlock), WRAM bank 0 a $6000
- IRQ scanline off inizialmente ($5204=$40... poi $00) â€” il gioco lo riattivera' per il HUD
- Canali audio extra off all'avvio ($5010), il driver li gestisce dopo

## Key MMC5 registers
| Addr         | Function |
|--------------|----------|
| $5100-$5101  | PRG / CHR bank mode |
| $5102-$5103  | WRAM write protect |
| $5113        | WRAM bank at $6000 |
| $5114-$5117  | PRG banks ($8000, $A000, $C000, $E000) |
| $5120-$512B  | CHR banks (BG + sprite) |
| $5130        | CHR bank upper bits |
| $5200-$5203  | Vertical split screen |
| $5204        | IRQ enable; $5205-$5206 = scanline counter 16-bit |
| $5010, $5015 | Extra sound: 2 square channels + PCM |

## Curiosita' dal dump
- Alla fine del banco $1F (offset $3FF0): firma ASCII "JUSTBREED" + metadati
  (54 04 01 08 B4 ...) â€” probabile integrita' o info toolchain originale.

References: NESdev Wiki â€” https://www.nesdev.org/wiki/MMC5
