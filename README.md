# Neo6502drive

Disque dur et disquettes virtuels pour le **Neo6502**, à base d'**Adafruit
Feather RP2040 USB Host**. Deux modes, complémentaires :

1. **Clé USB virtuelle (mode MSC)** — le Feather, branché par son USB-C sur
   le port USB-A (hub) du Neo6502, se présente comme une clé USB FAT32 dont le
   contenu est une image choisie parmi celles stockées sur la clé USB branchée
   au port hôte du Feather (ou une microSD). Changement de « disquette » sur
   le Feather, aucun driver 6502 : le firmware Neo6502 voit une clé ordinaire.
2. **Périphérique bloc (mode UEXT)** — secteurs de 512 octets, plusieurs
   unités, driver `ca65` via l'API UEXT (UART puis SPI) ; extensible à
   d'autres services (télécom).

Projet frère de [Neo6502kbd](../Neo6502kbd) (driver clavier), dont il réutilise
les conventions (ca65, outil Go, simulateur, méthode agile).

**État : sprint 1 (2026-09-15) — modem Wi-Fi sur Raspberry Pi Pico W**
(`firmware/picow-modem/`, US-T0..T2 : AT ESP8266 compatible netsetup/prophet
+ modem Hayes, sur USB CDC et UART UEXT) ; validation sur carte en cours. Le
mode MSC suit. Voir [docs/VISION.md](docs/VISION.md) et
[docs/BACKLOG.md](docs/BACKLOG.md).

## Pourquoi

Le Neo6502 accède déjà à des fichiers (API 3,x) mais n'a **aucun périphérique
bloc** : rien n'y joue le rôle d'un disque dur ou d'un lecteur de disquettes
pour un futur système (moniteur « Télémon », OS, portage de logiciels qui
attendent des secteurs). Ce projet fournit ce périphérique, à la manière de
[LOCI](https://github.com/sodiumlb/loci-firmware) pour l'Oric, mais adapté au
Neo6502 (pas de bus d'extension 6502 : on passe par l'UEXT).

## Arborescence

```
docs/                  cadrage agile, protocole, notes vérifiées sur le Neo6502 et le Feather
firmware/picow-modem/  modem Wi-Fi sur Pico W (C, Pico SDK, cyw43/lwIP, TinyUSB CDC) + tests PC
firmware/              (à venir) firmware du Feather RP2040 USB Host (MSC + hôte PIO-USB)
driver/                driver 6502 (ca65) : lecture/écriture de secteurs via UEXT
tools/                 outil Go : création/inspection d'images, simulateur du périphérique
hardware/              câblage UEXT <-> Pico W / Feather, nomenclature
```

`make test` (tests PC), `make firmware` (`PICO_SDK_PATH` requis), `make flash`
(Pico W en BOOTSEL).

## Documentation

- [docs/VISION.md](docs/VISION.md) — objectifs, périmètre, parties prenantes
- [docs/BACKLOG.md](docs/BACKLOG.md) — user stories
- [docs/SPRINTS.md](docs/SPRINTS.md) — planification
- [docs/DEFINITION_OF_DONE.md](docs/DEFINITION_OF_DONE.md)
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — architecture et protocole (proposition)
- [docs/NEO6502_UEXT_NOTES.md](docs/NEO6502_UEXT_NOTES.md) — faits vérifiés dans le firmware Neo6502
- [firmware/picow-modem/README.md](firmware/picow-modem/README.md) — modem Wi-Fi Pico W : commandes AT, compilation
- [hardware/PICOW_UEXT.md](hardware/PICOW_UEXT.md) — câblage Pico W ↔ Neo6502
- [CHANGELOG.md](CHANGELOG.md)

## Licence

[EUPL v1.2](LICENSE) (European Union Public Licence) — © 2026 bmarty.
