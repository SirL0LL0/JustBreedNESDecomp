; =============================================================
; PRG bank $1F — auto-disassembled skeleton (v3)
; CPU mapping: $C000-$DFFF (via $5116=$FE) + $E000-$FFFF (fixed)
; code bytes: 6321 / 16384
; NOTE: auto-generated. Refine labels & data tables by hand.
; =============================================================
.segment "CODE31"

main_loop:
    LDA #$FA
L_C002:
    JSR set_win8000_a
L_C005:
    LDA #$FB
L_C007:
    JSR set_winA000_a
L_C00A:
    JSR far_args_fetch
L_C00D:
    SED
    .byte $62, $9A, $AA, $F0, $14, $20, $43, $C8, $20, $BF, $E0, $A9, $36, $85, $DC, $A9
    .byte $00, $85, $DD, $20, $CB, $9D, $4C, $61, $C0, $20, $1D, $C2, $F7, $00, $80, $20
    .byte $34, $C1, $20, $1D, $C2, $F7, $29, $92, $20, $1D, $C2, $F8, $85, $9B, $AD, $00
    .byte $70, $18, $6D, $E0, $71, $69, $40, $20, $3A, $95, $AD, $86, $6D, $C9, $01, $F0
    .byte $0B, $20, $1D, $C2, $F7, $24, $80, $A9, $45, $20, $3A, $95, $20, $7B, $C5, $A9
    .byte $00, $85, $0A, $24, $D7, $30, $06, $20, $7C, $C0, $4C, $6E, $C0, $20, $ED, $C0
    .byte $20, $34, $C1, $20, $2C, $C1, $4C, $61, $C0, $00, $04, $03, $01, $02, $AD, $8F

L_C07E:
    ROR $25D0
L_C081:
    LDA $D7
L_C083:
    BNE L_C093
L_C085:
    BIT $0A
L_C087:
    BPL L_C093
L_C089:
    LDA #$01
L_C08B:
    JSR sub_953A
L_C08E:
    LDA $6E8F
L_C091:
    BNE L_C0A6
L_C093:
    LDA $6A81
L_C096:
    AND #$20
L_C098:
    BEQ L_C0A6
L_C09A:
    JSR rand_next
L_C09D:
    AND #$1F
L_C09F:
    BNE L_C0A6
L_C0A1:
    LDA #$DC
L_C0A3:
    STA $6E8F
L_C0A6:
    JSR party_scan
L_C0A9:
    LDA $6E8F
L_C0AC:
    BNE L_C0A6
L_C0AE:
    BIT $D7
L_C0B0:
    BMI L_C0EC
L_C0B2:
    LDA $0B
L_C0B4:
    AND #$0F
L_C0B6:
    BEQ L_C0EC
L_C0B8:
    JSR sub_C179
L_C0BB:
    LDA $6A81
L_C0BE:
    AND #$20
L_C0C0:
    BEQ L_C0D9
L_C0C2:
    JSR rand_next
L_C0C5:
    AND #$1F
L_C0C7:
    CMP #$08
L_C0C9:
    BCS L_C0D9
L_C0CB:
    CMP #$04
L_C0CD:
    BCC L_C0D7
L_C0CF:
    LDA #$DC
L_C0D1:
    STA $6E8F
L_C0D4:
    JMP L_C0D9
L_C0D7:
    TAX
L_C0D8:
    INX
L_C0D9:
    LDA $C077,X
L_C0DC:
    LDX $D3
L_C0DE:
    STA $6800,X
L_C0E1:
    LDA #$02
L_C0E3:
    BIT $0B
L_C0E5:
    BVC L_C0E9
L_C0E7:
    LDA #$04
L_C0E9:
    STA $6880,X
L_C0EC:
    RTS
    .byte $AD, $8F, $6E, $D0, $1C, $A5, $B7, $D0, $06, $20, $BC, $A8, $4C, $0E, $C1, $24
    .byte $0A, $10

L_C0FF:
    ORA #$20
    .byte $34, $C1, $20, $30, $A2, $4C, $0E, $C1, $50, $03, $20, $56, $B3, $20, $49, $C3
    .byte $AD, $8F, $6E, $D0, $F8, $24, $D7, $10, $11, $A5, $0B, $29, $0F, $F0, $0B, $20
    .byte $79, $C1, $BD, $77, $C0, $A6, $D3, $9D, $00, $68, $60, $A6, $D3, $BD, $C0, $66
    .byte $D0, $FB, $60

L_C134:
    JSR sub_C14E
L_C137:
    LDA #$01
L_C139:
    STA $E2
L_C13B:
    LDA $E2
L_C13D:
    BNE L_C13B
L_C13F:
    RTS
    .byte $20, $78, $C2, $48, $20, $34, $C1, $68, $38, $E9, $01, $D0, $F6, $60

L_C14E:
    RTS
    .byte $A5, $0B, $29, $28, $C9, $28, $D0, $03, $4C, $34, $E1, $A5, $0B, $29, $30, $C9
    .byte $30, $D0, $16, $A5, $E0, $48, $A9, $00, $85, $E0, $20, $37, $C1, $A5, $0A, $29
    .byte $10, $F0, $F7, $68, $85, $E0, $20, $37, $C1, $60

L_C179:
    LDX #$00
L_C17B:
    CMP #$00
L_C17D:
    BEQ L_C183
L_C17F:
    INX
L_C180:
    LSR
L_C181:
    BNE L_C17F
L_C183:
    RTS
set_win8000_a:
    STA $BC
L_C186:
    STA $5114
L_C189:
    RTS
L_C18A:
    JSR retaddr_fetch
L_C18D:
    STA $BC
L_C18F:
    STA $5114
L_C192:
    RTS
set_winA000_a:
    STA $BD
L_C195:
    STA $5115
L_C198:
    RTS
jsr_indirect:
    JMP ($00C0)
    .byte $60, $0A, $A8, $68, $85, $C0, $68, $85, $C1, $C8, $B1, $C0, $48, $C8, $B1, $C0
    .byte $85, $C1, $68, $85, $C0, $6C, $C0, $00

stack_save_x:
    TXA
L_C1B5:
    CLC
L_C1B6:
    ADC $C6
L_C1B8:
    STA $C6
L_C1BA:
    TAY
L_C1BB:
    LDA $EF,X
L_C1BD:
    DEY
L_C1BE:
    STA $0100,Y
L_C1C1:
    DEX
L_C1C2:
    BNE L_C1BB
L_C1C4:
    RTS
stack_load_x:
    LDY $C6
L_C1C7:
    DEY
L_C1C8:
    LDA $0100,Y
L_C1CB:
    STA $EF,X
L_C1CD:
    DEX
L_C1CE:
    BNE L_C1C7
L_C1D0:
    STY $C6
L_C1D2:
    RTS
    .byte $AA, $F0, $14, $A0, $FF, $C8, $B1, $BE, $D0, $FB, $98, $38, $65, $BE, $85, $BE
    .byte $90, $02, $E6, $BF, $CA, $D0, $EC, $60

L_C1EB:
    JSR retaddr_fetch
L_C1EE:
    STA $C4
L_C1F0:
    JSR retaddr_fetch
L_C1F3:
    STA $C2
L_C1F5:
    JSR retaddr_fetch
L_C1F8:
    STA $C3
L_C1FA:
    LDA $BC
L_C1FC:
    PHA
L_C1FD:
    LDA $C4
L_C1FF:
    JSR set_win8000_a
L_C202:
    LDA ($C2),Y
L_C204:
    STA $C4
L_C206:
    JMP L_C249
L_C209:
    LDA $BC
L_C20B:
    PHA
L_C20C:
    LDA #$F9
L_C20E:
    JSR set_win8000_a
L_C211:
    LDA $8FA2,Y
L_C214:
    STA $C4
L_C216:
    LDA $90A2,Y
L_C219:
    TAY
L_C21A:
    JMP L_C249
far_args_fetch:
    STA $C4
L_C21F:
    JSR retaddr_fetch
L_C222:
    STA $C5
L_C224:
    JSR retaddr_fetch
L_C227:
    STA $C0
L_C229:
    JSR retaddr_fetch
L_C22C:
    STA $C1
L_C22E:
    LDA $BC
L_C230:
    PHA
L_C231:
    LDA $BD
L_C233:
    PHA
L_C234:
    LDA $C5
L_C236:
    JSR set_win8000_a
L_C239:
    LDA #$FB
L_C23B:
    JSR set_winA000_a
L_C23E:
    LDA $C4
L_C240:
    JSR jsr_indirect
L_C243:
    STA $C4
L_C245:
    PLA
L_C246:
    JSR set_winA000_a
L_C249:
    PLA
L_C24A:
    JSR set_win8000_a
L_C24D:
    LDA $C4
L_C24F:
    RTS
far_copy_bytes:
    STA $C4
L_C252:
    JSR retaddr_fetch
L_C255:
    STA $C0
L_C257:
    JSR retaddr_fetch
L_C25A:
    STA $C1
L_C25C:
    JSR retaddr_fetch
L_C25F:
    STA $C2
L_C261:
    JSR retaddr_fetch
L_C264:
    STA $C3
L_C266:
    TYA
L_C267:
    PHA
L_C268:
    LDY #$00
L_C26A:
    LDA ($C0),Y
L_C26C:
    STA ($C2),Y
L_C26E:
    INY
L_C26F:
    LDA ($C0),Y
L_C271:
    STA ($C2),Y
L_C273:
    PLA
L_C274:
    TAY
L_C275:
    LDA $C4
L_C277:
    RTS
retaddr_fetch:
    PHA
L_C279:
    TXA
L_C27A:
    PHA
L_C27B:
    TYA
L_C27C:
    PHA
L_C27D:
    LDA $C0
L_C27F:
    PHA
L_C280:
    LDA $C1
L_C282:
    PHA
L_C283:
    TSX
L_C284:
    INC $0108,X
L_C287:
    BNE L_C28C
L_C289:
    INC $0109,X
L_C28C:
    LDA $0108,X
L_C28F:
    STA $C0
L_C291:
    LDA $0109,X
L_C294:
    STA $C1
L_C296:
    LDY #$00
L_C298:
    LDA ($C0),Y
L_C29A:
    STA $0105,X
L_C29D:
    PLA
L_C29E:
    STA $C1
L_C2A0:
    PLA
L_C2A1:
    STA $C0
L_C2A3:
    PLA
L_C2A4:
    TAY
L_C2A5:
    PLA
L_C2A6:
    TAX
L_C2A7:
    PLA
L_C2A8:
    RTS
    .byte $20, $78, $C2, $85, $C0, $20, $78, $C2, $85, $C1, $20, $78, $C2, $85, $C2, $20
    .byte $78, $C2, $85, $C3, $20, $78, $C2, $A8, $88, $B1, $C0, $91, $C2, $C0, $00, $D0
    .byte $F7, $60

L_C2CB:
    TXA
L_C2CC:
    LSR
L_C2CD:
    LSR
L_C2CE:
    LSR
L_C2CF:
    TAY
L_C2D0:
    TXA
L_C2D1:
    AND #$07
L_C2D3:
    TAX
L_C2D4:
    LDA $6F03,Y
L_C2D7:
    AND $C341,X
L_C2DA:
    RTS
L_C2DB:
    STX $6F2B
L_C2DE:
    STY $6F2C
L_C2E1:
    TAX
L_C2E2:
    JSR sub_C2CB
L_C2E5:
    LDY $6F2C
L_C2E8:
    LDX $6F2B
L_C2EB:
    CMP #$00
L_C2ED:
    RTS
    .byte $8A, $F0, $11, $4A, $4A, $4A, $A8, $8A, $29, $07, $AA, $B9, $03, $6F, $1D, $41
    .byte $C3, $99, $03, $6F, $60, $8A, $4A, $4A, $4A, $A8, $8A, $29, $07, $AA, $BD, $41
    .byte $C3, $49, $FF, $39, $03, $6F, $99, $03, $6F, $60, $8A, $29, $07, $AA, $AD, $0F
    .byte $6F, $3D, $41, $C3, $60, $8A, $29, $07, $AA, $AD, $0F, $6F, $1D, $41, $C3, $8D
    .byte $0F, $6F, $60, $8A, $29, $07, $AA, $BD, $41, $C3, $49, $FF, $2D, $0F, $6F, $8D
    .byte $0F, $6F, $60, $01, $02, $04, $08, $10, $20, $40, $80

party_scan:
    LDX $6E8F
L_C34C:
    BEQ L_C356
L_C34E:
    LDA #$00
L_C350:
    STA $6E8F
L_C353:
    JSR sub_DC50
L_C356:
    LDA $BC
L_C358:
    PHA
L_C359:
    LDA $BD
L_C35B:
    PHA
L_C35C:
    JSR sub_C93B
L_C35F:
    LDX $D0
L_C361:
    LDY #$00
L_C363:
    LDA ($C8),Y
L_C365:
    LSR
L_C366:
    LSR
L_C367:
    STA $F2
L_C369:
    CLC
L_C36A:
    SBC $6781
L_C36D:
    BPL L_C39C
L_C36F:
    LDA ($C8),Y
L_C371:
    AND #$03
L_C373:
    CLC
L_C374:
    ADC $F2
L_C376:
    CMP $6781
L_C379:
    BMI L_C39C
L_C37B:
    INY
L_C37C:
    LDA ($C8),Y
L_C37E:
    LSR
L_C37F:
    LSR
L_C380:
    STA $F2
L_C382:
    CLC
L_C383:
    SBC $67C1
L_C386:
    BPL L_C39D
L_C388:
    LDA ($C8),Y
L_C38A:
    AND #$03
L_C38C:
    CLC
L_C38D:
    ADC $F2
L_C38F:
    CMP $67C1
L_C392:
    BMI L_C39D
L_C394:
    INY
L_C395:
    LDA ($C8),Y
L_C397:
    BEQ L_C3E8
L_C399:
    JMP L_C407
L_C39C:
    INY
L_C39D:
    INY
L_C39E:
    INY
L_C39F:
    INY
L_C3A0:
    INY
L_C3A1:
    INY
L_C3A2:
    CPY $6F2E
L_C3A5:
    BNE L_C363
L_C3A7:
    PLA
L_C3A8:
    JSR set_winA000_a
L_C3AB:
    PLA
L_C3AC:
    JSR set_win8000_a
L_C3AF:
    LDA $D0
L_C3B1:
    CMP #$43
L_C3B3:
    BNE L_C3E7
L_C3B5:
    LDA $6F3B
L_C3B8:
    BEQ L_C3E7
L_C3BA:
    LDA $6781
L_C3BD:
    SEC
L_C3BE:
    SBC $6F3C
L_C3C1:
    BCC L_C3E7
L_C3C3:
    CMP #$02
L_C3C5:
    BCS L_C3E7
L_C3C7:
    LDA $67C1
L_C3CA:
    SEC
L_C3CB:
    SBC $6F3D
L_C3CE:
    BCC L_C3E7
L_C3D0:
    CMP #$02
L_C3D2:
    BCS L_C3E7
L_C3D4:
    LDA #$45
L_C3D6:
    STA $D0
L_C3D8:
    LDA #$0C
L_C3DA:
    STA $D4
L_C3DC:
    LDA #$24
L_C3DE:
    STA $D5
L_C3E0:
    LDA #$01
L_C3E2:
    STA $D6
L_C3E4:
    JMP L_C436
L_C3E7:
    RTS
L_C3E8:
    INY
L_C3E9:
    LDA ($C8),Y
L_C3EB:
    STA $F8
L_C3ED:
    INY
L_C3EE:
    LDA ($C8),Y
L_C3F0:
    STA $F9
L_C3F2:
    INY
L_C3F3:
    LDA ($C8),Y
L_C3F5:
    TAX
L_C3F6:
    JSR sub_C52F
L_C3F9:
    BEQ L_C3A1
L_C3FB:
    STY $6F2D
L_C3FE:
    JSR sub_DC50
L_C401:
    LDY $6F2D
L_C404:
    JMP L_C3A1
L_C407:
    BIT $D7
L_C409:
    BPL L_C410
L_C40B:
    LDA #$00
L_C40D:
    STA $6F3B
L_C410:
    LDA #$01
L_C412:
    STA $E0
L_C414:
    LDA ($C8),Y
L_C416:
    STA $D0
L_C418:
    INY
L_C419:
    LDA ($C8),Y
L_C41B:
    BEQ L_C43C
L_C41D:
    STA $D4
L_C41F:
    INY
L_C420:
    LDA ($C8),Y
L_C422:
    STA $D5
L_C424:
    INY
L_C425:
    LDA ($C8),Y
L_C427:
    BPL L_C42C
L_C429:
    LDA $6701
L_C42C:
    STA $D6
L_C42E:
    PLA
L_C42F:
    JSR set_winA000_a
L_C432:
    PLA
L_C433:
    JSR set_win8000_a
L_C436:
    JSR unit_data_clear
L_C439:
    JMP party_scan
L_C43C:
    INY
L_C43D:
    LDA ($C8),Y
L_C43F:
    STA $F0
L_C441:
    INY
L_C442:
    LDA ($C8),Y
L_C444:
    STA $F1
L_C446:
    LDA #$E4
L_C448:
    JSR set_win8000_a
L_C44B:
    LDX #$30
L_C44D:
    LDA #$00
L_C44F:
    STA $6500,X
L_C452:
    DEX
L_C453:
    BNE L_C44F
L_C455:
    LDX #$01
L_C457:
    LDY #$FF
L_C459:
    INY
L_C45A:
    LDA ($F0),Y
L_C45C:
    STA $F2
L_C45E:
    INY
L_C45F:
    LDA ($F0),Y
L_C461:
    STA $F3
L_C463:
    INY
L_C464:
    LDA ($F0),Y
L_C466:
    STA $F4
L_C468:
    INY
L_C469:
    LDA ($F0),Y
L_C46B:
    STA $F5
L_C46D:
    INY
L_C46E:
    LDA ($F0),Y
L_C470:
    STA $F6
L_C472:
    TYA
L_C473:
    PHA
L_C474:
    LDY #$06
L_C476:
    JSR sub_C51E
L_C479:
    ADC $F2
L_C47B:
    STA $6780,X
L_C47E:
    JSR sub_C51E
L_C481:
    ADC $F3
L_C483:
    STA $67C0,X
L_C486:
    INX
L_C487:
    DEY
L_C488:
    BNE L_C476
L_C48A:
    PLA
L_C48B:
    TAY
L_C48C:
    CPX #$19
L_C48E:
    BCC L_C459
L_C490:
    INY
L_C491:
    LDA ($F0),Y
L_C493:
    BEQ L_C4E9
L_C495:
    INX
L_C496:
    STA $6980,X
L_C499:
    INY
L_C49A:
    LDA ($F0),Y
L_C49C:
    STA $F2
L_C49E:
    AND #$3F
L_C4A0:
    STA $6780,X
L_C4A3:
    INY
L_C4A4:
    LDA ($F0),Y
L_C4A6:
    ASL $F2
L_C4A8:
    ROL
L_C4A9:
    ASL $F2
L_C4AB:
    ROL
L_C4AC:
    AND #$3F
L_C4AE:
    STA $67C0,X
L_C4B1:
    LDA ($F0),Y
L_C4B3:
    LSR
L_C4B4:
    LSR
L_C4B5:
    LSR
L_C4B6:
    LSR
L_C4B7:
    CMP #$05
L_C4B9:
    BNE L_C4C3
L_C4BB:
    LDA #$04
L_C4BD:
    JSR sub_DC29
L_C4C0:
    CLC
L_C4C1:
    ADC #$01
L_C4C3:
    STA $6AC0,X
L_C4C6:
    CMP #$00
L_C4C8:
    BNE L_C490
L_C4CA:
    INY
L_C4CB:
    LDA ($F0),Y
L_C4CD:
    STA $F9
L_C4CF:
    STA $6F36
L_C4D2:
    LDA #$02
L_C4D4:
    STA $F8
L_C4D6:
    JSR sub_C52F
L_C4D9:
    BNE L_C4E0
L_C4DB:
    LDA #$00
L_C4DD:
    STA $6980,X
L_C4E0:
    INY
L_C4E1:
    LDA ($F0),Y
L_C4E3:
    STA $6F35
L_C4E6:
    JMP L_C490
L_C4E9:
    CLC
L_C4EA:
    TYA
L_C4EB:
    ADC $F0
L_C4ED:
    STA $CE
L_C4EF:
    LDA $F1
L_C4F1:
    ADC #$00
L_C4F3:
    STA $CF
L_C4F5:
    INX
L_C4F6:
    LDA #$00
L_C4F8:
    STA $6980,X
L_C4FB:
    STA $6780,X
L_C4FE:
    STA $67C0,X
L_C501:
    STA $6AC0,X
L_C504:
    CPX #$31
L_C506:
    BCC L_C4F5
L_C508:
    CPX #$30
L_C50A:
    BCC L_C50E
L_C50C:
    LDX #$30
L_C50E:
    STX $D2
L_C510:
    PLA
L_C511:
    JSR set_winA000_a
L_C514:
    PLA
L_C515:
    JSR set_win8000_a
L_C518:
    JSR sub_C758
L_C51B:
    JMP party_scan
L_C51E:
    LDA #$00
L_C520:
    ASL $F6
L_C522:
    ROL $F5
L_C524:
    ROL $F4
L_C526:
    ROL
L_C527:
    ASL $F6
L_C529:
    ROL $F5
L_C52B:
    ROL $F4
L_C52D:
    ROL
L_C52E:
    RTS
L_C52F:
    DEC $F8
L_C531:
    BEQ L_C545
L_C533:
    DEC $F8
L_C535:
    BEQ L_C54E
L_C537:
    DEC $F8
L_C539:
    BEQ L_C557
L_C53B:
    DEC $F8
L_C53D:
    BEQ L_C55F
L_C53F:
    DEC $F8
L_C541:
    BEQ L_C567
L_C543:
    BNE L_C56D
L_C545:
    LDA $F9
L_C547:
    JSR sub_C2DB
L_C54A:
    BNE L_C56D
L_C54C:
    BEQ L_C570
L_C54E:
    LDA $F9
L_C550:
    JSR sub_C2DB
L_C553:
    BEQ L_C56D
L_C555:
    BNE L_C570
L_C557:
    LDA $F9
L_C559:
    CMP $C7
L_C55B:
    BCS L_C56D
L_C55D:
    BCC L_C570
L_C55F:
    LDA $C7
L_C561:
    CMP $F9
