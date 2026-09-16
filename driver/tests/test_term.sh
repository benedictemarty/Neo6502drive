#!/bin/bash
# test_term.sh — US-T9 : le terminal 6502 (term.s, ca65) relie le clavier au modem
# CDC (groupe 14) et affiche les réponses. Sans matériel : faux modem Hayes de
# Phosphoneo sur un pty, frappe auto « ATI\n » ; avec MODEM_TTY : vrai Pico W via
# le pont pyserial (tools/serial_tap.py). Réussite : identification + « OK ».
# SPDX-License-Identifier: EUPL-1.2
set -u
cd "$(dirname "$0")/.."
PH=${PHOSPHONEO_DIR:-$HOME/Phosphoneo}
[ -x "$PH/build/phosphoneo" ] || { echo "SKIP: Phosphoneo absent"; exit 0; }
OUT=build/test_term; rm -rf "$OUT"; mkdir -p "$OUT/storage"
if [ -n "${MODEM_TTY:-}" ]; then
    python3 ../tools/serial_tap.py "$MODEM_TTY" "$OUT/pty.txt" "$OUT/tap.log" >/dev/null 2>&1 &
    BR=$!; trap 'kill $BR 2>/dev/null' EXIT
    for i in $(seq 1 20); do [ -s "$OUT/pty.txt" ] && break; sleep 0.2; done
    PTY=$(cat "$OUT/pty.txt"); KEYS='3000000:ATI\n'; NEED_MODEM="modem"; CYCLES=120000000
else
    python3 "$PH/tools/fake_modem.py" "$OUT/pty.txt" >/dev/null 2>&1 &
    BR=$!; trap 'kill $BR 2>/dev/null' EXIT
    for i in $(seq 1 20); do [ -s "$OUT/pty.txt" ] && break; sleep 0.2; done
    PTY=$(cat "$OUT/pty.txt"); KEYS='3000000:ATI\n'; NEED_MODEM="modem"; CYCLES=12000000
fi
NEO_CDC_TTY=$PTY "$PH/build/phosphoneo" --headless --storage "$OUT/storage" --cycles "$CYCLES" \
    --type-keys "$KEYS" --screenshot-text-at "$((CYCLES - 10000)):$OUT/term.txt" build/term.bin@800 cold >"$OUT/log.txt" 2>&1
if grep -q "Modem connecte" "$OUT/term.txt" && grep -qi "$NEED_MODEM" "$OUT/term.txt" && grep -q "^OK" "$OUT/term.txt"; then
    echo "PASS: terminal série (term.s, ATI -> identification + OK)"; grep -v "^ *$" "$OUT/term.txt" | sed -n 4,9p; exit 0
fi
echo "FAIL: terminal série"; cat "$OUT/term.txt"; exit 1
