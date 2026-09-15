# Sprints

## Sprint 0 — 2026-09-15 — « Cadrage »

**Livré** : dépôt, vision, backlog, DoD, architecture et protocole proposés,
notes vérifiées sur l'API UEXT du Neo6502.

**Décisions** : cible Neo6502 ; carte **Adafruit Feather RP2040 USB Host**
(possédée par le PO) ; **mode MSC USB d'abord** (clé virtuelle, aucun driver
6502), puis mode bloc UEXT (UART v1, SPI v2), puis télécom (EPIC-02).

## Sprint 1 — 2026-09-15 — « Modem Wi-Fi sur Pico W » (EPIC-02)

**Décision PO (2026-09-15)** : un Pico W est disponible et doit servir de
modem Wi-Fi sur USB ; la télécom passe avant le prototype clé USB, qui glisse
en sprint 2.

**Livré** : `firmware/picow-modem/` (US-T0, US-T1, US-T2) — cœur AT/Hayes
portable + couche Pico W (cyw43, lwIP, TinyUSB CDC, UART0, flash) ;
126 vérifications unitaires sur PC (`make test`) rejouant les séquences de
netinfo/netsetup/prophet ; UF2 compilé sans avertissement (Pico SDK 2.2.0) ;
`hardware/PICOW_UEXT.md` ; `Makefile` racine (`test`, `firmware`, `flash`).

**Reste à faire dans le sprint** : flasher la carte (BOOTSEL), consigner ici
le test PC (`/dev/ttyACM0` : AT, CWLAP, CWJAP, CIPSTART/CIPSEND vers
mimuma.pl:8998, ATDT, +++), puis le test UEXT avec `netsetup.neo` /
`prophet.neo` sur le Neo6502. Contrainte : le port USB du Neo6502 n'est
exploitable qu'après F-13 (Neo6502firmware).

## Sprint 2 — à planifier — « Prototype clé USB virtuelle sur Pi Zero W »

Stories : **US-M0**, US-M4 (outil d'images). Objectif : le Neo6502 charge un
programme depuis une image choisie via la page web du Pi ; consigner :
alimentation par le hub, délai d'apparition, comportement au changement
d'image à chaud. Prérequis : hub USB, câble micro-USB OTG, carte SD Raspberry
Pi OS Lite. Aucun firmware à écrire.

## Sprint 3 — « Clé USB virtuelle embarquée (Feather) »

Stories : US-M1, US-M2, US-M3 (reprend images et outil validés en S1).
Prérequis : Pico SDK + TinyUSB + Pico-PIO-USB.

## Sprint 4 — « Périphérique bloc UEXT »

Candidats : US-01, US-02, US-03, US-04, US-10 (tout testable sans matériel).

## Sprint 5 — « Télécom : proxy de sockets et simulateur »

Stories : US-T3, US-T4 (proxy binaire dans le firmware Pico W, driver ca65
`net.s`, maquette réseau dans le simulateur Go). US-05/US-11 (firmware bloc
Feather, mesures) glissent en sprint 5 bis selon disponibilité du matériel.

## Sprint 6 — « CDC dans le firmware » (EPIC-04)

Candidats : US-C1 (build du firmware officiel), US-C2, US-C3, US-C4 ; US-C5
sur le Pi Zero W (configfs) peut être préparé dès le sprint 1 en composite
MSC + CDC, le CDC restant inactif côté Neo6502 jusqu'à US-C2.
