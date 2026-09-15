#!/bin/bash
# test_term.sh — US-T9 : le terminal 6502 relie le clavier au modem CDC et affiche les réponses.
# Faux modem Hayes de Phosphoneo sur un pty ; frappe automatique « ATI\n » ; la console doit
# montrer l'identification du modem et « OK ». Avec un vrai modem : MODEM_TTY=/dev/ttyACM0.
set -u
cd "$(dirname "$0")/.."
PH=${PHOSPHONEO_DIR:-$HOME/Phosphoneo}
OUT=build/test_term; rm -rf "$OUT"; mkdir -p "$OUT/storage"
if [ -n "${MODEM_TTY:-}" ]; then PTY=$MODEM_TTY; else
    python3 "$PH/tools/fake_modem.py" "$OUT/pty.txt" >/dev/null 2>&1 & MODEM=$!; trap 'kill $MODEM 2>/dev/null' EXIT
    for i in 1 2 3 4 5 6 7 8 9 10; do [ -s "$OUT/pty.txt" ] && break; sleep 0.2; done
    PTY=$(cat "$OUT/pty.txt")
fi
NEO_CDC_TTY=$PTY "$PH/build/phosphoneo" --headless --storage "$OUT/storage" --cycles 12000000 \
    --type-keys '3000000:ATI\n' --screenshot-text-at "11990000:$OUT/term.txt" build/term.neo6502@800 cold >"$OUT/log.txt" 2>&1
grep -q "Modem connecte" "$OUT/term.txt" && grep -q "modem" "$OUT/term.txt" && grep -q "^OK" "$OUT/term.txt" \
    && { echo "PASS: terminal série (ATI -> identification + OK)"; grep -v "^ *$" "$OUT/term.txt" | sed -n 5,9p; } \
    || { echo "FAIL: terminal série"; cat "$OUT/term.txt"; exit 1; }
