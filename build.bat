@echo off
setlocal
rem Uso: build.bat percorso\gioco.nes
if "%~1"=="" ( echo Uso: build.bat gioco.nes & exit /b 1 )

echo === 1/3 Compila il recompiler ===
cmake -S nesrecomp\recompiler -B nesrecomp\build_recomp -G "Visual Studio 17 2022" -A x64 || exit /b 1
cmake --build nesrecomp\build_recomp --config Release || exit /b 1

echo === 2/3 Ricompila la ROM 6502 -> C (genera generated\) ===
if not exist generated mkdir generated
nesrecomp\build_recomp\Release\NESRecomp.exe "%~1" --game game.toml || exit /b 2

echo === 3/3 Compila il gioco nativo ===
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 || exit /b 3
cmake --build build --config Release || exit /b 4

echo Fatto: build\Release\JustBreedRecomp.exe "%~1"
