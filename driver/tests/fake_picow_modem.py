#!/usr/bin/env python3
"""fake_picow_modem.py — simulateur minimal du modem Wi-Fi Neo6502drive (dialecte
AT ESP8266 + TLSPORT) sur un pseudo-terminal, pour tester le driver 6502 sans
matériel (US-T4, maquette). Écrit le chemin du pty dans le fichier donné.
Répond : ATE0/ATE1, ATI, AT+CIFSR, AT+TLSPORT=/?, AT+CIPSTART (CONNECT/OK),
AT+CIPSEND=n (OK > … Recv n bytes / SEND OK, puis +IPD avec une réponse HTTP et
CLOSED), AT+CIPCLOSE, AT → OK ; le reste → ERROR.
SPDX-License-Identifier: EUPL-1.2
"""
import os, pty, select, sys, time

master, slave = pty.openpty()
path = os.ttyname(slave)
if len(sys.argv) > 1:
    open(sys.argv[1], 'w').write(path)
print(path, flush=True)

echo, buf, connected, tls_ports = True, b'', False, []
send_expected = 0
HTTP = (b'HTTP/1.1 200 OK\r\nServer: fake-picow\r\nContent-Length: 12\r\nConnection: close\r\n\r\nhello, Neo!\n')

def w(b): os.write(master, b)

while True:
    r, _, _ = select.select([master], [], [], 1.0)
    if not r: continue
    try: data = os.read(master, 512)
    except OSError: break
    if not data: continue
    if send_expected:
        buf += data
        if len(buf) >= send_expected:
            payload, buf = buf[:send_expected], buf[send_expected:]
            w(b'\r\nRecv %d bytes\r\n\r\nSEND OK\r\n' % send_expected); send_expected = 0
            if connected:
                time.sleep(0.2); w(b'\r\n+IPD,%d:' % len(HTTP) + HTTP + b'CLOSED\r\n'); connected = False
        continue
    buf += data
    while b'\n' in buf or b'\r' in buf:
        cut = min(i for i in (buf.find(b'\r'), buf.find(b'\n')) if i >= 0)
        line, buf = buf[:cut], buf[cut + 1:]
        cmd = line.strip()
        if not cmd: continue
        if echo: w(cmd + b'\r\n')
        u = cmd.upper()
        if u == b'AT': w(b'\r\nOK\r\n')
        elif u in (b'ATE0', b'ATE1'): echo = (u == b'ATE1'); w(b'\r\nOK\r\n')
        elif u == b'ATI': w(b'Neo6502drive Pico W modem 0.2.0 (fake)\r\nTLS: fake, roots: 1\r\n\r\nOK\r\n')
        elif u == b'AT+CIFSR': w(b'+CIFSR:STAIP,"10.0.0.2"\r\n+CIFSR:STAMAC,"28:cd:c1:00:00:01"\r\n\r\nOK\r\n')
        elif u == b'AT+TLSPORT?': w(b'+TLSPORT:' + b','.join(str(p).encode() for p in tls_ports) + b'\r\n\r\nOK\r\n')
        elif u.startswith(b'AT+TLSPORT='):
            ports = [int(x) for x in u[11:].split(b',')]; tls_ports = [p for p in ports if p]; w(b'\r\nOK\r\n')
        elif u.startswith(b'AT+CIPSTART='):
            connected = True; w(b'CONNECT\r\n\r\nOK\r\n')
        elif u.startswith(b'AT+CIPSEND='):
            if not connected: w(b'link is not valid\r\n\r\nERROR\r\n')
            else: send_expected = int(u[11:]); w(b'\r\nOK\r\n> ')
        elif u == b'AT+CIPCLOSE':
            if connected: connected = False; w(b'CLOSED\r\n\r\nOK\r\n')
            else: w(b'\r\nERROR\r\n')
        else: w(b'\r\nERROR\r\n')
