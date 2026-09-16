# Product Backlog

Priorité P1 > P2 > P3. État : À faire / En cours / Terminé (sprint).

| ID | P | User story | État |
|----|---|------------|------|
| US-M0 | P1 | En tant que PO, je veux un prototype « clé USB virtuelle » sur **Raspberry Pi Zero W** (gadget USB `mass_storage` via configfs, script Python, page web de sélection d'image en Wi-Fi), afin de valider le concept, le changement d'image à chaud et l'alimentation avant d'écrire le firmware Feather. | À faire (S1) |
| US-M1 | P1 | En tant qu'utilisateur, je veux que le Feather apparaisse comme une clé USB FAT32 sur le Neo6502 (TinyUSB device MSC) servant une image `.img` fixe, afin de valider la chaîne sans driver 6502. | À faire (S2) |
| US-M2 | P1 | En tant qu'utilisateur, je veux que les images viennent de la clé USB branchée au port hôte du Feather (PIO-USB + FatFS) ou d'une microSD, afin de gérer plusieurs volumes. | À faire (S2) |
| US-M3 | P1 | En tant qu'utilisateur, je veux changer d'image (bouton / liste) et que le Neo6502 voie le nouveau volume (déconnexion/reconnexion USB), afin de « changer de disquette ». | À faire (S2) |
| US-M4 | P2 | En tant qu'utilisateur, je veux créer des images de volumes FAT32 depuis le PC (outil Go) et y copier des fichiers, afin de préparer mes disquettes. | À faire (S1) |
| US-M5 | P2 | En tant que développeur, je veux un test automatisé du mode MSC (image montée sur PC via le Feather, ou simulateur), afin d'éviter les régressions. | À faire |
| US-01 | P1 | En tant que développeur, je veux un protocole bloc documenté (commandes, trames, erreurs), afin que firmware, driver et outils partagent une même spécification. | À faire (S1) |
| US-02 | P1 | En tant que développeur, je veux un simulateur Go du périphérique (protocole sur flux), afin de tester driver et outils sans matériel. | À faire (S1) |
| US-03 | P1 | En tant que développeur 6502, je veux un driver ca65 `drv_read`/`drv_write`/`drv_info` par UART (API 10,13-10,18), afin de lire et écrire des secteurs. | À faire (S1) |
| US-04 | P1 | En tant qu'utilisateur, je veux créer et inspecter des images (`.img` brut, taille libre) avec un outil PC, afin de préparer un disque. | À faire (S1) |
| US-05 | P1 | En tant qu'utilisateur, je veux un firmware Feather RP2040 servant des images depuis la microSD (FeatherWing Adalogger) par UART. | À faire (S2) |
| US-06 | P2 | En tant qu'utilisateur, je veux sélectionner plusieurs unités (DD + disquettes) et changer d'image sans redémarrer. | À faire |
| US-07 | P2 | En tant qu'utilisateur, je veux le transport SPI (API 10,11/10,12, 1 MHz) pour des transferts plus rapides. | À faire |
| US-08 | P2 | En tant qu'utilisateur, je veux servir des images depuis une clé USB (USB hôte sur le Feather). | À faire |
| US-09 | P3 | En tant qu'utilisateur, je veux quelques images en flash interne du Feather. | À faire |
| US-10 | P2 | En tant que développeur, je veux un schéma de câblage UEXT ↔ Feather (niveaux 3,3 V, alimentation) vérifié. | À faire (S1) |
| US-11 | P2 | En tant que développeur, je veux mesurer le débit réel (UART vs SPI) sur matériel et le consigner. | À faire |
| US-12 | P3 | En tant qu'utilisateur du Télémon, je veux des commandes de chargement/sauvegarde par secteurs (intégration EPIC-01 de Neo6502kbd). | À faire |

## EPIC-02 — Télécom

Principe : la **pile TCP/IP reste sur le périphérique** ; le 6502 voit un canal
série (UART UEXT, puis CDC USB après EPIC-04). Matériel : **Raspberry Pi
Pico W** (décision PO du 2026-09-15 : carte possédée, RP2040 + CYW43, Pico
SDK), firmware `firmware/picow-modem/`. Le Pi Zero W n'est plus nécessaire
pour la télécom. Une pile sur le 6502 (Contiki/uIP, SLIP) n'est pas retenue.

Existant vérifié (gitlab.com/bocianu/neo-networking et neo-prophet) : la
communauté utilise le MOD-WIFI-ESP8266 sur l'UEXT avec le **firmware AT
d'Espressif** (`AT+CWMODE=1`, OTA), les outils `netconfig.neo`,
`netconsole.neo`, `netinfo.neo`, et le client **Prophet** (`prophet.neo`,
serveur public `mimuma.pl:8998`, commandes `cat/list/search/info/get`). Être
**compatible avec ce jeu de commandes AT** rend nos périphériques utilisables
par ces programmes sans modification.

| ID | P | User story | État |
|----|---|------------|------|
| US-T0 | P1 | En tant que PO, je veux un **firmware Pico W** (Pico SDK, cyw43/lwIP, TinyUSB) exposant le modem sur **USB CDC et UART0 GP0/GP1** à la fois, afin de brancher la carte en UEXT dès maintenant et en USB après F-13. | Terminé (S1) — validation sur carte à consigner |
| US-T1 | P1 | En tant qu'utilisateur, je veux un **modem Hayes virtuel** sur le canal série : `AT`, `ATDT hôte:port` (TCP sortant, mode transparent, `+++` pour revenir en commande), `ATH`, `ATA` (écoute entrante), registres S de base, afin d'utiliser tout programme terminal / BBS / MUD écrit pour un modem. | Terminé (S1) — tests PC ; carte à consigner |
| US-T10 | P1 | En tant qu'utilisateur de netsetup.neo/prophet.neo (non modifiés), je veux que le firmware **route l'API UART UEXT vers le modem USB CDC** (F-93 : fonction 10,19, mode AUTO), afin d'utiliser le modem Wi-Fi Pico W branché en USB sans recompiler ces outils. Vérifié en co-sim (Phosphoneo) et sur carte via `driver/examples/uarttest.s`. | **Terminé (S1)** — délégué firmware F-93 ; validation Neo6502 réel à faire (hub USB + firmware du fork) |
| US-T2 | P1 | En tant qu'utilisateur, je veux que le périphérique accepte le **sous-ensemble AT ESP8266** utilisé par `netsetup`/`netinfo`/`netconsole`/`prophet` (liste exacte relevée dans les sources : voir `firmware/picow-modem/README.md`), afin de rester compatible avec les outils existants de la communauté sans modification. | Terminé (S1) — tests PC ; carte à consigner |
| US-T9 | P1 | En tant qu'utilisateur de `prophet.neo` (non modifié), je veux que le modem **termine le TLS** (« picowifitls », mémo Neo6502Prophet du 2026-09-16, décisions D5/D6) : `AT+CIPSTART="SSL"`, `AT+TLSPORT=443` pour les clients qui ne savent dire que `"TCP"`, certificat vérifié contre une racine embarquée (ISRG Root X1) + nom d'hôte + dates (heure SNTP exigée), reprise de session, mesures de handshake ; afin de dialoguer en HTTPS avec un serveur Prophet sur Internet. | Terminé (S1) — validé sur carte ; test de bout en bout avec le serveur Prophet HTTPS à faire |
| US-T3 | P1 | En tant que développeur 6502, je veux un **proxy de sockets** binaire (commandes `$10-$1F` : open/read/write/close, DNS, statut, 4 connexions, non bloquant) et le driver ca65 `net.s`, afin d'écrire des programmes réseau sans parser de texte AT. | À faire (S4) |
| US-T9 | P1 | En tant qu'utilisateur, je veux un **terminal série** sur le Neo (clavier → modem CDC, modem → console, Échap = sortie) pour taper `ATI`, `ATDT hôte:port`, `+++`, `ATH` et dialoguer avec un BBS. | Terminé 2026-09-15 : `driver/src/term.asm` (64tass, groupe 14 du fork), `make -C driver test` (faux modem Hayes de Phosphoneo ; `MODEM_TTY=/dev/ttyACM0` pour le vrai) |
| US-T4 | P2 | En tant que développeur, je veux une **maquette réseau dans le simulateur Go** (le périphérique simulé ouvre de vraies sockets sur le PC) et des tests du driver assemblé, afin de valider sans matériel. | À faire (S4) |
| US-T5 | P2 | En tant qu'utilisateur, je veux **envoyer un `.neo` depuis le PC en Wi-Fi** et l'exécuter (remplace le câble série `nxmit`), ou l'écrire dans l'image disque. | À faire |
| US-T6 | P2 | En tant qu'utilisateur, je veux un **client HTTP simple et NTP** (télécharger un fichier vers la SD/l'image, mettre à l'heure), exposés en AT (`AT+HTTPGET`) et en binaire. | À faire |
| US-T7 | P3 | En tant qu'utilisateur du Télémon, je veux un **serveur telnet entrant** pour piloter le moniteur depuis le PC, et `load`/`save` réseau. | À faire |
| US-T8 | P3 | En tant qu'utilisateur, je veux un partage de fichiers réseau vers la SD/les images (Samba sur le Pi Zero W), afin de déposer des programmes sans manipuler la carte. | À faire |
| US-T11 | P2 | En tant que développeur, je veux un **mode « flux HTTP »** sur le proxy de sockets (US-T3) du modem : `open(url)` effectue le GET (Host, Range optionnel) et renvoie code + Content-Length, puis `read(n)` sert le corps (l'en-tête reste dans le modem) ; `HTTPS://` via le TLS embarqué. Base du périphérique réseau `N:` (mémo `docs/MEMO-PROPHET-N-DEVICE-2026-09-16.md`). | À faire — dépend de US-T3 |
| US-T12 | P1 | En tant qu'utilisateur, je veux une **liste d'hôtes autorisés / un journal** côté modem (`AT+NHOSTS=…`) pour le mode `N:`, afin qu'un `.neo` malveillant ne puisse pas exfiltrer le stockage vers un hôte arbitraire ; à croiser avec l'audit `neo-sandbox`. **Prérequis sécurité de `N:`.** | À faire — avant toute écriture réseau via `N:` |

Ordre : US-T0/T1/T2 (sprint 1, Pico W) → US-T3/T4 → T5/T6 → T7/T8. Périphérique
réseau `N:` (façon FujiNet, mémo Neo6502Prophet) : côté modem US-T11 (flux HTTP)
+ US-T12 (sécurité hôtes) ; côté firmware, le préfixe `N:` dans le groupe 3 est
une story du fork **Neo6502firmware** (lecture seule d'abord : 3,2/3,4/3,8/3,5/3,16
routés vers le proxy du modem). Le serveur Prophet n'a rien à changer. Transport
UART UEXT immédiat, transport CDC USB dès que F-13 (Neo6502firmware) est
livrée. Limites connues du firmware Pico W : TLS 1.2 seulement (pas de 1.3, pas de
certificat client), pas d'UDP, une connexion (`CIPMUX=0`), pas d'OTA.

## EPIC-03 — Périphérique sur le bus 6502 (connecteur BUS1)

Le connecteur BUS1 expose tout le bus du 65C02 (D0-D7, A0-A15, PHI2, R/W,
RESB, SOB, MLB, VPB, SYNC, NMIB, IRQB ; RDY et BE sur le schéma). Le RP2040
répond à toutes les adresses en lecture (`processor_pio.cpp`), donc :

| ID | P | User story | État |
|----|---|------------|------|
| US-B1 | P2 | En tant que développeur, je veux relever le brochage exact et les niveaux (3,3 V / 5 V) de BUS1 sur le schéma rev. B1, afin de câbler sans risque. | À faire |
| US-B2 | P2 | En tant que développeur, je veux un périphérique **en écoute d'écritures** (décodage d'une adresse `$FExx`, capture de D0-D7 sur R/W bas par le PIO du Feather), sans modification du firmware, afin d'envoyer des commandes au Feather par simple `STA`. | À faire |
| US-B3 | P3 | Fenêtre d'adresses externe dans le firmware (+ `RDY`). | **Délégué → Neo6502firmware F-20** |
| US-B4 | P3 | En tant que développeur, je veux un canal bloc complet sur BUS1 (écriture de commande + lecture via la fenêtre US-B3), plus rapide que l'UART/SPI. | À faire |

## EPIC-04 — Prise en charge CDC (série sur USB) dans le firmware Neo6502

Objectif : que le Neo6502 accepte un périphérique USB **CDC-ACM** (Feather ou
Pi Zero W en gadget série, éventuellement composite MSC + CDC) pour porter le
protocole bloc et le proxy TCP **sur le port USB-A**, sans câblage UEXT ni
interrupteur. Nécessite un fork du firmware (`tusb_config.h : CFG_TUH_CDC 0`
aujourd'hui) — à proposer en amont au projet officiel.

| ID | P | User story | État |
|----|---|------------|------|
| US-C1 | P2 | Compiler le firmware officiel tel quel. | **Délégué → Neo6502firmware F-00** |
| US-C2 | P2 | Hôte CDC dans TinyUSB. | **Fait dans Neo6502firmware F-90** (2026-09-15) : `CFG_TUH_CDC 2` + FTDI/CP210x |
| US-C3 | P2 | Exposition du CDC par l'API (routage UART ou nouvelles fonctions). | **Fait dans Neo6502firmware F-90** : groupe 14 (statut, octet/bloc, line coding) |
| US-C4 | P2 | Maquette CDC dans l'émulateur `neo`. | **Fait** : `NEO_CDC_TTY=/dev/pts/N bin/neo` (pty, tty réel ou fichier) ; co-sim Phosphoneo `--cdc-tty` ; faux modem Hayes `Phosphoneo/tools/fake_modem.py` |
| US-C5 | P3 | En tant qu'utilisateur, je veux un gadget composite MSC + CDC sur le Pi Zero W (configfs) puis sur le Feather (TinyUSB device), afin d'avoir clé virtuelle et canal série sur le même câble. | À faire |
| US-C6 | P3 | En tant que contributeur, je veux proposer la prise en charge CDC en amont (pull request neo6502-firmware) avec documentation API, afin de ne pas maintenir un fork. | À faire |

Dépendances : US-C1 → US-C2 → US-C3/US-C4 → US-C5 ; le mode bloc UEXT
(US-01..US-05) reste la voie sans modification du firmware.

## Modifications du firmware

Toute évolution du firmware Neo6502 vit dans le dépôt commun
`/home/bmarty/Neo6502firmware` (fork de neo6502-firmware, contributions amont) ;
ce projet n'en porte que les stories côté périphérique/driver.

## Hors périmètre (nécessite de modifier le firmware Neo6502)

- **Bank switching ROM/RAM** : la mémoire du 65C02 est émulée par le RP2040
  (64 Ko plats, aucun registre de banque). Ajouter des banques (pages de flash
  en « ROM », RAM supplémentaire limitée par les ~47 Ko libres du RP2040)
  demande de modifier la boucle PIO/mémoire du firmware, pas un périphérique
  externe. Alternative logicielle : overlays chargés à la demande depuis le
  disque virtuel (à étudier avec le Télémon).

## Questions ouvertes

- Pico W : budget de courant du 3,3 V UEXT (alimenter le Pico W par USB en
  attendant) ; brochage UEXT standard Olimex à confirmer sur le schéma rev. B1
  (`hardware/PICOW_UEXT.md`) ; débit réel `+IPD` vers le tampon UART du
  firmware Neo6502 à mesurer avec `pget.neo`.
- Feather RP2040 USB Host : brochage PIO-USB (D+/D-), alimentation 5 V du port
  hôte, coexistence hôte PIO-USB + device natif ; à vérifier sur la doc Adafruit.
- Changement d'image à chaud : le firmware Neo6502 gère-t-il une
  déconnexion/reconnexion MSC sans redémarrage ? À tester (usb_storage.cpp).
- Le Neo6502 n'a qu'un port USB-A : un hub (Olimex recommandé) est requis
  pour clavier + Feather.
- **Interrupteur de configuration (manuel Olimex)** : par défaut RESB, NMIB
  et IRQB sont reliés aux GPIO UEXT du RP2040 et le buzzer est activé ;
  « you can't use SPI on UEXT connector if you do not disconnect these
  signals ». **Le mode bloc SPI (US-07) impose de basculer cet interrupteur** ;
  vérifier aussi l'effet sur l'UART avant US-03.

- Vitesse UART maximale supportée de bout en bout (firmware Neo6502 :
  `IOUARTInitialise`, tampon de réception) : à mesurer (US-11).
- Le mode esclave SPI du RP2040 à 1 MHz avec le CS du Neo6502 (GP25) : à
  valider sur matériel avant US-07.
- Format d'image : brut (`.img`, 512 o/secteur) en v1 ; `.dsk` Oric/Apple
  seulement s'il y a un usage réel.
