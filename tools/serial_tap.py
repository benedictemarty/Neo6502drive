#!/usr/bin/env python3
"""serial_tap.py — relais pty <-> port série avec journal des deux sens.
    tools/serial_tap.py /dev/ttyACM0 chemin_pty.txt journal.log
Crée un pty (chemin écrit dans chemin_pty.txt), relaie vers le port série et
journalise « > » (vers le modem) et « < » (depuis le modem). Pour observer ce
que l'émulateur envoie réellement au Pico W. SPDX-License-Identifier: EUPL-1.2
"""
import os, pty, select, sys, time
import serial
port, ptyfile, logfile = sys.argv[1:4]
ser = serial.Serial(port, 115200, timeout=0)
master, slave = pty.openpty()
open(ptyfile, 'w').write(os.ttyname(slave))
log = open(logfile, 'wb')
t0 = time.time()
def out(tag, data):
    log.write(b'%7.2f %s %r\n' % (time.time() - t0, tag, data)); log.flush()
while True:
    r, _, _ = select.select([master, ser.fileno()], [], [], 0.05)
    if master in r:
        try: d = os.read(master, 4096)
        except OSError: break
        if d: ser.write(d); out(b'>', d)
    if ser.fileno() in r:
        d = ser.read(4096)
        if d: os.write(master, d); out(b'<', d)
