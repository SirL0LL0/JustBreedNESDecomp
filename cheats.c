/*
 * cheats.c - cheat di Just Breed come "mod" del launcher (nesrecomp mod runtime, backend a cicli).
 *
 * Ogni cheat e' una feature del pacchetto mods/packages/justbreed.cheats (manifest.toml) collegata a un plugin
 * registrato qui. Attivandola dal launcher, il plugin imposta un flag; prima di ogni frame (game.c -> cheats_on_frame)
 * i byte indicati vengono riscritti nella RAM di lavoro del cartuccio ($6000-$7FFF, indirizzi come nel file .cht),
 * con cyc_bus_write (il mapper la instrada come farebbe con una scrittura della CPU: vedi cyc_ext.h).
 *
 * Solo cheat RAM: il cheat Game Genie del runner precedente (DPCM pop-reducer, STA $4011 -> LDA $4011) non e'
 * stato portato, ne' la sua feature nel manifest. Il backend a cicli non applica patch di ROM in lettura (una
 * patch attiva costringerebbe la macchina sull'interprete, vedi Castlevania3Recomp). Se vuoi quella correzione
 * va applicata alla ROM in fase di build (tools/build_it.py), non come cheat.
 */
#include "cheats.h"
#include "mod_runtime.h"
#include "cyc_ext.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "crc32.h"

#define MAX_WRITES 13

typedef struct { uint16_t addr; uint8_t val; } Poke;
typedef struct { const char *plugin_id; int n; Poke w[MAX_WRITES]; } Cheat;

static const Cheat CHEATS[] = {
    /* 0 */ {"justbreed.exp_lots",  1, {{0x6F6E, 0xFF}}},
    /* 1 */ {"justbreed.exp_max",   2, {{0x6F6E, 0xFF}, {0x6F6F, 0xFF}}},
    /* 2 */ {"justbreed.gold_lots", 1, {{0x6F6C, 0xFF}}},
    /* 3 */ {"justbreed.gold_max",  2, {{0x6F6C, 0xFF}, {0x6F6D, 0xFF}}},
    /* 4 */ {"justbreed.hp_hero",   1, {{0x69C1, 0xFF}}},
    /* 5 */ {"justbreed.mp_hero",   1, {{0x6A01, 0xFF}}},
    /* 6 */ {"justbreed.hp_p2",     1, {{0x69C2, 0xFF}}},
    /* 7 */ {"justbreed.mp_p2",     1, {{0x6A02, 0xFF}}},
    /* 8 */ {"justbreed.hp_p3",     1, {{0x69C4, 0xFF}}},
    /* 9 */ {"justbreed.mp_p3",     1, {{0x6A04, 0xFF}}},
    /*10 */ {"justbreed.hp_p4",     1, {{0x69C6, 0xFF}}},
    /*11 */ {"justbreed.mp_p4",     1, {{0x6A06, 0xFF}}},
    /*12 */ {"justbreed.hp_p5",     1, {{0x69C5, 0xFF}}},
    /*13 */ {"justbreed.mp_p5",     1, {{0x6A05, 0xFF}}},
    /*14 */ {"justbreed.hp_p6",     1, {{0x69C3, 0xFF}}},
    /*15 */ {"justbreed.mp_p6",     1, {{0x6A03, 0xFF}}},
    /*16 */ {"justbreed.enemies_no_hp", 13,
             {{0x69DA, 0}, {0x69DB, 0}, {0x69DC, 0}, {0x69DD, 0}, {0x69DE, 0}, {0x69DF, 0}, {0x69E0, 0},
              {0x69E1, 0}, {0x69E2, 0}, {0x69E3, 0}, {0x69E4, 0}, {0x69E5, 0}, {0x69E6, 0}}},
};
#define N_CHEATS ((int)(sizeof CHEATS / sizeof CHEATS[0]))

static uint8_t s_on[N_CHEATS];

/* ---- registrazione plugin: una funzione per cheat (i callback non hanno contesto) ---- */
#define EN(n) static void en_##n(void) { s_on[n] = 1; }
EN(0) EN(1) EN(2) EN(3) EN(4) EN(5) EN(6) EN(7) EN(8) EN(9) EN(10) EN(11) EN(12) EN(13) EN(14) EN(15) EN(16)
static void (*const ENABLERS[N_CHEATS])(void) = {
    en_0, en_1, en_2, en_3, en_4, en_5, en_6, en_7, en_8, en_9, en_10, en_11, en_12, en_13, en_14, en_15, en_16,
};

static void reset_all(void) { memset(s_on, 0, sizeof s_on); }

/* Identita' della ROM per i target dei pacchetti: CRC32 del banco fisso 62 (mai modificato dalla traduzione),
 * cosi' il giapponese, le ROM derivate (italiano) e la versione inglese di Stealth usano gli stessi pacchetti. */
static int rom_identity(const char *path, char out[9]) {
    FILE *f = fopen(path, "rb");
    if (!f) return 0;
    uint8_t hdr[16];
    static uint8_t bank[0x2000];
    int ok = fread(hdr, 1, 16, f) == 16 && hdr[0] == 'N' && hdr[1] == 'E' && hdr[2] == 'S' && hdr[3] == 0x1A &&
             fseek(f, 16 + 62L * 0x2000, SEEK_SET) == 0 && fread(bank, 1, sizeof bank, f) == sizeof bank;
    fclose(f);
    if (!ok) return 0;
    uint32_t crc = crc32_compute(bank, sizeof bank);
    if (crc == 0xE9C39604u) crc = 0xA77EE1CEu;      /* patch inglese di Stealth: stessa famiglia del giapponese */
    else if (crc != 0xA77EE1CEu) return 0;          /* ROM non riconosciuta */
    snprintf(out, 9, "%08x", crc);
    return 1;
}

static int s_wired;
NES_MOD_CONSTRUCTOR(register_justbreed_cheats) {
    nes_mod_set_rom_identity(rom_identity);
    nes_mod_register_reset_callback(reset_all);
    for (int i = 0; i < N_CHEATS; i++)
        nes_mod_register_activation_plugin(CHEATS[i].plugin_id, ENABLERS[i]);
    s_wired = 1;
}

void cheats_prepare(void) { (void)s_wired; }

void cheats_on_frame(void) {
    for (int i = 0; i < N_CHEATS; i++) {
        if (!s_on[i]) continue;
        for (int k = 0; k < CHEATS[i].n; k++)
            cyc_bus_write(CHEATS[i].w[k].addr, CHEATS[i].w[k].val);
    }
}

int cheats_active_count(void) {
    int n = 0;
    for (int i = 0; i < N_CHEATS; i++) n += s_on[i];
    return n;
}
