#!/bin/bash
# test_uart_route.sh — F-93 (Neo6502firmware) : les fonctions UART UEXT (10,15..18)
# sont routées vers le modem USB CDC (mode AUTO). uarttest.s n'appelle QUE l'API
# UART (jamais le groupe 14), comme netsetup.neo/prophet.neo ; il doit dialoguer
# avec le modem : ATE0/ATI -> identification + OK. Sans matériel : faux modem sur
# pty ; avec MODEM_TTY : vrai Pico W via le pont pyserial.
# Nécessite un Phosphoneo compilé avec le firmware du fork (routage) : voir
# ~/Neo6502firmware (F-93). SPDX-License-Identifier: EUPL-1.2
set -u
cd "$(dirname "$0")/.."
PH=${PHOSPHONEO_DIR:-$HOME/Phosphoneo}
[ -x "$PH/build/phosphoneo" ] || { echo "SKIP: Phosphoneo absent"; exit 0; }
OUT=build/test_uart_route; rm -rf "$OUT"; mkdir -p "$OUT/storage"
if [ -n "${MODEM_TTY:-}" ]; then
    python3 ../tools/serial_tap.py "$MODEM_TTY" "$OUT/pty.txt" "$OUT/tap.log" >/dev/null 2>&1 &
    BR=$!; trap 'kill $BR 2>/dev/null' EXIT
    for i in $(seq 1 20); do [ -s "$OUT/pty.txt" ] && break; sleep 0.2; done
    PTY=$(cat "$OUT/pty.txt")
else
    python3 tests/fake_picow_modem.py "$OUT/pty.txt" >/dev/null 2>&1 &
    BR=$!; trap 'kill $BR 2>/dev/null' EXIT
    for i in $(seq 1 20); do [ -s "$OUT/pty.txt" ] && break; sleep 0.2; done
    PTY=$(cat "$OUT/pty.txt")
fi
# fenêtre d'affichage à 0xFFFF (1/100 s) via "TO" en $07FC : l'émulateur s'emballe
# quand il attend le réseau, il faut une grande valeur émulée.
POKE="--poke-at 0:07FC=54 --poke-at 0:07FD=4F --poke-at 0:07FE=FF --poke-at 0:07FF=FF"
NEO_CDC_TTY=$PTY "$PH/build/phosphoneo" --headless --storage "$OUT/storage" --cycles 6000000000 $POKE \
    --stop-on-self-jmp --screenshot-text "$OUT/screen.txt" build/uarttest.bin@800 cold >"$OUT/run.log" 2>&1
echo "--- écran ---"; sed '/^ *$/d' "$OUT/screen.txt" 2>/dev/null
if grep -q "^FIN" "$OUT/screen.txt" 2>/dev/null && grep -qi "modem" "$OUT/screen.txt" && grep -q "^OK" "$OUT/screen.txt"; then
    echo "PASS: routage UART->CDC (API UART seule atteint le modem)"; exit 0
fi
echo "FAIL: routage UART->CDC — voir $OUT/run.log"; exit 1
