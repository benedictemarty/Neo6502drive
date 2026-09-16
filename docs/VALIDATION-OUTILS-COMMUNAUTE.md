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
| `prophet.neo` (3617.fr) | **OK de bout en bout** | Config pré-remplie sur `3617.fr:8998` : « Server connected », « Prophet server version: 0.7.0 », puis `list` → **catalogue affiché** (« Total: 43, Page 1/3 », aerial/antiair/…/frogger) et `cat` → catégories (games 37, tools 5, other 1). Boucle réelle 6502 (Phosphoneo, vrai firmware) → routage F-93 → modem USB Pico W → 3617.fr. Le serveur Prophet a été rendu tolérant à l'espace en trop de `http.inc` (relais layer4 + prophetd 0.7.0) après signalement ; auparavant il renvoyait 400 (Caddy strict), reproduit en `nc` et par le modem. |

## Conclusion

Le routage F-93 permet aux outils communautaires de parler au modem USB sans
modification (netinfo et netconsole complets). **Boucle télécom complète prouvée** : `prophet.neo` non modifié, sur le 6502
(Phosphoneo + vrai firmware), liste le catalogue de `3617.fr:8998` via le modem
Wi-Fi Pico W en USB (routage F-93). Le serveur Prophet a été rendu tolérant à
l'espace en trop de `http.inc` (signalement §3 du mémo).

Réserve : dans l'émulateur headless (plus rapide que le temps réel), le délai
de lecture de prophet — compté en trames — expire parfois avant la réponse du
modem (~0,3 s réelles) → « No result » intermittent, alors que le tap montre la
liste complète reçue par le 6502. Sur un Neo6502 réel (6,25 MHz, temps réel),
non concerné. Limite restante côté serveur : `prophet.neo` + `AT+TLSPORT=443`
→ 400 (Caddy termine le TLS et analyse l'HTTP) ; passthrough SNI layer4 au
backlog de Neo6502Prophet. Les clients propres (ProphetGui, curl) passent en
443, et le TLS du Pico W est validé par ProphetGui (handshake 4,4 s, reprise
0,35–0,85 s, certificat vérifié).

Sur un Neo6502 **réel** : flasher le firmware du fork (F-93) et brancher un hub
USB (clavier + Pico W). Le comportement doit être identique.
