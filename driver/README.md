# driver/ — accès 6502 au modem Wi-Fi (USB CDC, groupe 14)

Code **ca65** (convention du projet, comme Neo6502kbd) pour piloter, depuis le
6502 du Neo6502, un périphérique série **USB CDC-ACM** branché sur le port
hôte — en pratique le modem Wi-Fi Pico W de `firmware/picow-modem/`. Le
firmware Neo6502 doit être celui du fork `Neo6502firmware` qui expose l'**API
groupe 14** (story F-90 ; le firmware officiel ignore le CDC).

## Contenu

```
src/neo6502.inc   sous-ensemble de l'API Neo6502 (groupes 1, 2, 14)
src/cdc.s/.inc    bibliothèque : accès CDC (14,1..14,6) + couche modem AT
                  (envoi de ligne, attente de réponse par suffixe, timeout,
                  synchronisation, invite « > » d'AT+CIPSEND)
examples/term.s   terminal série interactif (clavier <-> modem) — US-T9
examples/modemtest.s  test scénarisé : ATI, AT+CIFSR, requête HTTPS via
                  AT+TLSPORT=443, affichage de la réponse déchiffrée
examples/uarttest.s   preuve du routage UART->CDC (F-93) : n'utilise que
                  l'API UART UEXT (10,15..18), comme netsetup/prophet
cfg/neo.cfg       configuration ld65 (binaire brut chargé à $0800)
tests/            tests Phosphoneo (faux modem sans matériel, ou vrai Pico W)
```

## Construire et tester

```
make -C driver             # build/term.bin, build/modemtest.bin
make -C driver test        # Phosphoneo + faux modem (sans matériel)
make -C driver test-hw     # contre le vrai Pico W (MODEM_TTY=/dev/ttyACM0)
```
(ou `make driver`, `make test-driver`, `make test-driver-hw` depuis la racine).

Prérequis : `ca65`/`ld65` (cc65), l'émulateur `Phosphoneo` (`~/Phosphoneo`).
`term.bin` et `modemtest.bin` se chargent à `$0800` (`cold`).

## Convention API (groupe 14, fork Neo6502firmware F-90)

| Fonction | Rôle |
|---|---|
| 14,1 | statut (P7 = périphérique) → P0 = 1 connecté, P1-2 = octets en attente |
| 14,2 | lire un octet → P0 ; `NEO_ERROR` si rien |
| 14,3 | écrire un octet (P0) |
| 14,4 / 14,5 | lire / écrire un bloc mémoire |
| 14,6 | line coding (bauds, bits, parité, stop) |

## Tests contre le vrai modem : le pont série

L'émulateur, en ouvrant `/dev/ttyACM0` en direct, perd les réponses au-delà du
premier échange (DTR/configuration). Les tests `test-hw` passent donc par
`tools/serial_tap.py` (pont pyserial qui maintient le port ouvert et
journalise les deux sens dans `build/test_*/tap.log`). Le terminal et le test
HTTPS ont été validés ainsi contre le Pico W (identité, `AT+CIFSR`,
`AT+CIPSTART`/`CIPSEND` en TLS, réponse `+IPD` déchiffrée, `CLOSED`).

## Sur un Neo6502 réel

Nécessite le firmware du fork (groupe 14) flashé et un hub USB (clavier +
Pico W sur l'unique port USB-A). `netsetup.neo`/`prophet.neo` parlent à l'UART
UEXT, pas au groupe 14 : leur usage sur CDC demanderait un routage 10,x → CDC
dans le firmware (à décider) ou une recompilation sur le groupe 14.
