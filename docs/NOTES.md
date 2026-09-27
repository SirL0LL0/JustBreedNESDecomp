# Working notes â€” Just Breed

## ROM di riferimento
- baserom_jp.nes â€” SHA-1 516264328536F3D21594A0EC761A7EAA54CDD0DB
- Header: 4E 45 53 1A 20 20 52 08 (iNES 2.0, mapper 5, PRG 32x16K, CHR 32x8K)
- Vettori: NMI=$E143, RESET=$E000, IRQ=$E2C4

## Trovato finora
- RESET ($E000): vedi asm/banks/bank_1f.s â€” init standard + MMC5 con EXATTR attivo
- Dump troncato a $E07F su "A9 01 8D 04 [51]" â€” proseguire da li'

## Prossimi estratti da richiedere
- $E080-$E142 (fine RESET + gap fino a NMI)
- $E143-$E2C3 (NMI handler completo)
- $E2C4-$E3xx (inizio IRQ handler)
