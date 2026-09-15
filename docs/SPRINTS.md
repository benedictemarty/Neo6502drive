# Sprints

## Sprint 0 — 2026-09-15 — « Cadrage »

**Livré** : dépôt, vision, backlog, DoD, architecture et protocole proposés,
notes vérifiées sur l'API UEXT du Neo6502.

**Décisions** : cible Neo6502 ; carte **Adafruit Feather RP2040 USB Host**
(possédée par le PO) ; **mode MSC USB d'abord** (clé virtuelle, aucun driver
6502), puis mode bloc UEXT (UART v1, SPI v2), puis télécom (EPIC-02).

## Sprint 1 — 2026-09-15 — « Modem Wi-Fi sur Pico W » (EPIC-02)

**Décision PO (2026-09-15)** : un Pico W est disponible et doit servir de
modem Wi-Fi sur USB ; la télécom passe avant le prototype clé USB, qui glisse
en sprint 2.

**Livré** : `firmware/picow-modem/` (US-T0, US-T1, US-T2) — cœur AT/Hayes
portable + couche Pico W (cyw43, lwIP, TinyUSB CDC, UART0, flash) ;
126 vérifications unitaires sur PC (`make test`) rejouant les séquences de
netinfo/netsetup/prophet ; UF2 compilé sans avertissement (Pico SDK 2.2.0) ;
`hardware/PICOW_UEXT.md` ; `Makefile` racine (`test`, `firmware`, `flash`).