L_C563:
    BCS L_C56D
L_C565:
    BCC L_C570
L_C567:
    LDA $F9
L_C569:
    CMP $C7
L_C56B:
    BNE L_C570
L_C56D:
    LDA #$01
L_C56F:
    RTS
L_C570:
    LDA #$00
L_C572:
    RTS
    .byte $A9, $80, $8D, $46, $6F, $4C, $80, $C5

unit_data_clear:
    LDA #$00
L_C57D:
    STA $6F46
L_C580:
    LDA $6993
L_C583:
    BNE L_C58F
L_C585:
    LDA #$00
L_C587:
    LDX #$05
L_C589:
    STA $6993,X
L_C58C:
    DEX
L_C58D:
    BNE L_C589
L_C58F:
    JSR unit_refresh
L_C592:
    LDA $D1
L_C594:
    CMP #$28
L_C596:
    BCC L_C5AD
L_C598:
    CMP #$46
L_C59A:
    BCS L_C5AD
L_C59C:
    LDA #$00
L_C59E:
    STA $6E9F
L_C5A1:
    STA $6F31
L_C5A4:
    STA $6F32
L_C5A7:
    STA $6F0F
L_C5AA:
    STA $6F0E
L_C5AD:
    LDX #$18
L_C5AF:
    LDA $6A80,X
L_C5B2:
    AND #$E4
L_C5B4:
    STA $6A80,X
L_C5B7:
    DEX
L_C5B8:
    BNE L_C5AF
L_C5BA:
    LDA #$00
L_C5BC:
    STA $D7
L_C5BE:
    LDA $BC
L_C5C0:
    PHA
L_C5C1:
    LDA $BD
L_C5C3:
    PHA
L_C5C4:
    JSR sub_C93B
L_C5C7:
    LDY #$00
L_C5C9:
    LDA ($C8),Y
L_C5CB:
    INY
L_C5CC:
    ORA ($C8),Y
L_C5CE:
    BNE L_C5E8
L_C5D0:
    INY
L_C5D1:
    LDA ($C8),Y
L_C5D3:
    STA $6F37
L_C5D6:
    INY
L_C5D7:
    LDA ($C8),Y
L_C5D9:
    STA $6F38
L_C5DC:
    INY
L_C5DD:
    LDA ($C8),Y
L_C5DF:
    STA $6F39
L_C5E2:
    INY
L_C5E3:
    LDA ($C8),Y
L_C5E5:
    STA $6F3A
L_C5E8:
    LDX #$01
L_C5EA:
    STX $D3
L_C5EC:
    LDA #$02
L_C5EE:
    STA $6500,X
L_C5F1:
    LDA $6F05
L_C5F4:
    AND #$20
L_C5F6:
    BEQ L_C5FD
L_C5F8:
    LDA #$39
L_C5FA:
    STA $6500,X
L_C5FD:
    LDA $D4
L_C5FF:
    STA $6780,X
L_C602:
    LDA $D5
L_C604:
    STA $67C0,X
L_C607:
    JSR sub_C8DF
L_C60A:
    LDA $D6
L_C60C:
    BPL L_C617
L_C60E:
    AND #$7F
L_C610:
    PHA
L_C611:
    LDA #$00
L_C613:
    STA $6500,X
L_C616:
    PLA
L_C617:
    STA $6700,X
L_C61A:
    LDA #$00
L_C61C:
    STA $6740,X
L_C61F:
    LDY $D0
L_C621:
    LDA $82AC,Y
L_C624:
    BEQ L_C696
L_C626:
    STA $6F48
L_C629:
    LDY #$00
L_C62B:
    INX
L_C62C:
    LDA ($CA),Y
L_C62E:
    STA $6500,X
L_C631:
    LDA ($CC),Y
L_C633:
    INY
L_C634:
    STA $F8
L_C636:
    LDA ($CA),Y
L_C638:
    INY
L_C639:
    STA $F9
L_C63B:
    JSR sub_C52F
L_C63E:
    BNE L_C645
L_C640:
    LDA #$00
L_C642:
    STA $6500,X
L_C645:
    LDA ($CA),Y
L_C647:
    INY
L_C648:
    STA $6780,X
L_C64B:
    LDA ($CA),Y
L_C64D:
    STA $67C0,X
L_C650:
    JSR sub_C8DF
L_C653:
    LDA $F9
L_C655:
    STA $6800,X
L_C658:
    STA $6900,X
L_C65B:
    LDA ($CC),Y
L_C65D:
    INY
L_C65E:
    STA $6740,X
L_C661:
    LDA $6500,X
L_C664:
    CMP #$01
L_C666:
    BNE L_C66B
L_C668:
    DEC $6680,X
L_C66B:
    LDA $6740,X
L_C66E:
    CMP #$1C
L_C670:
    BNE L_C67D
L_C672:
    LDA #$02
L_C674:
    STA $6700,X
L_C677:
    INC $65C0,X
L_C67A:
    INC $65C0,X
L_C67D:
    LDA $6500,X
L_C680:
    CMP #$02
L_C682:
    BNE L_C691
L_C684:
    LDA #$00
L_C686:
    STA $6500,X
L_C689:
    STA $6501,X
L_C68C:
    INX
L_C68D:
    INY
L_C68E:
    INY
L_C68F:
    INY
L_C690:
    INY
L_C691:
    CPY $6F48
L_C694:
    BCC L_C62B
L_C696:
    PLA
L_C697:
    JSR set_winA000_a
L_C69A:
    PLA
L_C69B:
    JSR set_win8000_a
L_C69E:
    LDA $6F31
L_C6A1:
    BEQ L_C6C9
L_C6A3:
    JSR sub_C741
L_C6A6:
    LDA #$0E
L_C6A8:
    STA $6740,X
L_C6AB:
    LDA #$01
L_C6AD:
    STA $6800,X
L_C6B0:
    STX $6F33
L_C6B3:
    LDA $6F32
L_C6B6:
    BEQ L_C6C9
L_C6B8:
    JSR sub_C741
L_C6BB:
    LDA #$0E
L_C6BD:
    STA $6740,X
L_C6C0:
    LDA $DCAF,X
L_C6C3:
    STA $6800,X
L_C6C6:
    STX $6F34
L_C6C9:
    LDA $C7
L_C6CB:
    CMP #$A0
L_C6CD:
    BCC L_C6F1
L_C6CF:
    LDA $DCB1,X
L_C6D2:
    STA $6F33
L_C6D5:
    LDY #$00
L_C6D7:
    LDA $C7
L_C6D9:
    EOR #$AA
L_C6DB:
    BEQ L_C6E0
L_C6DD:
    LDA $C73C,Y
L_C6E0:
    JSR sub_C741
L_C6E3:
    LDA #$1E
L_C6E5:
    STA $6740,X
L_C6E8:
    TYA
L_C6E9:
    STA $6800,X
L_C6EC:
    INY
L_C6ED:
    CPY #$05
L_C6EF:
    BCC L_C6D7
L_C6F1:
    LDA #$00
L_C6F3:
    CPX #$19
L_C6F5:
    BCS L_C6FD
L_C6F7:
    INX
L_C6F8:
    STA $6500,X
L_C6FB:
    BNE L_C6F3
L_C6FD:
    STX $D2
L_C6FF:
    LDA #$00
L_C701:
    STA $E0
L_C703:
    JSR far_args_fetch
    .byte $F7, $A4, $87, $A5, $D0

L_C70B:
    CMP #$44
L_C70D:
    BNE L_C718
L_C70F:
    LDA #$F7
L_C711:
    STA $6501
L_C714:
    LDA #$20
L_C716:
    STA $D7
L_C718:
    LDA $D0
L_C71A:
    CMP #$D4
L_C71C:
    BNE L_C72D
L_C71E:
    LDA #$02
L_C720:
    STA $650A
L_C723:
    LDA #$02
L_C725:
    STA $670A
L_C728:
    LDA #$03
L_C72A:
    STA $6704
L_C72D:
    LDA #$01
L_C72F:
    STA $E0
L_C731:
    JSR sub_EA29
L_C734:
    JSR sub_C975
L_C737:
    LDA #$81
L_C739:
    STA $E0
L_C73B:
    RTS
    .byte $09, $0F, $15, $1B, $20

L_C741:
    INX
L_C742:
    STA $6500,X
L_C745:
    LDA $D4
L_C747:
    STA $6780,X
L_C74A:
    LDA $D5
L_C74C:
    STA $67C0,X
L_C74F:
    JSR sub_C8DF
L_C752:
    LDA $D6
L_C754:
    STA $6700,X
L_C757:
    RTS
L_C758:
    LDA #$00
L_C75A:
    STA $6F46
L_C75D:
    JSR unit_refresh
L_C760:
    LDA #$00
L_C762:
    STA $6E9F
L_C765:
    STA $6F31
L_C768:
    STA $6F32
L_C76B:
    STA $6F0F
L_C76E:
    STA $6F0E
L_C771:
    LDA #$80
L_C773:
    STA $D7
L_C775:
    LDX #$01
L_C777:
    LDY $6980,X
L_C77A:
    BEQ L_C79D
L_C77C:
    LDA $6A80,X
L_C77F:
    AND #$E4
L_C781:
    CPX #$19
L_C783:
    BCC L_C787
L_C785:
    LDA #$00
L_C787:
    STA $6A80,X
L_C78A:
    ASL
L_C78B:
    BCS L_C79D
L_C78D:
    JSR far_args_fetch
L_C790:
    SBC $96B2,Y
L_C793:
    JSR sub_C8DF
L_C796:
    CPX #$1A
L_C798:
    BCC L_C79D
L_C79A:
    JSR sub_CE4C
L_C79D:
    INX
L_C79E:
    CPX #$19
L_C7A0:
    BCS L_C7B4
L_C7A2:
    LDA $6F2F
L_C7A5:
    BEQ L_C7B4
L_C7A7:
    LDA $DCB5,X
L_C7AA:
    TAX
L_C7AB:
    LDA $6F2F
L_C7AE:
    CMP #$02
L_C7B0:
    BCC L_C7B4
L_C7B2:
    LDX #$19
L_C7B4:
    CPX #$31
L_C7B6:
    BCC L_C777
L_C7B8:
    LDA $C7
L_C7BA:
    CMP #$A0
L_C7BC:
    BCS L_C7E1
L_C7BE:
    LDX #$01
L_C7C0:
    LDA $6980,X
L_C7C3:
    BEQ L_C7D9
L_C7C5:
    LDA $6500,X
L_C7C8:
    BNE L_C7D9
L_C7CA:
    STA $6501,X
L_C7CD:
    STA $6502,X
L_C7D0:
    STA $6503,X
L_C7D3:
    STA $6504,X
L_C7D6:
    STA $6505,X
L_C7D9:
    LDA $DCB6,X
L_C7DC:
    TAX
L_C7DD:
    CPX #$19
L_C7DF:
    BCC L_C7C0
L_C7E1:
    LDA $6F2F
L_C7E4:
    STA $6F30
L_C7E7:
    LDA #$00
L_C7E9:
    STA $6F2F
L_C7EC:
    LDX #$19
L_C7EE:
    LDA #$8C
L_C7F0:
    STA $6500,X
L_C7F3:
    LDA $6781
L_C7F6:
    STA $6780,X
L_C7F9:
    LDA $67C1
L_C7FC:
    STA $67C0,X
L_C7FF:
    JSR sub_C8DF
L_C802:
    LDA #$04
L_C804:
    STA $6880,X
L_C807:
    LDA #$19
L_C809:
    STA $D3
L_C80B:
    LDA #$00
L_C80D:
    STA $E0
L_C80F:
    JSR far_args_fetch
    .byte $F7, $A4, $87, $20, $34

L_C817:
    CMP ($20,X)
L_C819:
    STY $C9
L_C81B:
    LDX $D2
L_C81D:
    LDA $6500,X
L_C820:
    BEQ L_C836
L_C822:
    LDY $6980,X
L_C825:
    BEQ L_C836
L_C827:
    LDA #$04
L_C829:
    CPX #$19
L_C82B:
    BCC L_C833
L_C82D:
    CPY #$6B
L_C82F:
    BCS L_C833
L_C831:
    LDA #$03
L_C833:
    JSR spr_priority_check
L_C836:
    DEX
L_C837:
    BNE L_C81D
L_C839:
    JSR sub_CB20
L_C83C:
    JSR sub_C72D
L_C83F:
    JSR sub_AB0C
L_C842:
    RTS
    .byte $A9, $00, $8D, $46, $6F, $8D, $44, $6F, $AD, $43, $6F, $48, $20, $46, $C9, $68
    .byte $8D, $43, $6F, $A9, $00, $85, $E0, $20, $1D, $C2, $F7, $5E, $88, $20, $A8, $96
    .byte $4C, $2D, $C7

unit_data_load:
    LDA #$FF
L_C868:
    STA $6F2D
L_C86B:
    LDA $BC
L_C86D:
    PHA
L_C86E:
    LDA $BD
L_C870:
    PHA
L_C871:
    JSR sub_C93B
L_C874:
    LDX $D0
L_C876:
    LDA $8000,X
L_C879:
    STA $6F47
L_C87C:
    LDA $80E4,X
L_C87F:
    BPL L_C887
L_C881:
    JSR far_args_fetch
    .byte $F7, $CA, $86

L_C887:
    STA $6F43
L_C88A:
    LDA $81C8,X
L_C88D:
    STA $6F2E
L_C890:
    LDA #$90
L_C892:
    STA $C8
L_C894:
    LDA #$83
L_C896:
    STA $C9
L_C898:
    LDA #$DE
L_C89A:
    STA $CA
L_C89C:
    LDA #$98
L_C89E:
    STA $CB
L_C8A0:
    LDA #$5E
L_C8A2:
    STA $CC
L_C8A4:
    LDA #$AC
L_C8A6:
    STA $CD
L_C8A8:
    LDX #$01
L_C8AA:
    CPX $D0
L_C8AC:
    BCS L_C8D6
L_C8AE:
    CLC
L_C8AF:
    LDA $C8
L_C8B1:
    ADC $81C8,X
L_C8B4:
    STA $C8
L_C8B6:
    BCC L_C8BA
L_C8B8:
    INC $C9
L_C8BA:
    CLC
L_C8BB:
    LDA $CA
L_C8BD:
    ADC $82AC,X
L_C8C0:
    STA $CA
L_C8C2:
    BCC L_C8C6
L_C8C4:
    INC $CB
L_C8C6:
    CLC
L_C8C7:
    LDA $CC
L_C8C9:
    ADC $82AC,X
L_C8CC:
    STA $CC
L_C8CE:
    BCC L_C8D2
L_C8D0:
    INC $CD
L_C8D2:
    INX
L_C8D3:
    JMP L_C8AA
L_C8D6:
    PLA
L_C8D7:
    JSR set_winA000_a
L_C8DA:
    PLA
L_C8DB:
    JSR set_win8000_a
L_C8DE:
    RTS
L_C8DF:
    JSR far_args_fetch
L_C8E2:
    SBC $9D51,Y
L_C8E5:
    RTS
    .byte $8A, $0A, $0A, $38, $E9, $07, $A8, $A5, $BC, $48, $A5, $BD, $48, $20, $3B, $C9
    .byte $B1, $CC, $AA, $C8, $B1, $CC, $A8, $4C, $D6, $C8, $A5, $BC, $48, $A5, $BD, $48
    .byte $A9, $E4, $20, $84, $C1, $C8

L_C90C:
    LDA ($CE),Y
L_C90E:
    STA $F2
L_C910:
    INY
L_C911:
    LDA ($CE),Y
L_C913:
    STA $F4
L_C915:
    AND #$3F
L_C917:
    STA $F3
L_C919:
    INY
L_C91A:
    LDA ($CE),Y
L_C91C:
    ASL $F4
L_C91E:
    ROL
L_C91F:
    ASL $F4
L_C921:
    ROL
L_C922:
    AND #$3F
L_C924:
    STA $F4
L_C926:
    LDA ($CE),Y
L_C928:
    LSR
L_C929:
    LSR
L_C92A:
    LSR
L_C92B:
    LSR
L_C92C:
    STA $F5
L_C92E:
    INY
L_C92F:
    LDA ($CE),Y
L_C931:
    STA $F6
L_C933:
    INY
L_C934:
    LDA ($CE),Y
L_C936:
    STA $F7
L_C938:
    JMP L_C8D6
L_C93B:
    LDA #$E0
L_C93D:
    JSR set_win8000_a
L_C940:
    LDA #$E1
L_C942:
    JSR set_winA000_a
L_C945:
    RTS
unit_refresh:
    LDA #$0F
L_C948:
    STA $0390
L_C94B:
    STA $0394
L_C94E:
    STA $0398
L_C951:
    STA $039C
L_C954:
    JSR sprite_frame_step
L_C957:
    JSR unit_data_load
L_C95A:
    LDA $6F44
L_C95D:
    BIT $6F46
L_C960:
    BPL L_C965
L_C962:
    STA $6F43
L_C965:
    CMP $6F43
L_C968:
    BEQ L_C96F
L_C96A:
    LDA #$01
L_C96C:
    JSR sfx_play
L_C96F:
    LDA $6F47
L_C972:
    STA $D1
L_C974:
    RTS
L_C975:
    LDA $6F43
L_C978:
    CMP $6F44
L_C97B:
    BEQ L_C983
L_C97D:
    STA $6F44
L_C980:
    JSR save_prep
L_C983:
    RTS
    .byte $8A, $48, $A9, $01, $8D

L_C989:
    EOR #$6F
L_C98B:
    JSR sub_C134
L_C98E:
    LDA #$00
L_C990:
    STA $DB
L_C992:
    JSR sub_CAF0
L_C995:
    STX $6F4A
L_C998:
    STY $6F4B
L_C99B:
    PLA
L_C99C:
    TAX
L_C99D:
    RTS
    .byte $48, $20, $84, $C9, $68, $20, $AA, $C9, $20, $20, $CB, $60

spr_priority_check:
    STA $FA
L_C9AC:
    LDA $6980,X
L_C9AF:
    CMP #$65
L_C9B1:
    BCC L_C9BD
L_C9B3:
    CMP #$6B
L_C9B5:
    BCS L_C9BD
L_C9B7:
    LDA #$00
L_C9B9:
    STA $68C0,X
L_C9BC:
    RTS
L_C9BD:
    LDA $68C0,X
L_C9C0:
    BNE L_C9FA
L_C9C2:
    STX $DA
L_C9C4:
    JSR get_unit_pos
L_C9C7:
    STX $D8
L_C9C9:
    STY $D9
L_C9CB:
    JSR map_cell_read
L_C9CE:
    LDX $DA
L_C9D0:
    CMP #$C0
L_C9D2:
    BCS L_C9F7
L_C9D4:
    STA $6940,X
L_C9D7:
    LDY $6980,X
L_C9DA:
    JSR sub_C1EB
L_C9DD:
    SBC $83B4,Y
L_C9E0:
    CMP #$FF
L_C9E2:
    BEQ L_C9E6
L_C9E4:
    LDA $FA
L_C9E6:
    STA $68C0,X
L_C9E9:
    LDX $D8
L_C9EB:
    LDY $D9
L_C9ED:
    LDA $DA
L_C9EF:
    ORA #$C0
L_C9F1:
    JSR sub_D6F9
L_C9F4:
    JSR metasprite_draw
L_C9F7:
    LDX $DA
L_C9F9:
    RTS
L_C9FA:
    BMI L_CA01
L_C9FC:
    LDA $FA
L_C9FE:
    STA $68C0,X
L_CA01:
    RTS
    .byte $98, $48, $A5, $F0, $48, $A5, $F1, $48, $20, $84, $C9, $20, $1C, $CA, $20, $20
    .byte $CB, $68, $85, $F1, $68, $85, $F0, $68, $A8, $60, $8A, $48, $BD, $C0, $68, $F0
    .byte $19, $A9, $00, $9D, $C0, $68, $BD, $40, $69, $85, $DA, $20, $18, $CB, $86, $D8
    .byte $84, $D9, $A5, $DA, $20, $F9, $D6, $20, $56, $CA, $68, $AA, $60, $85, $DA, $86
    .byte $D8, $84, $D9, $20, $F9, $D6, $20, $84, $C9, $20, $56, $CA, $20, $20, $CB, $60
    .byte $86, $D8, $84, $D9

metasprite_draw:
    LDX $D8
L_CA58:
    LDY $D9
L_CA5A:
    LDA $F2
L_CA5C:
    PHA
L_CA5D:
    LDA $F3
L_CA5F:
    PHA
L_CA60:
    LDA $F4
L_CA62:
    PHA
L_CA63:
    LDA $F5
L_CA65:
    PHA
L_CA66:
    LDA $F6
L_CA68:
    PHA
L_CA69:
    LDA $F7
L_CA6B:
    PHA
L_CA6C:
    LDA $F8
L_CA6E:
    PHA
L_CA6F:
    LDA $F9
L_CA71:
    PHA
L_CA72:
    JSR sprite_draw_core
L_CA75:
    JSR sub_CA98
L_CA78:
    PLA
L_CA79:
    STA $F9
L_CA7B:
    PLA
L_CA7C:
    STA $F8
L_CA7E:
    PLA
L_CA7F:
    STA $F7
L_CA81:
    PLA
L_CA82:
    STA $F6
L_CA84:
    PLA
L_CA85:
    STA $F5
L_CA87:
    PLA
L_CA88:
    STA $F4
L_CA8A:
    PLA
L_CA8B:
    STA $F3
L_CA8D:
    PLA
L_CA8E:
    STA $F2
L_CA90:
    RTS
    .byte $86, $D8, $84, $D9, $20, $BD, $D5

L_CA98:
    LDA $D8
L_CA9A:
    SEC
L_CA9B:
    SBC $6F4A
L_CA9E:
    CMP #$10
L_CAA0:
    BCS L_CAEF
L_CAA2:
    LDA $D9
L_CAA4:
    SEC
L_CAA5:
    SBC $6F4B
L_CAA8:
    CMP #$0F
L_CAAA:
    BCS L_CAEF
L_CAAC:
    LDX $DB
L_CAAE:
    LDA $D8
L_CAB0:
    STA $0606,X
L_CAB3:
    LDA $D9
L_CAB5:
    STA $060E,X
L_CAB8:
    LDA $F2
L_CABA:
    STA $061E,X
L_CABD:
    LDA $F6
L_CABF:
    STA $0616,X
L_CAC2:
    LDA $F3
L_CAC4:
    STA $062E,X
