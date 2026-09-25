# JustBreedRecomp

Ricompilazione statica di un gioco NES per PC nativo, basata su
[nesrecomp](https://github.com/mstan/nesrecomp) e strutturata come
[FaxanaduRecomp](https://github.com/mstan/FaxanaduRecomp).

Non e' un emulatore: il codice 6502 della ROM viene tradotto **una volta sola, in fase di build**, in C,
che poi il compilatore trasforma in codice x64 nativo.

## Come funziona (idea generale)

```
gioco.nes
   |  NESRecomp.exe gioco.nes --game game.toml       (fase 1: recompiler, offline)
   v
generated/justbreed_full.c       ogni funzione 6502 -> funzione C  (JSR = chiamata, branch = goto)
generated/justbreed_dispatch.c   call_by_address(): tabella indirizzo -> funzione, per salti indiretti
   |  + runner (nesrecomp/runner) + extras.c + SDL2  (fase 2: CMake/MSVC)
   v
JustBreedRecomp.exe              PPU, APU, mapper, input, video, audio, savestate simulati dal runner
```

Tre attori:

| Pezzo | Dove | Ruolo |
|-------|------|-------|
| **Recompiler** | `nesrecomp/recompiler/src` | Legge la ROM, trova le funzioni (BFS da RESET/NMI/IRQ, poi scanner di tabelle di puntatori), emette C. Decoder per tutti i 256 opcode. |
| **Runner** | `nesrecomp/runner` | Libreria comune: memoria NES, PPU (`ppu_renderer.c`), APU, mapper (0/1/4/66), SDL2 (`main_runner.c`), input, savestate, interprete di fallback. Non cambia per gioco. |
| **Il tuo repo** | questa cartella | Solo: `game.toml`, `extras.c`, `CMakeLists.txt`, script. `generated/` e' artefatto di build. |

## Struttura del repo

```
JustBreedRecomp/
  nesrecomp/        submodule git (framework), agganciato a un commit preciso
  game.toml         configurazione del recompiler (mapper, bank switch, tabelle, seed funzioni)
  extras.c/.h       hook del gioco (implementa runner/include/game_extras.h)
  CMakeLists.txt    include runner.cmake, aggiunge extras.c + generated/*.c, linka SDL2
  setup.bat/.sh     scarica il submodule nesrecomp
  build.bat         pipeline completa: recompiler -> generazione C -> exe
  generated/        (ignorato da git) output del recompiler
```

Nota: il submodule si aggancia a un commit fisso (come FaxanaduRecomp, che pinna `7f6377b`), cosi' il
codice generato e' riproducibile anche se nesrecomp cambia.

## Uso

Servono: Git, Visual Studio 2022 (C++ desktop), CMake 3.20+. SDL2 e' incluso in `nesrecomp/runner/external`.
La ROM **non** e' inclusa: usa la tua copia legale.

```bash
setup.bat                       # scarica nesrecomp
build.bat C:\percorso\gioco.nes # build completa
build\Release\JustBreedRecomp.exe C:\percorso\gioco.nes
```

In alternativa, la CLI precompilata di nesrecomp (`nesrecomp.exe build --rom ... --output ...`) genera una
`game.toml` proposta, ma non produce da sola un gioco giocabile.

## Il flusso di lavoro per portare un gioco

1. **Prima generazione** con `game.toml` minimo. Vedi la mapper della ROM (byte 6/7 dell'header iNES).
   Supportati: 0 NROM, 1 MMC1, 4 MMC3, 66 GxROM. Gli altri (2, 3, 7, 9...) richiedono lavoro nel runner.
2. **Bank switching** (mapper 1/4): individua nel disassemblato la routine che cambia banco e mettila in
   `[mapper] bank_switch` o come `[[trampoline]] ` se il gioco usa `JSR routine` + byte inline.
3. **Salti dinamici**: giochi con `RTS`-dispatch, tabelle di puntatori per AI/stati/suoni non sono visibili
   staticamente. Si aggiungono con `[[known_table]]`, `[[split_table]]`, `[functions]` / `[[extra_func]]`.
   `extra_label` se l'indirizzo cade *dentro* una funzione esistente (altrimenti la spezzi e il gioco si blocca).
4. **Scopri cosa manca a runtime**: se un indirizzo non e' stato ricompilato, il runner ripiega su un
   interprete 6502 e scrive `dispatch_misses.log` (righe `extra_func` pronte da incollare) e
   `fallback_telemetry.jsonl`. Incollale in `game.toml` e rigenera.
5. **Dati scambiati per codice**: `[[data_region]]`. **Stack-hack incompatibili**: `[[nop_jsr]]`.
6. **extras.c**: nome, CRC32 della ROM, argomenti CLI, patch per frame, ecc.
7. Non modificare mai `generated/`: se il C e' sbagliato, correggi `game.toml` (o il recompiler) e rigenera.

## Hook in extras.c

| Funzione | Quando |
|----------|--------|
| `game_get_name` / `game_get_expected_crc32` | titolo finestra; verifica ROM (0 = salta) |
| `game_on_init` | dopo il caricamento ROM |
| `game_on_frame` / `game_post_nmi` | ogni VBlank, prima/dopo NMI |
| `game_handle_arg` / `game_arg_usage` | opzioni CLI proprie |
| `game_dispatch_override` | indirizzo non trovato (es. codice copiato in SRAM) |
| `game_ram_read_hook` | modifica letture RAM per call-site |
| `game_run_nmi` / `game_run_main` | default: `func_NMI()` / `func_RESET()` |
| `game_post_render` | disegna sopra il framebuffer (widescreen, overlay) |
| `game_fill_frame_record` / `game_handle_debug_cmd` | debug server TCP |

## Extra del runner (gia' inclusi)

Hotkey: `Tab` turbo, `F1-F12` carica slot, `Shift+F1-F12` salva slot, `Alt+Enter` fullscreen.
`keybinds.ini` viene generato al primo avvio (tastiera P1, gamepad P1/P2 via SDL). Opzioni CMake:
`-DNESRECOMP_ENABLE_TRACE=ON` (debug server TCP), `-DNESRECOMP_ENABLE_MODS=ON` (mod package).
Il gioco di riferimento aggiunge inoltre un launcher grafico (`recomp-ui`, ImGui) e override di testo
(`override_text.c`): non inclusi qui per restare minimali, copiali da FaxanaduRecomp se servono.

## Licenza

Il codice qui e' tuo; nesrecomp ha la sua licenza (vedi il submodule). Nessuna ROM inclusa.

## Build solo-interprete (giocabile subito)

Il recompiler non ha ancora un modello dei banchi MMC5, ma il runner ha un interprete 6502 che legge il codice
attraverso la mappatura MMC5 live. `interp_boot.c` lo usa per tutto il gioco, senza `generated/`:

```bash
cmake -S . -B build_interp -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DJB_INTERP_ONLY=ON
cmake --build build_interp
build_interp\JustBreedRecomp.exe baserom.nes
```

Senza argomenti si apre il launcher grafico (recomp-ui) che chiede la ROM e verifica il CRC32
(nessun CRC obbligatorio: il gioco riconosce la ROM dal banco fisso 62 e accetta la ROM giapponese, quella di Stealth e le ROM derivate).

Con `--script file.txt` gira senza finestra (vedi `nesrecomp/CLAUDE.md`: WAIT, HOLD, SCREENSHOT, EXIT).
Ogni indirizzo raggiunto viene scritto in `dispatch_misses.log`: e' la copertura del codice che ci serve per il
recompiler, ottenuta giocando (formato `extra_func <banco> <indirizzo>`; il "banco" e' ancora g_current_bank).
`NESRECOMP_MMC5_TRACE=1` stampa le scritture ai registri MMC5.

## Strumenti (cartella tools/)

- `mesen_justbreed_trace.lua`: script per Mesen 2 (Script Window, con accesso I/O). Salva in `C:/temp/justbreed/`
  la copertura del codice per banco ROM reale, il log dei registri MMC5 e l'eventuale codice eseguito da RAM.
- `coverage.py report|merge|entries`: unisce CDL Mesen e `jb_exec.bin` e mostra la copertura per banco.
- `test_trace_lua.py`: prova lo script Lua con un finto `emu` (serve `pip install lupa`).