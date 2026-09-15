# Changelog

Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) ;
versionnement SemVer.

## [Unreleased]
- 2026-09-15 : US-T9 vérifiée avec le vrai Pico W modem (`MODEM_TTY=/dev/ttyACM0 make -C driver test`) : `ATI` → « Neo6502drive Pico W modem 0.1.0 / last reset: watchdog, stage 0 / OK ».
- 2026-09-15 : US-T9 — terminal série 6502 `driver/src/term.asm` (API groupe 14 : 14,1 statut, 14,2 lecture, 14,3 écriture ; CR ignoré, LF = ligne, Échap = quitter, détection de déconnexion) ; `make -C driver` et `make -C driver test` (Phosphoneo + faux modem ; `MODEM_TTY` pour un vrai modem).
- 2026-09-15 : premier dialogue de bout en bout : firmware Neo (fork F-90, groupe 14, co-sim Phosphoneo) ↔ Pico W modem réel (`2e8a:000a`, `/dev/ttyACM0`) — `ATI` → « Neo6502drive Pico W modem 0.1.0 », `ATZ` → `OK`. Le modem fait l'écho des commandes.
- 2026-09-15 : US-C2..C4 réalisées dans le fork firmware (F-90, groupe 14 « USB Serial (CDC) ») ; le modem Hayes de US-T1 peut être testé de bout en bout contre `Phosphoneo/tools/fake_modem.py` ou un vrai modem CDC.

### Ajouté
- Sprint 1 (2026-09-15) : firmware `firmware/picow-modem/` — modem Wi-Fi sur
  Raspberry Pi Pico W (US-T0, US-T1, US-T2) : dialecte AT ESP8266 relevé dans
  les sources de neo-networking/neo-prophet (CWMODE, CWJAP, CWLAP, CIFSR,
  CIPSTA, CIPDNS, CIPSTATUS, CIPSTART/SEND/CLOSE, +IPD, CIPSERVER, SNTP,
  PING…), modem Hayes (ATDT, +++, ATO, ATH, ATA, RING, S0/S2/S12), transports
  USB CDC-ACM et UART0 GP0/GP1 simultanés, configuration en flash ; cœur
  portable testé sur PC (`make test`, 126 vérifications) ; `Makefile` racine
  (`test`, `firmware`, `flash`) ; `hardware/PICOW_UEXT.md`.
- `AT+BOOTSEL` (reflash sans bouton) ; balayage Wi-Fi dédoublonné par SSID et
  trié par RSSI ; premier test sur carte (voir SPRINTS).
- Watchdog 8 s, points d'étape et capture des assertions lwIP, cause du
  dernier reset dans `ATI` ; connexion Wi-Fi asynchrone (compatible
  watchdog) ; `+++` retenus pendant le temps de garde (non transmis) ; envoi
  TCP groupé en ligne ; données d'un appel entrant retenues jusqu'à `ATA`.
  Validation réseau complète sur carte (Prophet sur HTTP, telnet, appel
  entrant) consignée dans SPRINTS.

### Corrigé
- Connexion Wi-Fi au démarrage abandonnée sur `LINK_NONET` (réseau pas encore
  vu) : relance jusqu'au délai, comme le SDK.
- Compilation en `-O2` : `-O3` (GCC 14.2.1, Cortex-M0+) rend AES-GCM de
  mbedTLS faux (`bad_record_mac`).
- Blocage de `AT+CIPSTART` après activation de SNTP (assertion lwIP
  « pool MEMP_SYS_TIMEOUT is empty ») : `MEMP_NUM_SYS_TIMEOUT` augmenté.
- SNTP non relancé après `AT+CIPSNTPCFG` ; `AT+CWJAP?` renvoyait la MAC de la
  carte au lieu du BSSID.
- Octet parasite avant la première commande après le boot (UART RX GP1 en
  l'air) : pull-up interne, vidage du FIFO et rejet des octets en erreur.

### Modifié
- Licence changée de MIT en EUPL v1.2 (décision du 2026-09-15, commune aux
  projets Neo6502 de bmarty ; le fork Neo6502firmware reste MIT).
- EPIC-02 : matériel Pico W (décision PO) à la place du Pi Zero W ; sprint 1
  réaffecté au modem Wi-Fi, prototype clé USB décalé en sprint 2, sprints
  renumérotés ; architecture et README mis à jour.
- Stories firmware (US-C1..C4, US-B3) déléguées au dépôt commun Neo6502firmware
  (F-00, F-13, F-20).

### Ajouté
- Sprint 0 (2026-09-15) : création du projet, cadrage (vision, backlog, DoD,
  architecture et protocole proposés, notes vérifiées sur l'API UEXT).
- EPIC-02 déclinée en US-T1..T8 (modem Hayes en premier, compatibilité AT
  ESP8266 avec netconfig/prophet, proxy de sockets, simulateur, transfert
  Wi-Fi, HTTP/NTP, telnet entrant, Samba) ; sprint 4 replanifié.
- EPIC-04 « prise en charge CDC » (US-C1..C6) : hôte CDC-ACM dans le firmware
  Neo6502, API routée, maquette émulateur, gadget composite MSC + CDC.
- EPIC-03 « périphérique sur BUS1 » (US-B1..B4) ; note sur l'interrupteur de
  configuration : SPI UEXT indisponible sans déconnecter RESB/NMIB/IRQB.
- US-M0 : prototype sur Raspberry Pi Zero W (gadget USB) en sprint 1 ; sprints
  replanifiés ; EPIC-02 précisée (pile TCP sur le périphérique) ; bank
  switching déclaré hors périmètre (modification du firmware).
- Réorientation : carte Feather RP2040 USB Host ; mode « clé USB virtuelle »
  (MSC) en sprint 1 (US-M1..M5), mode bloc UEXT ensuite, EPIC-02 télécom.
