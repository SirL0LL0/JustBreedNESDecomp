#!/usr/bin/env python3
"""
annotate.py â€” applica nomi reali alle label dello scheletro auto-generato.

Usage:
    py tools/annotate.py <skeleton_dir>

Modifica bank_1f.s e bank_1e.s in-place: ogni entry (L_xxxx / sub_xxxx)
diventa un nome simbolico. Le label definite E riferite vengono
rinominate insieme, quindi il file resta coerente e il verify continua
a funzionare (verify_skeleton accetta label generiche).
"""
import sys, re, pathlib

# (address, name) â€” bank $1F (layout fisso: $C000-$DFFF prima meta', $E000-$FFFF)
MAP_1F = [
    ("E000", "RESET"),
    ("E143", "NMI_handler"),
    ("E2C4", "IRQ_handler"),
    ("C000", "main_loop"),
    ("C184", "set_win8000_a"),
    ("C193", "set_winA000_a"),
    ("C199", "jsr_indirect"),
    ("C1B4", "stack_save_x"),
    ("C1C5", "stack_load_x"),
    ("C21D", "far_args_fetch"),
    ("C250", "far_copy_bytes"),
    ("C278", "retaddr_fetch"),
    ("C349", "party_scan"),
    ("C57B", "unit_data_clear"),
    ("C866", "unit_data_load"),
    ("C946", "unit_refresh"),
    ("C9AA", "spr_priority_check"),
    ("CA56", "metasprite_draw"),
    ("CB18", "get_unit_pos"),
    ("CB31", "sprite_select"),
    ("CEBB", "spr_attr_set"),
    ("CF9A", "anim_table_load"),
    ("D00D", "npc_id_dispatch"),
    ("D1BE", "nmi_mid_hook"),
    ("D2D9", "dir_index_calc"),
    ("D31C", "irq_work"),
    ("D5C5", "sprite_draw_core"),
    ("D6E6", "map_cell_read"),
    ("DAEE", "mul16"),
    ("DBFD", "rand_next"),
    ("E103", "nametable_clear"),
    ("E205", "pad_read"),
    ("E228", "irq_vec_dispatch"),
    ("E25D", "hud_dispatch"),
    ("E29C", "hud_flag_set"),
    ("E2B4", "hud_wait"),
    ("E2BD", "hud_frame_delay"),
    ("E34B", "far_call_routine"),
    ("E44C", "oam_buffer_clear"),
    ("E58C", "metasprite_blit"),
    ("E63F", "camera_update"),
    ("E680", "scroll_ppu_update"),
    ("E7A0", "split_update"),
    ("E826", "camera_step"),
    ("E868", "camera_dispatch"),
    ("E908", "oam_dma"),
    ("EA0D", "sprite_frame_step"),
    ("EA63", "sprite_attr_calc"),
    ("EACE", "music_tick"),
    ("EB80", "winctx_save"),
    ("EB8D", "winctx_restore"),
    ("EB96", "trampoline_8000"),   # STA $BC / STA $5114 (finestra $8000)
    ("EB9C", "trampoline_A000"),   # STA $BD / STA $5115 (finestra $A000)
    ("EBA5", "save_prep"),
    ("EBE8", "save_commit"),
    ("EC9A", "music_track_load"),
    ("ED02", "music_bank_fetch"),
    ("ED1F", "apu_reset"),
    ("ED45", "sfx_pulse_a"),
    ("EDAF", "sfx_pulse_b"),
    ("EDC6", "sfx_flags_clear"),
    ("EDD0", "audio_init"),
    ("EE4A", "music_seq_clear"),
    ("EE7B", "music_chan_init"),
    ("EE9B", "music_seq_load"),
    ("EEC6", "music_track_read"),
    ("EEE4", "music_vol_calc"),
    ("EF3D", "sfx_play"),
    ("EF53", "music_track_load2"),
    ("EF73", "music_bank_fetch2"),
    ("EF8C", "music_seq_play"),
    ("EF9B", "music_seq_addr"),
]

# bank $1E (layout window: $8000-$9FFF prima meta', $A000-$BFFF seconda meta')
# NB: il codice della seconda meta' gira a $C000-$DFFF quando $5116=$FD,
#     ma nel file e' etichettato con gli indirizzi $Axxx.
# Gli hook del NMI ($A757/$AFCD/$A22E) girano con $5115=$FC: prima meta' ($8xxx).
# Gli hook del RESET ($A762/$B013) girano con $5115=$FB: seconda meta' ($Axxx/$Bxxx).
MAP_1E = [
    ("A000", "game_farcall_entry"),   # = $C000 runtime via $FD
    ("8757", "chr_bank_compute"),    # NMI hook
    ("8FCD", "chr_tile_prepare"),    # NMI hook
    ("822E", "main_logic_hook"),     # NMI hook
    ("A762", "sys_init_hook"),       # RESET hook (via $FB)
    ("B013", "chr_init_hook"),       # RESET hook (via $FB)
]

def apply_map(path, pairs):
    text = pathlib.Path(path).read_text(encoding="utf-8")
    found, missing = [], []
    for addr, name in pairs:
        hit = False
        for prefix in ("L_", "sub_"):
            old = prefix + addr
            pat = r"(?<![A-Za-z0-9_])" + re.escape(old) + r"(?![A-Za-z0-9_])"
            if re.search(pat, text):
                text = re.sub(pat, name, text)
                hit = True
        (found if hit else missing).append(addr)
    pathlib.Path(path).write_text(text, encoding="utf-8")
    return found, missing

def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    d = pathlib.Path(sys.argv[1])
    for fname, pairs in (("bank_1f.s", MAP_1F), ("bank_1e.s", MAP_1E)):
        p = d / fname
        if not p.exists():
            print(f"{fname}: NON TROVATO")
            continue
        found, missing = apply_map(p, pairs)
        print(f"{fname}: {len(found)} label rinominate")
        if missing:
            print(f"  non trovate: {' '.join(missing)}")

if __name__ == "__main__":
    main()