L_CAC7:
    LDA $F7
L_CAC9:
    STA $0626,X
L_CACC:
    LDA $F4
L_CACE:
    STA $063E,X
L_CAD1:
    LDA $F8
L_CAD3:
    STA $0636,X
L_CAD6:
    LDA $F5
L_CAD8:
    STA $064E,X
L_CADB:
    LDA $F9
L_CADD:
    STA $0646,X
L_CAE0:
    INC $DB
L_CAE2:
    LDX $DB
L_CAE4:
    CPX #$08
L_CAE6:
    BCC L_CAEF
L_CAE8:
    JSR metasprite_blit
L_CAEB:
    LDA #$00
L_CAED:
    STA $DB
L_CAEF:
    RTS
L_CAF0:
    LDX $D3
L_CAF2:
    JSR get_unit_pos
L_CAF5:
    TXA
L_CAF6:
    SEC
L_CAF7:
    SBC #$08
L_CAF9:
    TAX
L_CAFA:
    BCS L_CAFE
L_CAFC:
    LDX #$00
L_CAFE:
    CPX $6ED5
L_CB01:
    BCC L_CB06
L_CB03:
    LDX $6ED5
L_CB06:
    TYA
L_CB07:
    SEC
L_CB08:
    SBC #$07
L_CB0A:
    TAY
L_CB0B:
    BCS L_CB0F
L_CB0D:
    LDY #$00
L_CB0F:
    CPY $6ED6
L_CB12:
    BCC L_CB17
L_CB14:
    LDY $6ED6
L_CB17:
    RTS
get_unit_pos:
    LDA $6780,X
L_CB1B:
    LDY $67C0,X
L_CB1E:
    TAX
L_CB1F:
    RTS
L_CB20:
    TXA
L_CB21:
    PHA
L_CB22:
    LDX $DB
L_CB24:
    BEQ L_CB29
L_CB26:
    JSR metasprite_blit
L_CB29:
    LDA #$00
L_CB2B:
    STA $6F49
L_CB2E:
    PLA
L_CB2F:
    TAX
L_CB30:
    RTS
sprite_select:
    LDA $6980,X
L_CB34:
    CMP #$5A
L_CB36:
    BNE L_CB8B
L_CB38:
    TXA
L_CB39:
    PHA
L_CB3A:
    LDX #$01
L_CB3C:
    JSR sub_CB8B
L_CB3F:
    PLA
L_CB40:
    TAX
L_CB41:
    LDA $69C0,X
L_CB44:
    STA $6F70
L_CB47:
    LDA $6A00,X
L_CB4A:
    STA $6F74
L_CB4D:
    LDA $6A40,X
L_CB50:
    TAY
L_CB51:
    AND #$0F
L_CB53:
    STA $6F71
L_CB56:
    LDA $DDD0,Y
L_CB59:
    PHA
L_CB5A:
    AND #$01
L_CB5C:
    STA $6F75
L_CB5F:
    PLA
L_CB60:
    LSR
L_CB61:
    STA $6F78
L_CB64:
    LDA $6F93
L_CB67:
    STA $6F8E
L_CB6A:
    LDA #$B4
L_CB6C:
    STA $6F8F
L_CB6F:
    LDA #$00
L_CB71:
    STA $6F90
L_CB74:
    STA $6F91
L_CB77:
    STA $6F92
L_CB7A:
    STA $6F88
L_CB7D:
    STA $6F89
L_CB80:
    LDA #$F4
L_CB82:
    STA $6F8A
L_CB85:
    LDA #$01
L_CB87:
    STA $6F8B
L_CB8A:
    RTS
L_CB8B:
    TXA
L_CB8C:
    PHA
L_CB8D:
    LDA $6980,X
L_CB90:
    CMP #$25
L_CB92:
    BCC L_CB97
L_CB94:
    JMP L_CCA0
L_CB97:
    CPX #$19
L_CB99:
    BCC L_CBA3
L_CB9B:
    LDX #$00
L_CB9D:
    INX
L_CB9E:
    CMP $6980,X
L_CBA1:
    BNE L_CB9D
L_CBA3:
    TXA
L_CBA4:
    PHA
L_CBA5:
    LDY $6980,X
L_CBA8:
    JSR far_args_fetch
L_CBAB:
    SBC $9785,Y
L_CBAE:
    PLA
L_CBAF:
    TAX
L_CBB0:
    LDA $69C0,X
L_CBB3:
    STA $6F70
L_CBB6:
    LDA $6A00,X
L_CBB9:
    STA $6F74
L_CBBC:
    LDA $6A40,X
L_CBBF:
    TAY
L_CBC0:
    AND #$0F
L_CBC2:
    STA $6F71
L_CBC5:
    LDA $DDD0,Y
L_CBC8:
    PHA
L_CBC9:
    AND #$01
L_CBCB:
    STA $6F75
L_CBCE:
    PLA
L_CBCF:
    LSR
L_CBD0:
    STA $6F78
L_CBD3:
    LDA $6AC0,X
L_CBD6:
    STA $6F72
L_CBD9:
    LDA $6B00,X
L_CBDC:
    STA $6F76
L_CBDF:
    LDA $6B18,X
L_CBE2:
    TAY
L_CBE3:
    AND #$0F
L_CBE5:
    STA $6F73
L_CBE8:
    LDA $DDD0,Y
L_CBEB:
    STA $6F77
L_CBEE:
    LDA $6B78,X
L_CBF1:
    STA $6F93
L_CBF4:
    LDA $6B90,X
L_CBF7:
    STA $6F94
L_CBFA:
    LDA $6BA8,X
L_CBFD:
    TAY
L_CBFE:
    AND #$0F
L_CC00:
    CLC
L_CC01:
    ADC #$8C
L_CC03:
    STA $6F95
L_CC06:
    LDA $DDD0,Y
L_CC09:
    CLC
L_CC0A:
    ADC #$27
L_CC0C:
    STA $6F96
L_CC0F:
    LDA $6B30,X
L_CC12:
    STA $6F7A
L_CC15:
    LDA $6B48,X
L_CC18:
    STA $6F7C
L_CC1B:
    LDA $6B60,X
L_CC1E:
    STA $6F7E
L_CC21:
    LDA #$00
L_CC23:
    STA $6F7B
L_CC26:
    STA $6F7D
L_CC29:
    STA $6F7F
L_CC2C:
    JSR far_copy_bytes
    .byte $7C, $6F, $99, $6F, $AE, $94, $6F, $20, $10, $CF, $20, $22, $CD, $AE, $95, $6F
    .byte $20, $10, $CF, $20, $22, $CD, $AE, $96, $6F, $20, $10, $CF, $20, $22, $CD, $AE
    .byte $93, $6F, $20, $10, $CF, $20, $50, $C2, $A3, $6F, $97, $6F, $68, $AA, $AD, $93
    .byte $6F, $C9, $44, $F0, $31, $C9, $48, $F0, $2D, $18, $AD, $97, $6F, $6D, $7A, $6F
    .byte $8D, $97, $6F, $AD, $98, $6F, $6D, $7B, $6F, $8D, $98, $6F, $BD, $80, $6A, $29
    .byte $03, $F0, $13, $18, $AD, $97, $6F, $6D, $7A, $6F, $8D, $97, $6F, $AD, $98, $6F
    .byte $6D, $7B, $6F, $8D, $98, $6F, $A9, $00, $8D, $8C, $6F, $A9, $06, $8D, $8D, $6F
    .byte $60

L_CCA0:
    LDY $6980,X
L_CCA3:
    JSR far_args_fetch
L_CCA6:
    SBC $9785,Y
L_CCA9:
    PLA
L_CCAA:
    PHA
L_CCAB:
    TAX
L_CCAC:
    LDA $69C0,X
L_CCAF:
    STA $6F70
L_CCB2:
    LDA $6A00,X
L_CCB5:
    STA $6F74
L_CCB8:
    LDA $6A40,X
L_CCBB:
    TAY
L_CCBC:
    AND #$0F
L_CCBE:
    STA $6F71
L_CCC1:
    LDA $DDD0,Y
L_CCC4:
    PHA
L_CCC5:
    AND #$01
L_CCC7:
    STA $6F75
L_CCCA:
    PLA
L_CCCB:
    LSR
L_CCCC:
    STA $6F78
L_CCCF:
    LDA #$00
L_CCD1:
    STA $6F93
L_CCD4:
    STA $6F94
L_CCD7:
    STA $6F95
L_CCDA:
    STA $6F96
L_CCDD:
    JSR far_copy_bytes
    .byte $7A, $6F, $97, $6F, $AE, $8E, $6F, $E0, $D3, $F0, $08, $E0, $D4, $F0, $04, $E0
    .byte $6C, $B0, $16, $20

L_CCF4:
    BPL L_CCC5
L_CCF6:
    CLC
L_CCF7:
    LDA $6F97
L_CCFA:
    ADC $6FA3
L_CCFD:
    STA $6F97
L_CD00:
    LDA $6F98
L_CD03:
    ADC $6FA4
L_CD06:
    STA $6F98
L_CD09:
    JSR far_copy_bytes
    .byte $7C, $6F, $99, $6F, $AD, $85, $6F, $A8, $29, $10, $8D, $8C, $6F, $B9, $D0, $DD
    .byte $8D, $8D, $6F, $68, $AA, $60, $A0, $00, $18, $B9, $99, $6F, $79, $A3, $6F, $99
    .byte $99, $6F, $B9, $9A, $6F, $79, $A4, $6F, $99, $9A, $6F, $B9, $99, $6F, $C9, $E7
    .byte $B9, $9A, $6F, $E9, $03, $90, $0A, $A9, $E7, $99, $99, $6F, $A9, $03, $99, $9A
    .byte $6F, $C8, $C8, $C0, $08, $90, $D1, $18, $AD, $80, $6F, $6D, $B1, $6F, $8D, $80
    .byte $6F, $18, $AD, $81, $6F, $6D, $B2, $6F, $8D, $81, $6F, $60, $E0, $31, $B0, $24
    .byte $BD, $80, $69, $C9, $25, $90, $1E, $AD, $70, $6F, $9D, $C0, $69, $AD, $74, $6F
    .byte $9D, $00, $6A, $AD, $78, $6F, $0A, $0D, $75, $6F

L_CD86:
    TAY
L_CD87:
    LDA $DED0,Y
L_CD8A:
    ORA $6F71
L_CD8D:
    STA $6A40,X
L_CD90:
    RTS
    .byte $AD, $70, $6F, $9D, $C0, $69, $AD, $74, $6F, $9D, $00, $6A, $AD, $78, $6F, $0A
    .byte $0D, $75, $6F, $A8

L_CDA5:
    LDA $DED0,Y
L_CDA8:
    ORA $6F71
L_CDAB:
    STA $6A40,X
L_CDAE:
    LDA $6F72
L_CDB1:
    STA $6AC0,X
L_CDB4:
    LDA $6F76
L_CDB7:
    STA $6B00,X
L_CDBA:
    LDY $6F77
L_CDBD:
    LDA $6F73
L_CDC0:
    ORA $DED0,Y
L_CDC3:
    STA $6B18,X
L_CDC6:
    LDA $6F93
L_CDC9:
    STA $6B78,X
L_CDCC:
    LDA $6F94
L_CDCF:
    STA $6B90,X
L_CDD2:
    LDA $6F96
L_CDD5:
    SEC
L_CDD6:
    SBC #$27
L_CDD8:
    TAY
L_CDD9:
    LDA $6F95
L_CDDC:
    SEC
L_CDDD:
    SBC #$8C
L_CDDF:
    ORA $DED0,Y
L_CDE2:
    STA $6BA8,X
L_CDE5:
    LDA $6F7A
L_CDE8:
    STA $6B30,X
L_CDEB:
    LDA $6F7C
L_CDEE:
    STA $6B48,X
L_CDF1:
    LDA $6F7E
L_CDF4:
    STA $6B60,X
L_CDF7:
    RTS
    .byte $AD, $B3, $6F, $85, $EB, $AD, $B4, $6F, $85, $EC, $60, $BE, $AF, $DC, $A5, $C7
    .byte $C9, $A0, $B0, $03, $BE, $33, $CE, $A5, $BC, $48, $20, $8A, $C1, $F9, $A0, $00
    .byte $C8, $BD, $4C, $6F, $D9, $09, $8F, $BD, $52, $6F, $F9, $3C, $8F, $BD, $58, $6F
    .byte $F9, $6F, $8F, $B0, $EB, $68, $20, $84, $C1, $98, $60, $FF, $00, $00, $00, $00
    .byte $00, $00, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $03, $03
    .byte $03, $03, $03, $03

L_CE4C:
    LDA #$00
L_CE4E:
    STA $6A80,X
L_CE51:
    LDA #$37
L_CE53:
    STA $6F93
L_CE56:
    LDA #$6D
L_CE58:
    STA $6F94
L_CE5B:
    LDA #$8C
L_CE5D:
    STA $6F95
L_CE60:
    LDA #$27
L_CE62:
    STA $6F96
L_CE65:
    LDY $6980,X
L_CE68:
    BEQ L_CEB4
L_CE6A:
    CPY #$5A
L_CE6C:
    BNE L_CE7A
L_CE6E:
    TXA
L_CE6F:
    PHA
L_CE70:
    LDX #$01
L_CE72:
    JSR sprite_select
L_CE75:
    PLA
L_CE76:
    TAX
L_CE77:
    JMP L_CE84
L_CE7A:
    TXA
L_CE7B:
    PHA
L_CE7C:
    JSR far_args_fetch
L_CE7F:
    SBC $9785,Y
L_CE82:
    PLA
L_CE83:
    TAX
L_CE84:
    JSR far_copy_bytes
    .byte $72, $6F, $70, $6F, $20, $50, $C2, $76, $6F, $74, $6F, $C0, $25, $B0, $1B, $20
    .byte $EB, $C1, $F9, $B0, $88, $8D, $93, $6F, $20, $EB, $C1, $F9, $24, $89, $8D, $94
    .byte $6F, $20, $EB, $C1, $F9, $98, $89, $8D, $95, $6F, $20, $68, $CD

L_CEB4:
    RTS
    .byte $20, $78, $C2, $9D, $40, $69

spr_attr_set:
    JSR retaddr_fetch
L_CEBE:
    STA $6740,X
L_CEC1:
    JSR retaddr_fetch
L_CEC4:
    STA $6500,X
L_CEC7:
    RTS
    .byte $A0, $0A, $20, $D9, $CE, $A2, $07, $BD, $0A, $07, $9D, $FB, $6E, $CA, $10, $F7
    .byte $60, $85, $BE, $A9, $00, $06, $BE, $2A, $06, $BE, $2A, $06, $BE, $2A, $85, $BF
    .byte $18, $A5, $BE, $69, $00, $85, $BE, $A5, $BF, $69, $80, $85, $BF, $A5, $BC, $48
    .byte $20, $8A

L_CEFA:
    CMP ($E6,X)
L_CEFC:
    TYA
L_CEFD:
    TAX
L_CEFE:
    LDY #$00
L_CF00:
    LDA ($BE),Y
L_CF02:
    STA $0700,X
L_CF05:
    INX
L_CF06:
    INY
L_CF07:
    CPY #$08
L_CF09:
    BCC L_CF00
L_CF0B:
    PLA
L_CF0C:
    JSR set_win8000_a
L_CF0F:
    RTS
    .byte $A5, $BC, $48, $20, $8A, $C1

L_CF16:
    INC $BD
L_CF18:
    JSR sub_8D87
L_CF1B:
    LDA ($6F,X)
L_CF1D:
    LDA $8804,X
L_CF20:
    STA $6FA2
L_CF23:
    LDY $88E8,X
L_CF26:
    JSR sub_C209
L_CF29:
    STA $6FA3
L_CF2C:
    STY $6FA4
L_CF2F:
    LDY $89CC,X
L_CF32:
    STY $6FAB
L_CF35:
    JSR sub_C209
L_CF38:
    STA $6FA5
L_CF3B:
    STY $6FA6
L_CF3E:
    LDY $8AB0,X
L_CF41:
    STY $6FAC
L_CF44:
    JSR sub_C209
L_CF47:
    STA $6FA7
L_CF4A:
    STY $6FA8
L_CF4D:
    LDA $8B94,X
L_CF50:
    STA $6FAD
L_CF53:
    AND #$1F
L_CF55:
    ASL
L_CF56:
    STA $6FA9
L_CF59:
    LDA #$00
L_CF5B:
    STA $6FAA
L_CF5E:
    LDA $8C78,X
L_CF61:
    STA $6FAE
L_CF64:
    LDA $8D5C,X
L_CF67:
    STA $6FAF
L_CF6A:
    LDA $8E40,X
L_CF6D:
    STA $6FB0
L_CF70:
    LDA $8F24,X
L_CF73:
    STA $6FB1
L_CF76:
    LDA $9008,X
L_CF79:
    STA $6FB2
L_CF7C:
    LDA $90EC,X
L_CF7F:
    STA $6FB3
L_CF82:
    LDA $91D0,X
L_CF85:
    STA $6FB4
L_CF88:
    PLA
L_CF89:
    JSR set_win8000_a
L_CF8C:
    RTS
    .byte $85, $BE, $09, $80, $AA, $20, $DB, $C2, $D0, $04, $A9, $1E, $85

anim_table_load:
    LDX $BEA5,Y
L_CF9D:
    ASL
L_CF9E:
    ASL
L_CF9F:
    CLC
L_CFA0:
    ADC $BE
L_CFA2:
    ASL
L_CFA3:
    STA $BE
L_CFA5:
    LDA #$00
L_CFA7:
    ROL
L_CFA8:
    STA $BF
L_CFAA:
    CLC
L_CFAB:
    LDA $BE
L_CFAD:
    ADC #$B4
L_CFAF:
    STA $BE
L_CFB1:
    LDA $BF
L_CFB3:
    ADC #$92
L_CFB5:
    STA $BF
L_CFB7:
    LDA $BC
L_CFB9:
    PHA
L_CFBA:
    JSR sub_C18A
L_CFBD:
    INC $98
L_CFBF:
    TAX
L_CFC0:
    LDY #$00
L_CFC2:
    LDA ($BE),Y
L_CFC4:
    STA $0700,X
L_CFC7:
    INX
L_CFC8:
    INY
L_CFC9:
    CPY #$0A
L_CFCB:
    BCC L_CFC2
L_CFCD:
    PLA
L_CFCE:
    JSR set_win8000_a
L_CFD1:
    RTS
    .byte $A5, $BC, $48, $20, $8A, $C1, $E6, $A4, $D0, $BD, $EA, $93, $C5, $D0

L_CFE0:
    STA $D0
L_CFE2:
    BCC L_CFF6
L_CFE4:
    LDA $9409,X
L_CFE7:
    STA $D4
L_CFE9:
    LDA $9428,X
L_CFEC:
    STA $D5
L_CFEE:
    LDA $9447,X
L_CFF1:
    STA $D6
L_CFF3:
    JMP L_D005
L_CFF6:
    LDA $9466,X
L_CFF9:
    STA $D4
L_CFFB:
    LDA $9485,X
L_CFFE:
    STA $D5
L_D000:
    LDA $94A4,X
L_D003:
    STA $D6
L_D005:
    PLA
L_D006:
    JSR set_win8000_a
L_D009:
    JSR npc_id_dispatch
L_D00C:
    RTS
npc_id_dispatch:
    LDA $D0
L_D00F:
    CMP #$24
L_D011:
    BEQ L_D028
L_D013:
    CMP #$57
L_D015:
    BEQ L_D033
L_D017:
    CMP #$83
L_D019:
    BEQ L_D042
L_D01B:
    CMP #$8A
L_D01D:
    BEQ L_D051
L_D01F:
    CMP #$A7
L_D021:
    BEQ L_D06A
L_D023:
    CMP #$7D
L_D025:
    BEQ L_D079
L_D027:
    RTS
L_D028:
    LDA $C7
L_D02A:
    CMP #$1B
L_D02C:
    BCC L_D027
L_D02E:
    LDA #$27
L_D030:
    STA $D0
L_D032:
    RTS
L_D033:
    CPY #$58
L_D035:
    BCC L_D027
L_D037:
    CPY #$5D
L_D039:
    BCS L_D027
L_D03B:
    JSR sub_D084
L_D03E:
    ROL
L_D03F:
    ASL $02,X
L_D041:
    RTS
L_D042:
    CPY #$84
L_D044:
    BCC L_D027
L_D046:
    CPY #$86
L_D048:
    BCS L_D027
L_D04A:
    JSR sub_D084
    .byte $02, $0D, $03, $60

L_D051:
    LDA $C7
L_D053:
    CMP #$83
L_D055:
    BCC L_D05B
L_D057:
    LDA #$8E
L_D059:
    STA $D0
L_D05B:
    CPY #$8F
L_D05D:
    BCC L_D027
L_D05F:
    CPY #$9B
L_D061:
    BCS L_D027
L_D063:
    JSR sub_D084
    .byte $0B, $02, $00, $60

L_D06A:
    CPY #$A8
L_D06C:
    BCC L_D027
L_D06E:
    CPY #$B2
L_D070:
    BCS L_D027
L_D072:
    JSR sub_D084
    .byte $02, $15, $01, $60

L_D079:
    LDA $C7
L_D07B:
    CMP #$78
L_D07D:
    BCC L_D027
L_D07F:
    LDA #$7E
L_D081:
    STA $D0
L_D083:
    RTS
L_D084:
    JSR retaddr_fetch
L_D087:
    STA $D4
L_D089:
    JSR retaddr_fetch
L_D08C:
    STA $D5
L_D08E:
    JSR retaddr_fetch
L_D091:
    STA $D6
