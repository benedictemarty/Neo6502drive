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
| `prophet.neo` (mimuma.pl) | réseau | `ATE0`→`OK`, `AT+CIPSTART="TCP","mimuma.pl",8998` : port **8998 injoignable depuis ce réseau** (le PC non plus). |
| `prophet.neo` (3617.fr) | **transport OK, serveur 400** | Config pré-remplie sur `3617.fr:8998` : le modem **se connecte** (`CONNECT`), envoie la requête et reçoit `+IPD` — la chaîne 6502→modem→serveur fonctionne. Le serveur (**Caddy**) répond **HTTP 400** car prophet émet une ligne de requête `GET … HTTP/1.1 ` avec un **espace en trop** (bug de `http.inc`). Vérifié : requête *propre* → **200 OK**, requête *avec l'espace* → **400**, aussi bien en `nc` depuis le PC qu'en envoyant la requête propre **par le modem** (`AT+CIPSTART`/`CIPSEND` vers 3617.fr → `HTTP/1.1 200 OK, Server: Caddy`). |

## Conclusion

Le routage F-93 permet aux outils communautaires de parler au modem USB sans
modification (netinfo et netconsole complets). Le modem atteint un vrai serveur Prophet (`3617.fr:8998`, Caddy) et en reçoit
`200 OK` sur une requête propre. Le seul obstacle à un `get` prophet complet
est **l'espace en trop dans la ligne de requête de prophet** (`http.inc`),
que Caddy rejette par un 400 : soit corriger prophet, soit placer devant le
serveur un proxy tolérant. Point déjà signalé au projet Neo6502Prophet
(`docs/MEMO-PROPHET-picowifitls-reponse.md`, §3).

Sur un Neo6502 **réel** : flasher le firmware du fork (F-93) et brancher un hub
USB (clavier + Pico W). Le comportement doit être identique.
