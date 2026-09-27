; =============================================================
; PRG bank $1F â€” fixed at $E000-$FFFF (MMC5 PRG mode 3)
; Entry points: RESET=$E000, NMI=$E143, IRQ=$E2C4
; Disassembled: RESET ($E000-$E0xx), NMI ($E143-$E202)
; TODO: IRQ ($E2C4), resto del banco
; =============================================================
.segment "CODE31"

    ; ---- $C000-$DFFF: not yet disassembled (bank $1E maps here at runtime!)
    .res $2000

; -------------------------------------------------------------
; RESET â€” $E000
; Init PPU, clear RAM, setup MMC5. Verified against dump.
; -------------------------------------------------------------
RESET:
    SEI
    CLD
    LDA #$00
    STA $2000              ; NMI off during init
    LDA $2002
@w1: BPL @w1
    LDA $2002
@w2: BPL @w2
    LDA $2002
@w3: BPL @w3               ; 3x vblank wait
    LDA #$00
    STA $2001              ; rendering off

; --- clear RAM $0000-$07FF ($0200 = OAM buffer) ---
    LDX #$00
@clr:
    STA $0000,X
    STA $0100,X
    STA $0200,X
    STA $0300,X
    STA $0400,X
    STA $0500,X
    STA $0600,X
    STA $0700,X
    INX
    BNE @clr
    LDX #$FF
    TXS

; --- PPU / APU ---
    LDA #$08
    STA $2000              ; NMI on
    LDA #$00
    STA $4010
    LDA #$40
    STA $4017
    STA $5204              ; MMC5 scanline IRQ off
    STA $5010              ; MMC5 extra audio off

; --- MMC5 setup ---
    LDA #$03
    STA $5100              ; PRG mode 3: $8000/$A000/$C000 switch, $E000 fixed
    STA $5101              ; CHR mode 3
    LDA #$00
    STA $5113              ; WRAM bank 0 @ $6000
    LDA #$FE
    STA $5116              ; bank $C000 = $FE
    LDA #$FF
    STA $5117              ; bank $E000 = $FF (this bank, $1F)
    LDA #$00
    STA $5130
    LDA #$44
    STA $5105              ; vertical mirroring
    LDA #$02
    STA $5102              ; WRAM protect unlock ($02,$01)
    LDA #$01
    STA $5103
    LDA #$01
    STA $5104              ; EXATTR mode ON (extended attributes!)

    ; TODO: resto del RESET fino a $E142 (dump parziale)
    .res $100              ; placeholder â€” sostituire col codice reale

; -------------------------------------------------------------
; NMI handler â€” $E143 (completo, $E143-$E202)
; Frame heartbeat: CHR banking dinamico, HUD, split screen,
; save WRAM, re-bank $C000 -> $1E, music tick.
; -------------------------------------------------------------
NMI:
    INC $52                ; frame counter
    PHA
    LDA #$00
    STA $54
    TXA
    PHA
    TYA
    PHA
    PHA
    LDA #$03
    STA $5800              ; MMC5 protect sequence
    LDA #$01
    STA $5800
    PLA
    LDA $BC
    PHA
    LDA $BD
    PHA
    LDA #$FC
    JSR $EB9C              ; stack helper (sprite shadow?)
    LDA $E5
    BEQ @no_chr            ; flag: CHR update requested?
    JSR $A757              ; compute CHR banks (bank $1E code)
    JSR $AFCD
    LDA $83
    STA $5120              ; upload 8x BG 1K banks from RAM $83-$8A
    LDA $84
    STA $5121
    LDA $85
    STA $5122
    LDA $86
    STA $5123
    LDA $87
    STA $5124
    LDA $88
    STA $5125
    LDA $89
    STA $5126
    LDA $8A
    STA $5127              ; -> animated tiles every frame!
    LDA #$00
    STA $E5
@no_chr:
    JSR $E680              ; scroll / PPU register update
    LDA $53
    BEQ @no_hud
    JSR $E25D              ; HUD update (battle status bar)
    LDA #$00
    STA $53
@no_hud:
    CLI                    ; re-enable IRQs inside NMI (timing technique)
    JSR $E908              ; OAM DMA / sprite upload
    PHA
    LDA #$00
    STA $5800              ; MMC5 protect off
    PLA
    JSR $E205              ; joypad low-level read
    JSR $A22E              ; main game logic hook (bank $1E)
    JSR $E219              ; PPUMASK / audio update
    LDA $05FE
    BNE @no_scanwait
    BIT $5204              ; wait for MMC5 scanline IRQ flag
    BVC @no_scanwait
@no_scanwait:
    LDA $62
    BEQ @no_split
    LDX #$00
    STX $62
    JSR $E7A0              ; MMC5 vertical split update ($5200-$5203)
@no_split:
    JSR $E34B              ; WRAM / backup handling
    LDA $0402
    BNE @no_save
    LDA $69
    BEQ @no_save
    JSR $EBE8              ; battery save to WRAM
@no_save:
    LDA #$FE
    STA $5116              ; re-map $C000 -> bank $1E (game logic)
    JSR $D1BE              ; (bank $1E)
    LDX #$10
    JSR $C1C5              ; dispatcher call in bank $1E
    LDA #$00
    STA $63
    JSR $EACE              ; music driver tick (APU + MMC5 PCM/squares)
    PLA
    JSR $EB9C
    PLA
    JSR $EB96              ; restore stack helpers
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI                    ; $E202

    ; TODO: $E203-$E2C3 (utilities + gap), IRQ handler $E2C4

; -------------------------------------------------------------
; IRQ handler â€” $E2C4 â€” TODO (MMC5 scanline IRQ, split HUD)
; -------------------------------------------------------------
IRQ_HANDLER:
    .res $1D36             ; placeholder fino a $FFFA

; -------------------------------------------------------------
; Vettori â€” $FFFA
; -------------------------------------------------------------
.segment "VECTORS"
    .word $E143            ; NMI
    .word $E000            ; RESET
    .word $E2C4            ; IRQ
