#pragma once
/* Cheat come mod del launcher: vedi cheats.c, mods/packages/justbreed.cheats. */
void cheats_prepare(void);         /* da chiamare a macchina pronta (on_init) */
void cheats_on_frame(void);        /* da chiamare prima di ogni frame: riscrive i byte WRAM dei cheat attivi */
int  cheats_active_count(void);    /* numero di cheat attivi nella sessione */
