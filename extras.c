/*
 * extras.c - hook specifici del gioco (interfaccia: nesrecomp/runner/include/game_extras.h).
 * Il runner chiama queste funzioni nel main loop. Per un gioco "semplice" bastano stub vuoti.
 */
#include "game_extras.h"
#include "nes_runtime.h"
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>

const char *game_get_name(void) { return "Just Breed"; }

/* CRC32 dei soli dati ROM (header escluso): Just Breed (Japan) [T-Eng by Stealth Translations v1.00]. */
uint32_t game_get_expected_crc32(void) {
    /* JB_ANY_ROM=1 salta il controllo (sviluppo: ROM giapponese, ROM patchate). */
    return getenv("JB_ANY_ROM") ? 0u : 0x735528D8u;
}

void game_on_init(void) {}                       /* dopo il caricamento ROM + runtime_init() */
#include <stdio.h>
/* Strumento di reverse engineering: JB_DUMP_FRAMES="1800,1810" scrive, ai frame indicati, la
 * nametable (4KB), le palette e la RAM di lavoro (2KB) in C:/temp/jb_dump_<frame>_{nt,pal,ram}.bin. */
void game_on_frame(uint64_t frame) {
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
