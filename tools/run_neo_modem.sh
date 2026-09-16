#!/bin/bash
# run_neo_modem.sh — exécute un programme .neo dans Phosphoneo (headless), avec le
# vrai code firmware du fork (routage UART->CDC F-93), contre le modem Wi-Fi Pico W
# branché en USB. Sert à faire tourner les outils série de la communauté
# (netinfo.neo, netconsole.neo, prophet.neo…) SANS Neo6502 physique.
#
#   tools/run_neo_modem.sh PROG.neo [CYCLE:TOUCHES] [MODEM_TTY]
#     PROG.neo        chemin du programme (ex. ~/neo-networking/netinfo.neo)
#     CYCLE:TOUCHES   frappe clavier optionnelle (ex. 200000000:AT+GMR\n)
#     MODEM_TTY       port du modem (défaut /dev/ttyACM0)
#
# Affiche l'écran console final et le dialogue série (build/run_neo_modem/tap.log).
# Prérequis : Phosphoneo compilé avec le firmware du fork (F-93), pyserial, modem
# provisionné (Wi-Fi en flash). SPDX-License-Identifier: EUPL-1.2
set -u
PROG=${1:?usage: run_neo_modem.sh PROG.neo [CYCLE:TOUCHES] [MODEM_TTY]}
KEYS=${2:-}
TTY=${3:-/dev/ttyACM0}
PH=${PHOSPHONEO_DIR:-$HOME/Phosphoneo}
cd "$(dirname "$0")/.."
[ -x "$PH/build/phosphoneo" ] || { echo "Phosphoneo absent ($PH)"; exit 2; }
[ -r "$PROG" ] || { echo "programme introuvable : $PROG"; exit 2; }
OUT=build/run_neo_modem; rm -rf "$OUT"; mkdir -p "$OUT/storage"
cp "$PROG" "$OUT/storage/" 2>/dev/null || true
python3 tools/serial_tap.py "$TTY" "$OUT/pty.txt" "$OUT/tap.log" >/dev/null 2>&1 &
BR=$!; trap 'kill $BR 2>/dev/null' EXIT
for i in $(seq 1 20); do [ -s "$OUT/pty.txt" ] && break; sleep 0.2; done
PTY=$(cat "$OUT/pty.txt")
KEYOPT=(); [ -n "$KEYS" ] && KEYOPT=(--type-keys "$KEYS")
NEO_CDC_TTY=$PTY "$PH/build/phosphoneo" --headless --storage "$OUT/storage" \
    --cycles 4000000000 "${KEYOPT[@]}" --screenshot-text-at "3999000000:$OUT/screen.txt" \
    "$PROG" >"$OUT/log" 2>&1
echo "=== console ==="; sed '/^ *$/d' "$OUT/screen.txt" 2>/dev/null
echo "=== dialogue série (modem) ==="; grep -E ' > | < ' "$OUT/tap.log" 2>/dev/null | cut -c1-100
