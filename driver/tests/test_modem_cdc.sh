#!/bin/bash
# test_modem_cdc.sh — exécute build/modemtest.bin dans Phosphoneo (headless) contre
# le faux modem (sans matériel) ou, avec MODEM_TTY=/dev/ttyACM0, contre le vrai
# Pico W. Réussite : la console affiche « FIN » (et « hello, Neo! » avec le faux).
# SPDX-License-Identifier: EUPL-1.2
set -u
cd "$(dirname "$0")/.."
PHOS=${PHOSPHONEO:-$HOME/Phosphoneo/build/phosphoneo}
[ -x "$PHOS" ] || { echo "SKIP: Phosphoneo absent ($PHOS)"; exit 0; }
OUT=build/test_modem_cdc; rm -rf "$OUT"; mkdir -p "$OUT/storage"
# L'émulateur va ~40x plus vite que le réel : délai modem ("TO" + mot en 1/100 s à
# $07FC, hors binaire) porté à 60000 (600 s émulées ≈ 15 s réelles) ;
# --stop-on-self-jmp arrête dès FIN/ECHEC (JMP *).
POKE="--poke-at 0:07FC=54 --poke-at 0:07FD=4F --poke-at 0:07FE=FF --poke-at 0:07FF=FF"
if [ -n "${MODEM_TTY:-}" ]; then
    # Pont pyserial <-> port réel : maintient DTR et une config stable (l'ouverture
    # brute du tty par l'émulateur perd les réponses au-delà du 1er échange) et
    # journalise les deux sens dans $OUT/tap.log.
    python3 ../tools/serial_tap.py "$MODEM_TTY" "$OUT/pty.txt" "$OUT/tap.log" >/dev/null 2>&1 &
    TAP=$!; trap 'kill $TAP 2>/dev/null' EXIT
    for i in $(seq 1 20); do [ -s "$OUT/pty.txt" ] && break; sleep 0.2; done
    TTY=$(cat "$OUT/pty.txt"); CYCLES=${CYCLES:-6000000000}; EXPECT="HTTP/1.1"
else
    python3 tests/fake_picow_modem.py "$OUT/pty.txt" >/dev/null 2>&1 &
    MODEM=$!; trap 'kill $MODEM 2>/dev/null' EXIT
    for i in $(seq 1 20); do [ -s "$OUT/pty.txt" ] && break; sleep 0.2; done
    TTY=$(cat "$OUT/pty.txt"); CYCLES=${CYCLES:-2000000000}; EXPECT="hello, Neo!"
fi
NEO_CDC_TTY=$TTY "$PHOS" --headless --storage "$OUT/storage" --cycles "$CYCLES" $POKE \
    --stop-on-self-jmp --screenshot-text "$OUT/screen.txt" build/modemtest.bin@800 cold >"$OUT/run.log" 2>&1
echo "--- écran ---"; cat "$OUT/screen.txt" 2>/dev/null | sed '/^ *$/d'
if grep -q "^FIN" "$OUT/screen.txt" 2>/dev/null && grep -q "$EXPECT" "$OUT/screen.txt"; then
    echo "PASS: modemtest (groupe 14) sur $TTY"; exit 0
fi
echo "FAIL: modemtest — voir $OUT/run.log"; exit 1
