; =============================================================
; PRG bank $1F â€” fixed at $C000-$FFFF (MMC5 PRG mode 3)
; Contains: RESET ($E000), NMI ($E143), IRQ ($E2C4), vectors ($FFFA)
; Vectors (from ROM): NMI=$E143, RESET=$E000, IRQ=$E2C4
; =============================================================
.segment "CODE31"

    ; ---- $C000-$DFFF: not yet disassembled ----
    .res $2000

; -------------------------------------------------------------
; RESET â€” $E000 (originale: offset banco $2000)
; Inizializzazione CPU + azzeramento RAM + setup MMC5.
; Disassemblato dai byte:
; 78 D8 A9 00 8D 00 20 AD 02 20 10 FB AD 02 20 10 FB AD 02 20 10 FB
; A9 00 8D 01 20 A2 00 95 00 9D 00 01 9D 00 02 9D 00 03 9D 00 04
; 9D 00 05 9D 00 06 9D 00 07 E8 D0 E6 A2 FF 9A A9 08 8D 00 20
; A9 00 8D 10 40 A9 40 8D 17 40 8D 10 50 8D 04 52 A9 03 8D 00 51
; A9 03 8D 01 51 A9 00 8D 13 51 A9 FE 8D 16 51 A9 FF 8D 17 51
; A9 00 8D 30 51 A9 44 8D 05 51 A9 02 8D 02 51 A9 01 8D 03 51 A9 01 8D 04 ...
; -------------------------------------------------------------
    * = $E000   ; (ca65: usa .org via linker; qui il segmento e' gia' mappato a $C000)

RESET:
    SEI                    ; $78 â€” interrupt off
    CLD                    ; $D8 â€” decimal mode off
    LDA #$00
    STA $2000              ; NMI off durante l'init
    LDA $2002
@w1: BPL @w1               ; attesa vblank x1
    LDA $2002
@w2: BPL @w2               ; attesa vblank x2
    LDA $2002
@w3: BPL @w3               ; attesa vblank x3
    LDA #$00
    STA $2001              ; rendering off

; --- azzera RAM $0000-$07FF ($0200 = buffer OAM) ---
    LDX #$00
@clr:
    STA $0000,X
    STA $0100,X
    STA $0200,X            ; OAM DMA buffer
    STA $0300,X
    STA $0400,X
    STA $0500,X
    STA $0600,X
    STA $0700,X
    INX
    BNE @clr
    LDX #$FF
    TXS                    ; stack = $FF

; --- PPU / APU ---
    LDA #$08
    STA $2000              ; NMI on
    LDA #$00
    STA $4010              ; APU PCM off
    LDA #$40
    STA $4017              ; APU frame IRQ off
    STA $5204              ; MMC5 scanline IRQ off
    STA $5010              ; MMC5 extra audio off

; --- MMC5 setup ---
    LDA #$03
    STA $5100              ; PRG mode 3: $8000/$A000/$C000 switch, $E000 fisso
    STA $5101              ; CHR mode 3
    LDA #$00
    STA $5113              ; WRAM bank 0 @ $6000
    LDA #$FE
    STA $5116              ; banco $C000 = $FE
    LDA #$FF
    STA $5117              ; banco $E000 = $FF ($1F = questo banco)
    LDA #$00
    STA $5130              ; CHR upper bits
    LDA #$44
    STA $5105              ; mirroring verticale
    LDA #$02
    STA $5102              ; WRAM write-protect (seq $02,$01)
    LDA #$01
    STA $5103
    LDA #$01
    STA $5104              ; EXATTR mode ON (attributi estesi MMC5!)

    ; TODO: continuare da "8D 04 ..." â€” dump troncato a $E07F
    ; l'ultima istruzione incompleta e': STA $5104 (A9 01 8D 04 [51])
    ; Prossimo passo: disassemblare fino a NMI ($E143)

    .res $FF               ; riempitivo fino a $E143 (da sostituire col codice reale)

; -------------------------------------------------------------
; NMI handler â€” $E143 â€” TODO: disassemblare
; -------------------------------------------------------------
NMI_HANDLER:
    .res $180              ; riempitivo fino a $E2C4 (da sostituire)

; -------------------------------------------------------------
; IRQ handler â€” $E2C4 â€” TODO: disassemblare (scanline IRQ MMC5)
; -------------------------------------------------------------
IRQ_HANDLER:
    .res $1D32             ; riempitivo fino a $FFFA (da sostituire)

; -------------------------------------------------------------
; Vettori â€” $FFFA (valori reali dalla ROM)
; -------------------------------------------------------------
.segment "VECTORS"
    .word $E143            ; NMI
    .word $E000            ; RESET
    .word $E2C4            ; IRQ (MMC5 scanline)
