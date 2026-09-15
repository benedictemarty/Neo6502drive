# Neo6502drive

Disque dur et disquettes virtuels pour le **Neo6502**, à base d'**Adafruit
Feather RP2040** branché sur le port **UEXT**. Le Feather expose un
périphérique bloc (secteurs de 512 octets) dont les images vivent sur
microSD, clé USB ou flash interne ; côté 6502, un driver en assembleur `ca65`
lit et écrit des secteurs via l'API UEXT du firmware Neo6502.

Projet frère de [Neo6502kbd](../Neo6502kbd) (driver clavier), dont il réutilise
les conventions (ca65, outil Go, simulateur, méthode agile).

**État : cadrage (sprint 0).** Aucun code n'est encore écrit ; voir
[docs/VISION.md](docs/VISION.md) et [docs/BACKLOG.md](docs/BACKLOG.md).

## Pourquoi

Le Neo6502 accède déjà à des fichiers (API 3,x) mais n'a **aucun périphérique
bloc** : rien n'y joue le rôle d'un disque dur ou d'un lecteur de disquettes
pour un futur système (moniteur « Télémon », OS, portage de logiciels qui
attendent des secteurs). Ce projet fournit ce périphérique, à la manière de
[LOCI](https://github.com/sodiumlb/loci-firmware) pour l'Oric, mais adapté au
Neo6502 (pas de bus d'extension 6502 : on passe par l'UEXT).

## Arborescence prévue

```
docs/       cadrage agile, protocole, notes vérifiées sur le Neo6502 et le Feather
firmware/   firmware du Feather RP2040 (C, Pico SDK + TinyUSB)
driver/     driver 6502 (ca65) : lecture/écriture de secteurs via UEXT
tools/      outil Go : création/inspection d'images, simulateur du périphérique
hardware/   câblage UEXT <-> Feather, nomenclature
```

## Documentation

- [docs/VISION.md](docs/VISION.md) — objectifs, périmètre, parties prenantes
- [docs/BACKLOG.md](docs/BACKLOG.md) — user stories
- [docs/SPRINTS.md](docs/SPRINTS.md) — planification
- [docs/DEFINITION_OF_DONE.md](docs/DEFINITION_OF_DONE.md)
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — architecture et protocole (proposition)
- [docs/NEO6502_UEXT_NOTES.md](docs/NEO6502_UEXT_NOTES.md) — faits vérifiés dans le firmware Neo6502
- [CHANGELOG.md](CHANGELOG.md)

## Licence

MIT.