L_D093:
    RTS
    .byte $86, $DC, $84, $DD, $A5, $BC, $48, $A5, $BD, $48, $A9, $EE, $20, $84, $C1, $A9
    .byte $EF, $20, $93, $C1, $A5, $DC, $85, $BE, $A5, $DD, $18, $69, $82, $85, $BF, $A9
    .byte $00, $85, $F0, $85, $F1, $85, $F2, $A0, $00, $B1, $BE, $AA, $C8, $B1, $BE, $86
    .byte $BE, $AA, $29, $0F, $06, $BE, $2A, $09, $80, $85, $BF, $BD, $D0, $DD, $09, $D0
    .byte $20, $84, $C1, $18, $69, $01, $20, $93, $C1, $A0, $00, $B1, $BE, $99, $00, $64
    .byte $C8, $D0, $F8, $A9, $EE, $20, $84, $C1, $A9, $EF, $20, $93, $C1, $A9, $00, $85
    .byte $BE, $A9, $64, $85, $BF, $A2, $00, $20, $61, $D1, $9D, $00, $07, $F0, $40, $E8
    .byte $C9, $01, $D0, $10, $86, $F7, $A2, $07, $20, $9A, $D1, $A6, $F7, $0A, $9D, $00
    .byte $07, $E8, $D0, $E3, $C9, $02, $F0, $18, $C9, $03, $F0, $14, $C9, $04, $F0, $10
    .byte $C9, $60, $F0, $0C, $C9, $61, $F0, $08, $C9, $62, $F0, $04, $C9, $63, $D0, $C7
    .byte $86, $F7, $A2, $08, $20, $9A, $D1, $A6, $F7, $9D, $00, $07, $E8, $D0, $B8, $A2
    .byte $00, $BD, $00, $07, $9D, $00, $64, $E8, $C9, $00, $D0, $F5, $68, $20, $93, $C1
    .byte $68, $20, $84, $C1, $A9, $00, $85, $BE, $A9, $64, $85, $BF, $60, $A9, $00, $85
    .byte $F5, $A9, $80, $85, $F6, $20, $A4, $D1, $B0, $15, $A0, $00, $B1, $F5, $C9, $02
    .byte $B0, $04, $C8, $B1, $F5, $60, $E6, $F5, $D0, $EB, $E6, $F6, $4C, $69, $D1, $A0
    .byte $00, $B1, $F5, $D0, $05, $A0, $02, $B1, $F5, $60, $38, $65, $F5, $85, $F5, $90
    .byte $D4, $E6, $F6, $4C, $69, $D1, $A9, $00, $20, $A4, $D1, $2A, $CA, $D0, $F9, $60
    .byte $06, $F0, $F0, $01, $60, $48, $20, $B3, $D1, $38, $2A, $85, $F0, $68, $60, $A0
    .byte $00, $B1, $BE, $E6, $BE, $D0, $02, $E6, $BF, $60

nmi_mid_hook:
    LDX $52
L_D1C0:
    DEX
L_D1C1:
    BEQ L_D1CA
L_D1C3:
    LDA $E0
L_D1C5:
    BPL L_D1C9
L_D1C7:
    INC $E1
L_D1C9:
    RTS
L_D1CA:
    LDA #$00
L_D1CC:
    STA $E2
L_D1CE:
    LDA $BC
L_D1D0:
    PHA
L_D1D1:
    LDA #$F8
L_D1D3:
    JSR set_win8000_a
L_D1D6:
    LDA $BD
L_D1D8:
    PHA
L_D1D9:
    LDA #$FB
L_D1DB:
    JSR set_winA000_a
L_D1DE:
    LDA $C0
L_D1E0:
    PHA
L_D1E1:
    LDA $C1
L_D1E3:
    PHA
L_D1E4:
    LDA $EB
L_D1E6:
    PHA
L_D1E7:
    LDA $EC
L_D1E9:
    PHA
L_D1EA:
    LDA $ED
L_D1EC:
    PHA
L_D1ED:
    LDA $EE
L_D1EF:
    PHA
L_D1F0:
    LDA $C4
L_D1F2:
    PHA
L_D1F3:
    LDA $C5
L_D1F5:
    PHA
L_D1F6:
    LDA $E0
L_D1F8:
    BEQ L_D20F
L_D1FA:
    LDA #$00
L_D1FC:
    STA $6BD5
L_D1FF:
    INC $E1
L_D201:
    LDA $E1
L_D203:
    BEQ L_D20F
L_D205:
    JSR far_args_fetch
L_D208:
    INC $00,X
    .byte $80, $C6, $E1, $D0, $F6

L_D20F:
    LDA $5D
L_D211:
    BNE L_D217
L_D213:
    LDX $D3
L_D215:
    BNE L_D21A
L_D217:
    JMP L_D283
L_D21A:
    LDA $66C0,X
L_D21D:
    BEQ L_D27A
L_D21F:
    BIT $D7
L_D221:
    BVS L_D229
L_D223:
    LDA $D1
L_D225:
    CMP #$C8
L_D227:
    BCC L_D242
L_D229:
    LDA $6780,X
L_D22C:
    SEC
L_D22D:
    SBC #$08
L_D22F:
    STA $DE
L_D231:
    LDA $67C0,X
L_D234:
    SEC
L_D235:
    SBC #$07
L_D237:
    STA $DF
L_D239:
    LDY $6700,X
L_D23C:
    LDA $D2C9,Y
L_D23F:
    JMP L_D27A
L_D242:
    LDY $6700,X
L_D245:
    LDA $6780,X
L_D248:
    SEC
L_D249:
    SBC #$08
L_D24B:
    BCS L_D24F
L_D24D:
    LDA #$00
L_D24F:
    CMP $6ED5
L_D252:
    BCC L_D257
L_D254:
    LDA $6ED5
L_D257:
    STA $F0
L_D259:
    LDA $67C0,X
L_D25C:
    SEC
L_D25D:
    SBC #$07
L_D25F:
    BCS L_D263
L_D261:
    LDA #$00
L_D263:
    CMP $6ED6
L_D266:
    BCC L_D26B
L_D268:
    LDA $6ED6
L_D26B:
    STA $F1
L_D26D:
    JSR dir_index_calc
L_D270:
    PHA
L_D271:
    LDA $F0
L_D273:
    STA $DE
L_D275:
    LDA $F1
L_D277:
    STA $DF
L_D279:
    PLA
L_D27A:
    PHA
L_D27B:
    LDA $6840,X
L_D27E:
    TAX
L_D27F:
    PLA
L_D280:
    JSR camera_update
L_D283:
    LDA $E0
L_D285:
    BEQ L_D2A4
L_D287:
    TSX
L_D288:
    STX $E4
L_D28A:
    LDA #$80
L_D28C:
    STA $E3
L_D28E:
    JSR sub_8553
L_D291:
    JSR sub_8883
L_D294:
    LDA #$01
L_D296:
    STA $E5
L_D298:
    BIT $D7
L_D29A:
    BPL L_D2A4
L_D29C:
    LDA $6F49
L_D29F:
    BNE L_D2A4
L_D2A1:
    JSR sub_9010
L_D2A4:
    LDA #$00
L_D2A6:
    STA $E3
L_D2A8:
    PLA
L_D2A9:
    STA $C5
L_D2AB:
    PLA
L_D2AC:
    STA $C4
L_D2AE:
    PLA
L_D2AF:
    STA $EE
L_D2B1:
    PLA
L_D2B2:
    STA $ED
L_D2B4:
    PLA
L_D2B5:
    STA $EC
L_D2B7:
    PLA
L_D2B8:
    STA $EB
L_D2BA:
    PLA
L_D2BB:
    STA $C1
L_D2BD:
    PLA
L_D2BE:
    STA $C0
L_D2C0:
    PLA
L_D2C1:
    JSR set_winA000_a
L_D2C4:
    PLA
L_D2C5:
    JSR set_win8000_a
L_D2C8:
    RTS
    .byte $01, $04, $02, $03, $04, $01, $03, $02, $06, $07, $05, $08, $06, $07, $05, $08

dir_index_calc:
    LDA $F0
L_D2DB:
    CMP $DE
L_D2DD:
    BEQ L_D30B
L_D2DF:
    LDA $F1
L_D2E1:
    CMP $DF
L_D2E3:
    BEQ L_D2FF
L_D2E5:
    BPL L_D2F3
L_D2E7:
    LDA $F0
L_D2E9:
    CMP $DE
L_D2EB:
    BPL L_D2F0
L_D2ED:
    LDA #$05
L_D2EF:
    RTS
L_D2F0:
    LDA #$07
L_D2F2:
    RTS
L_D2F3:
    LDA $F0
L_D2F5:
    CMP $DE
L_D2F7:
    BPL L_D2FC
L_D2F9:
    LDA #$06
L_D2FB:
    RTS
L_D2FC:
    LDA #$08
L_D2FE:
    RTS
L_D2FF:
    LDA $F0
L_D301:
    CMP $DE
L_D303:
    BPL L_D308
L_D305:
    LDA #$02
L_D307:
    RTS
L_D308:
    LDA #$03
L_D30A:
    RTS
L_D30B:
    LDA $F1
L_D30D:
    CMP $DF
L_D30F:
    BEQ L_D319
L_D311:
    BPL L_D316
L_D313:
    LDA #$04
L_D315:
    RTS
L_D316:
    LDA #$01
L_D318:
    RTS
L_D319:
    LDA #$00
L_D31B:
    RTS
irq_work:
    BIT $E3
L_D31E:
    BPL L_D326
L_D320:
    LDX $E4
L_D322:
    TXS
L_D323:
    JMP L_D2A4
L_D326:
    RTI
    .byte $48, $20, $C5, $D5, $68, $AA, $A5, $F2, $9D, $00, $03, $A5, $F3, $9D, $01, $03
    .byte $A5, $F4, $9D, $20, $03, $A5, $F5, $9D, $21, $03, $A5, $F6, $9D, $40, $03, $A5
    .byte $F7, $9D, $41, $03, $A5, $F8, $9D, $60, $03, $A5, $F9, $9D, $61, $03, $60, $48
    .byte $20, $C5, $D5, $68, $AA, $A5, $F2, $9D, $00, $03, $A5, $F4, $9D, $01, $03, $A5
    .byte $F3, $9D, $20, $03, $A5, $F5, $9D, $21, $03, $A5, $F6, $9D, $40, $03, $A5, $F8
    .byte $9D, $41, $03, $A5, $F7, $9D, $60, $03, $A5, $F9, $9D, $61, $03, $60, $A5, $BC
    .byte $48, $98, $10, $02, $A0, $00, $C4, $E8, $90, $03, $A4, $E8, $88, $86, $FB, $84
    .byte $FC, $A2, $00, $8A, $48, $20, $C2, $D3, $E6, $FB, $68, $AA, $A5, $F2, $9D, $00
    .byte $03, $A5, $F3, $9D, $01, $03, $A5, $F6, $9D, $40, $03, $A5, $F7, $9D, $41, $03
    .byte $E8, $E8, $E0, $20, $90, $DD, $68, $20, $84, $C1, $60, $A6, $FB, $10, $02, $A2
    .byte $00, $E4, $E7, $90, $03, $A6, $E7, $CA, $A4, $FC, $20, $E6, $D6, $24, $D7, $10
    .byte $5B, $C9, $C0, $90, $57, $AA, $BC, $00, $68, $F0, $4E, $30, $4C, $B9, $B9, $D6
    .byte $85, $FA, $BC, $C0, $68, $A9, $F9, $20, $84, $C1, $B9, $B4, $83, $A8, $BD, $40
    .byte $66, $29, $03, $0A, $0A, $19, $D0, $DE, $85, $F0, $B9, $D0, $DD, $09, $90, $85
    .byte $F1, $A9, $EC, $20, $84, $C1, $A0, $00, $B1, $F0, $85, $F2, $C8, $B1, $F0, $85
    .byte $F3, $A5, $F1, $09, $98, $85, $F1, $B1, $F0, $29, $3F, $05, $FA, $85, $F7, $88
    .byte $B1, $F0, $29, $3F, $05, $FA, $85, $F6, $60, $BD, $80, $68, $A8, $A9, $CA, $20
    .byte $84, $C1, $B1, $E9, $85, $F0, $A9, $CB, $20, $84, $C1, $B1, $E9, $48, $29, $03
    .byte $06, $F0, $2A, $06, $F0, $2A, $06, $F0, $2A, $09, $80, $85, $F1, $68, $4A, $4A
    .byte $18, $69, $CC, $20, $84, $C1, $A0, $00, $B1, $F0, $85, $F2, $C8, $B1, $F0, $85
    .byte $F6, $C8, $B1, $F0, $85, $F3, $C8, $B1, $F0, $85, $F7, $60, $A5, $BC, $48, $98
    .byte $10, $02, $A0, $00, $C4, $E8, $90, $03, $A4, $E8, $88, $86, $FB, $84, $FC, $A2
    .byte $00, $8A, $48, $20, $B0, $D4, $E6, $FB, $68, $AA, $A5, $F4, $9D, $00, $03, $A5
    .byte $F5, $9D, $01, $03, $A5, $F8, $9D, $40, $03, $A5, $F9, $9D, $41, $03, $E8, $E8
    .byte $E0, $20, $90, $DD, $68, $20, $84, $C1, $60, $A6, $FB, $10, $02, $A2, $00, $E4
    .byte $E7, $90, $03, $A6, $E7, $CA, $A4, $FC, $20, $E6, $D6, $24, $D7, $10, $5B, $C9
    .byte $C0, $90, $57, $AA, $BC, $00, $68, $F0, $4E, $30, $4C, $B9, $B9, $D6, $85, $FA
    .byte $BC, $C0, $68, $A9, $F9, $20, $84, $C1, $B9, $B4, $83, $A8, $BD, $40, $66, $29
    .byte $03, $0A, $0A, $19, $D0, $DE, $85, $F0, $B9, $D0, $DD, $09, $90, $85, $F1, $A9
    .byte $EC, $20, $84, $C1, $A0, $02, $B1, $F0, $85, $F4, $C8, $B1, $F0, $85, $F5, $A5
    .byte $F1, $09, $98, $85, $F1, $B1, $F0, $29, $3F, $05, $FA, $85, $F9, $88, $B1, $F0
    .byte $29, $3F, $05, $FA, $85, $F8, $60, $BD, $80, $68, $A8, $A9, $CA, $20, $84, $C1
    .byte $B1, $E9, $85, $F0, $A9, $CB, $20, $84, $C1, $B1, $E9, $48, $29, $03, $06, $F0
    .byte $2A, $06, $F0, $2A, $06, $F0, $2A, $09, $80, $85, $F1, $68, $4A, $4A, $18, $69
    .byte $CC, $20, $84, $C1, $A0, $04, $B1, $F0, $85, $F4, $C8, $B1, $F0, $85, $F8, $C8
    .byte $B1, $F0, $85, $F5, $C8, $B1, $F0, $85, $F9, $60, $86, $FB, $84, $FC, $A2, $00
    .byte $8A, $48, $A6, $FB, $A4, $FC, $20, $C5, $D5, $E6, $FC, $68, $AA, $A5, $F2, $9D
    .byte $00, $03, $A5, $F4, $9D, $01, $03, $A5, $F6, $9D, $40, $03, $A5, $F8, $9D, $41
    .byte $03, $E8, $E8, $E0, $1E, $90, $D9, $60, $86, $FB, $84, $FC, $A2, $00, $8A, $48
    .byte $A6, $FB, $A4, $FC, $20, $C5, $D5, $E6, $FC, $68, $AA, $A5, $F3, $9D, $00, $03
    .byte $A5, $F5, $9D, $01, $03, $A5, $F7, $9D, $40, $03, $A5, $F9, $9D, $41, $03, $E8
    .byte $E8, $E0, $1E, $90, $D9, $60, $AA, $A5, $BC, $48, $8A, $4C, $E3, $D5

sprite_draw_core:
    LDA $BC
L_D5C7:
    PHA
L_D5C8:
    TXA
L_D5C9:
    BPL L_D5CD
L_D5CB:
    LDX #$00
L_D5CD:
    CPX $E7
L_D5CF:
    BCC L_D5D4
L_D5D1:
    LDX $E7
L_D5D3:
    DEX
L_D5D4:
    TYA
L_D5D5:
    BPL L_D5D9
L_D5D7:
    LDY #$00
L_D5D9:
    CPY $E8
L_D5DB:
    BCC L_D5E0
L_D5DD:
    LDY $E8
L_D5DF:
    DEY
L_D5E0:
    JSR map_cell_read
L_D5E3:
    BIT $D7
L_D5E5:
    BPL L_D662
L_D5E7:
    CMP #$C0
L_D5E9:
    BCC L_D662
L_D5EB:
    TAX
L_D5EC:
    LDY $6800,X
L_D5EF:
    BEQ L_D65F
L_D5F1:
    BMI L_D65F
L_D5F3:
    LDA $D6B9,Y
L_D5F6:
    STA $FA
L_D5F8:
    LDY $68C0,X
L_D5FB:
    LDA #$F9
L_D5FD:
    JSR set_win8000_a
L_D600:
    LDA $83B4,Y
L_D603:
    TAY
L_D604:
    LDA $6640,X
L_D607:
    AND #$03
L_D609:
    ASL
L_D60A:
    ASL
L_D60B:
    ORA $DED0,Y
L_D60E:
    STA $F0
L_D610:
    LDA $DDD0,Y
L_D613:
    ORA #$90
L_D615:
    STA $F1
L_D617:
    LDA #$EC
L_D619:
    JSR set_win8000_a
L_D61C:
    LDY #$00
L_D61E:
    LDA ($F0),Y
L_D620:
    STA $F2
L_D622:
    INY
L_D623:
    LDA ($F0),Y
L_D625:
    STA $F3
L_D627:
    INY
L_D628:
    LDA ($F0),Y
L_D62A:
    STA $F4
L_D62C:
    INY
L_D62D:
    LDA ($F0),Y
L_D62F:
    STA $F5
L_D631:
    LDA $F1
L_D633:
    ORA #$98
L_D635:
    STA $F1
L_D637:
    LDA ($F0),Y
L_D639:
    AND #$3F
L_D63B:
    ORA $FA
L_D63D:
    STA $F9
L_D63F:
    DEY
L_D640:
    LDA ($F0),Y
L_D642:
    AND #$3F
L_D644:
    ORA $FA
L_D646:
    STA $F8
L_D648:
    DEY
L_D649:
    LDA ($F0),Y
L_D64B:
    AND #$3F
L_D64D:
    ORA $FA
L_D64F:
    STA $F7
L_D651:
    DEY
L_D652:
    LDA ($F0),Y
L_D654:
    AND #$3F
L_D656:
    ORA $FA
L_D658:
    STA $F6
L_D65A:
    PLA
L_D65B:
    JSR set_win8000_a
L_D65E:
    RTS
L_D65F:
    LDA $6880,X
L_D662:
    TAY
L_D663:
    LDA #$CA
L_D665:
    JSR set_win8000_a
L_D668:
    LDA ($E9),Y
L_D66A:
    STA $F0
L_D66C:
    LDA #$CB
L_D66E:
    JSR set_win8000_a
L_D671:
    LDA ($E9),Y
L_D673:
    PHA
L_D674:
    AND #$03
L_D676:
    ASL $F0
L_D678:
    ROL
L_D679:
    ASL $F0
L_D67B:
    ROL
L_D67C:
    ASL $F0
L_D67E:
    ROL
L_D67F:
    ORA #$80
L_D681:
    STA $F1
L_D683:
    PLA
L_D684:
    LSR
L_D685:
    LSR
L_D686:
    CLC
L_D687:
    ADC #$CC
L_D689:
    JSR set_win8000_a
L_D68C:
    LDY #$00
L_D68E:
    LDA ($F0),Y
L_D690:
    STA $F2
L_D692:
    INY
L_D693:
    LDA ($F0),Y
L_D695:
    STA $F6
L_D697:
    INY
L_D698:
    LDA ($F0),Y
L_D69A:
    STA $F3
L_D69C:
    INY
L_D69D:
    LDA ($F0),Y
L_D69F:
    STA $F7
L_D6A1:
    INY
L_D6A2:
    LDA ($F0),Y
L_D6A4:
    STA $F4
L_D6A6:
    INY
L_D6A7:
    LDA ($F0),Y
L_D6A9:
    STA $F8
L_D6AB:
    INY
L_D6AC:
    LDA ($F0),Y
L_D6AE:
    STA $F5
L_D6B0:
    INY
L_D6B1:
    LDA ($F0),Y
L_D6B3:
    STA $F9
L_D6B5:
    PLA
L_D6B6:
    JSR set_win8000_a
L_D6B9:
    RTS
    .byte $10, $50, $90, $D0, $A9, $FF, $85, $F6, $85, $F7, $85, $F8, $85, $F9, $60, $8A
    .byte $30, $F2, $E4, $E7, $B0, $EE, $98, $30, $EB, $C4, $E8, $B0, $E7, $20, $E6, $D6
    .byte $C9, $C0, $B0, $E0, $AA, $A5, $BC, $48, $8A, $4C, $62, $D6

map_cell_read:
    TXA
L_D6E7:
    CLC
L_D6E8:
    ADC $D78F,Y
L_D6EB:
    STA $F0
L_D6ED:
    LDA $D757,Y
L_D6F0:
    ADC #$00
L_D6F2:
    STA $F1
L_D6F4:
    LDY #$00
L_D6F6:
    LDA ($F0),Y
L_D6F8:
    RTS
L_D6F9:
    PHA
L_D6FA:
    TXA
L_D6FB:
    CLC
L_D6FC:
    ADC $D78F,Y
L_D6FF:
    STA $F0
L_D701:
    LDA $D757,Y
L_D704:
    ADC #$00
L_D706:
    STA $F1
L_D708:
    LDY #$00
L_D70A:
    PLA
L_D70B:
    STA ($F0),Y
