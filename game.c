/*
 * game.c - Just Breed: descrizione per l'application layer del backend a cicli di nesrecomp (runner/cyc/app/cyc_app.h).
 * Launcher, menu di gioco, mod e salvataggi di stato li fornisce il livello app; qui c'e' solo l'identita' del gioco,
 * la verifica della ROM (che cambia a ogni build della traduzione italiana) e il collegamento ai cheat.
 */
#include "cyc_app.h"
#include "cheats.h"
#include "cyc_ext.h"
#include <stdio.h>

/* Il launcher non puo' confrontare il CRC dell'intera ROM (expected_crc = 0, sotto): cambia a ogni build della patch
 * italiana. Il riconoscimento vero avviene su cheats.c (nes_mod_set_rom_identity, CRC32 del banco fisso 62, mai
 * toccato dalla traduzione): A77EE1CE = Just Breed (Japan) e le sue derivate, E9C39604 = T-Eng di Stealth. */
static void on_init(void) { cheats_prepare(); }

static void on_frame(uint64_t frame) {
    (void)frame;
    cheats_on_frame();
}

static const CycAppGame k_game = {
    "Just Breed", "just-breed", "a77ee1ce", 0u, 1, on_init, on_frame,
};

const CycAppGame *cyc_app_game(void) { return &k_game; }
