# Architecture et protocole (proposition, sprint 0)

```
 Neo6502 (65C02)                RP2040 Neo6502            Feather RP2040
 programme / Télémon            firmware officiel          Neo6502drive
   jsr drv_read  ───► API 10,x ───► UART (v1) / SPI (v2) ───► serveur de blocs
   (driver ca65)        $FF00       connecteur UEXT             │
                                                          microSD / USB / flash
                                                          images .img (512 o/secteur)
```

## Principes

- **Périphérique bloc pur** : le 6502 demande « unité U, secteur LBA N »,
  reçoit ou envoie 512 octets. Pas de notion de piste/tête : une disquette
  virtuelle est simplement une petite image (ex. 720 Ko = 1440 secteurs).
- **Transport séparé du protocole** : mêmes trames sur UART (v1) et SPI (v2).
- **Tout est testable sans matériel** : le simulateur Go implémente le
  serveur de blocs sur un flux ; le driver ca65 est exécuté dans le
  simulateur 65C02 (réutilisé de Neo6502kbd) avec une maquette des fonctions
  10,13..10,18.

## Protocole v1 (brouillon, à figer dans US-01)

Trame de commande (6502 → Feather), 8 octets :

| Octet | Contenu |
|---|---|
| 0 | `$4E` magique ('N') |
| 1 | commande : `$01` INFO, `$02 READ`, `$03 WRITE`, `$04 SELECT` (changer d'image), `$05 LIST` |
| 2 | unité (0..3) |
| 3..6 | LBA 32 bits (petit-boutiste) |
| 7 | somme de contrôle (XOR des octets 0..6) |

Réponse (Feather → 6502) : `$4E`, statut (`$00` OK, `$01` unité absente,
`$02` LBA hors limite, `$03` protégé en écriture, `$04` somme de contrôle,
`$05` erreur support), puis pour READ 512 octets de données + 1 octet XOR ;
pour WRITE le 6502 envoie 512 octets + XOR après l'accusé initial ; pour INFO
la taille en secteurs (32 bits) et un drapeau lecture seule par unité.

Délais : le driver abandonne après un timeout (compteur de boucles côté 6502
ou timeout de 10,13) et renvoie une erreur `$FF`.

## Driver ca65 (v1)

`drv_init` (10,15 vitesse), `drv_info` (A = unité → taille), `drv_read`
(A = unité, X/Y = LBA bas/haut via zone de paramètres, tampon 512 o),
`drv_write`, `drv_select`. Aucune page zéro imposée (comme Neo6502kbd) ;
tampon fourni par l'appelant.

## Firmware Feather (v2, sprint 2)

C + Pico SDK, TinyUSB (device CDC pour le débogage ; hôte en option), FatFS
sur la microSD (SPI du Feather), boucle : lire une trame, servir depuis le
fichier image ouvert, répondre. Images : `.img` bruts ; unité 0 = disque dur
(`HD0.IMG`), 1..3 = disquettes (`FD1.IMG`…), configuration `NEODRIVE.CFG`.

## Outil Go (v1)

`neodrive img create|info|dump` (images), `neodrive sim` (serveur de blocs
sur un pty ou TCP pour tester depuis l'émulateur/PC), paquet `protocol`
partagé avec les tests.