L_D70D:
    RTS
    .byte $20, $E6, $D6, $24, $D7, $10, $18, $C9, $C0, $90, $14, $A8, $B9, $80, $68, $C0
    .byte $D8, $B0, $06, $20, $2D, $D7, $09, $40, $60, $20, $2D, $D7, $09, $80, $60, $A8
    .byte $A5, $BC, $48, $A9, $CA, $20, $84, $C1, $B1, $E9, $85, $F0, $A9, $CB, $20, $84
    .byte $C1, $B1, $E9, $09, $80, $85, $F1, $A9, $EC, $20, $84, $C1, $A0, $00, $B1, $F0
    .byte $A8, $68, $20, $84, $C1, $98, $29, $3F, $60, $73, $73, $74, $74, $74, $74, $75
    .byte $75, $75, $75, $75, $76, $76, $76, $76, $77, $77, $77, $77, $77, $78, $78, $78
    .byte $78, $79, $79, $79, $79, $79, $7A, $7A, $7A, $7A, $7A, $7B, $7B, $7B, $7B, $7C
    .byte $7C, $7C, $7C, $7C, $7D, $7D, $7D, $7D, $7E, $7E, $7E, $7E, $7E, $7F, $7F, $7F
    .byte $7F, $C0, $F8, $30, $68, $A0, $D8, $10, $48, $80, $B8, $F0, $28, $60, $98, $D0
    .byte $08, $40, $78, $B0, $E8, $20, $58, $90, $C8, $00, $38, $70, $A8, $E0, $18, $50
    .byte $88, $C0, $F8, $30, $68, $A0, $D8, $10, $48, $80, $B8, $F0, $28, $60, $98, $D0
    .byte $08, $40, $78, $B0, $E8, $20, $58, $90, $C8, $03, $FF, $06, $04, $FF, $FF, $04
    .byte $05, $03, $03, $FF, $FF, $FF, $FF, $03, $05, $02, $FF, $02, $02, $02, $02, $02
    .byte $02, $02, $02, $FF, $FF, $FF, $FF, $02, $02, $03, $FF, $06, $04, $FF, $FF, $04
    .byte $05, $03, $03, $FF, $FF, $FF, $07, $03, $05, $02, $FF, $02, $02, $02, $02, $02
    .byte $02, $02, $02, $FF, $FF, $FF, $07, $02, $02, $60, $A9, $02, $8D, $04, $51, $A5
    .byte $BC, $48, $A5, $BD, $48, $A9, $C0, $20, $84, $C1, $A6, $D1, $BD, $00, $80, $85
    .byte $F0, $BD, $00, $81, $A8, $29, $0F, $06, $F0, $2A, $09, $80, $85, $F1, $B9, $D0
    .byte $DD, $09, $C0, $20, $84, $C1, $18, $69, $01, $20, $93, $C1, $A9, $00, $85, $F2
    .byte $85, $FC, $A9, $00, $85, $F3, $A9, $73, $85, $F4, $A9, $FF, $A0, $C0, $91, $F3
    .byte $C8, $D0, $FB, $E6, $F4, $10, $F7, $20, $CB, $DA, $85, $E7, $20, $CB, $DA, $85
    .byte $E8, $A9, $00, $85, $FB, $20, $3F, $DA, $85, $F7, $20, $3F, $DA, $85, $F8, $05
    .byte $F7, $C9, $01, $F0, $29, $A2, $06, $20, $A9, $DA, $85, $FA, $A2, $06, $20, $A9
    .byte $DA, $85, $F9, $A6, $FB, $A5, $F7, $9D, $00, $5C, $A5, $F8, $9D, $00, $5D, $A5
    .byte $F9, $9D, $00, $5E, $A5, $FA, $9D, $00, $5F, $E6, $FB, $4C, $63, $D8, $C6, $FB
    .byte $A5, $FB, $20, $79, $C1, $86, $FB, $A9, $00, $85, $F6, $A9, $00, $85, $F5, $A6
    .byte $F6, $18, $A5, $F5, $7D, $8F, $D7, $85, $F3, $BD, $57, $D7, $69, $00, $85, $F4
    .byte $A0, $00, $B1, $F3, $C9, $FF, $D0, $0C, $20, $D7, $DA, $B0, $1A, $20, $CB, $DA
    .byte $A0, $00, $91, $F3, $E6, $F5, $A5, $F5, $C5, $E7, $90, $D3, $E6, $F6, $A5, $F6
    .byte $C5, $E8, $90, $C7, $4C, $BB, $D9, $20, $D7, $DA, $B0, $29, $20, $5E, $DA, $85
    .byte $F7, $20, $5E, $DA, $85, $F8, $20, $CB, $DA, $AA, $8A, $A4, $F7, $88, $91, $F3
    .byte $88, $10, $FB, $18, $A5, $F3, $69, $38, $85, $F3, $90, $02, $E6, $F4, $C6, $F8
    .byte $D0, $E8, $4C, $D2, $D8, $20, $3F, $DA, $85, $F7, $20, $3F, $DA, $85, $F8, $05
    .byte $F7, $C9, $01, $D0, $1D, $A6, $FB, $20, $A9, $DA, $AA, $BD, $00, $5C, $85, $F7
    .byte $BD, $00, $5D, $85, $F8, $BD, $00, $5E, $85, $F9, $BD, $00, $5F, $85, $FA, $4C
    .byte $51, $D9, $A5, $F6, $20, $79, $C1, $20, $A9, $DA, $85, $FA, $A2, $06, $20, $A9
    .byte $DA, $85, $F9, $A6, $FA, $18, $A5, $F9, $7D, $8F, $D7, $85, $F9, $BD, $57, $D7
    .byte $69, $00, $85, $FA, $A6, $FC, $A5, $F7, $9D, $00, $07, $A5, $F8, $9D, $00, $60
    .byte $A5, $F3, $9D, $00, $61, $A5, $F4, $9D, $00, $62, $A5, $F9, $9D, $00, $63, $A5
    .byte $FA, $9D, $00, $64, $A9, $00, $85, $FD, $A4, $F7, $88, $B1, $F9, $C9, $FE, $90
    .byte $04, $A9, $FE, $E6, $FD, $91, $F3, $88, $10, $F1, $18, $A5, $F3, $69, $38, $85
    .byte $F3, $90, $02, $E6, $F4, $18, $A5, $F9, $69, $38, $85, $F9, $90, $02, $E6, $FA
    .byte $C6, $F8, $D0, $D4, $A5, $FD, $F0, $02, $E6, $FC, $4C, $D2, $D8, $A5, $FC, $F0
    .byte $77, $A2, $00, $86, $FB, $A4, $FB, $BD, $00, $07, $99, $00, $07, $85, $F7, $BD
    .byte $00, $60, $99, $00, $60, $85, $F8, $BD, $00, $61, $99, $00, $61, $85, $F3, $BD
    .byte $00, $62, $99, $00, $62, $85, $F4, $BD, $00, $63, $99, $00, $63, $85, $F9, $BD
    .byte $00, $64, $99, $00, $64, $85, $FA, $A9, $00, $85, $FD, $A4, $F7, $88, $B1, $F9
    .byte $C9, $FE, $90, $04, $A9, $FE, $E6, $FD, $91, $F3, $88, $10, $F1, $18, $A5, $F3
    .byte $69, $38, $85, $F3, $90, $02, $E6, $F4, $18, $A5, $F9, $69, $38, $85, $F9, $90
    .byte $02, $E6, $FA, $C6, $F8, $D0, $D4, $A5, $FD, $F0, $02, $E6, $FB, $E8, $E4, $FC
    .byte $90, $93, $A5, $FB, $85, $FC, $D0, $89, $68, $20, $93, $C1, $68, $20, $84, $C1
    .byte $60, $20, $D7, $DA, $B0, $03, $A9, $01, $60, $20, $D7, $DA, $B0, $07, $A9, $01
    .byte $20, $D7, $DA, $2A, $60, $A9, $01, $20, $D7, $DA, $2A, $20, $D7, $DA, $2A, $60
    .byte $20, $D7, $DA, $B0, $03, $A9, $01, $60, $20, $D7, $DA, $B0, $07, $20, $D7, $DA
    .byte $A9, $01, $2A, $60, $20, $D7, $DA, $B0, $0B, $A9, $01, $20, $D7, $DA, $2A, $20
    .byte $D7, $DA, $2A, $60, $20, $D7, $DA, $B0, $0F, $A9, $01, $20, $D7, $DA, $2A, $20
    .byte $D7, $DA, $2A, $20, $D7, $DA, $2A, $60, $A9, $01, $20, $D7, $DA, $2A, $20, $D7
    .byte $DA, $2A, $20, $D7, $DA, $2A, $20, $D7, $DA, $2A, $60, $A9, $00, $E0, $00, $F0
    .byte $08, $06, $F2, $F0, $05, $2A, $CA, $D0, $F8, $60, $48, $A0, $00, $B1, $F0, $E6
    .byte $F0, $D0, $02, $E6, $F1, $38, $2A, $85, $F2, $68, $4C, $B3, $DA, $A0, $00, $B1
    .byte $F0, $E6, $F0, $F0, $01, $60, $E6, $F1, $60, $06, $F2, $F0, $01, $60, $48, $A0
    .byte $00, $B1, $F0, $38, $2A, $85, $F2, $68, $E6, $F0, $F0, $01, $60, $E6, $F1, $60

mul16:
    CMP #$01
L_DAF0:
    BCC L_DB11
L_DAF2:
    BEQ L_DB13
L_DAF4:
    EOR #$FF
L_DAF6:
    LDY #$08
L_DAF8:
    DEY
L_DAF9:
    ASL
L_DAFA:
    BCS L_DAF8
L_DAFC:
    STA $EC
L_DAFE:
    LDA $EB
L_DB00:
    ASL
L_DB01:
    ROL $EC
L_DB03:
    BCS L_DB0B
L_DB05:
    ADC $EB
L_DB07:
    BCC L_DB0B
L_DB09:
    INC $EC
L_DB0B:
    DEY
L_DB0C:
    BNE L_DB00
L_DB0E:
    STA $EB
L_DB10:
    RTS
L_DB11:
    STA $EB
L_DB13:
    LDA #$00
L_DB15:
    STA $EC
L_DB17:
    RTS
    .byte $85, $EE, $98, $48, $A9, $00, $A0, $10, $0A, $26, $EB, $26, $EC, $90, $07, $18
    .byte $65, $EE, $90, $02, $E6, $EB, $88, $D0, $EF, $A4, $EC, $84, $ED, $A4, $EB, $84
    .byte $EC, $85, $EB, $68, $A8, $60, $85, $EE, $98, $48, $A9, $00, $A0, $10, $06, $EB
    .byte $26, $EC, $2A, $B0, $04, $C5, $EE, $90, $04, $E5, $EE, $E6, $EB, $88, $D0, $EE
    .byte $85, $EE, $68, $A8, $60, $85, $EE, $98, $48, $A9, $00, $A0, $18, $06, $EB, $26
    .byte $EC, $26, $ED, $2A, $B0, $04, $C5, $EE, $90, $04, $E5, $EE, $E6, $EB, $88, $D0
    .byte $EC, $85, $EE, $68, $A8, $60, $85, $EB, $A9, $00, $85, $EC, $A9, $00, $85, $ED
    .byte $A9, $00, $8D, $0A, $07, $A2, $09, $A9, $0A, $20, $5D, $DB, $A5, $EE, $18, $69
    .byte $30, $9D, $00, $07, $CA, $A5, $EB, $05, $EC, $05, $ED, $D0, $EA, $A9, $20, $9D
    .byte $00, $07, $CA, $10, $FA, $60, $20, $78, $C2, $85, $C2, $20, $78, $C2, $85, $C3
    .byte $A0, $00, $B1, $C2, $85, $EB, $C8, $B1, $C2, $85, $EC, $60, $20, $78, $C2, $85
    .byte $C2, $20, $78, $C2, $85, $C3, $A0, $00, $18, $B1, $C2, $65, $EB, $91, $C2, $C8
    .byte $B1, $C2, $65, $EC, $91, $C2, $60, $20, $84, $DB, $A2, $00, $BD, $00, $07, $C9
    .byte $20, $D0, $03, $E8, $D0, $F6, $A0, $00, $BD, $00, $07, $99, $EB, $6E, $F0, $04
    .byte $E8, $C8, $D0, $F4, $60

rand_next:
    TXA
L_DBFE:
    PHA
L_DBFF:
    TYA
L_DC00:
    PHA
L_DC01:
    LDX $6FED
L_DC04:
    TXA
L_DC05:
    SEC
L_DC06:
    SBC #$18
L_DC08:
    BCS L_DC0C
L_DC0A:
    ADC #$37
L_DC0C:
    TAY
L_DC0D:
    LDA $6FB6,X
L_DC10:
    EOR $6FB6,Y
L_DC13:
    STA $6FB6,X
L_DC16:
    INX
L_DC17:
    CPX #$37
L_DC19:
    BCC L_DC1D
L_DC1B:
    LDX #$00
L_DC1D:
    STX $6FED
L_DC20:
    STA $C4
L_DC22:
    PLA
L_DC23:
    TAY
L_DC24:
    PLA
L_DC25:
    TAX
L_DC26:
    LDA $C4
L_DC28:
    RTS
L_DC29:
    STA $EB
L_DC2B:
    TYA
L_DC2C:
    PHA
L_DC2D:
    JSR rand_next
L_DC30:
    JSR mul16
L_DC33:
    PLA
L_DC34:
    TAY
L_DC35:
    LDA $EC
L_DC37:
    RTS
    .byte $A9, $00, $85, $EB, $85, $EC, $A0, $04, $20, $FD, $DB, $18, $65, $EB, $85, $EB
    .byte $90, $02, $E6, $EC, $88, $D0, $F1, $60

L_DC50:
    TXA
L_DC51:
    BEQ L_DC8F
L_DC53:
    LDA $BC
L_DC55:
    PHA
L_DC56:
    LDA $BD
L_DC58:
    PHA
L_DC59:
    LDA $6881
L_DC5C:
    PHA
L_DC5D:
    LDA #$02
L_DC5F:
    STA $6881
L_DC62:
    CPX #$C9
L_DC64:
    BCS L_DC76
L_DC66:
    LDA #$F0
L_DC68:
    JSR set_win8000_a
L_DC6B:
    LDA #$F1
L_DC6D:
    JSR set_winA000_a
L_DC70:
    JSR sub_8000
L_DC73:
    JMP L_DC83
L_DC76:
    LDA #$F2
L_DC78:
    JSR set_win8000_a
L_DC7B:
    LDA #$F3
L_DC7D:
    JSR set_winA000_a
L_DC80:
    JSR sub_8000
L_DC83:
    PLA
L_DC84:
    STA $6881
L_DC87:
    PLA
L_DC88:
    JSR set_winA000_a
L_DC8B:
    PLA
L_DC8C:
    JSR set_win8000_a
L_DC8F:
    RTS
    .byte $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF
    .byte $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF
    .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
    .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
    .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
    .byte $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
    .byte $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
    .byte $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F
    .byte $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F
    .byte $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
    .byte $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F
    .byte $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF
    .byte $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF
    .byte $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF
    .byte $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF
    .byte $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF
    .byte $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF
    .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
    .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
    .byte $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
    .byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
    .byte $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05
    .byte $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
    .byte $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
    .byte $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
    .byte $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
    .byte $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
    .byte $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
    .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
    .byte $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    .byte $00, $01, $01, $01, $01, $01, $01, $07, $07, $07, $07, $07, $07, $0D, $0D, $0D
    .byte $0D, $0D, $0D, $13, $13, $13, $13, $13, $13, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

RESET:
    SEI
L_E001:
    CLD
L_E002:
    LDA #$00
L_E004:
    STA $2000
L_E007:
    LDA $2002
L_E00A:
    BPL L_E007
L_E00C:
    LDA $2002
L_E00F:
    BPL L_E00C
L_E011:
    LDA $2002
L_E014:
    BPL L_E011
L_E016:
    LDA #$00
L_E018:
    STA $2001
L_E01B:
    LDX #$00
L_E01D:
    STA $00,X
L_E01F:
    STA $0100,X
L_E022:
    STA $0200,X
L_E025:
    STA $0300,X
L_E028:
    STA $0400,X
L_E02B:
    STA $0500,X
L_E02E:
    STA $0600,X
L_E031:
    STA $0700,X
L_E034:
    INX
L_E035:
    BNE L_E01D
L_E037:
    LDX #$FF
L_E039:
    TXS
L_E03A:
    LDA #$08
L_E03C:
    STA $2000
L_E03F:
    LDA #$00
L_E041:
    STA $4010
L_E044:
    LDA #$40
L_E046:
    STA $4017
L_E049:
    STA $5010
L_E04C:
    STA $5204
L_E04F:
    LDA #$03
L_E051:
    STA $5100
L_E054:
    LDA #$03
L_E056:
    STA $5101
L_E059:
    LDA #$00
L_E05B:
    STA $5113
L_E05E:
    LDA #$FE
L_E060:
    STA $5116
L_E063:
    LDA #$FF
L_E065:
    STA $5117
L_E068:
    LDA #$00
L_E06A:
    STA $5130
L_E06D:
    LDA #$44
L_E06F:
    STA $5105
L_E072:
    LDA #$02
L_E074:
    STA $5102
L_E077:
    LDA #$01
L_E079:
    STA $5103
L_E07C:
    LDA #$01
L_E07E:
    STA $5104
L_E081:
    LDA #$00
L_E083:
    STA $5200
L_E086:
    LDA #$00
L_E088:
    STA $5201
L_E08B:
    LDA #$00
L_E08D:
    STA $5202
L_E090:
    JSR winctx_save
L_E093:
    JSR sub_B013
L_E096:
    JSR sub_A762
L_E099:
    LDA #$06
L_E09B:
    STA $03C6
L_E09E:
    LDA #$01
L_E0A0:
    STA $0688
L_E0A3:
    LDA #$14
L_E0A5:
    STA $03DB
L_E0A8:
    JSR audio_init
L_E0AB:
    JSR nametable_clear
L_E0AE:
    LDA #$E8
L_E0B0:
    STA $01
L_E0B2:
    STA $2001
L_E0B5:
    LDA #$A8
L_E0B7:
    STA $00
L_E0B9:
    STA $2000
L_E0BC:
    JMP main_loop
    .byte $A9, $00, $8D, $FC, $05, $A9, $DC, $8D, $03, $52, $8D, $FD, $05, $A9, $80, $8D
    .byte $04, $52, $58, $60, $C9, $00, $D0, $06, $A5, $01, $09, $06, $D0, $04, $A5, $01
    .byte $29, $F9, $85, $01, $8D, $01, $20, $60, $C9, $00, $F0, $06, $A5, $01, $09, $01
    .byte $D0, $04, $A5, $01, $29, $FE, $85, $01, $8D, $01, $20, $60, $AD, $02, $20, $A9
    .byte $20, $4C, $08, $E1

nametable_clear:
    LDA $2002
L_E106:
    LDA #$24
L_E108:
    STA $2006
L_E10B:
    LDA #$00
L_E10D:
    STA $2006
L_E110:
    LDY #$04
L_E112:
    LDA #$40
L_E114:
    LDX #$00
L_E116:
    STA $2007
L_E119:
    DEX
L_E11A:
    BNE L_E116
L_E11C:
    DEY
L_E11D:
    BNE L_E114
L_E11F:
    RTS
    .byte $A9, $3C, $A2, $00, $9D, $00, $5C, $9D, $00, $5D, $9D, $00, $5E, $9D, $00, $5F
    .byte $E8, $D0, $F1, $60, $A9, $00, $20, $A5, $EB, $20, $80, $EB, $20, $68, $A7, $20
    .byte $8D, $EB, $60

NMI_handler:
    INC $52
L_E145:
    PHA
L_E146:
    LDA #$00
L_E148:
    STA $54
L_E14A:
    TXA
L_E14B:
    PHA
L_E14C:
    TYA
L_E14D:
    PHA
L_E14E:
    PHA
L_E14F:
    LDA #$03
L_E151:
    STA $5800
L_E154:
    LDA #$01
L_E156:
    STA $5800
L_E159:
    PLA
L_E15A:
    LDA $BC
L_E15C:
    PHA
L_E15D:
    LDA $BD
L_E15F:
    PHA
L_E160:
    LDA #$FC
L_E162:
    JSR trampoline_A000
L_E165:
    LDA $E5
L_E167:
    BEQ L_E19B
L_E169:
    JSR sub_A757
L_E16C:
    JSR sub_AFCD
L_E16F:
    LDA $83
L_E171:
    STA $5120
L_E174:
    LDA $84
L_E176:
    STA $5121
L_E179:
    LDA $85
L_E17B:
    STA $5122
L_E17E:
    LDA $86
L_E180:
    STA $5123
L_E183:
    LDA $87
L_E185:
    STA $5124
L_E188:
    LDA $88
L_E18A:
    STA $5125
L_E18D:
    LDA $89
L_E18F:
    STA $5126
L_E192:
    LDA $8A
L_E194:
    STA $5127
L_E197:
    LDA #$00
L_E199:
    STA $E5
L_E19B:
    JSR scroll_ppu_update
L_E19E:
    LDA $53
L_E1A0:
    BEQ L_E1A9
L_E1A2:
    JSR hud_dispatch
L_E1A5:
    LDA #$00
L_E1A7:
    STA $53
L_E1A9:
    CLI
L_E1AA:
    JSR oam_dma
L_E1AD:
    PHA
L_E1AE:
    LDA #$00
L_E1B0:
    STA $5800
L_E1B3:
    PLA
L_E1B4:
    JSR pad_read
L_E1B7:
    JSR sub_A22E
L_E1BA:
    JSR sub_E219
L_E1BD:
    LDA $05FE
L_E1C0:
    BNE L_E1C7
L_E1C2:
    BIT $5204
L_E1C5:
    BVC L_E1BD
L_E1C7:
    LDA $62
L_E1C9:
    BEQ L_E1D2
L_E1CB:
    LDX #$00
L_E1CD:
    STX $62
L_E1CF:
    JSR split_update
L_E1D2:
    JSR far_call_routine
L_E1D5:
    LDA $0402
L_E1D8:
    BNE L_E1E1
L_E1DA:
    LDA $69
L_E1DC:
    BEQ L_E1E1
L_E1DE:
    JSR save_commit
L_E1E1:
    LDA #$FE
L_E1E3:
    STA $5116
L_E1E6:
    JSR nmi_mid_hook
L_E1E9:
    LDX #$10
L_E1EB:
    JSR stack_load_x
L_E1EE:
    LDA #$00
L_E1F0:
    STA $63
L_E1F2:
    JSR music_tick
L_E1F5:
    PLA
L_E1F6:
    JSR trampoline_A000
L_E1F9:
    PLA
L_E1FA:
    JSR trampoline_8000
L_E1FD:
    PLA
L_E1FE:
    TAY
L_E1FF:
    PLA
L_E200:
    TAX
L_E201:
    PLA
L_E202:
    DEC $52
L_E204:
    RTI
pad_read:
    LDA $63
L_E207:
    BEQ L_E210
L_E209:
    LDA $52
L_E20B:
    CMP #$02
L_E20D:
    BEQ L_E210
L_E20F:
    RTS
L_E210:
    LDA #$01
L_E212:
    STA $63
L_E214:
    LDX #$10
L_E216:
    JMP stack_save_x
L_E219:
    LDA $05FB
L_E21C:
    BNE L_E21F
L_E21E:
    RTS
L_E21F:
    JSR irq_vec_dispatch
L_E222:
    LDA #$00
L_E224:
    STA $05FB
L_E227:
    RTS
irq_vec_dispatch:
    ASL
L_E229:
    TAX
L_E22A:
    LDA $E23F,X
L_E22D:
    STA $05F9
