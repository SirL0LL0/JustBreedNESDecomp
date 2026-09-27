# Roadmap

## Phase 0 â€” Scaffolding
- [x] Repo structure, build system, MMC5 linker config
- [x] ROM extraction / verification tooling
- [x] Dump verificato: mapper 5, 32 PRG + 32 CHR, SHA-1 516264328536F3D21594A0EC761A7EAA54CDD0DB

## Phase 1 â€” Static analysis (current)
- [x] Vettori identificati: NMI=$E143, RESET=$E000, IRQ=$E2C4 (banco $1F)
- [x] RESET disassemblato: init PPU, clear RAM, setup MMC5 (PRG mode 3, EXATTR on)
- [ ] NMI handler $E143 (disassemblare ~ fino a IRQ)
- [ ] IRQ handler $E2C4 (MMC5 scanline IRQ â€” probabilmente split screen battle HUD)
- [ ] Firma "JUSTBREED" + metadati alla fine del banco $1F (offset $3FF0): capire a cosa servono
- [ ] Scrittura MMC5 ($5114-$5115): quali banchi switcha a $8000/$A000
- [ ] Mappa uso RAM $0000-$07FF + WRAM $6000-$7FFF

## Phase 2 â€” Labeled disassembly
- [ ] Un file ca65 per ogni banco PRG 16 KB, byte-perfect
- [ ] Routine chiave: main loop, joypad, PPU update, OAM DMA
- [ ] Battle engine ("Team Spirits")
- [ ] Map/town engine, text engine (encoding giapponese -> table file)
- [ ] Sound driver (2 canali extra MMC5 + APU)

## Phase 3 â€” Data tables
- [ ] Text banks, map data, stats nemici, items, level-up
- [ ] Organizzazione CHR/EXATTR

## Phase 4 â€” Deliverables
- [ ] Re-build byte-perfect completo
- [ ] Documentazione engine
- [ ] Fork traduzione inglese (base partendo dal patch Stealth Translations)

## Stretch goal â€” static recomp
NESRecomp non supporta MMC5 (mapper 0,1,4,66 oggi). Se arriva il supporto,
il disassembly etichettato della Phase 2 diventa l'input ideale per una recomp nativa.
