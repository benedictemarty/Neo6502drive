# Vision

## Énoncé

Pour les développeurs Neo6502 qui veulent un **stockage par secteurs**
(disque dur virtuel, disquettes virtuelles) que le firmware ne fournit pas,
**Neo6502drive** est un périphérique externe (Adafruit Feather RP2040 sur le
port UEXT) qui sert des images de disques depuis microSD, clé USB ou flash,
avec un driver 6502 minimal et des outils PC pour préparer les images.

## Objectifs

1. **Mode MSC (v1)** : le Feather est vu par le Neo6502 comme une clé USB ;
   il sert une image de volume FAT32 choisie sur le Feather parmi celles de sa
   clé USB / microSD ; changement d'image à chaud (réénumération USB).
2. **Mode bloc UEXT (v2)** : lire/écrire un secteur de 512 octets par LBA,
   plusieurs unités ; protocole documenté, UART d'abord puis SPI ; réservé
   `$10-$1F` pour d'autres services (télécom, EPIC-02).
3. Driver ca65 réutilisable par le futur moniteur « Télémon » (Neo6502kbd,
   EPIC-01) et par tout programme.
4. Qualité vérifiable sans matériel : simulateur du périphérique en Go et
   tests du driver assemblé (même approche que Neo6502kbd).
5. Ne rien inventer : chaque fait sur le Neo6502 ou le Feather est vérifié
   et cité (docs/NEO6502_UEXT_NOTES.md).

## Hors périmètre

- Émulation d'un contrôleur de disquette réel (WD179x, Disk II) : le Neo6502
  n'en a pas et aucun logiciel Neo6502 n'en attend.
- Série ou protocole libre sur USB : le firmware Neo6502 n'accepte que les
  classes HID, MSC et hub (`tusb_config.h` : `CFG_TUH_CDC 0`,
  `CFG_TUH_VENDOR 0`).
- Clone de LOCI pour Oric.
- Système de fichiers côté 6502 (ce sera un projet/épopée distinct, au-dessus
  de ce périphérique bloc).

## Parties prenantes

- Product owner / développeur : bmarty.
- Utilisateurs : programmeurs Neo6502 (assembleur, C), projet Télémon.
