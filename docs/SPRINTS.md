# Sprints

## Sprint 0 — 2026-09-15 — « Cadrage »

**Livré** : dépôt, vision, backlog, DoD, architecture et protocole proposés,
notes vérifiées sur l'API UEXT du Neo6502.

**Décisions** : cible Neo6502 ; carte **Adafruit Feather RP2040 USB Host**
(possédée par le PO) ; **mode MSC USB d'abord** (clé virtuelle, aucun driver
6502), puis mode bloc UEXT (UART v1, SPI v2), puis télécom (EPIC-02).

## Sprint 1 — à planifier — « Clé USB virtuelle »

Stories : US-M1, US-M2, US-M3, US-M4. Objectif : brancher le Feather au
Neo6502 et charger un programme depuis une image choisie sur le Feather.
Prérequis : Pico SDK + TinyUSB + Pico-PIO-USB installés (à faire), hub USB.

## Sprint 2 — « Périphérique bloc UEXT »

Candidats : US-01, US-02, US-03, US-04, US-10 (tout testable sans matériel).

## Sprint 3 — « Firmware bloc et mesures »

Candidats : US-05, US-11 ; puis EPIC-02.
