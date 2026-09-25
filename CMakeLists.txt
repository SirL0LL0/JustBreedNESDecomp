cmake_minimum_required(VERSION 3.20)
project(JustBreedRecomp C CXX)
option(JB_INTERP_ONLY "Build senza codice ricompilato: solo interprete 6502" OFF)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# nesrecomp/ e' un submodule git (vedi .gitmodules): setup.bat / setup.sh lo scaricano.
set(NESRECOMP_ROOT ${CMAKE_SOURCE_DIR}/nesrecomp)

# Mod (cheat) attivabili dal launcher: pacchetti in mods/packages, plugin in cheats.c
set(NESRECOMP_ENABLE_MODS ON CACHE BOOL "" FORCE)
# Menu di gioco (recomp-ui runtime UI): Esc apre, mette in pausa; vedi nesrecomp/runner/include/runtime_ui_host.h
set(NESRECOMP_ENABLE_RUNTIME_UI ON CACHE BOOL "" FORCE)

# Fornisce NESRECOMP_RUNNER_SOURCES, NESRECOMP_RUNNER_INCLUDE_DIRS, NESRECOMP_RUNNER_ROOT
include(${NESRECOMP_ROOT}/runner/runner.cmake)

list(APPEND CMAKE_PREFIX_PATH "${NESRECOMP_ROOT}/runner/external/SDL2/cmake")
find_package(SDL2 REQUIRED)

add_executable(JustBreedRecomp
    ${NESRECOMP_RUNNER_SOURCES}
    extras.c
    cheats.c
)
if(JB_INTERP_ONLY)
    # Bootstrap: nessun codice ricompilato, tutto passa dall'interprete del runner.
    target_sources(JustBreedRecomp PRIVATE interp_boot.c)
    # Blocchi base tradotti in C (python tools/mmc5_blocks.py baserom_jp.nes generated/blocks analysis/all.bin):
    # l'interprete li esegue al posto della decodifica. JB_BLOCKS=OFF li esclude.
    option(JB_BLOCKS "Usa i blocchi C tradotti (generated/blocks) sopra l'interprete" ON)
    file(GLOB JB_BLOCK_SRC CONFIGURE_DEPENDS generated/blocks/jb_blocks_*.c)
    if(JB_BLOCKS AND JB_BLOCK_SRC)
        target_sources(JustBreedRecomp PRIVATE ${JB_BLOCK_SRC})
        target_compile_definitions(JustBreedRecomp PRIVATE JB_BLOCKS=1)
    endif()
    # Funzioni C decompilate (python tools/decompile.py baserom_jp.nes generated/decomp analysis/all.bin):
    # l'interprete le chiama al posto di interpretare la routine (modo handoff 'safe'). JB_DECOMP=OFF le esclude.
    option(JB_DECOMP "Usa le funzioni decompilate (generated/decomp)" ON)
    file(GLOB JB_DEC_SRC CONFIGURE_DEPENDS generated/decomp/jb_dec_u*.c generated/decomp/jb_dec_tab.c)
    list(FILTER JB_DEC_SRC EXCLUDE REGEX "_readable\\.c$")
    if(JB_DECOMP AND JB_DEC_SRC)
        target_sources(JustBreedRecomp PRIVATE ${JB_DEC_SRC})
        target_include_directories(JustBreedRecomp PRIVATE ${CMAKE_SOURCE_DIR}/generated/decomp)
        target_compile_definitions(JustBreedRecomp PRIVATE JB_DECOMP=1)
    endif()
else()
    # Prodotti da NESRecomp.exe (prefisso = output_prefix in game.toml)
    file(GLOB JB_GENERATED CONFIGURE_DEPENDS generated/justbreed_full*.c generated/justbreed_dispatch.c)
    target_sources(JustBreedRecomp PRIVATE ${JB_GENERATED})
endif()

target_include_directories(JustBreedRecomp PRIVATE
    ${NESRECOMP_RUNNER_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}
    ${SDL2_INCLUDE_DIRS}
)

target_link_libraries(JustBreedRecomp PRIVATE ${SDL2_LIBRARIES})

# ---- Launcher grafico pre-avvio (recomp-ui / Dear ImGui, submodule) ----
# Definisce RECOMP_LAUNCHER, che attiva il blocco launcher in main() di nesrecomp.
include(${CMAKE_SOURCE_DIR}/recomp-ui/recomp_ui.cmake)
recomp_target_launcher_ui(JustBreedRecomp CONSOLE nes LANGUAGE it)
recomp_target_runtime_ui_sdlrenderer2(JustBreedRecomp)

# Gioco a un solo giocatore: nasconde la scheda Player 2 nel launcher.
target_compile_definitions(JustBreedRecomp PRIVATE NESRECOMP_GAME_PLAYERS=1
    NESRECOMP_GAME_ID="just-breed" NESRECOMP_GAME_ROM_CRC32="a77ee1ce")

# Pacchetti mod accanto all'eseguibile (mods/packages/<id>/<versione>/manifest.toml)
add_custom_command(TARGET JustBreedRecomp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_SOURCE_DIR}/mods/packages"
        "$<TARGET_FILE_DIR:JustBreedRecomp>/mods/packages")

if(WIN32)
    target_link_libraries(JustBreedRecomp PRIVATE ws2_32)
    add_custom_command(TARGET JustBreedRecomp POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${NESRECOMP_ROOT}/runner/external/SDL2/lib/x64/SDL2.dll"
            "$<TARGET_FILE_DIR:JustBreedRecomp>")
endif()

if(MSVC)
    target_compile_options(JustBreedRecomp PRIVATE /W3 /WX- /wd4102)
endif()

# Opzionale: debug server TCP, shadow stack, ring diagnostici
#   cmake ... -DNESRECOMP_ENABLE_TRACE=ON
