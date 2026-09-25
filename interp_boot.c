/*
 * interp_boot.c - build "solo interprete": nessun codice ricompilato.
 *
 * Sostituisce generated/justbreed_full.c + _dispatch.c. Ogni chiamata dinamica passa
 * all'interprete 6502 del runner, che legge il codice attraverso la mappatura MMC5 live
 * (mapper_peek_prg), quindi qualsiasi banco/finestra/WRAM funziona senza modello di banco
 * nel recompiler. Ogni indirizzo raggiunto viene registrato (dispatch_misses.log), cioe'
 * abbiamo la copertura del codice gratis mentre si gioca.
 */
#include "nes_runtime.h"
#include "interp.h"

int g_recomp_push_all_jsr = 1;

int call_by_address(uint16_t addr)                      { return nes_interp_dispatch(addr); }
int call_by_address_cb(uint16_t addr, int caller_bank)  { (void)caller_bank; return nes_interp_dispatch(addr); }

#include <stdio.h>
#include <stdlib.h>
extern int g_interp_hw_brk;
void func_RESET(void) {
    /* BRK come sull'hardware: alcune routine con dati inline ne dipendono.
     * JB_NO_HW_BRK=1 lo disattiva (solo per confronti A/B). */
    g_interp_hw_brk = getenv("JB_NO_HW_BRK") ? 0 : 1;
    nes_interp_resume(nes_read16(0xFFFC));
    /* Non dovrebbe mai tornare: se succede, dice perche' (kind: 0 declined, 1 return, 2 rti, 3 native, 4 stack, 5 brk). */
    NesInterpExit ex;
    nes_interp_get_last_exit(&ex);
    fprintf(stderr, "[JB] interprete uscito dal ciclo principale: kind=%d entry=$%04X next=$%04X S=$%02X->$%02X frame=%llu\n",
            (int)ex.kind, ex.entry_pc, ex.next_pc, ex.entry_s, ex.exit_s, (unsigned long long)g_frame_count);
}
void func_NMI(void)   { nes_interp_force(nes_read16(0xFFFA)); }
void func_IRQ(void)   { nes_interp_force(nes_read16(0xFFFE)); }


/* Stato che il codice generato definirebbe; l'interprete lo usa per i confini RTS/RTI. */
uint16_t g_rts_target = 0;
uint16_t g_rti_target = 0;
uint16_t g_rti_source = 0;
int      g_rti_bank   = -1;