L_E230:
    INX
L_E231:
    LDA $E23F,X
L_E234:
    STA $05FA
L_E237:
    BIT $5204
L_E23A:
    BVC L_E237
L_E23C:
    JMP ($05F9)
    .byte $00, $00, $19, $AE, $46, $AE, $6F, $AE, $92, $AE, $C9, $AE, $FC, $AE, $C8, $B0
    .byte $B8, $B1, $7D, $B2, $0C, $B3, $07, $A0, $08, $A0, $09, $A0, $08, $AE

hud_dispatch:
    ASL
L_E25E:
    TAX
L_E25F:
    LDA $E26F,X
L_E262:
    STA $05F9
L_E265:
    INX
L_E266:
    LDA $E26F,X
L_E269:
    STA $05FA
L_E26C:
    JMP ($05F9)
    .byte $00, $00, $42, $B1, $3D, $AF, $8B, $E2, $9F, $AF, $3A, $B0, $37, $B2, $2F, $B0
    .byte $45, $EA, $F6, $AF, $00, $00, $00, $00, $AD, $B0, $AA, $B2, $60, $A9, $01, $D0
    .byte $26, $A9, $02, $D0, $22, $A9, $04, $D0, $1E, $A9, $05, $D0, $1A

hud_flag_set:
    LDA #$06
L_E29E:
    BNE L_E2B6
L_E2A0:
    LDA #$07
L_E2A2:
    BNE L_E2B6
L_E2A4:
    LDA #$08
L_E2A6:
    BNE L_E2B6
L_E2A8:
    LDA #$0C
L_E2AA:
    BNE L_E2B6
L_E2AC:
    LDA #$09
L_E2AE:
    BNE L_E2B6
L_E2B0:
    LDA #$0D
L_E2B2:
    BNE L_E2B6
hud_wait:
    LDA #$03
L_E2B6:
    STA $53
L_E2B8:
    LDA $53
L_E2BA:
    BNE L_E2B8
L_E2BC:
    RTS
hud_frame_delay:
    JSR hud_wait
L_E2C0:
    DEX
L_E2C1:
    BNE hud_frame_delay
L_E2C3:
    RTS
IRQ_handler:
    SEI
L_E2C5:
    PHA
L_E2C6:
    TXA
L_E2C7:
    PHA
L_E2C8:
    LDA $5204
L_E2CB:
    LDA $6FB5
L_E2CE:
    CMP #$01
L_E2D0:
    BEQ L_E2EA
L_E2D2:
    LDA #$01
L_E2D4:
    STA $54
L_E2D6:
    LDX #$DC
L_E2D8:
    STX $05FD
L_E2DB:
    STX $5203
L_E2DE:
    LDA #$80
L_E2E0:
    STA $5204
L_E2E3:
    PLA
L_E2E4:
    TAX
L_E2E5:
    PLA
L_E2E6:
    CLI
L_E2E7:
    JMP irq_work
L_E2EA:
    TXA
L_E2EB:
    PHA
L_E2EC:
    LDX $05FC
L_E2EF:
    LDA $2002
L_E2F2:
    LDA $0700,X
L_E2F5:
    BMI L_E2FF
L_E2F7:
    CLC
L_E2F8:
    ADC $5B
L_E2FA:
    BCC L_E310
L_E2FC:
    JMP L_E304
L_E2FF:
    CLC
L_E300:
    ADC $5B
L_E302:
    BCS L_E310
L_E304:
    PHA
L_E305:
    LDA $00
L_E307:
    EOR #$01
L_E309:
    STA $2000
L_E30C:
    PLA
L_E30D:
    JMP L_E317
L_E310:
    PHA
L_E311:
    LDA $00
L_E313:
    STA $2000
L_E316:
    PLA
L_E317:
    STA $2005
L_E31A:
    INX
L_E31B:
    CPX #$0E
L_E31D:
    BEQ L_E325
L_E31F:
    INC $05FC
L_E322:
    JMP L_E32A
L_E325:
    LDX #$00
L_E327:
    STX $05FC
L_E32A:
    LDA $E33D,X
L_E32D:
    STA $05FD
L_E330:
    STA $5203
L_E333:
    LDA #$80
L_E335:
    STA $5204
L_E338:
    PLA
L_E339:
    TAX
L_E33A:
    PLA
L_E33B:
    CLI
L_E33C:
    RTI
    .byte $11, $21, $31, $41, $51, $61, $71, $81, $91, $A1, $B1, $C1, $D1, $E1

far_call_routine:
    LDA $068C
L_E34E:
    JSR trampoline_8000
L_E351:
    LDA $068D
L_E354:
    JSR trampoline_A000
L_E357:
    LDA #$FD
L_E359:
    STA $5116
L_E35C:
    JSR main_loop
L_E35F:
    RTS
    .byte $20, $03, $A0, $8E, $02, $06, $8D, $03, $06, $A4, $56, $8C, $00, $06, $A4, $57
    .byte $8C, $01, $06, $8E, $05, $06, $AA, $20, $07, $D8, $AD, $05, $06, $20, $57, $E4
    .byte $20, $B4, $E2, $A5, $00, $29, $F8, $85, $00, $8D, $00, $20, $A9, $01, $8D, $FE
    .byte $05, $A5, $01, $29, $E1, $85, $01, $8D, $01, $20, $A9, $00, $85, $5B, $85, $5A
    .byte $85, $58, $85, $59, $20, $8C, $E9, $A9, $01, $8D, $04, $51, $A5, $01, $09, $18
    .byte $85, $01, $8D, $01, $20, $20, $B4, $E2, $A9, $00, $8D, $FE, $05, $A9, $EF, $85
    .byte $5C, $60, $20, $B4, $E2, $A9, $00, $85, $53, $20, $B4, $E2, $A5, $00, $29, $F8
    .byte $85, $00, $8D, $00, $20, $A9, $01, $8D, $FE, $05, $A5, $01, $29, $E1, $85, $01
    .byte $8D, $01, $20, $A9, $00, $8D, $FF, $05, $85, $5B, $85, $5C, $85, $58, $85, $59
    .byte $A9, $08, $85, $5A, $A9, $02, $8D, $04, $51, $20, $FB, $E0, $20, $03, $E1, $20
    .byte $20, $E1, $A9, $01, $8D, $04, $51, $A9, $50, $8D, $05, $51, $A5, $01, $09, $18
    .byte $85, $01, $8D, $01, $20, $20, $B4, $E2, $A9, $00, $8D, $FE, $05, $A9, $01, $85
    .byte $55, $60, $AD, $FF, $05, $D0, $FB, $A9, $00, $85, $55, $20, $0D, $EA, $A9, $44
    .byte $8D, $05, $51, $A9, $02, $8D, $04, $51, $60, $A9, $01, $8D, $C0, $03, $60, $86
    .byte $56, $84, $57, $20, $E8, $E9, $A9, $02, $8D, $C0, $03, $60

oam_buffer_clear:
    LDX #$00
L_E44E:
    LDA #$F0
L_E450:
    STA $0200,X
L_E453:
    INX
L_E454:
    BNE L_E450
L_E456:
    RTS
    .byte $0A, $0A, $0A, $0A, $A8, $A2, $00, $B9, $00, $FB, $9D, $A0, $03, $C8, $E8, $E0
    .byte $10, $D0, $F4, $60, $8A, $48, $AD, $C9, $03, $38, $E9, $02, $AA, $BD, $B0, $E4
    .byte $85, $02, $BD, $CC, $E4, $85, $03, $AD, $C8, $03, $38, $E9, $02, $18, $65, $02
    .byte $85, $02, $A9, $00, $65, $03, $85, $03, $18, $A9, $00, $65, $02, $85, $02, $85
    .byte $04, $A9, $60, $65, $03, $85, $03, $85, $05, $18, $A9, $1C, $65, $04, $85, $04
    .byte $A9, $00, $65, $05, $85, $05, $68, $AA, $60, $00, $1C, $38, $54, $70, $8C, $A8
    .byte $C4, $E0, $FC, $18, $34, $50, $6C, $88, $A4, $C0, $DC, $F8, $14, $30, $4C, $68
    .byte $84, $A0, $BC, $D8, $F4, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
    .byte $01, $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02
    .byte $02, $AD, $C8, $03, $85, $08, $AD, $C9, $03, $85, $09, $4C, $F9, $E4, $86, $08
    .byte $84, $09

L_E4F9:
    TYA
L_E4FA:
    PHA
L_E4FB:
    LDA $5A
L_E4FD:
    ORA #$20
L_E4FF:
    STA $06
L_E501:
    LDA $59
L_E503:
    CLC
L_E504:
    ADC $09
L_E506:
    CMP #$1E
L_E508:
    BCC L_E50C
L_E50A:
    SBC #$1E
L_E50C:
    STA $04
L_E50E:
    LDA #$1E
L_E510:
    SEC
L_E511:
    SBC $04
L_E513:
    STA $03D1
L_E516:
    LDA $58
L_E518:
    CLC
L_E519:
    ADC $08
L_E51B:
    STA $05
L_E51D:
    CMP #$20
L_E51F:
    BCC L_E52B
L_E521:
    SBC #$20
L_E523:
    STA $05
L_E525:
    LDA $06
L_E527:
    EOR #$04
L_E529:
    STA $06
L_E52B:
    LDA #$20
L_E52D:
    SEC
L_E52E:
    SBC $05
L_E530:
    STA $03D0
L_E533:
    LDA $04
L_E535:
    LSR
L_E536:
    LSR
L_E537:
    LSR
L_E538:
    STA $0605
L_E53B:
    LDA $04
L_E53D:
    AND #$07
L_E53F:
    TAY
L_E540:
    LDA $E584,Y
L_E543:
    CLC
L_E544:
    ADC $05
L_E546:
    STA $02
L_E548:
    STA $04
L_E54A:
    LDA $0605
L_E54D:
    ORA $06
L_E54F:
    ADC #$00
L_E551:
    STA $03
L_E553:
    AND #$03
L_E555:
    CLC
L_E556:
    ADC #$5C
L_E558:
    STA $05
L_E55A:
    PLA
L_E55B:
    TAY
L_E55C:
    RTS
    .byte $45, $5A, $8D, $05, $06, $98, $4A, $4A, $4A, $09, $20, $0D, $05, $06, $8D, $F4
    .byte $03, $29, $23, $18, $69, $3C, $85, $10, $98, $48, $29, $07, $A8, $8A, $18, $79
    .byte $84, $E5, $85, $0F, $68, $A8, $60, $00, $20, $40, $60, $80, $A0, $C0, $E0

metasprite_blit:
    STX $0676
L_E58F:
    LDX #$00
L_E591:
    LDA $0606,X
L_E594:
    SEC
L_E595:
    SBC $56
L_E597:
    ASL
L_E598:
    STA $08
L_E59A:
    LDA $060E,X
L_E59D:
    SEC
L_E59E:
    SBC $57
L_E5A0:
    ASL
L_E5A1:
    STA $09
L_E5A3:
    JSR sub_E4F9
L_E5A6:
    LDA $02
L_E5A8:
    STA $065E,X
L_E5AB:
    LDA $03
L_E5AD:
    STA $066E,X
L_E5B0:
    LDA $04
L_E5B2:
    STA $0656,X
L_E5B5:
    LDA $05
L_E5B7:
    STA $0666,X
L_E5BA:
    INX
L_E5BB:
    CPX $0676
L_E5BE:
    BNE L_E591
L_E5C0:
    JSR hud_flag_set
L_E5C3:
    RTS
    .byte $8E, $76, $06, $A2, $00, $BD, $06, $06, $85, $08, $BD, $0E, $06, $85, $09, $20
    .byte $F9, $E4, $A5, $02, $9D, $00, $07, $A5, $03, $9D, $20, $07, $A5, $04, $9D, $40
    .byte $07, $A5, $05, $9D, $60, $07, $E6, $08, $20, $F9, $E4, $A5, $02, $9D, $08, $07
    .byte $A5, $03, $9D, $28, $07, $A5, $04, $9D, $48, $07, $A5, $05, $9D, $68, $07, $E6
    .byte $09, $20, $F9, $E4, $A5, $02, $9D, $18, $07, $A5, $03, $9D, $38, $07, $A5, $04
    .byte $9D, $58, $07, $A5, $05, $9D, $78, $07, $C6, $08, $20, $F9, $E4, $A5, $02, $9D
    .byte $10, $07, $A5, $03, $9D, $30, $07, $A5, $04, $9D, $50, $07, $A5, $05, $9D, $70
    .byte $07, $E8, $EC, $76, $06, $D0, $8E, $20, $B0, $E2, $60

camera_update:
    STA $5E
L_E641:
    CMP #$00
L_E643:
    BEQ L_E658
L_E645:
    SBC #$01
L_E647:
    ASL
L_E648:
    STA $5F
L_E64A:
    TXA
L_E64B:
    LSR
L_E64C:
    STA $61
L_E64E:
    JSR camera_step
L_E651:
    LDA #$00
L_E653:
    STA $60
L_E655:
    JSR sub_E7CA
L_E658:
    LDA #$01
L_E65A:
    STA $5D
L_E65C:
    RTS
    .byte $03, $03, $02, $00, $00, $04, $04, $03, $00, $00, $10, $08, $04, $00, $02, $11
    .byte $09, $05, $00, $03, $12, $0A, $06, $00, $00, $13, $0B, $07, $00, $00, $1F, $10
    .byte $08, $00, $04

scroll_ppu_update:
    LDA $55
L_E682:
    BEQ L_E687
L_E684:
    JMP L_A00A
L_E687:
    LDA $5D
L_E689:
    BEQ L_E6D8
L_E68B:
    INC $5D
L_E68D:
    LDX $5E
L_E68F:
    BEQ L_E6E1
L_E691:
    LDY $61
L_E693:
    CPY #$04
L_E695:
    BNE L_E69E
L_E697:
    CPX #$05
L_E699:
    BCC L_E69E
L_E69B:
    JMP L_E766
L_E69E:
    CMP #$20
L_E6A0:
    BEQ L_E6E1
L_E6A2:
    CMP #$01
L_E6A4:
    BEQ L_E6E6
L_E6A6:
    CMP $E667,Y
L_E6A9:
    BEQ L_E6EF
L_E6AB:
    CMP $E66C,Y
L_E6AE:
    BEQ L_E6F8
L_E6B0:
    CPX #$05
L_E6B2:
    BCC L_E6D0
L_E6B4:
    LDX #$F8
L_E6B6:
    CMP $E65D,Y
L_E6B9:
    BEQ L_E70A
L_E6BB:
    LDX #$00
L_E6BD:
    CMP $E662,Y
L_E6C0:
    BEQ L_E70A
L_E6C2:
    LDX #$08
L_E6C4:
    CMP $E671,Y
L_E6C7:
    BEQ L_E70A
L_E6C9:
    LDX #$10
L_E6CB:
    CMP $E676,Y
L_E6CE:
    BEQ L_E70A
L_E6D0:
    CMP $E67B,Y
L_E6D3:
    BEQ L_E6D9
L_E6D5:
    JSR camera_dispatch
L_E6D8:
    RTS
L_E6D9:
    JSR camera_dispatch
L_E6DC:
    LDA $61
L_E6DE:
    BNE L_E6E1
L_E6E0:
    RTS
L_E6E1:
    LDA #$00
L_E6E3:
    STA $5D
L_E6E5:
    RTS
L_E6E6:
    JSR camera_dispatch
L_E6E9:
    LDA #$10
L_E6EB:
    JSR sub_E7CA
L_E6EE:
    RTS
L_E6EF:
    JSR camera_dispatch
L_E6F2:
    LDA #$20
L_E6F4:
    JSR sub_E7CA
L_E6F7:
    RTS
L_E6F8:
    PHA
L_E6F9:
    JSR camera_dispatch
L_E6FC:
    LDA #$30
L_E6FE:
    JSR sub_E7CA
L_E701:
    PLA
L_E702:
    LDY $61
L_E704:
    CMP $E67B,Y
L_E707:
    BEQ L_E6D9
L_E709:
    RTS
L_E70A:
    PHA
L_E70B:
    JSR sub_E71F
L_E70E:
    PLA
L_E70F:
    LDY $61
L_E711:
    CMP $E67B,Y
L_E714:
    BNE L_E71E
L_E716:
    CPY #$00
L_E718:
    BEQ L_E71E
L_E71A:
    LDA #$00
L_E71C:
    STA $5D
L_E71E:
    RTS
L_E71F:
    TXA
L_E720:
    CMP #$F8
L_E722:
    BEQ L_E73E
L_E724:
    CMP #$08
L_E726:
    BEQ L_E73E
L_E728:
    CLC
L_E729:
    ADC $5F
L_E72B:
    TAX
L_E72C:
    LDA $E746,X
L_E72F:
    STA $067F
L_E732:
    LDA $E747,X
L_E735:
    STA $0680
L_E738:
    JSR camera_dispatch
L_E73B:
    JMP ($067F)
L_E73E:
    PHA
L_E73F:
    JSR pad_read
L_E742:
    PLA
L_E743:
    JMP L_E728
    .byte $77, $FD, $B0, $FD, $13, $FE, $76, $FE, $D6, $B0, $D6, $B0, $D6, $B0, $D6, $B0
    .byte $85, $FD, $CA, $FD, $2D, $FE, $93, $FE, $D6, $B0, $D6, $B0, $D6, $B0, $D6, $B0

L_E766:
    CMP #$01
L_E768:
    BEQ L_E77C
L_E76A:
    CMP #$02
L_E76C:
    BEQ L_E789
L_E76E:
    CMP #$03
L_E770:
    BEQ L_E793
L_E772:
    LDX #$10
L_E774:
    JSR sub_E70A
L_E777:
    LDA #$00
L_E779:
    STA $5D
L_E77B:
    RTS
L_E77C:
    JSR camera_dispatch
L_E77F:
    LDA #$10
L_E781:
    JSR sub_E7CA
L_E784:
    LDA #$01
L_E786:
    JMP L_E79D
L_E789:
    LDX #$00
L_E78B:
    JSR sub_E70A
L_E78E:
    LDA #$02
L_E790:
    JMP L_E79D
L_E793:
    JSR camera_dispatch
L_E796:
    LDA #$30
L_E798:
    JSR sub_E7CA
L_E79B:
    LDA #$03
L_E79D:
    STA $62
L_E79F:
    RTS
split_update:
    CMP #$03
L_E7A2:
    BEQ L_E7B2
L_E7A4:
    CMP #$02
L_E7A6:
    BEQ L_E7AD
L_E7A8:
    LDA #$F8
L_E7AA:
    JMP L_E7B4
L_E7AD:
    LDA #$20
L_E7AF:
    JMP L_E7CA
L_E7B2:
    LDA #$08
L_E7B4:
    CLC
L_E7B5:
    ADC $5F
L_E7B7:
    TAX
L_E7B8:
    LDA $E746,X
L_E7BB:
    STA $067F
L_E7BE:
    LDA $E747,X
L_E7C1:
    STA $0680
L_E7C4:
    JSR pad_read
L_E7C7:
    JMP ($067F)
L_E7CA:
    CMP #$20
L_E7CC:
    BNE L_E7D3
L_E7CE:
    PHA
L_E7CF:
    JSR pad_read
L_E7D2:
    PLA
L_E7D3:
    CLC
L_E7D4:
    ADC $5F
L_E7D6:
    TAX
L_E7D7:
    LDA $E7E6,X
L_E7DA:
    STA $067D
L_E7DD:
    LDA $E7E7,X
L_E7E0:
    STA $067E
L_E7E3:
    JMP ($067D)
    .byte $83, $FC, $46, $FC, $00, $FC, $CB, $FC, $59, $FD, $8F, $FD, $E3, $FD, $43, $FE
    .byte $D6, $B0, $DE, $B0, $DE, $B0, $D6, $B0, $DE, $B0, $DE, $B0, $DE, $B0, $DE, $B0
    .byte $97, $FC, $52, $FC, $14, $FC, $D7, $FC, $6B, $FD, $A1, $FD, $FB, $FD, $5B, $FE
    .byte $D6, $B0, $DE, $B0, $DE, $B0, $D6, $B0, $DE, $B0, $DE, $B0, $DE, $B0, $DE, $B0

camera_step:
    LDA $5E
L_E828:
    CMP #$04
L_E82A:
    BEQ L_E84A
L_E82C:
    CMP #$03
L_E82E:
    BEQ L_E84D
L_E830:
    CMP #$01
L_E832:
    BEQ L_E850
L_E834:
    CMP #$02
L_E836:
    BEQ L_E853
L_E838:
    CMP #$05
L_E83A:
    BEQ L_E856
L_E83C:
    CMP #$06
L_E83E:
    BEQ L_E85C
L_E840:
    CMP #$07
L_E842:
    BEQ L_E862
L_E844:
    JSR sub_E84D
L_E847:
    JMP L_E850
L_E84A:
    DEC $57
L_E84C:
    RTS
L_E84D:
    INC $56
L_E84F:
    RTS
L_E850:
    INC $57
L_E852:
    RTS
L_E853:
    DEC $56
L_E855:
    RTS
L_E856:
    JSR sub_E853
L_E859:
    JMP L_E84A
L_E85C:
    JSR sub_E853
L_E85F:
    JMP L_E850
L_E862:
    JSR sub_E84D
L_E865:
    JMP L_E84A
camera_dispatch:
    LDA $61
L_E86A:
    BNE L_E877
L_E86C:
    LDA $60
L_E86E:
    EOR #$FF
L_E870:
    STA $60
L_E872:
    BNE L_E877
L_E874:
    JMP oam_dma
L_E877:
    LDX $5F
L_E879:
    LDA $E88C,X
L_E87C:
    STA $067D
L_E87F:
    LDA $E88D,X
L_E882:
    STA $067E
L_E885:
    LDA $61
L_E887:
    LSR
L_E888:
    TAX
