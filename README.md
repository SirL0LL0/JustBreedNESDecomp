# Just Breed (NES) â€” Disassembly Project

A disassembly / decompilation project for **Just Breed** (ã‚¸ãƒ£ã‚¹ãƒˆãƒ–ãƒªãƒ¼ãƒ‰), the tactical RPG
published by Enix for the Family Computer in 1992, developed by Random House.

> [!CAUTION]
> This repository contains **no copyrighted game assets**. You must provide your own
> legally dumped ROM. The build process extracts code and data from your ROM at build time.

## Why Just Breed?

- One of the largest Famicom RPGs ever made: **6 Mbit** (768 KB PRG+CHR)
- Uses the **MMC5** mapper (mapper 5) â€” Nintendo's most elaborate mapper ASIC â€” for
  enhanced graphics and two extra sound channels
- Never released outside Japan (an unofficial English patch by Stealth Translations exists)
- No public disassembly existed â€” this project aims to fix that

## Progress

- [x] Repository structure & build system (ca65/ld65)
- [x] ROM extraction tooling (32 PRG + 32 CHR banks, mapper 5 verified)
- [x] Entry vectors: NMI=$E143, RESET=$E000, IRQ=$E2C4
- [x] RESET ($E000) disassembled â€” MMC5 init, EXATTR mode ON
- [x] NMI ($E143-$E202) disassembled â€” CHR dynamic banking, HUD, split screen, battery save, music hook
- [ ] IRQ handler ($E2C4) â€” MMC5 scanline
- [ ] Bank $1E: main loop + dispatcher (jump table at $C153)
- [ ] Full PRG-ROM disassembly with labels
- [ ] Data tables (text banks, tilemaps, enemy stats, map data)
- [ ] Byte-perfect re-build of the original ROM

See [docs/ROADMAP.md](docs/ROADMAP.md) and [docs/NOTES.md](docs/NOTES.md).

## Requirements

- [cc65](https://github.com/cc65/cc65) (ca65/ld65)
- Python 3
- A legally obtained ROM of Just Breed (Japan), SHA-1: 516264328536F3D21594A0EC761A7EAA54CDD0DB

## Build

~~~bash
cp "/path/to/Just Breed (Japan).nes" rom/justbreed.nes
python3 tools/extract_rom.py rom/justbreed.nes build/
make
~~~

## Legal

Just Breed Â© 1992 Enix (today Square Enix). Character design Yuzo Takada, music Kohei Tanaka.
Non-profit fan reverse-engineering for preservation and study. No ROMs included.
