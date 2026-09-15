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

## EPIC-02 — Télécom (après le mode bloc UEXT)

Services réseau exposés au 6502 par le même protocole (commandes `$10-$1F`),
la **pile TCP restant sur le périphérique** (proxy de sockets) : ouvrir/lire/
écrire/fermer, DNS, NTP, téléchargement dans une image, pont série↔TCP.
Matériel : Pi Zero W (Wi-Fi intégré, UART UEXT) pour prototyper ; AirLift
FeatherWing ou Feather ESP32-S3 pour la version embarquée. Une vraie pile
TCP/IP sur le 6502 (Contiki/uIP via cc65, SLIP sur l'UART) est possible mais
lourde et lente : non retenue en première approche.

## EPIC-03 — Périphérique sur le bus 6502 (connecteur BUS1)

Le connecteur BUS1 expose tout le bus du 65C02 (D0-D7, A0-A15, PHI2, R/W,
RESB, SOB, MLB, VPB, SYNC, NMIB, IRQB ; RDY et BE sur le schéma). Le RP2040
répond à toutes les adresses en lecture (`processor_pio.cpp`), donc :

| ID | P | User story | État |
|----|---|------------|------|
| US-B1 | P2 | En tant que développeur, je veux relever le brochage exact et les niveaux (3,3 V / 5 V) de BUS1 sur le schéma rev. B1, afin de câbler sans risque. | À faire |
| US-B2 | P2 | En tant que développeur, je veux un périphérique **en écoute d'écritures** (décodage d'une adresse `$FExx`, capture de D0-D7 sur R/W bas par le PIO du Feather), sans modification du firmware, afin d'envoyer des commandes au Feather par simple `STA`. | À faire |
| US-B3 | P3 | En tant que développeur, je veux une **fenêtre d'adresses** dans le firmware Neo6502 où le RP2040 ne pilote pas D0-D7 (et `RDY` pour les périphériques lents), reportée dans l'émulateur, afin de brancher des périphériques lisibles (ROM, 6522, RAM). | À faire (firmware) |
| US-B4 | P3 | En tant que développeur, je veux un canal bloc complet sur BUS1 (écriture de commande + lecture via la fenêtre US-B3), plus rapide que l'UART/SPI. | À faire |

## EPIC-04 — Prise en charge CDC (série sur USB) dans le firmware Neo6502

Objectif : que le Neo6502 accepte un périphérique USB **CDC-ACM** (Feather ou
Pi Zero W en gadget série, éventuellement composite MSC + CDC) pour porter le
protocole bloc et le proxy TCP **sur le port USB-A**, sans câblage UEXT ni
interrupteur. Nécessite un fork du firmware (`tusb_config.h : CFG_TUH_CDC 0`
aujourd'hui) — à proposer en amont au projet officiel.

| ID | P | User story | État |
|----|---|------------|------|
| US-C1 | P2 | En tant que développeur, je veux compiler le firmware Neo6502 officiel tel quel (chaîne arm-none-eabi, Pico SDK, 64tass), afin d'avoir une base reproductible avant modification. | À faire |
| US-C2 | P2 | En tant que développeur, je veux activer l'hôte CDC dans TinyUSB (`CFG_TUH_CDC 1`, callbacks `tuh_cdc_*`, tampon de réception) et vérifier la coexistence avec HID, MSC et hub, afin qu'un périphérique série USB soit reconnu. | À faire |
| US-C3 | P2 | En tant que développeur 6502, je veux accéder au flux CDC par l'API : soit en routant les fonctions UART existantes (10,13..10,18) vers le CDC quand il est présent, soit par de nouvelles fonctions (groupe 10, ≥ 19), afin de réutiliser le driver ca65 du mode bloc sans changement. | À faire |
| US-C4 | P2 | En tant que développeur, je veux une maquette CDC dans l'émulateur `neo` (pty ou TCP), afin de tester le protocole sans matériel. | À faire |
| US-C5 | P3 | En tant qu'utilisateur, je veux un gadget composite MSC + CDC sur le Pi Zero W (configfs) puis sur le Feather (TinyUSB device), afin d'avoir clé virtuelle et canal série sur le même câble. | À faire |
| US-C6 | P3 | En tant que contributeur, je veux proposer la prise en charge CDC en amont (pull request neo6502-firmware) avec documentation API, afin de ne pas maintenir un fork. | À faire |

Dépendances : US-C1 → US-C2 → US-C3/US-C4 → US-C5 ; le mode bloc UEXT
(US-01..US-05) reste la voie sans modification du firmware.

## Hors périmètre (nécessite de modifier le firmware Neo6502)

- **Bank switching ROM/RAM** : la mémoire du 65C02 est émulée par le RP2040
  (64 Ko plats, aucun registre de banque). Ajouter des banques (pages de flash
  en « ROM », RAM supplémentaire limitée par les ~47 Ko libres du RP2040)
  demande de modifier la boucle PIO/mémoire du firmware, pas un périphérique
  externe. Alternative logicielle : overlays chargés à la demande depuis le
  disque virtuel (à étudier avec le Télémon).

## Questions ouvertes

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
