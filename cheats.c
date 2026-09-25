/*
 * cheats.c - cheat di Just Breed come "mod" del launcher (nesrecomp mod runtime).
 *
 * Ogni cheat e' una feature del pacchetto mods/packages/justbreed.cheats (manifest.toml) collegata a un plugin
 * registrato qui. Attivandola dal launcher, il plugin imposta un flag; ogni frame (game_on_frame) i cheat attivi
 * riscrivono i loro byte nella RAM di lavoro ($6000-$7FFF, indirizzi come nel file .cht). Il cheat 17 e' un codice
 * Game Genie: patch di un byte di ROM, applicata in lettura dal mapper solo se il byte originale coincide.
 */
#include "cheats.h"
#include "mod_runtime.h"
#include "mapper.h"
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
static int s_gg_on, s_gg_applied, s_gg_cmp;
static uint16_t s_gg_addr;
static uint8_t s_gg_val;

/* ---- Game Genie (NES) ---- */
static int gg_decode(const char *code, uint16_t *addr, uint8_t *val, int *cmp) {
    static const char L[] = "APZLGITYEOXUKSVN";
    int n[8], len = (int)strlen(code);
    if (len != 6 && len != 8) return 0;
    for (int i = 0; i < len; i++) {
        const char *p = strchr(L, code[i]);
        if (!p || !*p) return 0;
        n[i] = (int)(p - L);
    }
    *addr = (uint16_t)(0x8000 + (((n[3] & 7) << 12) | ((n[5] & 7) << 8) | ((n[4] & 8) << 8) |
                                 ((n[2] & 7) << 4) | ((n[1] & 8) << 4) | (n[4] & 7) | (n[3] & 8)));
    if (len == 8) {
        *val = (uint8_t)(((n[1] & 7) << 4) | ((n[0] & 8) << 4) | (n[0] & 7) | (n[7] & 8));
        *cmp = ((n[7] & 7) << 4) | ((n[6] & 8) << 4) | (n[6] & 7) | (n[5] & 8);
    } else {
        *val = (uint8_t)(((n[1] & 7) << 4) | ((n[0] & 8) << 4) | (n[0] & 7) | (n[5] & 8));
        *cmp = -1;
    }
    return 1;
}

static void gg_enable(void) {
    uint16_t a; uint8_t v; int c;
    /* DPCM pop-reducer: STA $4011 -> LDA $4011 (banco 61). Il mapper non e' ancora inizializzato quando i
     * plugin vengono attivati (prima di runner_run): la patch viene applicata al primo frame. */
    if (gg_decode("SZVIZESE", &a, &v, &c)) {
        s_gg_addr = a; s_gg_val = v; s_gg_cmp = c;
        s_gg_on = 1;
        s_gg_applied = 0;
    }
}

/* ---- registrazione plugin: una funzione per cheat (i callback non hanno contesto) ---- */
#define EN(n) static void en_##n(void) { s_on[n] = 1; }
EN(0) EN(1) EN(2) EN(3) EN(4) EN(5) EN(6) EN(7) EN(8) EN(9) EN(10) EN(11) EN(12) EN(13) EN(14) EN(15) EN(16)
static void (*const ENABLERS[N_CHEATS])(void) = {
    en_0, en_1, en_2, en_3, en_4, en_5, en_6, en_7, en_8, en_9, en_10, en_11, en_12, en_13, en_14, en_15, en_16,
};

static void reset_all(void) {
    memset(s_on, 0, sizeof s_on);
    s_gg_on = s_gg_applied = 0;
    mapper_gg_clear();
}

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

NES_MOD_CONSTRUCTOR(register_justbreed_cheats) {
    nes_mod_set_rom_identity(rom_identity);
    nes_mod_register_reset_callback(reset_all);
    for (int i = 0; i < N_CHEATS; i++)
        nes_mod_register_activation_plugin(CHEATS[i].plugin_id, ENABLERS[i]);
    nes_mod_register_activation_plugin("justbreed.dpcm_popreduce", gg_enable);
}

void cheats_on_frame(void) {
    static int s_log = -1, s_frames;
    if (s_log < 0) s_log = getenv("JB_CHEAT_LOG") != NULL;
    if (s_gg_on && !s_gg_applied) s_gg_applied = mapper_gg_add(s_gg_addr, s_gg_val, s_gg_cmp);
    for (int i = 0; i < N_CHEATS; i++) {
        if (!s_on[i]) continue;
        for (int k = 0; k < CHEATS[i].n; k++) {
            mapper_write_ext(CHEATS[i].w[k].addr, CHEATS[i].w[k].val);
            if (s_log && s_frames == 5) {           /* verifica: rilegge il byte dal bus della CPU */
                uint8_t v = 0xEE;
                int ok = mapper_read_ext(CHEATS[i].w[k].addr, &v);
                printf("[cheat] %s $%04X = %02X (letto=%d, atteso %02X)\n", CHEATS[i].plugin_id,
                       CHEATS[i].w[k].addr, v, ok, CHEATS[i].w[k].val);
            }
        }
    }
    if (s_log && s_frames == 5) {
        printf("[cheat] attivi: %d\n", cheats_active_count());
        if (getenv("JB_CHEAT_GGTEST")) {      /* solo diagnostica: rimappa $C000 sul banco 61 e legge $D062 */
            uint8_t v = 0;
            mapper_write_ext(0x5116, 0x80 | 61);
            mapper_read_ext(0xD062, &v);
            printf("[cheat] $D062 (banco 61) = %02X (originale 8D, con Game Genie AD)\n", v);
        }
    }
    s_frames++;
}

int cheats_active_count(void) {
    int n = s_gg_on;
    for (int i = 0; i < N_CHEATS; i++) n += s_on[i];
    return n;
}
