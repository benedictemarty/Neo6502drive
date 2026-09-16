# Validation : outils réseau de la communauté sur le modem USB (F-93)

Date : 2026-09-16. But : prouver que les programmes série existants de la
communauté Neo6502 (bocianu, gitlab.com/bocianu) fonctionnent **sans
modification** avec le modem Wi-Fi Pico W branché en USB, grâce au routage
UART→CDC du firmware du fork (F-93, fonction 10,19, mode AUTO).

Méthode : ces programmes n'ont pas de Neo6502 physique disponible ; on les
exécute dans **Phosphoneo** (émulateur headless qui compile et exécute le
*vrai* code firmware commun, routage inclus), avec le modem Pico W réel sur
`/dev/ttyACM0` relié par le pont `tools/serial_tap.py`. Rejouable via
`tools/run_neo_modem.sh PROG.neo [CYCLE:TOUCHES]`.

Sources testées : `neo-networking` et `neo-prophet`
(`git clone https://gitlab.com/bocianu/neo-networking` / `neo-prophet`),
binaires `.neo` d'origine, **non recompilés**.

## Résultats

| Outil | Résultat | Détail |
|---|---|---|
| `netinfo.neo` | **OK** | Écran : « Station Mode », « AP connected (IP obtained) ». Dialogue AT correct : `ATE0`, `AT+CWMODE?`→`+CWMODE:1`, `AT+CIPSTATUS`→`STATUS:2`, `AT+CWJAP_CUR?` (SSID/BSSID/canal/RSSI), `AT+CIPSTA_CUR?` (ip/gw/masque), `AT+CIPDNS_CUR?`. |
| `netconsole.neo` | **OK** | Console AT interactive ; `AT+GMR` tapé → relayé au modem → « AT version:1.7.4.0(Neo6502drive) / SDK version:0.2.0 / … / OK » affiché. |
| `prophet.neo` | **partiel** | Démarre, `ATE0`→`OK`, puis `AT+CIPSTART="TCP","mimuma.pl",8998`. Le modem exécute la commande ; le port **8998 est injoignable depuis ce réseau** (le PC non plus n'y accède pas) → « Error connecting server ». Côté modem/routage : conforme ; échec purement réseau, hors de notre contrôle. |

## Conclusion

Le routage F-93 permet aux outils communautaires de parler au modem USB sans
modification (netinfo et netconsole complets). Un `get` Prophet réel demande un
serveur Prophet joignable (port 8998 bloqué ici ; test de bout en bout à
refaire avec le serveur HTTPS de Neo6502Prophet, cf.
`docs/MEMO-PROPHET-picowifitls-reponse.md`).

Sur un Neo6502 **réel** : flasher le firmware du fork (F-93) et brancher un hub
USB (clavier + Pico W). Le comportement doit être identique.
