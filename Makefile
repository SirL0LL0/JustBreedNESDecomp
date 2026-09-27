# Just Breed (Famicom) â€” MMC5, 512 KB PRG (32 banks x 16 KB), 256 KB CHR
# Assembled with ca65/ld65. make â€”> build/justbreed_built.nes

AS      := ca65
LD      := ld65
ROM     := rom/justbreed.nes
OUTDIR  := build
TARGET  := $(OUTDIR)/justbreed_built.nes

BANK_SRC := $(wildcard asm/banks/*.s)
BANK_OBJ := $(patsubst asm/banks/%.s,$(OUTDIR)/%.o,$(BANK_SRC))

ASFLAGS := -t nes -I asm/
LDFLAGS  := -m $(OUTDIR)/map.txt -Ln $(OUTDIR)/labels.txt

.PHONY: all clean extract verify

all: $(TARGET)

extract: $(OUTDIR)
	python3 tools/extract_rom.py $(ROM) $(OUTDIR)

$(OUTDIR)/%.o: asm/banks/%.s | $(OUTDIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(OUTDIR)/header.o: asm/header.s | $(OUTDIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(TARGET): $(OUTDIR)/header.o $(BANK_OBJ)
	$(LD) -C config/nes.cfg $(LDFLAGS) -o $@ $^

verify: $(TARGET)
	python3 tools/verify_rom.py $(ROM) $(TARGET)

$(OUTDIR):
	mkdir -p $(OUTDIR)

clean:
	rm -rf $(OUTDIR)
