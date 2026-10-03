# Working notes â€” Just Breed

## ROM di riferimento
- baserom_jp.nes â€” SHA-1 516264328536F3D21594A0EC761A7EAA54CDD0DB
- Header: 4E 45 53 1A 20 20 52 08 (iNES 2.0, mapper 5)
- Vettori: NMI=$E143, RESET=$E000, IRQ=$E2C4

## Architettura (banco $1F, layout 8K-slot MMC5)
- MMC5 PRG mode 3, slot da 8K: $5114->$8000, $5115->$A000, $5116->$C000, $5117->$E000
- Valori: $FC/$FD = banco $1E (1a/2a meta), $FE/$FF = banco $1F (1a/2a meta)
- Trampolini: JSR $EB9C (window $8000 = A, shadow RAM $BC), JSR $EB96 ($A000, RAM $BD)
- sub_EB80/$EB8D: save/restore contesto finestre
- Main loop: $C000 (banco $1F prima meta), raggiunto con JMP da RESET ($E0BC)
- IRQ ($E2C4): sistema split-screen multi-scanline, tabelle dispatch a $E228/$E25D
- NMI: contatore frame $52 usato INC/DEC come semaforo; CLI interno; driver audio a $ED1F+
- Driver save/load WRAM: $EBA5/$EBE8

## Stato decompilazione
- RESET disassemblato e verificato ($E000-$E0BC)
- NMI completo ($E143-$E204)
- IRQ completo ($E2C4-$E33C)
- Scheletro automatico: 13.108 byte di codice individuati (banco $1E: 6167, $1F: 6306)
- Banchi $00-$1D: dati (testo/mappe/tabelle) salvo piccole routine contestuali

## Strumenti
- tools/auto_disasm.py v3: discesa ricorsiva MMC5-aware, punto fisso, 2 layout ($1F fisso)
- tools/trace_banks.py: static scan dei punti di bank-switch
- tools/verify_skeleton.py: ri-assembla lo scheletro e verifica byte-perfect

## Prossimi passi
- [ ] verify_skeleton: portare i 32 banchi a PERFECT
- [ ] Annotare: nomi reali alle routine (main loop $C000, dispatcher, CHR-compute $A757, audio $ED1F)
- [ ] Identificare banche dati: charset testo (kana), tabelle mappe, stats nemici
- [ ] Build byte-perfect con ca65/ld65 (config gia' pronto)
