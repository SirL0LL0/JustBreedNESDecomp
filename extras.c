/*
 * extras.c - hook specifici del gioco (interfaccia: nesrecomp/runner/include/game_extras.h).
 * Il runner chiama queste funzioni nel main loop. Per un gioco "semplice" bastano stub vuoti.
 */
#include "game_extras.h"
#include "nes_runtime.h"
#include "mapper.h"
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *game_get_name(void) { return "Just Breed"; }

/* Il launcher non confronta il CRC dell'intera ROM (cambia a ogni build della patch italiana): 0 = nessun controllo.
 * Il riconoscimento avviene in game_on_init() sul banco fisso 62, che non modifichiamo mai:
 *   A77EE1CE = Just Breed (Japan) e le ROM derivate (traduzione italiana)
 *   E9C39604 = Just Breed (Japan) [T-Eng by Stealth Translations v1.00] */
uint32_t game_get_expected_crc32(void) { return 0u; }

#include "crc32.h"
static void verify_known_rom(void) {
    const uint8_t *bank = runner_get_prg_bank_rw(31);       /* 16KB: unita' 62 + 63 */
    if (!bank) return;
    uint32_t c = crc32_compute(bank, 0x2000);                /* unita' 62 */
    if (c != 0xA77EE1CEu && c != 0xE9C39604u)
        fprintf(stderr, "[JB] ATTENZIONE: ROM non riconosciuta (CRC banco 62 = %08X). "
                        "Attesa Just Breed (Japan) o una sua derivata.\n", c);
}

void game_on_init(void) {                        /* dopo il caricamento ROM + runtime_init() */
    verify_known_rom();
    /* Registrazione della copertura del codice mentre giochi: crea un file vuoto "coverage.on" nella
     * cartella da cui avvii il gioco. Scrive jb_coverage.bin (+ .win e .ram) ogni ~600 frame e all'uscita. */
    if (!getenv("NESRECOMP_COV_FILE")) {
        FILE *f = fopen("coverage.on", "rb");
        if (f) { fclose(f); _putenv("NESRECOMP_COV_FILE=jb_coverage.bin"); }
    }
}
#include <stdio.h>
/* Strumento di reverse engineering: JB_DUMP_FRAMES="1800,1810" scrive, ai frame indicati, la
 * nametable (4KB), le palette e la RAM di lavoro (2KB) in C:/temp/jb_dump_<frame>_{nt,pal,ram}.bin. */
void game_on_frame(uint64_t frame) {
    /* JB_DUMP_EVERY=N: accoda (frame:u32 + nametable 4KB + ExRAM 1KB) a C:/temp/jb_nt_all.bin ogni N frame,
     * solo se la nametable e' cambiata dall'ultima registrazione. */
    static int s_every = -1;
    if (s_every < 0) { const char *e = getenv("JB_DUMP_EVERY"); s_every = e ? atoi(e) : 0; }
    if (s_every > 0 && frame % (unsigned)s_every == 0) {
        static uint8_t last[0x1000]; static FILE *all;
        if (!all) all = fopen("C:/temp/jb_nt_all.bin", "wb");
        if (all && memcmp(last, g_ppu_nt, sizeof last) != 0) {
            uint32_t f = (uint32_t)frame;
            fwrite(&f, 4, 1, all); fwrite(g_ppu_nt, 1, sizeof last, all);
            { static const uint8_t zero[0x400] = {0}; const uint8_t *ex = mapper_get_exram(); fwrite(ex ? ex : zero, 1, 0x400, all); }
            fflush(all);
            memcpy(last, g_ppu_nt, sizeof last);
        }
    }
    static const char *s_list = (const char *)-1;
    if (s_list == (const char *)-1) s_list = getenv("JB_DUMP_FRAMES");
    if (!s_list) return;
    for (const char *p = s_list; *p; ) {
        unsigned long f = strtoul(p, (char **)&p, 10);
        if (f == frame) {
            char path[128];
            snprintf(path, sizeof path, "C:/temp/jb_dump_%llu_nt.bin", (unsigned long long)frame);
            FILE *o = fopen(path, "wb"); if (o) { fwrite(g_ppu_nt, 1, sizeof g_ppu_nt, o); fclose(o); }
            snprintf(path, sizeof path, "C:/temp/jb_dump_%llu_pal.bin", (unsigned long long)frame);
            o = fopen(path, "wb"); if (o) { fwrite(g_ppu_pal, 1, sizeof g_ppu_pal, o); fclose(o); }
            snprintf(path, sizeof path, "C:/temp/jb_dump_%llu_ex.bin", (unsigned long long)frame);
            o = fopen(path, "wb"); if (o) { const uint8_t *ex = mapper_get_exram(); if (ex) fwrite(ex, 1, 0x400, o); fclose(o); }
            snprintf(path, sizeof path, "C:/temp/jb_dump_%llu_ram.bin", (unsigned long long)frame);
            o = fopen(path, "wb"); if (o) { fwrite(g_ram, 1, 0x800, o); fclose(o); }
        }
        if (*p == ',') p++; else if (*p) break;
    }
}
void game_post_nmi(uint64_t frame) { (void)frame; }   /* ogni VBlank, dopo NMI */

int game_handle_arg(const char *key, const char *val) { (void)key; (void)val; return 0; }
const char *game_arg_usage(void) { return NULL; }

/* Chiamata quando call_by_address non trova l'indirizzo (es. codice in SRAM). 1 = gestito. */
int game_dispatch_override(uint16_t addr) { (void)addr; return 0; }

uint8_t game_ram_read_hook(uint16_t pc, uint16_t addr, uint8_t val) {
    (void)pc; (void)addr; return val;
}

void game_run_nmi(void)  { func_NMI(); }
void game_run_main(void) { func_RESET(); }       /* non ritorna */

void game_post_render(uint32_t *framebuf) { (void)framebuf; }
void game_fill_frame_record(void *record) { (void)record; }
int  game_handle_debug_cmd(const char *cmd, int id, const char *json) {
    (void)cmd; (void)id; (void)json; return 0;
}

/* Percorso ROM esposto dal runner (usato dal debug server). */
const char *g_rom_path_for_extras = NULL;
