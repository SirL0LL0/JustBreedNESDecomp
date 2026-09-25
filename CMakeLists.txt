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