**Test sur carte (2026-09-15, PC, `/dev/ttyACM0`)** : le Pico W est
énuméré `2e8a:000a Neo6502drive Pico W Wi-Fi modem` ; `AT`, `ATE0`, `AT+GMR`,
`AT+CWMODE?`, `AT+CIPSTATUS` (`STATUS:5` sans AP), `AT+CIFSR` (MAC) et
`AT+CWLAP=,,,1,,` (10 réseaux, ecn/ssid/rssi) conformes. Anomalies vues et
corrigées sur place : doublons de SSID (un par point d'accès) ; octet
parasite avant le premier `AT` après le boot (RX UART flottant). Le premier
flash a nécessité un câble micro-USB de données (le premier câble essayé
n'était pas vu du PC) ; les suivants passent par `AT+BOOTSEL`.

**Test réseau sur carte (2026-09-15, suite, Wi-Fi = partage de connexion
Android 2,4 GHz)** :
- `AT+CWJAP_DEF` (saisi par le PO dans `screen`) → `WIFI CONNECTED / WIFI
  GOT IP` ; un premier essai avait donné `+CWJAP:1` (timeout, SSID/mdp à
  revoir côté PO) ; reconnexion automatique au boot vérifiée (`STATUS:2`).
- `AT+CIPSTA_CUR?`, `AT+CIPDNS_CUR?`, `AT+CWDHCP_DEF?`, `AT+CWJAP_CUR?`
  (BSSID, canal, RSSI), `AT+PING="mimuma.pl"` (158 ms), SNTP
  (`+CIPSNTPTIME:Tue Sep 15 22:59:00 2026`) : conformes.
- Séquence Prophet vers `mimuma.pl:80` (le port 8998 est injoignable
  depuis ce réseau, PC compris) : `CONNECT` → `AT+CIPSEND=57` → `> ` →
  `Recv 57 bytes` / `SEND OK` → `+IPD,483:` (réponse HTTP) → `CLOSED` ;
  `STATUS:4` ensuite ; deux connexions successives OK.
- Hayes : `ATDT telehack.com:23` → `CONNECT`, dialogue transparent
  (`date`), `+++` → `OK` sans transmission des `+`, `ATO`, `ATH` ;
  `AT+CIPSERVER=1,6502` puis connexion depuis le PC → `RING`, `ATA` →
  `CONNECT` + données envoyées avant le décroché, réponse reçue entière par
  le PC, `NO CARRIER` à la fermeture.

**Anomalies trouvées sur carte et corrigées** : (1) blocage de
`tcp_connect` après `sntp_init` — assertion lwIP « pool MEMP_SYS_TIMEOUT is
empty » (temporisateurs non comptés pour SNTP) → `MEMP_NUM_SYS_TIMEOUT`
augmenté ; diagnostiqué grâce au watchdog + points d'étape + capture du
message d'assertion, désormais lisibles par `ATI` ; (2) `+++` transmis au
distant ; (3) données d'un appel entrant émises en `+IPD` avant `RING` ;
(4) envoi TCP octet par octet en ligne ; (5) `CWJAP?` renvoyait la MAC de
la carte au lieu du BSSID ; (6) SNTP non relancé après `AT+CIPSNTPCFG`.

**US-T9 « picowifitls » (2026-09-16, à la demande du projet Neo6502Prophet)** :
TLS terminé sur le Pico W livré et validé sur carte — `AT+CIPSTART="SSL"`,
`AT+TLSPORT`, vérification CA (ISRG Root X1) + SNI + dates, refus sans heure
SNTP, reprise de session, `AT+TLSTEST`, diagnostic dans `ATI`. Mesures :
handshake complet 2,4–2,8 s (mimuma.pl, ECDHE-RSA-AES256-GCM, chaîne de 4),
repris 0,3–0,5 s ; scénario Prophet (une connexion par bloc) 3–4 s puis
1,2 s par bloc ; letsencrypt.org (ECDSA, CDN) 5 s. Refus vérifiés : nom
d'hôte faux (IP directe, drapeau 0x4), racine inconnue (www.google.com,
0x8). Anomalies trouvées et corrigées : `-O3` casse AES-GCM (GCC 14.2.1,
autotest mbedTLS en échec, `bad_record_mac` partout) → `-O2` ; handshake
> 8 s dans l'IRQ lwIP → timer de garde du watchdog ; fenêtre ECC 6→4 après
mesure (16 s → 3 s de vérification) ; **`altcp_tls` en `VERIFY_OPTIONAL` par
défaut acceptait un certificat au mauvais nom** → `REQUIRED` forcé ; join
Wi-Fi au boot abandonné sur `LINK_NONET` → relance comme le SDK ; migration
de la configuration flash v1 → v2 sans ressaisie. Tests PC : 164 + 10 804
(dates). Reste : test de bout en bout avec le serveur Prophet en HTTPS
(Sprint 2 de Neo6502Prophet), mesure `pget` réelle ; observation : une
connexion fermée côté client aussitôt après le handshake n'a pas été reprise
(à creuser, sans impact sur Prophet).

**Non testé** : transport UART (GP0/GP1) — nécessite le câblage UEXT ou un
adaptateur USB-série ; `netsetup.neo` / `prophet.neo` sur le Neo6502 réel.
Contrainte : le port USB du Neo6502 n'est exploitable qu'après F-13
(Neo6502firmware).

## Sprint 2 — à planifier — « Prototype clé USB virtuelle sur Pi Zero W »

Stories : **US-M0**, US-M4 (outil d'images). Objectif : le Neo6502 charge un
programme depuis une image choisie via la page web du Pi ; consigner :
alimentation par le hub, délai d'apparition, comportement au changement
d'image à chaud. Prérequis : hub USB, câble micro-USB OTG, carte SD Raspberry
Pi OS Lite. Aucun firmware à écrire.

## Sprint 3 — « Clé USB virtuelle embarquée (Feather) »

Stories : US-M1, US-M2, US-M3 (reprend images et outil validés en S1).
Prérequis : Pico SDK + TinyUSB + Pico-PIO-USB.

## Sprint 4 — « Périphérique bloc UEXT »

Candidats : US-01, US-02, US-03, US-04, US-10 (tout testable sans matériel).

## Sprint 5 — « Télécom : proxy de sockets et simulateur »

Stories : US-T3, US-T4 (proxy binaire dans le firmware Pico W, driver ca65
`net.s`, maquette réseau dans le simulateur Go). US-05/US-11 (firmware bloc
Feather, mesures) glissent en sprint 5 bis selon disponibilité du matériel.

## Sprint 6 — « CDC dans le firmware » (EPIC-04)

Candidats : US-C1 (build du firmware officiel), US-C2, US-C3, US-C4 ; US-C5
sur le Pi Zero W (configfs) peut être préparé dès le sprint 1 en composite
MSC + CDC, le CDC restant inactif côté Neo6502 jusqu'à US-C2.
