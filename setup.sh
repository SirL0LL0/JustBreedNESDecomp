#!/usr/bin/env bash
set -euo pipefail
git submodule update --init --recursive nesrecomp recomp-ui
echo "Pronto: nesrecomp e recomp-ui scaricati."