L_E889:
    JMP ($067D)
    .byte $CD, $E8, $9C, $E8, $BD, $E8, $AC, $E8, $E0, $E8, $E6, $E8, $EC, $E8, $F2, $E8
    .byte $A5, $5B, $38, $FD, $F8, $E8, $85, $5B, $B0, $03, $20, $01, $E9, $4C, $08, $E9
    .byte $A5, $5C, $38, $FD, $F8, $E8, $C9, $FF, $D0, $02, $A9, $EF, $85, $5C, $4C, $08
    .byte $E9, $A5, $5B, $18, $7D, $F8, $E8, $85, $5B, $D0, $03, $20, $01, $E9, $4C, $08
    .byte $E9, $A5, $5C, $18, $7D, $F8, $E8, $DD, $FB, $E8, $D0, $03, $BD, $FE, $E8, $85
    .byte $5C, $4C, $08, $E9, $20, $9C, $E8, $4C, $AC, $E8, $20, $9C, $E8, $4C, $CD, $E8
    .byte $20, $BD, $E8, $4C, $AC, $E8, $20, $BD, $E8, $4C, $CD, $E8, $01, $02, $04, $F0
    .byte $F1, $F3, $00, $01, $03, $A5, $00, $49, $01, $85, $00, $60

oam_dma:
    LDA $2002
L_E90B:
    LDA $64
L_E90D:
    ORA $65
L_E90F:
    BNE L_E921
L_E911:
    LDA $5B
L_E913:
    STA $2005
L_E916:
    LDA $5C
L_E918:
    STA $2005
L_E91B:
    LDA $00
L_E91D:
    STA $2000
L_E920:
    RTS
L_E921:
    LDA $64
L_E923:
    BMI L_E943
L_E925:
    CLC
L_E926:
    ADC $5B
L_E928:
    BCC L_E948
L_E92A:
    STA $2005
L_E92D:
    LDA $5C
L_E92F:
    CLC
L_E930:
    ADC $65
L_E932:
    CMP #$F0
L_E934:
    BCC L_E938
L_E936:
    AND #$0F
L_E938:
    STA $2005
L_E93B:
    LDA $00
L_E93D:
    EOR #$01
L_E93F:
    STA $2000
L_E942:
    RTS
L_E943:
    CLC
L_E944:
    ADC $5B
L_E946:
    BCC L_E92A
L_E948:
    STA $2005
L_E94B:
    LDA $5C
L_E94D:
    CLC
L_E94E:
    ADC $65
L_E950:
    CMP #$F0
L_E952:
    BCC L_E956
L_E954:
    AND #$0F
L_E956:
    STA $2005
L_E959:
    LDA $00
L_E95B:
    STA $2000
L_E95E:
    RTS
    .byte $20, $65, $E9, $4C, $80, $EB, $A5, $57, $48, $A9, $0F, $85, $71, $A2, $00, $20
    .byte $7D, $E9, $E8, $E8, $E6, $57, $C6, $71, $D0, $F5, $68, $85, $57, $60, $86, $70
    .byte $8A, $A6, $56, $A4, $57, $20, $56, $D3, $A6, $70, $60, $60, $60, $A5, $57, $48
    .byte $A9, $20, $8D, $F4, $03, $A9, $5C, $85, $10, $A9, $00, $85, $0F, $A9, $0F, $85
    .byte $72, $20, $E8, $E9, $AD, $02, $20, $AD, $F4, $03, $8D, $06, $20, $A5, $0F, $8D
    .byte $06, $20, $A2, $00, $BD, $00, $03, $8D, $07, $20, $E8, $E0, $40, $D0, $F5, $A0
    .byte $00, $B9, $40, $03, $91, $0F, $C8, $C0, $40, $D0, $F6, $A5, $0F, $18, $69, $40
    .byte $85, $0F, $AD, $F4, $03, $69, $00, $8D, $F4, $03, $18, $69, $3C, $85, $10, $E6
    .byte $57, $C6, $72, $D0, $BC, $68, $85, $57, $60, $A5, $56, $48, $A9, $10, $85, $71
    .byte $A2, $00, $20, $00, $EA, $E8, $E8, $E6, $56, $C6, $71, $D0, $F5, $68, $85, $56
    .byte $60, $86, $70, $8A, $A6, $56, $A4, $57, $20, $27, $D3, $A6, $70, $60

sprite_frame_step:
    LDA #$00
L_EA0F:
    STA $74
L_EA11:
    LDA $74
L_EA13:
    STA $66
L_EA15:
    STA $67
L_EA17:
    JSR sub_E2A4
L_EA1A:
    LDX $0688
L_EA1D:
    JSR hud_frame_delay
L_EA20:
    DEC $74
L_EA22:
    LDA $74
L_EA24:
    CMP #$FB
L_EA26:
    BNE L_EA11
L_EA28:
    RTS
L_EA29:
    LDA #$FC
L_EA2B:
    STA $74
L_EA2D:
    LDA $74
L_EA2F:
    STA $66
L_EA31:
    STA $67
L_EA33:
    JSR sub_E2A4
L_EA36:
    LDX $0688
L_EA39:
    JSR hud_frame_delay
L_EA3C:
    INC $74
L_EA3E:
    LDA $74
L_EA40:
    CMP #$01
L_EA42:
    BNE L_EA2D
L_EA44:
    RTS
    .byte $A0, $00, $98, $48, $A2, $04, $A5, $66, $20, $63, $EA, $C8, $C8, $C8, $C8, $CA
    .byte $D0, $F4, $68, $A8, $C8, $C0, $03, $D0, $E9, $A9, $01, $85, $E6, $60

sprite_attr_calc:
    BMI L_EAA8
L_EA65:
    CMP #$04
L_EA67:
    BNE L_EA6E
L_EA69:
    LDA #$30
L_EA6B:
    JMP L_EAA4
L_EA6E:
    ASL
L_EA6F:
    ASL
L_EA70:
    ASL
L_EA71:
    ASL
L_EA72:
    STA $0689
L_EA75:
    LDA $03A1,Y
L_EA78:
    CLC
L_EA79:
    ADC $0689
L_EA7C:
    CMP #$40
L_EA7E:
    BCC L_EA84
L_EA80:
    AND #$0F
L_EA82:
    ORA #$30
L_EA84:
    CMP #$1F
L_EA86:
    BEQ L_EA9F
L_EA88:
    CMP #$2F
L_EA8A:
    BEQ L_EA9F
L_EA8C:
    CMP #$3F
L_EA8E:
    BEQ L_EA9F
L_EA90:
    CMP #$33
L_EA92:
    BNE L_EA96
L_EA94:
    LDA #$30
L_EA96:
    CMP #$3B
L_EA98:
    BNE L_EAA4
L_EA9A:
    LDA #$30
L_EA9C:
    JMP L_EAA4
L_EA9F:
    AND #$F0
L_EAA1:
    SEC
L_EAA2:
    SBC #$10
L_EAA4:
    STA $0381,Y
L_EAA7:
    RTS
L_EAA8:
    CMP #$FC
L_EAAA:
    BEQ L_EAC9
L_EAAC:
    EOR #$FF
L_EAAE:
    STA $0689
L_EAB1:
    INC $0689
L_EAB4:
    ASL $0689
L_EAB7:
    ASL $0689
L_EABA:
    ASL $0689
L_EABD:
    ASL $0689
L_EAC0:
    LDA $03A1,Y
L_EAC3:
    SEC
L_EAC4:
    SBC $0689
L_EAC7:
    BPL L_EAA4
L_EAC9:
    LDA #$0F
L_EACB:
    JMP L_EAA4
music_tick:
    LDX #$00
L_EAD0:
    LDA $0390,X
L_EAD3:
    STA $03B0,X
L_EAD6:
    INX
L_EAD7:
    CPX #$10
L_EAD9:
    BNE L_EAD0
L_EADB:
    LDY #$10
L_EADD:
    TYA
L_EADE:
    PHA
L_EADF:
    LDX #$04
L_EAE1:
    LDA $67
L_EAE3:
    JSR sprite_attr_calc
L_EAE6:
    INY
L_EAE7:
    INY
L_EAE8:
    INY
L_EAE9:
    INY
L_EAEA:
    DEX
L_EAEB:
    BNE L_EAE1
L_EAED:
    PLA
L_EAEE:
    TAY
L_EAEF:
    INY
L_EAF0:
    CPY #$13
L_EAF2:
    BNE L_EADD
L_EAF4:
    RTS
    .byte $20, $80, $EB, $20, $D8, $AD, $4C, $8D, $EB, $20, $80, $EB, $20, $E0, $A5, $4C
    .byte $8D, $EB, $20, $80, $EB, $20, $65, $A5, $4C, $8D, $EB, $20, $80, $EB, $20, $9C
    .byte $A5, $4C, $8D, $EB, $20, $80, $EB, $20, $6E, $A6, $4C, $8D, $EB, $20, $80, $EB
    .byte $20, $70, $A6, $4C, $8D, $EB, $20, $80, $EB, $20, $B4, $A1, $4C, $8D, $EB, $20
    .byte $80, $EB, $20, $AD, $A2, $20, $8D, $EB, $60, $8A, $48, $A2, $08, $A9, $00, $85
    .byte $06, $26, $02, $26, $06, $A5, $06, $C5, $04, $90, $04, $E5, $04, $85, $06, $26
    .byte $02, $CA, $D0, $EF, $68, $AA, $60, $8E, $C8, $03, $8E, $CA, $03, $8C, $C9, $03
    .byte $8C, $CB, $03, $60, $8A, $48, $A2, $3C, $20, $B4, $E2, $A5, $0B, $D0, $09, $CA
    .byte $D0, $F6, $68, $AA, $CA, $D0, $ED, $60, $68, $AA, $60

winctx_save:
    PHA
L_EB81:
    LDA $BD
L_EB83:
    STA $068A
L_EB86:
    LDA #$FC
L_EB88:
    JSR trampoline_A000
L_EB8B:
    PLA
L_EB8C:
    RTS
winctx_restore:
    PHA
L_EB8E:
    LDA $068A
L_EB91:
    JSR trampoline_A000
L_EB94:
    PLA
L_EB95:
    RTS
trampoline_8000:
    STA $BC
L_EB98:
    STA $5114
L_EB9B:
    RTS
trampoline_A000:
    STA $BD
L_EB9E:
    STA $5115
L_EBA1:
    RTS
L_EBA2:
    JMP L_EBA2
save_prep:
    PHA
L_EBA6:
    LDA #$00
L_EBA8:
    STA $69
L_EBAA:
    STA $0567
L_EBAD:
    JSR apu_reset
L_EBB0:
    JSR sfx_pulse_a
L_EBB3:
    PLA
L_EBB4:
    BNE L_EBB7
L_EBB6:
    RTS
L_EBB7:
    LDX $BC
L_EBB9:
    STX $6A
L_EBBB:
    LDX $BD
L_EBBD:
    STX $6B
L_EBBF:
    PHA
L_EBC0:
    JSR music_track_load
L_EBC3:
    JSR music_seq_clear
L_EBC6:
    JSR music_seq_load
L_EBC9:
    LDA $6A
L_EBCB:
    JSR trampoline_8000
L_EBCE:
    LDA $6B
L_EBD0:
    JSR trampoline_A000
L_EBD3:
    JSR sfx_flags_clear
L_EBD6:
    PLA
L_EBD7:
    JSR music_seq_play
L_EBDA:
    STA $0402
L_EBDD:
    LDA #$1F
L_EBDF:
    STA $05F7
L_EBE2:
    LDA #$03
L_EBE4:
    STA $05F8
L_EBE7:
    RTS
save_commit:
    PHA
L_EBE9:
    JSR sub_ED27
L_EBEC:
    JSR sfx_pulse_b
L_EBEF:
    PLA
L_EBF0:
    PHA
L_EBF1:
    JSR music_track_load2
L_EBF4:
    JSR music_seq_clear
L_EBF7:
    JSR music_seq_load
L_EBFA:
    JSR sfx_flags_clear
L_EBFD:
    LDA #$FC
L_EBFF:
    STA $5115
L_EC02:
    PLA
L_EC03:
    JSR music_seq_addr
L_EC06:
    JSR sub_EBDA
L_EC09:
    LDA #$00
L_EC0B:
    STA $69
L_EC0D:
    RTS
    .byte $86, $6C, $20, $A5, $EB, $A5, $6C, $85, $69, $60, $C9, $FF, $F0, $2D, $C9, $00
    .byte $F0, $08, $48, $20, $45, $ED, $68, $4C, $4C, $EC, $20, $45, $ED, $AD, $02, $04
    .byte $F0, $18, $20, $8C, $EF, $A2, $00, $BD, $E7, $03, $38, $FD, $E0, $03, $B0, $02
    .byte $A9, $00, $9D, $0E, $04, $E8, $E0, $05, $D0, $ED, $60, $4C, $F5, $EA, $AC, $67
    .byte $05, $D0, $D7, $A6, $BC, $86, $6A, $A6, $BD, $86, $6B, $48, $20, $BA, $EC, $20
    .byte $62, $EE, $20, $B3, $EE, $A5, $6A, $20, $96, $EB, $A5, $6B, $20, $9C, $EB, $A2
    .byte $00, $A0, $01, $A5, $2D, $05, $2E, $F0, $06, $8E, $C7, $04, $8C, $CB, $04, $A5
    .byte $2F, $05, $30, $F0, $06, $8E, $C8, $04, $8C, $CC, $04, $A5, $31, $05, $32, $F0
    .byte $06, $8E, $C9, $04, $8C, $CD, $04, $68, $8D, $03, $04, $60

music_track_load:
    SEC
L_EC9B:
    SBC #$01
L_EC9D:
    ASL
L_EC9E:
    TAX
L_EC9F:
    JSR music_bank_fetch
L_ECA2:
    PHA
L_ECA3:
    LDA $ED1B,Y
L_ECA6:
    STA $068C
L_ECA9:
    JSR trampoline_8000
L_ECAC:
    PLA
L_ECAD:
    ORA #$80
L_ECAF:
    STA $6E
L_ECB1:
    STA $068F
L_ECB4:
    LDA $6D
L_ECB6:
    STA $068E
L_ECB9:
    RTS
    .byte $48, $A9, $FC, $20, $9C, $EB, $68, $38, $E9, $01, $30, $0D, $0A, $AA, $BD, $01
    .byte $BE, $85, $6D, $BD, $00, $BE, $4C, $DF, $EC, $29, $7F, $0A, $AA, $BD, $01, $BF
    .byte $85, $6D, $BD, $00, $BF, $AA, $29, $3F, $09, $A0, $85, $6E, $8A, $29, $C0, $F0
    .byte $0E, $C9, $80, $F0, $05, $A9, $EA, $4C, $FB, $EC, $A9, $E9, $4C, $FB, $EC, $A9
    .byte $E8, $8D, $8D, $06, $20, $9C, $EB, $60

music_bank_fetch:
    LDA #$FD
L_ED04:
    JSR trampoline_A000
L_ED07:
    LDA $B201,X
L_ED0A:
    STA $6D
L_ED0C:
    LDA $B200,X
L_ED0F:
    PHA
L_ED10:
    CLC
L_ED11:
    ROL
L_ED12:
    ROL
L_ED13:
    ROL
L_ED14:
    AND #$03
L_ED16:
    TAY
L_ED17:
    PLA
L_ED18:
    AND #$1F
L_ED1A:
    RTS
    .byte $DC, $DD, $DE, $DF

apu_reset:
    LDA #$00
L_ED21:
    STA $0402
L_ED24:
    JSR hud_wait
L_ED27:
    LDA #$00
L_ED29:
    STA $4015
L_ED2C:
    STA $5015
L_ED2F:
    LDA #$0F
L_ED31:
    STA $4015
L_ED34:
    LDA #$03
L_ED36:
    STA $5015
L_ED39:
    LDX #$00
L_ED3B:
    LDA #$00
L_ED3D:
    STA $21,X
L_ED3F:
    INX
L_ED40:
    CPX #$14
L_ED42:
    BNE L_ED3D
L_ED44:
    RTS
sfx_pulse_a:
    JSR hud_wait
L_ED48:
    LDA #$00
L_ED4A:
    STA $0403
L_ED4D:
    LDA $04CB
L_ED50:
    BEQ L_ED72
L_ED52:
    LDA #$00
L_ED54:
    STA $04CB
L_ED57:
    LDA #$01
L_ED59:
    STA $04C7
L_ED5C:
    LDA $0596
L_ED5F:
    STA $4002
L_ED62:
    LDA $058D
L_ED65:
    STA $4003
L_ED68:
    LDA $0424
L_ED6B:
    ORA #$30
L_ED6D:
    AND #$F0
L_ED6F:
    STA $4000
L_ED72:
    LDA $04CC
L_ED75:
    BEQ L_ED97
L_ED77:
    LDA #$00
L_ED79:
    STA $04CC
L_ED7C:
    LDA #$01
L_ED7E:
    STA $04C8
L_ED81:
    LDA $0597
L_ED84:
    STA $4006
L_ED87:
    LDA $058E
L_ED8A:
    STA $4007
L_ED8D:
    LDA $0425
L_ED90:
    ORA #$30
L_ED92:
    AND #$F0
L_ED94:
    STA $4004
L_ED97:
    LDA $04CD
L_ED9A:
    BEQ L_EDAB
L_ED9C:
    LDA #$00
L_ED9E:
    STA $04CD
L_EDA1:
    LDA #$01
L_EDA3:
    STA $04C9
L_EDA6:
    LDA #$30
L_EDA8:
    STA $400C
L_EDAB:
    JSR hud_wait
L_EDAE:
    RTS
sfx_pulse_b:
    LDA #$00
L_EDB1:
    STA $04CB
L_EDB4:
    STA $04CC
L_EDB7:
    STA $04CD
L_EDBA:
    LDA #$01
L_EDBC:
    STA $04C7
L_EDBF:
    STA $04C8
L_EDC2:
    STA $04C9
L_EDC5:
    RTS
sfx_flags_clear:
    JSR sfx_pulse_b
L_EDC9:
    STA $04C5
L_EDCC:
    STA $04C6
L_EDCF:
    RTS
audio_init:
    LDA #$00
L_EDD2:
    STA $4015
L_EDD5:
    STA $5015
L_EDD8:
    STA $5010
L_EDDB:
    LDA #$B0
L_EDDD:
    STA $4000
L_EDE0:
    STA $4004
L_EDE3:
    STA $400C
L_EDE6:
    STA $5000
L_EDE9:
    STA $5004
L_EDEC:
    LDA #$08
L_EDEE:
    STA $4001
L_EDF1:
    STA $4005
L_EDF4:
    LDA #$80
L_EDF6:
    STA $4008
L_EDF9:
    LDA #$0F
L_EDFB:
    STA $4015
L_EDFE:
    LDA #$03
L_EE00:
    STA $5015
L_EE03:
    LDA #$01
L_EE05:
    STA $04C5
L_EE08:
    STA $04C6
L_EE0B:
    STA $04C7
L_EE0E:
    STA $04C8
L_EE11:
    STA $04C9
L_EE14:
    STA $04CA
L_EE17:
    LDA #$00
L_EE19:
    STA $04CB
L_EE1C:
    STA $04CC
L_EE1F:
    STA $04CD
L_EE22:
    LDA #$00
L_EE24:
    STA $2E
L_EE26:
    STA $2D
L_EE28:
    STA $30
L_EE2A:
    STA $2F
L_EE2C:
    STA $32
L_EE2E:
    STA $31
L_EE30:
    LDX #$00
L_EE32:
    LDA $EE3E,X
L_EE35:
    STA $06F4,X
L_EE38:
    INX
L_EE39:
    CPX #$0C
L_EE3B:
    BNE L_EE32
L_EE3D:
    RTS
    .byte $9D, $B1, $04, $A8, $B1, $00, $F0, $F8, $FE, $B1, $04, $60

music_seq_clear:
    LDX #$00
L_EE4C:
    JSR music_chan_init
L_EE4F:
    LDA #$00
L_EE51:
    STA $0448,X
L_EE54:
    STA $0450,X
L_EE57:
    INX
L_EE58:
    CPX #$06
L_EE5A:
    BNE L_EE4C
L_EE5C:
    LDA #$00
L_EE5E:
    STA $040D
L_EE61:
    RTS
    .byte $A2, $06, $20, $7B, $EE, $E8, $E0, $09, $D0, $F8, $A9, $00, $8D, $4E, $04, $8D
    .byte $4F, $04, $8D, $56, $04, $8D, $57, $04, $60

music_chan_init:
    LDA #$00
L_EE7D:
    STA $0404,X
L_EE80:
    STA $04F7,X
L_EE83:
    STA $059D,X
L_EE86:
    LDA #$0C
L_EE88:
    STA $0579,X
L_EE8B:
    LDA #$07
L_EE8D:
    STA $0434,X
L_EE90:
    LDA #$FF
L_EE92:
    STA $058B,X
L_EE95:
    LDA #$B0
L_EE97:
    STA $0418,X
L_EE9A:
    RTS
music_seq_load:
    LDY #$00
L_EE9D:
    LDX #$00
L_EE9F:
    JSR music_track_read
L_EEA2:
    CPX #$0C
L_EEA4:
    BNE L_EE9F
L_EEA6:
    LDX #$12
L_EEA8:
    JSR music_track_read
L_EEAB:
    LDA ($6D),Y
L_EEAD:
    LDX #$00
L_EEAF:
    JSR music_vol_calc
L_EEB2:
    RTS
    .byte $A0, $00, $A2, $0C, $20, $C6, $EE, $E0, $12, $D0, $F9, $B1, $6D, $A2, $0B, $20
    .byte $E4, $EE, $60

music_track_read:
    LDA ($6D),Y
L_EEC8:
    STA $21,X
L_EECA:
    INY
L_EECB:
    LDA ($6D),Y
L_EECD:
    STA $22,X
L_EECF:
    ORA $21,X
L_EED1:
    BEQ L_EEE0
L_EED3:
    LDA $21,X
L_EED5:
    CLC
L_EED6:
    ADC $6D
L_EED8:
    STA $21,X
L_EEDA:
    LDA $22,X
L_EEDC:
    ADC $6E
L_EEDE:
    STA $22,X
L_EEE0:
    INY
L_EEE1:
    INX
L_EEE2:
    INX
L_EEE3:
    RTS
music_vol_calc:
    STA $0551,X
L_EEE7:
    CMP #$00
L_EEE9:
    BNE L_EEF0
L_EEEB:
    LDA #$80
L_EEED:
    JMP L_EEF1
L_EEF0:
    LSR
L_EEF1:
    STA $0553,X
L_EEF4:
    LSR
L_EEF5:
    STA $0555,X
L_EEF8:
    LSR
L_EEF9:
    STA $0557,X
L_EEFC:
    LSR
L_EEFD:
    STA $0559,X
L_EF00:
    LSR
L_EF01:
    STA $055A,X
L_EF04:
    LSR
L_EF05:
    STA $055B,X
L_EF08:
    LDA $0553,X
L_EF0B:
    CLC
