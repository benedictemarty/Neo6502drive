# Vision

## Énoncé

Pour les développeurs Neo6502 qui veulent un **stockage par secteurs**
(disque dur virtuel, disquettes virtuelles) que le firmware ne fournit pas,
**Neo6502drive** est un périphérique externe (Adafruit Feather RP2040 sur le
port UEXT) qui sert des images de disques depuis microSD, clé USB ou flash,
avec un driver 6502 minimal et des outils PC pour préparer les images.

## Objectifs

1. Périphérique bloc simple : lire/écrire un secteur de 512 octets par numéro
   (LBA), plusieurs « unités » (disque dur + disquettes) sélectionnables.
2. Protocole documenté, indépendant du bus : d'abord UART (robuste, testable
   depuis un PC), puis SPI (plus rapide) en option.
3. Driver ca65 réutilisable par le futur moniteur « Télémon » (Neo6502kbd,
   EPIC-01) et par tout programme.
4. Qualité vérifiable sans matériel : simulateur du périphérique en Go et
   tests du driver assemblé (même approche que Neo6502kbd).
5. Ne rien inventer : chaque fait sur le Neo6502 ou le Feather est vérifié
   et cité (docs/NEO6502_UEXT_NOTES.md).

## Hors périmètre

- Émulation d'un contrôleur de disquette réel (WD179x, Disk II) : le Neo6502
  n'en a pas et aucun logiciel Neo6502 n'en attend.
- Clone de LOCI pour Oric.
- Système de fichiers côté 6502 (ce sera un projet/épopée distinct, au-dessus
  de ce périphérique bloc).

## Parties prenantes

- Product owner / développeur : bmarty.
- Utilisateurs : programmeurs Neo6502 (assembleur, C), projet Télémon.
