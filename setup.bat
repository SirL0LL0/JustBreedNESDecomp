@echo off
rem Scarica i submodule nesrecomp (runner + recompiler) e recomp-ui (launcher grafico) alle versioni fissate.
git submodule update --init --recursive nesrecomp recomp-ui
if errorlevel 1 ( echo Errore: submodule fallito & exit /b 1 )
echo Pronto: nesrecomp e recomp-ui scaricati.
