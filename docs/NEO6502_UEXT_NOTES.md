# Faits vérifiés : Neo6502 côté UEXT et périphériques

Sources : `neo6502-firmware` (branche `main`, mai 2026 ; `ports.cpp`,
`serial.cpp`, `group10_uext.inc`, `group3_fileio.inc`) et « Neo6502
Documentation » (PDF officiel, 80 p.).

## API groupe 10 (UExt I/O) — `group10_uext.inc`

| Fonction | Rôle |
|---|---|
| 10,1 | initialise l'UEXT |
| 10,2 / 10,3 / 10,4 | GPIO : écrire, lire, direction |
| 10,5 / 10,6 / 10,8 / 10,9 / 10,10 | I2C : octet, statut, blocs |
| 10,7 | lecture analogique |
| **10,11 / 10,12** | **SPI** : lire / écrire un bloc mémoire (P1,2 = adresse, P3,4 = longueur) |
| **10,13 / 10,14** | **UART** : lire / écrire un bloc (idem ; la lecture peut échouer par timeout) |
| **10,15** | UART : vitesse (P0..3) et protocole (P4, seul 8N1 = 0 supporté) |
| **10,16 / 10,17 / 10,18** | UART : écrire un octet, lire un octet (erreur si vide), octet disponible ? |

## Brochage RP2040 côté Neo6502 — `ports.cpp`

- I2C : SCL GP23, SDA GP22.
- SPI : `spi1`, MISO GP24, MOSI GP27, SCK GP26, **CS GP25**, initialisé à
  **1 MHz** ; le Neo6502 est maître.
- UART : `uart0` (`serial.cpp`), réception par interruption dans un tampon
  circulaire ; vitesse réglable par 10,15.
- Ces GPIO du RP2040 sont routés vers le connecteur **UEXT** (10 broches,
  3,3 V : alimentation, UART TX/RX, I2C, SPI). Le brochage exact du
  connecteur UEXT sur la carte Neo6502 doit être relevé sur le schéma Olimex
  avant câblage (**non vérifié ici**).

## Interrupteur de configuration et connecteur BUS1 — manuel Olimex (`DOCUMENTS/Neo6502-user-manual.pdf`)

- Interrupteur à glissière : active/désactive le buzzer et **connecte ou
  déconnecte RESB, NMIB, IRQB des signaux UEXT du RP2040**. Livré tout
  connecté ⇒ **SPI inutilisable sur UEXT tant qu'on ne déconnecte pas ces
  signaux** (citation du manuel). À basculer pour le mode SPI.
- BUS1 : +5 V, 3,3 V, GND, D0-D7, A0-A15, PHI2, R/W, RESB, SOB, MLB, VPB,
  SYNC, NMIB, IRQB, SWDIO/SWCLK (à laisser libres) ; RDY et BE visibles sur
  le schéma rev. B1 avec pull-ups. Niveau logique du bus : à confirmer sur le
  schéma (74LVC245 alimentés en 3,3 V entre 65C02 et RP2040).
- Le RP2040 pilote D0-D7 à **chaque lecture** quelle que soit l'adresse
  (`processor_pio.cpp`) : périphériques externes en écriture seule OK sans
  firmware modifié ; lecture ⇒ fenêtre d'adresses à ajouter au firmware.

## Stockage interne existant — `group3_fileio.inc`, PDF §3.7

FAT32 (première partition, noms 8.3) sur clé USB ou microSD, accès fichiers
uniquement (3,2 chargement, 3,3 sauvegarde, 3,4..3,19 ouverture, lecture,
écriture, positionnement, répertoires). **Aucune fonction d'accès par
secteur** : c'est le manque que ce projet comble.

## Non vérifié / à faire

- Débit UART maximal fiable (taille du tampon de `serial.cpp`, pertes).
- Mode esclave SPI du RP2040 à 1 MHz face au CS GP25 (chip select géré par
  le firmware à chaque bloc ?).
- Adafruit Feather RP2040 : brochage (SPI/UART/I2C sur le rail), USB hôte
  (nécessite PIO-USB + connecteur), FeatherWing Adalogger (microSD SPI).
  À vérifier sur la documentation Adafruit avant US-05/US-10.
