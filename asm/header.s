; iNES header for Just Breed (Enix, 1992)
; Mapper 5 (MMC5) | PRG 512 KB (32 x 16 KB banks) | CHR 256 KB
; Actual header (iNES 2.0): 4E 45 53 1A 20 20 52 08 ...
.segment "HEADER"
    .byte 'N','E','S',$1A   ; iNES magic
    .byte $20               ; 32 x 16 KB PRG banks = 512 KB
    .byte $20               ; 32 x  8 KB CHR banks = 256 KB
    .byte $52               ; flags6: mapper low = 5 (MMC5), 4-screen? (bit 3 set in dump)
    .byte $08               ; flags7: iNES 2.0 identifier
    .byte $00,$70,$00,$00   ; iNES 2.0: mapper 5, PRG/CHR shift 0, misc
    .byte $00,$00,$01