L_EF0C:
    ADC $0555,X
L_EF0F:
    STA $0552,X
L_EF12:
    LDA $0555,X
L_EF15:
    CLC
L_EF16:
    ADC $0557,X
L_EF19:
    STA $0554,X
L_EF1C:
    LDA $0557,X
L_EF1F:
    CLC
L_EF20:
    ADC $0559,X
L_EF23:
    STA $0556,X
L_EF26:
    LDA $0559,X
L_EF29:
    CLC
L_EF2A:
    ADC $055A,X
L_EF2D:
    STA $0558,X
L_EF30:
    LDA $0551,X
L_EF33:
    CMP #$60
L_EF35:
    BNE L_EF3C
L_EF37:
    LDA #$08
L_EF39:
    STA $055B,X
L_EF3C:
    RTS
sfx_play:
    LDY $0402
L_EF40:
    BEQ L_EF52
L_EF42:
    STA $0569
L_EF45:
    STA $056A
L_EF48:
    LDA #$0F
L_EF4A:
    STA $0568
L_EF4D:
    LDA #$01
L_EF4F:
    STA $0567
L_EF52:
    RTS
music_track_load2:
    SEC
L_EF54:
    SBC #$01
L_EF56:
    ASL
L_EF57:
    TAX
L_EF58:
    JSR music_bank_fetch2
L_EF5B:
    PHA
L_EF5C:
    LDA $ED1B,Y
L_EF5F:
    STA $068C
L_EF62:
    STA $5114
L_EF65:
    PLA
L_EF66:
    ORA #$80
L_EF68:
    STA $6E
L_EF6A:
    STA $068F
L_EF6D:
    LDA $6D
L_EF6F:
    STA $068E
L_EF72:
    RTS
music_bank_fetch2:
    LDA #$FD
L_EF75:
    STA $5115
L_EF78:
    LDA $B201,X
L_EF7B:
    STA $6D
L_EF7D:
    LDA $B200,X
L_EF80:
    PHA
L_EF81:
    CLC
L_EF82:
    ROL
L_EF83:
    ROL
L_EF84:
    ROL
L_EF85:
    AND #$03
L_EF87:
    TAY
L_EF88:
    PLA
L_EF89:
    AND #$1F
L_EF8B:
    RTS
music_seq_play:
    LDX $0690
L_EF8F:
    BNE L_EF9A
L_EF91:
    JSR winctx_save
L_EF94:
    JSR music_seq_addr
L_EF97:
    JSR winctx_restore
L_EF9A:
    RTS
music_seq_addr:
    PHA
L_EF9C:
    TAX
L_EF9D:
    DEX
L_EF9E:
    TXA
L_EF9F:
    STA $6D
L_EFA1:
    ASL
L_EFA2:
    ASL
L_EFA3:
    CLC
L_EFA4:
    ADC $6D
L_EFA6:
    TAX
L_EFA7:
    LDA $AC98,X
L_EFAA:
    STA $03E0
L_EFAD:
    LDA $AC99,X
L_EFB0:
    STA $03E1
L_EFB3:
    LDA $AC9A,X
L_EFB6:
    STA $03E2
L_EFB9:
    LDA $AC9B,X
L_EFBC:
    STA $03E3
L_EFBF:
    LDA $AC9C,X
L_EFC2:
    STA $03E4
L_EFC5:
    PLA
L_EFC6:
    RTS
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $1F, $AA, $FA, $0A, $AA, $AA, $02
    .byte $0F, $AA, $AA, $A2, $AA, $FF, $00, $0F, $FF, $0A, $FA, $0A, $0A, $FF, $0A, $FA
    .byte $AA, $FF, $20, $FF, $00, $2F, $02, $A0, $0B, $02, $A0, $AA, $AA, $AB, $AB, $AA
    .byte $AB, $A0, $00, $F0, $FF, $0F, $F0, $FF, $00, $FF, $AF, $FA, $AA, $AA, $BA, $AA
    .byte $2A, $2A, $AA, $2A, $AA, $AA, $2A, $AB, $AA, $FF, $20, $B0, $BA, $BA, $0A, $0A
    .byte $AA, $A2, $2B, $A0, $AA, $AB, $A0, $AF, $0A, $0F, $FA, $0F, $FA, $0F, $0F, $F0
    .byte $0F, $FA, $AA, $0F, $0F, $AA, $0F, $AA, $AA, $BA, $0A, $BA, $0A, $AA, $AA, $A2
    .byte $AB, $A2, $A0, $FF, $A2, $BA, $0B, $B2, $AA, $AA, $AB, $AB, $AA, $BA, $AA, $BA
    .byte $0B, $A0, $AB, $A0, $AA, $AA, $AA, $0B, $0F, $AA, $BB, $AA, $A0, $FA, $0F, $FF
    .byte $AA, $AA, $AA, $A2, $AA, $AA, $A2, $AA, $AB, $AA, $AA, $AA, $AA, $2A, $AA, $2B
    .byte $A0, $AB, $AA, $2A, $AA, $AA, $2A, $BA, $2A, $AA, $BA, $AA, $AA, $AA, $AA, $AA
    .byte $BA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $2A, $AA, $AA, $AA
    .byte $AA, $2A, $AA, $2A, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $BA, $AA, $AA, $AA
    .byte $BA, $AA, $AB, $AA, $AB, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $0A, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $1F, $FA, $00, $00, $FF, $BB, $0F
    .byte $FF, $00, $AA, $A0, $F0, $00, $AB, $00, $0A, $B0, $FF, $0F, $FF, $FF, $F2, $F0
    .byte $0A, $00, $0A, $BF, $AA, $0A, $FF, $F0, $AA, $AA, $2A, $00, $00, $0A, $0F, $BA
    .byte $AB, $BB, $BB, $BF, $FF, $0F, $AA, $AA, $02, $AA, $AF, $FA, $0A, $A0, $0B, $AB
    .byte $A0, $22, $A0, $FA, $02, $AF, $A2, $0B, $FA, $0F, $BF, $FB, $FA, $0A, $BA, $20
    .byte $F0, $FA, $A0, $FA, $0A, $BA, $A0, $FB, $BA, $00, $2A, $AA, $0F, $AA, $A2, $AA
    .byte $0A, $AA, $BF, $A0, $FF, $FA, $A0, $FF, $A2, $AB, $BA, $22, $2B, $AA, $0B, $A0
    .byte $BA, $A0, $AA, $0A, $AB, $AA, $AA, $0F, $FA, $2A, $BF, $A0, $A2, $0F, $F0, $F0
    .byte $FF, $A2, $AA, $A0, $F0, $FA, $A0, $0F, $FB, $A2, $2A, $A0, $AB, $AB, $AA, $AA
    .byte $2A, $A2, $AA, $2A, $AB, $AA, $FB, $AF, $AB, $AA, $AA, $AF, $A0, $A0, $2A, $0A
    .byte $AA, $B0, $FA, $A2, $AA, $AB, $AA, $AA, $2A, $A0, $BA, $BF, $AA, $AA, $AA, $AA
    .byte $AA, $FA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $A0, $AB, $AA
    .byte $A2, $AA, $AA, $AA, $BA, $AB, $AA, $AA, $AA, $BB, $AA, $BB, $AA, $2A, $A0, $AA
    .byte $A0, $AB, $AA, $A0, $AB, $FA, $0B, $BA, $2A, $AA, $AA, $2A, $AA, $20, $F0, $FF
    .byte $FA, $AA, $AA, $AA, $AA, $2A, $AA, $A2, $AA, $BA, $BA, $AA, $AA, $A2, $AA, $0B
    .byte $AA, $A2, $AA, $2A, $AA, $FB, $AA, $BA, $AA, $AA, $AA, $20, $AA, $AA, $B0, $FF
    .byte $AA, $BA, $AA, $A0, $AB, $A0, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $2B
    .byte $AA, $AA, $AA, $AA, $AB, $AA, $A2, $AB, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA
    .byte $AA, $AA, $2A, $AA, $AB, $AA, $AA, $AA, $AA, $AB, $AA, $2A, $AA, $2A, $BA, $AA
    .byte $AB, $AA, $AA, $AA, $AB, $AA, $A0, $AA, $BA, $2A, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $2A, $AA, $AB, $AA, $BA, $AA, $AA, $AA, $BA, $AA, $A2, $AA, $2A, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $A2, $AA
    .byte $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $BA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $2A, $AA, $AA, $AA, $AA
    .byte $AA, $A2, $AA, $AA, $AB, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $BA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $BA, $AA, $AA, $AB, $AA, $AA, $AA, $2A
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $BA, $AA
    .byte $AA, $AA, $BA, $AA, $AA, $AA, $A2, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA
    .byte $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $10, $0F, $FF, $F0, $FF, $FF, $00
    .byte $00, $00, $00, $A0, $A0, $FF, $FF, $F0, $FA, $0F, $F0, $FF, $00, $BF, $B0, $FF
    .byte $B0, $20, $0F, $A2, $BA, $A2, $AA, $20, $AA, $0A, $AA, $2A, $AA, $FA, $AF, $F0
    .byte $0F, $0F, $F0, $FF, $A0, $FF, $B2, $B2, $2A, $00, $FA, $0F, $F0, $AA, $AA, $AA
    .byte $02, $2A, $AA, $00, $FF, $0F, $FA, $AB, $0F, $AA, $AA, $FB, $AA, $A0, $FF, $A2
    .byte $AB, $0B, $02, $AA, $AA, $AA, $AB, $A2, $0A, $2A, $A0, $AF, $AA, $B0, $FF, $AA
    .byte $AA, $AA, $BA, $AA, $AA, $A0, $FF, $B2, $AA, $A2, $AA, $A2, $AA, $AB, $AA, $A2
    .byte $A2, $20, $AB, $2A, $AA, $AF, $AA, $0F, $0F, $FA, $2A, $AB, $AA, $AA, $AB, $BA
    .byte $0F, $0F, $AA, $AA, $AA, $0A, $AA, $AA, $AA, $AA, $AA, $22, $AA, $AA, $A0, $0F
    .byte $F0, $F0, $FF, $AA, $AA, $BA, $A2, $AB, $AB, $AA, $AA, $AA, $BA, $AA, $A2, $2A
    .byte $AA, $AA, $AA, $AA, $AA, $2A, $2A, $A2, $AA, $AA, $AA, $BA, $BA, $AA, $BA, $BA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA
    .byte $A2, $AA, $2A, $AA, $AA, $AA, $AB, $AA, $AA, $0F, $BA, $AA, $AA, $BA, $BA, $AA
    .byte $AA, $AA, $2A, $AA, $AA, $2A, $AA, $AB, $AA, $AA, $AA, $2A, $A2, $AA, $AA, $AA
    .byte $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AB, $AA, $AA, $AA, $AA, $2A
    .byte $AA, $AA, $A2, $AA, $BA, $AA, $AA, $A2, $AA, $A2, $AA, $AA, $AA, $AA, $BA, $AA
    .byte $AB, $AA, $AA, $2A, $AA, $AA, $BA, $AA, $BA, $AA, $AA, $AA, $AA, $A2, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $2A, $AA, $2A, $AA, $AA, $AA, $AB, $AA, $AA, $AB, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA
    .byte $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA
    .byte $AB, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA
    .byte $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA
    .byte $BA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $2A
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AB, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $17, $FF, $AB, $A2, $AF, $00, $FF
    .byte $00, $FA, $00, $AA, $00, $0F, $F0, $0B, $F0, $AF, $AA, $F0, $FB, $AA, $A0, $FF
    .byte $02, $FF, $0F, $0F, $B2, $AA, $0A, $0F, $FA, $0F, $0A, $AA, $A0, $A0, $0A, $FA
    .byte $FB, $AA, $AA, $B0, $F0, $AB, $AA, $0F, $FA, $AA, $2B, $A0, $2A, $2A, $FA, $0F
    .byte $AA, $BA, $BA, $2F, $0F, $2F, $A0, $A0, $0B, $AB, $0F, $AA, $A0, $A0, $FA, $2A
    .byte $BF, $BA, $AB, $BA, $0A, $BA, $AA, $0F, $AA, $AB, $BA, $2B, $A2, $AA, $AA, $AA
    .byte $AA, $A0, $0B, $A2, $BB, $AA, $0A, $AB, $A0, $FB, $FA, $AB, $AA, $2A, $AA, $AA
    .byte $AA, $AA, $AA, $0A, $A0, $BB, $AA, $0A, $BA, $AA, $BA, $BA, $A2, $AA, $BB, $02
    .byte $A0, $FF, $FA, $2A, $BA, $0B, $A0, $AA, $AA, $0A, $A0, $FF, $20, $F0, $FF, $BA
    .byte $AA, $AB, $BA, $0A, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $A0, $BA, $AA, $AA, $A0, $FA, $AA
    .byte $AA, $AA, $A2, $AA, $AB, $AB, $AA, $AA, $AA, $AA, $AA, $2A, $AB, $A2, $A0, $F0
    .byte $FF, $BA, $AA, $02, $A2, $AA, $AA, $BA, $AA, $AA, $0F, $0F, $BA, $AA, $AA, $AA
    .byte $AA, $AA, $AB, $AA, $AA, $2A, $B2, $AA, $AA, $AA, $AA, $AA, $0B, $AA, $AA, $AA
    .byte $AA, $AA, $A0, $F0, $FB, $AA, $BA, $A2, $A2, $AA, $BA, $2A, $AA, $AA, $AA, $AA
    .byte $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $BA, $AA, $BA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $2A, $AB, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $2A, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $2A, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $2A, $BA, $AA, $AA, $AA, $AA, $BA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $2A, $AA, $BA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AB, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $BA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $0F, $18, $27, $30, $0F, $18, $1A
    .byte $29, $0F, $00, $10, $30, $0F, $1C, $29, $3C, $0F, $1A, $29, $30, $0F, $00, $29
    .byte $10, $0F, $16, $29, $37, $0F, $1C, $29, $3C, $0F, $08, $27, $30, $0F, $08, $18
    .byte $28, $0F, $00, $10, $30, $0F, $1C, $28, $2C, $0F, $18, $27, $30, $0F, $18, $19
    .byte $28, $0F, $00, $10, $30, $0F, $1C, $28, $2C, $0F, $25, $34, $30, $0F, $00, $00
    .byte $10, $0F, $16, $00, $37, $0F, $1C, $00, $3C, $0F, $1A, $2B, $30, $0F, $00, $2B
    .byte $10, $0F, $16, $2B, $37, $0F, $1C, $2B, $3C, $0F, $08, $17, $30, $0F, $08, $0C
    .byte $1C, $0F, $0F, $00, $30, $0F, $0C, $1C, $2C, $0F, $21, $31, $30, $0F, $00, $21
    .byte $10, $0F, $16, $21, $37, $0F, $1C, $21, $3C, $0F, $10, $20, $30, $0F, $01, $11
    .byte $21, $0F, $11, $21, $30, $0F, $14, $24, $34, $0F, $1A, $29, $30, $0F, $00, $00
    .byte $10, $0F, $16, $00, $37, $0F, $1C, $00, $3C, $1F, $18, $27, $30, $0F, $18, $1A
    .byte $29, $0F, $18, $28, $37, $0F, $1C, $29, $3C, $0F, $1A, $29, $30, $0F, $00, $18
    .byte $10, $0F, $16, $18, $37, $0F, $1C, $18, $3C, $0F, $1A, $14, $30, $0F, $00, $14
    .byte $10, $0F, $16, $14, $37, $0F, $1C, $14, $3C, $0F, $18, $28, $30, $0F, $00, $28
    .byte $10, $0F, $16, $28, $37, $0F, $1C, $28, $3C, $0F, $18, $27, $30, $0F, $00, $18
    .byte $10, $0F, $10, $18, $30, $0F, $1C, $18, $3C, $0F, $27, $37, $30, $0F, $27, $37
    .byte $17, $0F, $27, $37, $17, $0F, $27, $37, $30, $A6, $58, $A4, $59, $A9, $04, $20
    .byte $5D, $E5, $E6, $58, $20, $47, $FD, $20, $61, $D5, $4C, $26, $FC, $A6, $58, $A4
    .byte $59, $A9, $04, $20, $5D, $E5, $20, $0A, $FD, $20, $47, $FD, $20, $8F, $D5, $A9
    .byte $1E, $38, $E5, $59, $85, $11, $A5, $59, $85, $14, $F0, $12, $AD, $F4, $03, $29
    .byte $24, $8D, $F7, $03, $A9, $5C, $85, $13, $A5, $0F, $29, $1F, $85, $12, $60, $20
    .byte $1D, $FD, $20, $42, $FD, $20, $8F, $D5, $4C, $5A, $FC, $C6, $58, $20, $42, $FD
    .byte $20, $61, $D5, $A9, $1E, $38, $E5, $59, $85, $11, $A6, $58, $A4, $59, $A9, $00
    .byte $20, $5D, $E5, $A5, $59, $85, $14, $F0, $12, $AD, $F4, $03, $29, $24, $8D, $F7
    .byte $03, $A9, $5C, $85, $13, $A5, $0F, $29, $1F, $85, $12, $60, $A6, $58, $A4, $59
    .byte $A9, $00, $20, $5D, $E5, $E6, $59, $20, $50, $FD, $20, $85, $D3, $4C, $A9, $FC
    .byte $A6, $58, $A4, $59, $A9, $00, $20, $5D, $E5, $20, $2C, $FD, $20, $50, $FD, $20
    .byte $73, $D4, $A9, $20, $38, $E5, $58, $85, $11, $A5, $58, $85, $14, $F0, $14, $A5
    .byte $0F, $29, $E0, $85, $12, $AD, $F4, $03, $49, $04, $8D, $F7, $03, $29, $03, $09
    .byte $5C, $85, $13, $60, $20, $39, $FD, $20, $42, $FD, $20, $73, $D4, $4C, $DF, $FC
    .byte $C6, $59, $20, $42, $FD, $20, $85, $D3, $A9, $20, $38, $E5, $58, $85, $11, $A6
    .byte $58, $A4, $59, $A9, $00, $20, $5D, $E5, $A5, $58, $85, $14, $F0, $14, $A5, $0F
    .byte $29, $E0, $85, $12, $AD, $F4, $03, $49, $04, $8D, $F7, $03, $29, $03, $09, $5C
    .byte $85, $13, $60, $E6, $58, $A5, $58, $C9, $20, $D0, $0A, $A9, $00, $85, $58, $A5
    .byte $5A, $49, $04, $85, $5A, $60, $C6, $58, $10, $0A, $A9, $1F, $85, $58, $A5, $5A
    .byte $49, $04, $85, $5A, $60, $E6, $59, $A5, $59, $C9, $1E, $D0, $04, $A9, $00, $85
    .byte $59, $60, $C6, $59, $10, $04, $A9, $1D, $85, $59, $60, $A6, $56, $A4, $57, $60
    .byte $A5, $56, $18, $69, $0F, $AA, $A4, $57, $60, $A5, $57, $18, $69, $0E, $A8, $A6
    .byte $56, $60, $20, $1D, $FD, $20, $39, $FD, $C6, $59, $20, $42, $FD, $20, $8F, $D5
    .byte $20, $5A, $FC, $60, $C6, $59, $20, $42, $FD, $20, $61, $D5, $20, $5A, $FC, $60
    .byte $C6, $58, $E6, $59, $20, $42, $FD, $20, $73, $D4, $20, $DF, $FC, $60, $20, $42
    .byte $FD, $20, $85, $D3, $20, $DF, $FC, $60, $20, $1D, $FD, $E6, $59, $20, $2C, $FD
    .byte $20, $42, $FD, $20, $8F, $D5, $20, $5A, $FC, $60, $E6, $59, $20, $2C, $FD, $20
    .byte $42, $FD, $20, $61, $D5, $20, $5A, $FC, $60, $20, $50, $FD, $20, $85, $D3, $20
    .byte $39, $FD, $C6, $59, $C6, $58, $A6, $58, $A4, $59, $A9, $00, $20, $5D, $E5, $20
    .byte $A9, $FC, $60, $20, $39, $FD, $A9, $00, $A6, $58, $A4, $59, $20, $5D, $E5, $20
    .byte $50, $FD, $20, $73, $D4, $20, $A9, $FC, $20, $2C, $FD, $60, $20, $39, $FD, $C6
    .byte $59, $A6, $58, $A4, $59, $A9, $04, $20, $5D, $E5, $20, $47, $FD, $20, $61, $D5
    .byte $20, $26, $FC, $60, $C6, $59, $20, $1D, $FD, $A6, $58, $A4, $59, $A9, $04, $20
    .byte $5D, $E5, $20, $47, $FD, $20, $8F, $D5, $20, $26, $FC, $60, $E6, $59, $E6, $58
    .byte $20, $0A, $FD, $A6, $58, $A4, $59, $A9, $00, $20, $5D, $E5, $20, $42, $FD, $20
    .byte $73, $D4, $20, $DF, $FC, $60, $20, $0A, $FD, $A6, $58, $A4, $59, $A9, $00, $20
    .byte $5D, $E5, $20, $42, $FD, $20, $85, $D3, $20, $DF, $FC, $60, $E6, $59, $20, $2C
    .byte $FD, $A6, $58, $A4, $59, $A9, $04, $20, $5D, $E5, $20, $47, $FD, $20, $61, $D5
    .byte $20, $26, $FC, $60, $E6, $59, $20, $2C, $FD, $20, $1D, $FD, $A6, $58, $A4, $59
    .byte $A9, $04, $20, $5D, $E5, $20, $47, $FD, $20, $8F, $D5, $20, $26, $FC, $60, $20
    .byte $39, $FD, $C6, $59, $E6, $58, $20, $0A, $FD, $A6, $58, $A4, $59, $A9, $00, $20
    .byte $5D, $E5, $20, $50, $FD, $20, $85, $D3, $20, $A9, $FC, $60, $20, $0A, $FD, $20
    .byte $39, $FD, $A6, $58, $A4, $59, $A9, $00, $20, $5D, $E5, $20, $50, $FD, $20, $73
    .byte $D4, $20, $A9, $FC, $20, $2C, $FD, $60, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $4A, $55, $53, $54, $42, $52, $45, $45, $44, $00, $00, $00, $00, $54, $04, $01
    .byte $08, $B4, $00, $43, $E1, $00, $E0, $C4, $E2

; Real vectors ($FFFA): NMI=$E143 RESET=$E000 IRQ=$E2C4
; (emitted by the linker config, see config/nes.cfg)
