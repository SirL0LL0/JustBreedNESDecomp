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
- [x] Entry vectors identified: NMI=$E143, RESET=$E000, IRQ=$E2C4
- [x] RESET routine at $E000 disassembled (MMC5 init, EXATTR mode)
- [ ] NMI handler at $E143
- [ ] IRQ handler at $E2C4 (MMC5 scanline IRQ)
- [ ] Full PRG-ROM disassembly with labels
- [ ] Data tables (text banks, tilemaps, enemy stats, map data)
- [ ] Byte-perfect re-build of the original ROM

See [docs/ROADMAP.md](docs/ROADMAP.md) and [docs/NOTES.md](docs/NOTES.md) for details.

## Requirements

- [cc65](https://github.com/cc65/cc65) (ca65/ld65) â€” the 6502 assembler toolchain
- Python 3 (only for the ROM extraction script)
- A legally obtained ROM of Just Breed (Japan), SHA-1: 516264328536F3D21594A0EC761A7EAA54CDD0DB

## Build

~~~bash
# 1. Place your ROM at rom/justbreed.nes (git-ignored)
cp "/path/to/Just Breed (Japan).nes" rom/justbreed.nes

# 2. Extract PRG/CHR banks from the ROM
python3 tools/extract_rom.py rom/justbreed.nes build/

# 3. Assemble back into a .nes file
make
~~~

The output is `build/justbreed_built.nes`. Once the disassembly is complete,
this must be **byte-identical** to the original ROM.

## Repository layout

~~~
asm/          6502 assembly sources (ca65 syntax)
asm/banks/    one .s file per 16 KB PRG bank
docs/         notes, roadmap, MMC5 documentation
tools/        extraction & verification scripts
Makefile      build orchestration
~~~

## Legal

Just Breed Â© 1992 Enix (today Square Enix). Character design Yuzo Takada, music Kohei Tanaka.
This is a non-profit, fan-made reverse-engineering effort for preservation and study.
No ROMs, no copyrighted data files are included. If the copyright holder objects,
this repository will be taken down.

## Credits

- [NESdev Wiki](https://www.nesdev.org/wiki/) â€” hardware and MMC5 documentation
- [cc65](https://github.com/cc65/cc65) project
- The NES decompilation community (SMB, LoZ, and other disassembly projects) for methodology
