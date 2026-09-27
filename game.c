/*
 * game.c - Just Breed: descrizione per l'application layer del backend a cicli di nesrecomp (runner/cyc/app/cyc_app.h).
 * Launcher, menu di gioco, mod e salvataggi di stato li fornisce il livello app; qui c'e' solo l'identita' del gioco,
 * la verifica della ROM (che cambia a ogni build della traduzione italiana) e il collegamento ai cheat.
 */
#include "cyc_app.h"
#include "cheats.h"
#include "cyc_ext.h"
#include <stdio.h>
#include <stdlib.h>

/* Il launcher non puo' confrontare il CRC dell'intera ROM (expected_crc = 0, sotto): cambia a ogni build della patch
 * italiana. Il riconoscimento vero avviene su cheats.c (nes_mod_set_rom_identity, CRC32 del banco fisso 62, mai
 * toccato dalla traduzione): A77EE1CE = Just Breed (Japan) e le sue derivate, E9C39604 = T-Eng di Stealth. */
static void on_init(void) { cheats_prepare(); }

static void on_frame(uint64_t frame) {
    cheats_on_frame();
    /* Diagnostica temporanea (bug del blocco a $E2): JB_DEBUG_DUMP=<frame> stampa la pagina zero $BC-$D6/$E0-$E3
     * e il buffer del messaggio decodificato ($6400-$643F, $0700-$073F) a quel frame. Da togliere a bug chiuso. */
    static long dbg = -2;
    if (dbg == -2) { const char *e = getenv("JB_DEBUG_DUMP"); dbg = e ? atol(e) : -1; }
    if (dbg >= 0 && (long)frame == dbg) {
        printf("[dbg] frame %lld\n", (long long)frame);
        printf("[dbg] zp BC-D6:"); for (uint16_t a = 0xBC; a <= 0xD6; a++) printf(" %02X", cyc_bus_read(a)); printf("\n");
        printf("[dbg] zp E0-E5:"); for (uint16_t a = 0xE0; a <= 0xE5; a++) printf(" %02X", cyc_bus_read(a)); printf("\n");
        printf("[dbg] zp 50-55:"); for (uint16_t a = 0x50; a <= 0x55; a++) printf(" %02X", cyc_bus_read(a)); printf("\n");
        printf("[dbg] $6400:"); for (uint16_t a = 0x6400; a < 0x6440; a++) printf(" %02X", cyc_bus_read(a)); printf("\n");
        printf("[dbg] $0700:"); for (uint16_t a = 0x0700; a < 0x0740; a++) printf(" %02X", cyc_bus_read(a)); printf("\n");
        printf("[dbg] $01xx (pila):"); for (uint16_t a = 0x0100; a <= 0x01FF; a++) printf(" %02X", cyc_bus_read(a)); printf("\n");
        printf("[dbg] $A750:"); for (uint32_t a = 0xA750; a <= 0xA7A0; a++) printf(" %02X", cyc_bus_read((uint16_t)a)); printf("\n");
    }
}

static const CycAppGame k_game = {
    "Just Breed", "just-breed", "a77ee1ce", 0u, 1, on_init, on_frame,
};

const CycAppGame *cyc_app_game(void) { return &k_game; }
