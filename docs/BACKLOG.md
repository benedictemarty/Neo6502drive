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

- Vitesse UART maximale supportée de bout en bout (firmware Neo6502 :
  `IOUARTInitialise`, tampon de réception) : à mesurer (US-11).
- Le mode esclave SPI du RP2040 à 1 MHz avec le CS du Neo6502 (GP25) : à
  valider sur matériel avant US-07.
- Format d'image : brut (`.img`, 512 o/secteur) en v1 ; `.dsk` Oric/Apple
  seulement s'il y a un usage réel.
