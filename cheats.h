#pragma once
/* Cheat come mod del launcher: vedi cheats.c e mods/packages/justbreed.cheats. */
void cheats_on_frame(void);        /* da chiamare a ogni VBlank (game_on_frame) */
int  cheats_active_count(void);    /* numero di cheat attivi nella sessione */
